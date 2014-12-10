/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package es.ua.first.coreference;

import es.ua.first.coreference.util.AnaphoricExpresion;
import es.ua.first.coreference.util.Mention;
import es.upv.xmlutils.XMLUtils;
import java.io.*;
import java.util.*;
import java.util.logging.Level;
import java.util.logging.Logger;
import org.w3c.dom.Document;
import org.w3c.dom.Element;
import org.w3c.dom.NodeList;
import weka.classifiers.Classifier;
import weka.core.Instance;
import weka.core.Instances;

/**
 *
 * @author imoreno
 */
class SpanishDefiniteDescription extends AnaphoraResolutionUtils implements AnaphoraResolutionInterface {
    private String appPath;                     //contexto de la aplicación web
    
    private HashMap<Integer,ArrayList<AnaphoricExpresion>> pronous;
    Set<String> funcionesSintacticasPP, palabrasPP, lemasPP;
    int sentencesSize;
    
    Classifier cDD;                             //modelo para resolver las DDs
    Instances dDD;                              //info de las cabeceras
    
    ArrayList<Mention> candidates; //listado de los candidatos (sn) que nos encontramos y pueden resolver las DDs
    HashMap<Integer,Mention> firstMentions; //listado de las menciones que ya hemos visto al menos una vez
               
    private static final double complexity = 0.3;
    
    public SpanishDefiniteDescription(String path) throws FileNotFoundException, Exception {
        appPath = path;
        sentencesSize = 0;
        //cargamos los modelos y las cabeceras
        Object obj_exp[] =  weka.core.SerializationHelper.readAll(path+"models/PART_dd.model");
        cDD = (Classifier)obj_exp[0];
        dDD = (Instances) obj_exp[1];
        
    }

    private ArrayList<Mention> extractFeaturesFromNounPhrasesAndResolve() throws Exception{
        int num=0;
        
        ArrayList<Mention> ddlist = new ArrayList<Mention>();
        
        for(Mention mention : candidates){
            if(mention.isPreceedByAnArticle()){ //es una DD y tengo que preguntarle por todos los anteriores
                //System.out.println("DD " + mention.getToken() + "(número: "+ mention.getNumToken() +")  <" + mention.getStartOffset() + ", "+ mention.getEndOffset() + ">");
                List<Mention> subList = candidates.subList(0, num); //los nuevos candidatos
                //saco las características de la dd
                Instance ins = new Instance(18);                      
                ins.setDataset(dDD);
                ins.setMissing(17);
                ins.setValue(2, String.valueOf(mention.isPreceedByAnArticle()));
                ins.setValue(4, String.valueOf(mention.getSentence()==1)); //asumo que las oraciones empiezan en 0
                ins.setValue(7, String.valueOf(mention.isFollowedBySP()));
                ins.setValue(9, String.valueOf(mention.isFollowedBySA()));
                ins.setValue(11, String.valueOf(mention.isNE()));
                
                //para cada candidato
                ListIterator<Mention> listIterator = subList.listIterator(subList.size());
                
                double mayor = Double.MIN_VALUE;
                while(listIterator.hasPrevious()){
                
                    Mention candidate = listIterator.previous();
                    if(candidate.getToken()!=null){
                        //saco las características del candidato
                        ins.setValue(3, String.valueOf(candidate.isPreceedByAnArticle()));
                        ins.setValue(5, String.valueOf(candidate.getSentence()==1));
                        ins.setValue(8, String.valueOf(candidate.isFollowedBySP()));
                        ins.setValue(10, String.valueOf(candidate.isFollowedBySA()));
                        //saco las características que relacionan al candidato y la dd.
                        ins.setValue(0, String.valueOf(candidate.sameHeadToken(mention)));
                        ins.setValue(1, String.valueOf(candidate.sameHeadLema(mention)));
                        ins.setValue(6, String.valueOf(candidate.getSentence()==mention.getSentence()));
                        ins.setValue(13, String.valueOf(candidate.sameTypeNE(mention)));
                        ins.setValue(14, String.valueOf(candidate.sameGenre(mention)));
                        ins.setValue(15, String.valueOf(candidate.sameNumber(mention)));
                        ins.setValue(16, String.valueOf(candidate.samePostype(mention)));

                        //Obtener la clasificación con ML 
                        double[] res = cDD.distributionForInstance(ins);

                        //*** ¿qué pasa si hay varios que la resuelven? Eso no lo puedo controlar en el entrenamiento. 
                        //Aquí me quedaría con el primero
                        if(res[0] < res[1]){ //nos guardamos todos los posibles antecedentes
                            candidate.setConfidence(res[1]);
                            mention.getAntecedentsSet().add(candidate);
                        }
                        if(res[0]< res[1] && res[1]>= mayor){ //nos guardamos el antecedente con mayor probabilidad
                            mention.setConfidence(res[1]);
                            mention.setAntecedent(candidate);
                            mayor = res[1];
                        }  
                        //System.out.println("Probabilidad Si_ser_antecedente: " + res[1]  + " # "+ mention.getToken() + " <-> " + candidate.getToken());
                    }
                }
                
                ddlist.add(mention);
                
                
            }
            num++;
        }
        
        return ddlist;
    }
          
    public String resolveAnaphora(String gDocument) throws AnaphoraResolutionException {
        String newDoc = gDocument;      
        Document doc = null;
        Element documentElement = null;
        Element textWithNodesElement = null;
        Element asde = null;
        int minNewId = -1;
        candidates = new ArrayList<Mention>(); //listado de los candidatos (sn) que nos encontramos y pueden resolver las DDs
        firstMentions = new HashMap<Integer,Mention>(); //listado de las menciones que ya hemos visto al menos una vez
    
        try {
            doc = XMLUtils.readXML(gDocument,"UTF8");
            documentElement = doc.getDocumentElement();
            textWithNodesElement = XMLUtils.getElementNamed(documentElement, "TextWithNodes");

            minNewId = getNextFreeID(doc);
            
            asde = insertNewAnnotationSet(doc,"Definite Descriptions Anaphora markups");
            
        } catch(Exception e){
            throw new AnaphoraResolutionException("Error 6: Problem processing input document due to parsing problems",e); //error parsing gate format
        }
        
        
        File outputFreeling = null;
        try {
            outputFreeling = runFreeling(textWithNodesElement.getTextContent(), appPath);
        } catch (IOException ex) {
            Logger.getLogger(SpanishDefiniteDescription.class.getName()).log(Level.SEVERE, null, ex);
            throw new AnaphoraResolutionException("Error 3: Problem with external NLP tool: freeling",ex);
        } catch (InterruptedException ex) {
            Logger.getLogger(SpanishDefiniteDescription.class.getName()).log(Level.SEVERE, null, ex);
            throw new AnaphoraResolutionException("Error 3: Problem with external NLP tool: freeling",ex);

        }
        
        
        //procesamos el texto a partir de la salida de freeling
        
        //2.1 detectar sintagmas nominales dpe todas las frases distinguiendo si son dd y si es primera mención o no
        
        try {
            textWithNodesElement = XMLUtils.getElementNamed(documentElement, "TextWithNodes");
            detectNounPhrases(outputFreeling,textWithNodesElement.getTextContent());
            
        } catch (Exception ex) {
            throw new AnaphoraResolutionException("Error 3: Problem with external NLP tool: freeling",ex);
        }
        
        
        //sacamos las características de lo detectado y lo solucionamos
        TreeSet<Integer> node_offsets = new TreeSet<Integer>();
        ArrayList<Mention> ddsResolved = new ArrayList<Mention>();
        try {
            ddsResolved = extractFeaturesFromNounPhrasesAndResolve();
        } catch (Exception ex) {
            throw new AnaphoraResolutionException(ex);
        }
        
        
        //almacenamos el resultado en un archivo XML de GATE
         //1. rellanamos el nuevo annotationset
        for(Mention dd : ddsResolved){
//            if(dd.getAntecedent()!=null){ //esta resuelto
              if(dd.getAntecedentsSet()!=null && !dd.getAntecedentsSet().isEmpty()){  //esta resuelto
                  /*** añadimos los antecedentes ***/
                Collections.sort(dd.getAntecedentsSet());
                String idAntecedente = null;
                Iterator<Mention> iterator = dd.getAntecedentsSet().iterator();
                StringBuilder idsAntecedents = new StringBuilder();
                StringBuilder startNodeAntecedents = new StringBuilder();
                StringBuilder endNodeAntecedents = new StringBuilder(); 
                StringBuilder confidenceAntecedents = new StringBuilder();
                
                while(iterator.hasNext()){
                    Mention next = iterator.next();
                
                    if(!node_offsets.contains(next.getStartOffset()) 
                        && !node_offsets.contains(next.getEndOffset())){
                        Element antecedentElement = doc.createElement("Annotation");
                        idAntecedente = Integer.toString(minNewId);
                        antecedentElement.setAttribute("Id", minNewId+"");
                        if(dd.getAntecedent().getStartOffset()==-1){
                            node_offsets.add(0);
                            antecedentElement.setAttribute("StartNode", "0"); 
                        } else {
                            node_offsets.add(dd.getAntecedent().getStartOffset());
                            antecedentElement.setAttribute("StartNode", next.getStartOffset()+""); 
                        }
                        antecedentElement.setAttribute("EndNode", next.getEndOffset()+""); 
                        node_offsets.add(dd.getAntecedent().getEndOffset());
                        antecedentElement.setAttribute("Type", "DiscourseEntity");
                        asde.appendChild(antecedentElement); //"Discourse Entity markups");
                        minNewId++;
                    } else {
                        //sino es que este antecedente ya esta marcado pero 
                        // tengo que saber su id para no liarla

                        node_offsets.add(dd.getAntecedent().getStartOffset());
                        node_offsets.add(dd.getAntecedent().getEndOffset());//vuelvo a incluir los offsets para asegurarme que no se quedan sin incluir
                        
                        NodeList annotations = XMLUtils.getElementsNamed(asde, "Annotation");

                        boolean enc = false;

                        for(int indice=0; indice< annotations.getLength() && !enc; indice++){
                            Element item = (Element) annotations.item(indice);
                            Integer startp = Integer.parseInt(item.getAttribute("StartNode"));
                            Integer endp = Integer.parseInt(item.getAttribute("EndNode"));
                            if(startp.equals(next.getStartOffset()) 
                                    && endp.equals(next.getEndOffset())){
                                idAntecedente = item.getAttribute("Id");
                                enc = true;
                            }
                        }

                        if (!enc){
                            System.err.println("¡OJO! POSIBLE BUG: No se encuentra la anotación de "
                                    + textWithNodesElement.getTextContent().substring(
                                    next.getStartOffset(), 
                                    next.getEndOffset()) 
                                    + " en la posición " + 
                                    next.getStartOffset() +"," 
                                    + next.getEndOffset());
                        }
                    }
                    
                    idsAntecedents.append(idAntecedente).append("|");
                    startNodeAntecedents.append(next.getStartOffset()).append("|");
                    endNodeAntecedents.append(next.getEndOffset()).append("|");
                    confidenceAntecedents.append(next.getConfidence()).append("|");
                
                }
                
                /*** añadimos la descripción definida ***/
                
                Element pronounElement = doc.createElement("Annotation");
                pronounElement.setAttribute("Id", minNewId+"");
                pronounElement.setAttribute("StartNode", dd.getStartOffset()+"");
                node_offsets.add(dd.getStartOffset());
                pronounElement.setAttribute("EndNode", dd.getEndOffset()+""); 
                node_offsets.add(dd.getEndOffset());
                pronounElement.setAttribute("Type", "DefiniteDescription");
                asde.appendChild(pronounElement);
                
                Element feature = doc.createElement("Feature");
                pronounElement.appendChild(feature);
                Element name = doc.createElement("Name");
                name.setAttribute("className", "java.lang.String");
                name.setTextContent("complexity");
                feature.appendChild(name);
                Element value = doc.createElement("Value");
                value.setAttribute("className", "java.lang.String");
//                value.setTextContent("0.85");
                value.setTextContent(Double.toString(complexity));
                feature.appendChild(value);
                
                /*** incluimos información de todos los antecedentes posibles ordenados de mayor a menor probabilidad ***/

                feature = doc.createElement("Feature");
                pronounElement.appendChild(feature);
                name = doc.createElement("Name");
                name.setAttribute("className", "java.lang.String");
                name.setTextContent("StartNodeAntecedent");
                feature.appendChild(name);
                value = doc.createElement("Value");
                value.setAttribute("className", "java.lang.String");
                value.setTextContent(startNodeAntecedents.substring(0, startNodeAntecedents.length()-1)); //quitamos el último |
//                value.setTextContent(dd.getAntecedent().getStartOffset()+"");
                feature.appendChild(value);

                feature = doc.createElement("Feature");
                pronounElement.appendChild(feature);
                name = doc.createElement("Name");
                name.setAttribute("className", "java.lang.String");
                name.setTextContent("EndNodeAntecedent");
                feature.appendChild(name);
                value = doc.createElement("Value");
                value.setAttribute("className", "java.lang.String");
//                value.setTextContent(dd.getAntecedent().getEndOffset()+"");
                value.setTextContent(endNodeAntecedents.substring(0, endNodeAntecedents.length()-1)); //quitamos el último |
                feature.appendChild(value);

                feature = doc.createElement("Feature");
                pronounElement.appendChild(feature);
                name = doc.createElement("Name");
                name.setAttribute("className", "java.lang.String");
                name.setTextContent("confidence");
                feature.appendChild(name);
                value = doc.createElement("Value");
                value.setAttribute("className", "java.lang.String");
//                value.setTextContent(dd.getConfidence()+"");
                value.setTextContent(confidenceAntecedents.substring(0, confidenceAntecedents.length()-1)); //quitamos el último |
                feature.appendChild(value);

                feature = doc.createElement("Feature");
                pronounElement.appendChild(feature);
                name = doc.createElement("Name");
                name.setAttribute("className", "java.lang.String");
                name.setTextContent("AntecedentId");
                feature.appendChild(name);
                value = doc.createElement("Value");
                value.setAttribute("className", "java.lang.String");
//                value.setTextContent(idAntecedente);
                value.setTextContent(idsAntecedents.substring(0, idsAntecedents.length()-1)); //quitamos el último |
                feature.appendChild(value);


                minNewId++;
                
            } else {
                Element pronounElement = doc.createElement("Annotation");
                pronounElement.setAttribute("Id", minNewId+"");
                pronounElement.setAttribute("StartNode", dd.getStartOffset()+"");
                node_offsets.add(dd.getStartOffset());
                pronounElement.setAttribute("EndNode", dd.getEndOffset()+""); 
                node_offsets.add(dd.getEndOffset());
                pronounElement.setAttribute("Type", "DefiniteDescription");
                
                Element feature = doc.createElement("Feature");
                pronounElement.appendChild(feature);
                Element name = doc.createElement("Name");
                name.setAttribute("className", "java.lang.String");
                name.setTextContent("complexity");
                feature.appendChild(name);
                Element value = doc.createElement("Value");
                value.setAttribute("className", "java.lang.String");
//                value.setTextContent("0.85");
                value.setTextContent(Double.toString(complexity));
                feature.appendChild(value);
                
                
                asde.appendChild(pronounElement);
                
                minNewId++;
            }
        }
        
        //modificar el gDocument para incluir las anotaciones:
        //los que ya tuvieramos y los de nuestras nuevas anotaciones,
        //teniendo en cuenta la salida de freeling para saber donde ponerlos
        try {
            addOffsetNodes(textWithNodesElement,node_offsets, doc);
        } catch(Exception ex){
            Logger.getLogger(SpanishDefiniteDescription.class.getName()).log(Level.SEVERE, null, ex);
            throw new AnaphoraResolutionException("Error 2: Incorrect offsets generation",ex);
        }

        try{
            outputFreeling.delete(); //ahora que ya no necesito la salida de freeling, borro el fichero

            newDoc = generateStringOutput(doc);
        } catch (Exception ex) {
            Logger.getLogger(SpanishDefiniteDescription.class.getName()).log(Level.SEVERE, null, ex);
            throw new AnaphoraResolutionException("Error 7: Problem generating output document",ex);

        } 
        
        return newDoc;
        
    }
    
    /**
     * Detect NounPhrases and extracts the information needed for resolving DDs
     * @param outputFreeling    Freeling's shallow parsing output
     * @param original  Original text
     * @throws Exception 
     */
    private void detectNounPhrases(File outputFreeling, String original) throws Exception {
        candidates = new ArrayList<Mention>(); //listado de los candidatos (sn) que nos encontramos y pueden resolver las DDs
        //firstMentions = new HashMap<Integer,Mention>(); //listado de las menciones que ya hemos visto al menos una vez
               
        int contador = 0;
        
        FileReader fr = null;
        BufferedReader br = null;
        int current_sentence = 0;
        int num_token = 0;
        int start_offset=0, end_offset=0;
        int corchetes= 0;
        String patronInicioSN = "\\s+\\+?grup-nom"; 
        String patronOracion = "\\+grup-verb_\\[";
        String patronOracion2 = "S_\\[";
        String lineaAnterior = null;
        Mention tokenAnterior = null;
        boolean lineaAnteriorVacia = false;
        boolean primeraOracion = true;
        boolean nucleo = false;
        boolean contarCorchetes = false;
        boolean ignorarToken = false;
        Mention m = null;
        boolean guardarDD = false;
            
        //buscamos expresiones anaforicas de tipo pronominal
        //en todas la oraciones
        //expresion para buscar los pronombres de un tipo
        //grep "[[:space:]]$tag$type[A-Z0-9]\{6\}[[:space:]]-)$
        //problema: no sé de que oracion es!!!
        //solucion: leer linea a linea el fichero y ejecutar el comando grep (más lento pero me permite saber donde estoy)

        //1. leemos el fichero de salida de freeling linea a linea

        try {
            // Apertura del fichero y creacion de BufferedReader 
            fr = new FileReader (outputFreeling);
            br = new BufferedReader(fr);

            // Lectura del fichero
            String linea;
            
            while((linea=br.readLine())!=null){
                
                if(linea.matches(patronOracion2)){
                    current_sentence++;
                    num_token=0;
                }
                //procesamos todas las frases
                //if((num_sentence == current_sentence) || (num_sentence-1 == current_sentence)){
                if(linea.contains("+(") || linea.contains("(")){
                            
                    num_token++;
                    String llinea = linea.substring(linea.indexOf("+(")+2).trim();
                    if(!linea.contains("+("))
                        llinea = linea.substring(linea.indexOf("(")+1).trim();
                    String [] aux = llinea.split("\\s+");
                    if(aux[0].contains("_")){
                        start_offset = original.indexOf(aux[0].substring(0, aux[0].indexOf("_")), end_offset);
                        String [] tokens = aux[0].split("_");
                        int tam = 0;
                        for(int i=0; i<tokens.length; i++){
                            tam += tokens[i].length();
                            if(original.substring(start_offset + tam, start_offset + tam +1).equals(" "))
                                tam++;
                        }
                        end_offset = start_offset + tam;
                        //System.out.println(aux[0] + " ->" + start_offset + ", " + end_offset);
                    } else {
                        start_offset = original.indexOf(aux[0], end_offset);
                        int offset_espacio = original.indexOf(" ", start_offset+1);
                        if(offset_espacio>= original.length() || offset_espacio==-1)
                            offset_espacio = original.length()-1;
                        //System.out.println(aux[0] + " ->" + start_offset + ", " + offset_espacio);
                        String o = original.substring(start_offset, offset_espacio);
                        if(offset_espacio==start_offset)
                            o = original.substring(start_offset);
                            end_offset = start_offset + aux[0].length();
                    }
                                
                    if(start_offset == -1 || end_offset ==-1){
                        throw new AnaphoraResolutionException("Error 2: Incorrect offsets generation with "+ num_token +"st token " + aux[0] + " in sentence " + current_sentence);
                    }
                    
                    tokenAnterior = new Mention();
                    tokenAnterior.addWord(linea);
                    tokenAnterior.setNumToken(num_token);
                    tokenAnterior.setStartOffset(start_offset);
                    tokenAnterior.setEndOffset(end_offset);
                    tokenAnterior.setSentence(current_sentence);
                    
                    tokenAnterior.setToken(aux[0]);
                    tokenAnterior.setLemma(aux[1]);
                    if(aux[2].length()>1 && !aux[2].contains("+")){
                        //System.out.println(aux[2].substring(0, 2));
                        tokenAnterior.setPostype(aux[2].substring(0, 2));
                    } else {
                        tokenAnterior.setPostype(aux[2]);
                    }
                    
                    if(tokenAnterior.getPostype().equals("DD") || 
                            tokenAnterior.getPostype().equals("DA") ||
                            tokenAnterior.getPostype().endsWith("+DD") || //CONTRACCIONES
                            tokenAnterior.getPostype().endsWith("+DA")){ //CONTRACCIONES
                        tokenAnterior.setPreceedByAnArticle(true);
                    }
                }
                        //if(linea.matches(patronInicioSN) && !contarCorchetes){ 
                if(linea.contains("grup-nom") && !contarCorchetes){ 
                    //a partir de ahora hay que contar el numero de [ que se abren y ] que cierran
                    //System.out.println("Entro!");
                    corchetes = 1;
                    contarCorchetes = true;
                    m = new Mention();
                    m.setPreviousToken(tokenAnterior);
                    //an.startPosition = start_offset;//num_token+1;
                } else {
                    if(contarCorchetes){
                        if(linea.endsWith("[")){
                            corchetes++;
                        } else {
                            if(linea.endsWith("]")){
                                corchetes--;
                                if(corchetes==0) { //fin del sn
                                    contarCorchetes = false;
                                    m.setEndOffset(end_offset);
                                    //no tiene núcleo y sólo tiene una palabra
                                    if(m.getWords().size()==1 && m.getToken()==null){
                                        String [] aux = m.getWords().get(0).split("\\s+");
                                        m.setToken(aux[0]);
                                        m.setNumToken(num_token);
                                        m.setLemma(aux[1]);
                                        m.setPostype(aux[2].substring(0,2));
                                        if(aux[2].length()>=5){
                                            m.setGenre(String.valueOf(aux[2].charAt(3)));
                                            m.setNumber(String.valueOf(aux[2].charAt(4)));
                                        }
                                        if(aux[2].length()>=7){
                                            m.setTypeNE(aux[2].substring(4,6));
                                        }
                                        m.setSentence(current_sentence);
                                        //miramos si el nucleo está precedido de un determinante demostrativo o artículo
                                        if(m.getPreviousToken()!=null){
                                            if(m.getPreviousToken().getPostype().equals("DD") || 
                                                m.getPreviousToken().getPostype().equals("DA") ||
                                                m.getPreviousToken().getPostype().endsWith("+DD") || //CONTRACCIONES
                                                m.getPreviousToken().getPostype().endsWith("+DA")){ //CONTRACCIONES
                                                m.setPreceedByAnArticle(true);
                                            }
                                        }
                                    }
                                    guardarDD = true;
                                    //aqui tendría que decidir si va a primera mención o a candidato
                                    //candidates.add(m);
                                }
                            }
                        }
                    }
                            
                    if(corchetes >=1){

                        if(linea.contains("+n-") || linea.contains("psubj") || linea.contains("w-") || linea.contains("paton")){ //esto no se cumple para los sn compuestos de pronombres ni números
                            nucleo = true;
                        }
                        

                        if(linea.contains("+(")){
                            linea = linea.substring(linea.indexOf("+")+2, linea.length()-1);
                            if(m!=null){
                                String [] aux = linea.split("\\s+");
                                m.addWord(linea);
                                if(nucleo){
                                    m.setToken(aux[0]);
                                    m.setNumToken(num_token);
                                    m.setLemma(aux[1]);
                                    m.setGenre(String.valueOf(aux[2].charAt(3)));
                                    m.setNumber(String.valueOf(aux[2].charAt(4)));
                                    m.setPostype(aux[2].substring(0,2));
                                    m.setTypeNE(aux[2].substring(4,6));
                                    nucleo = false;
                                    m.setSentence(current_sentence);
                                    
                                    //m.setPreviousToken(tokenAnterior);
                                    //miramos si el nucleo está precedido de un determinante demostrativo o artículo
                                    if(m.getPreviousToken()!=null){
                                        if(m.getPreviousToken().getPostype().equals("DD") || 
                                            m.getPreviousToken().getPostype().equals("DA") ||
                                            m.getPreviousToken().getPostype().endsWith("+DD") || //CONTRACCIONES
                                            m.getPreviousToken().getPostype().endsWith("+DA")){ //CONTRACCIONES
                                            m.setPreceedByAnArticle(true);
                                        }
                                    }
                                }
                                if(m.getStartOffset()==-1){
                                    m.setStartOffset(start_offset);
                                }
                                

                            }
                        }

                    }
                       
                }
                
                if(guardarDD && linea.endsWith("_[")){
                    //aqui miramos si le sigue un SP o un SA
                    m.setFollowedBySA(false); 
                    m.setFollowedBySP(false);
                    if(linea.trim().startsWith("s-a")){
                        m.setFollowedBySA(true);
                    } 
                    if(linea.trim().startsWith("grup-sp") || linea.trim().startsWith("sp-de") || linea.trim().startsWith("prepc-ms")){
                        m.setFollowedBySP(true);
                    }
                    
                    candidates.add(m);
                    
                    m = null;
                    guardarDD = false;
                }
            }

        } catch (IOException ex) {
            Logger.getLogger(SpanishDefiniteDescription.class.getName()).log(Level.SEVERE, null, ex);
        } finally{
                // En el finally cerramos el fichero, para asegurarnos
                // que se cierra tanto si todo va bien como si salta 
                // una excepcion.
                try{                    
                    if( null != fr ){   
                    fr.close();     
                    }                  
                }catch (Exception e2){ 
                    e2.printStackTrace();
                }
            }
        
        //l"Número de oraciones:" + current_sentence);
         
    }

    public String resolveAnaphora(String text, File outputFreeling, int nextID, Element as, Document doc) throws AnaphoraResolutionException {
        String newDoc = text;      
        Element documentElement = null;
        Element textWithNodesElement = null;
        Element asde = as;
        int minNewId = nextID;
        candidates = new ArrayList<Mention>(); //listado de los candidatos (sn) que nos encontramos y pueden resolver las DDs
        firstMentions = new HashMap<Integer,Mention>(); //listado de las menciones que ya hemos visto al menos una vez
    
        try {
            //doc = XMLUtils.readXML(gDocument,"UTF8");
            documentElement = doc.getDocumentElement();
            textWithNodesElement = XMLUtils.getElementNamed(documentElement, "TextWithNodes");

            //minNewId = getNextFreeID(doc);
            //asde = insertNewAnnotationSet(doc,"Definite Descriptions Anaphora markups");
            
        } catch(Exception e){
            throw new AnaphoraResolutionException("Error 6: Problem processing input document due to parsing problems",e); //error parsing gate format
        }
        
        
//        File outputFreeling = null;
//        try {
//            outputFreeling = runFreeling(textWithNodesElement.getTextContent(), appPath);
//        } catch (IOException ex) {
//            Logger.getLogger(SpanishDefiniteDescription.class.getName()).log(Level.SEVERE, null, ex);
//            throw new AnaphoraResolutionException("Error 3: Problem with external NLP tool: freeling",ex);
//        } catch (InterruptedException ex) {
//            Logger.getLogger(SpanishDefiniteDescription.class.getName()).log(Level.SEVERE, null, ex);
//            throw new AnaphoraResolutionException("Error 3: Problem with external NLP tool: freeling",ex);
//
//        }
        
        
        //procesamos el texto a partir de la salida de freeling
        
        //2.1 detectar sintagmas nominales dpe todas las frases distinguiendo si son dd y si es primera mención o no
        
        try {
            textWithNodesElement = XMLUtils.getElementNamed(documentElement, "TextWithNodes");
            detectNounPhrases(outputFreeling,textWithNodesElement.getTextContent());
            
        } catch (Exception ex) {
            throw new AnaphoraResolutionException("Error 3: Problem with external NLP tool: freeling",ex);
        }
        
        
        //sacamos las características de lo detectado y lo solucionamos
        TreeSet<Integer> node_offsets = new TreeSet<Integer>();
        ArrayList<Mention> ddsResolved = new ArrayList<Mention>();
        try {
            ddsResolved = extractFeaturesFromNounPhrasesAndResolve();
        } catch (Exception ex) {
            throw new AnaphoraResolutionException(ex);
        }
        
        
        //almacenamos el resultado en un archivo XML de GATE
         //1. rellanamos el nuevo annotationset
        for(Mention dd : ddsResolved){
//            if(dd.getAntecedent()!=null){ //esta resuelto
              if(dd.getAntecedentsSet()!=null && !dd.getAntecedentsSet().isEmpty()){  //esta resuelto
                  /*** añadimos los antecedentes ***/
                String idAntecedente = null;
                Collections.sort(dd.getAntecedentsSet());
                Iterator<Mention> iterator = dd.getAntecedentsSet().iterator();
                StringBuilder idsAntecedents = new StringBuilder();
                StringBuilder startNodeAntecedents = new StringBuilder();
                StringBuilder endNodeAntecedents = new StringBuilder(); 
                StringBuilder confidenceAntecedents = new StringBuilder();
                
                while(iterator.hasNext()){
                    Mention next = iterator.next();
                
                    if(!node_offsets.contains(next.getStartOffset()) 
                        && !node_offsets.contains(next.getEndOffset())){
                        Element antecedentElement = doc.createElement("Annotation");
                        idAntecedente = Integer.toString(minNewId);
                        antecedentElement.setAttribute("Id", minNewId+"");
                        if(dd.getAntecedent().getStartOffset()==-1){
                            node_offsets.add(0);
                            antecedentElement.setAttribute("StartNode", "0"); 
                        } else {
                            node_offsets.add(next.getStartOffset());
                            antecedentElement.setAttribute("StartNode", next.getStartOffset()+""); 
                        }
                        antecedentElement.setAttribute("EndNode", next.getEndOffset()+""); 
                        node_offsets.add(next.getEndOffset());
                        antecedentElement.setAttribute("Type", "DiscourseEntity");
                        asde.appendChild(antecedentElement); //"Discourse Entity markups");
                        minNewId++;
                    } else {
                        //sino es que este antecedente ya esta marcado pero 
                        // tengo que saber su id para no liarla
                        
                        node_offsets.add(next.getStartOffset());
                        node_offsets.add(next.getEndOffset());//vuelvo a incluir los offsets para asegurarme que no se quedan sin incluir

                        NodeList annotations = XMLUtils.getElementsNamed(asde, "Annotation");

                        boolean enc = false;

                        for(int indice=0; indice< annotations.getLength() && !enc; indice++){
                            Element item = (Element) annotations.item(indice);
                            Integer startp = Integer.parseInt(item.getAttribute("StartNode"));
                            Integer endp = Integer.parseInt(item.getAttribute("EndNode"));
                            if(startp.equals(next.getStartOffset()) 
                                    && endp.equals(next.getEndOffset())){
                                idAntecedente = item.getAttribute("Id");
                                enc = true;
                            }
                        }

                        if (!enc){
                            System.err.println("¡OJO! POSIBLE BUG: No se encuentra la anotación de "
                                    + textWithNodesElement.getTextContent().substring(
                                    next.getStartOffset(), 
                                    next.getEndOffset()) 
                                    + " en la posición " + 
                                    next.getStartOffset() +"," 
                                    + next.getEndOffset());
                        }
                    }
                    
                    idsAntecedents.append(idAntecedente).append("|");
                    startNodeAntecedents.append(next.getStartOffset()).append("|");
                    endNodeAntecedents.append(next.getEndOffset()).append("|");
                    confidenceAntecedents.append(next.getConfidence()).append("|");
                
                }
                
                /*** añadimos la descripción definida ***/
                
                Element pronounElement = doc.createElement("Annotation");
                pronounElement.setAttribute("Id", minNewId+"");
                pronounElement.setAttribute("StartNode", dd.getStartOffset()+"");
                node_offsets.add(dd.getStartOffset());
                pronounElement.setAttribute("EndNode", dd.getEndOffset()+""); 
                node_offsets.add(dd.getEndOffset());
                pronounElement.setAttribute("Type", "DefiniteDescription");
                asde.appendChild(pronounElement);
                
                Element feature = doc.createElement("Feature");
                pronounElement.appendChild(feature);
                Element name = doc.createElement("Name");
                name.setAttribute("className", "java.lang.String");
                name.setTextContent("complexity");
                feature.appendChild(name);
                Element value = doc.createElement("Value");
                value.setAttribute("className", "java.lang.String");
//                value.setTextContent("0.85");
                value.setTextContent(Double.toString(complexity));
                feature.appendChild(value);
                
                /*** incluimos información de todos los antecedentes posibles ordenados de mayor a menor probabilidad ***/

                feature = doc.createElement("Feature");
                pronounElement.appendChild(feature);
                name = doc.createElement("Name");
                name.setAttribute("className", "java.lang.String");
                name.setTextContent("StartNodeAntecedent");
                feature.appendChild(name);
                value = doc.createElement("Value");
                value.setAttribute("className", "java.lang.String");
                value.setTextContent(startNodeAntecedents.substring(0, startNodeAntecedents.length()-1)); //quitamos el último |
//                value.setTextContent(dd.getAntecedent().getStartOffset()+"");
                feature.appendChild(value);

                feature = doc.createElement("Feature");
                pronounElement.appendChild(feature);
                name = doc.createElement("Name");
                name.setAttribute("className", "java.lang.String");
                name.setTextContent("EndNodeAntecedent");
                feature.appendChild(name);
                value = doc.createElement("Value");
                value.setAttribute("className", "java.lang.String");
//                value.setTextContent(dd.getAntecedent().getEndOffset()+"");
                value.setTextContent(endNodeAntecedents.substring(0, endNodeAntecedents.length()-1)); //quitamos el último |
                feature.appendChild(value);

                feature = doc.createElement("Feature");
                pronounElement.appendChild(feature);
                name = doc.createElement("Name");
                name.setAttribute("className", "java.lang.String");
                name.setTextContent("confidence");
                feature.appendChild(name);
                value = doc.createElement("Value");
                value.setAttribute("className", "java.lang.String");
//                value.setTextContent(dd.getConfidence()+"");
                value.setTextContent(confidenceAntecedents.substring(0, confidenceAntecedents.length()-1)); //quitamos el último |
                feature.appendChild(value);

                feature = doc.createElement("Feature");
                pronounElement.appendChild(feature);
                name = doc.createElement("Name");
                name.setAttribute("className", "java.lang.String");
                name.setTextContent("AntecedentId");
                feature.appendChild(name);
                value = doc.createElement("Value");
                value.setAttribute("className", "java.lang.String");
//                value.setTextContent(idAntecedente);
                value.setTextContent(idsAntecedents.substring(0, idsAntecedents.length()-1)); //quitamos el último |
                feature.appendChild(value);


                minNewId++;
                
            } else {
                Element pronounElement = doc.createElement("Annotation");
                pronounElement.setAttribute("Id", minNewId+"");
                pronounElement.setAttribute("StartNode", dd.getStartOffset()+"");
                node_offsets.add(dd.getStartOffset());
                pronounElement.setAttribute("EndNode", dd.getEndOffset()+""); 
                node_offsets.add(dd.getEndOffset());
                pronounElement.setAttribute("Type", "DefiniteDescription");
                
                Element feature = doc.createElement("Feature");
                pronounElement.appendChild(feature);
                Element name = doc.createElement("Name");
                name.setAttribute("className", "java.lang.String");
                name.setTextContent("complexity");
                feature.appendChild(name);
                Element value = doc.createElement("Value");
                value.setAttribute("className", "java.lang.String");
//                value.setTextContent("0.85");
                value.setTextContent(Double.toString(complexity));
                feature.appendChild(value);
                
                
                asde.appendChild(pronounElement);
                
                minNewId++;
            }
        }
        
        //modificar el gDocument para incluir las anotaciones:
        //los que ya tuvieramos y los de nuestras nuevas anotaciones,
        //teniendo en cuenta la salida de freeling para saber donde ponerlos
        try {
            addOffsetNodes(textWithNodesElement,node_offsets, doc);
        } catch(Exception ex){
            Logger.getLogger(SpanishDefiniteDescription.class.getName()).log(Level.SEVERE, null, ex);
            throw new AnaphoraResolutionException("Error 2: Incorrect offsets generation",ex);
        }

        try{
            //outputFreeling.delete(); //ahora que ya no necesito la salida de freeling, borro el fichero - se hace arriba

            newDoc = generateStringOutput(doc);
        } catch (Exception ex) {
            Logger.getLogger(SpanishDefiniteDescription.class.getName()).log(Level.SEVERE, null, ex);
            throw new AnaphoraResolutionException("Error 7: Problem generating output document",ex);

        } 
        
        return newDoc;
    }
     
    
    public String resolveAnaphora(String text, File outputFreeling, int nextID, Element as, Document doc, Boolean allAlternatives, Threshold minConfidence) throws AnaphoraResolutionException {
        String newDoc = text;      
        Element documentElement = null;
        Element textWithNodesElement = null;
        Element asde = as;
        int minNewId = nextID;
        candidates = new ArrayList<Mention>(); //listado de los candidatos (sn) que nos encontramos y pueden resolver las DDs
        firstMentions = new HashMap<Integer,Mention>(); //listado de las menciones que ya hemos visto al menos una vez
    
        try {
            //doc = XMLUtils.readXML(gDocument,"UTF8");
            documentElement = doc.getDocumentElement();
            textWithNodesElement = XMLUtils.getElementNamed(documentElement, "TextWithNodes");

            //minNewId = getNextFreeID(doc);
            //asde = insertNewAnnotationSet(doc,"Definite Descriptions Anaphora markups");
            
        } catch(Exception e){
            throw new AnaphoraResolutionException("Error 6: Problem processing input document due to parsing problems",e); //error parsing gate format
        }
        
        
//        File outputFreeling = null;
//        try {
//            outputFreeling = runFreeling(textWithNodesElement.getTextContent(), appPath);
//        } catch (IOException ex) {
//            Logger.getLogger(SpanishDefiniteDescription.class.getName()).log(Level.SEVERE, null, ex);
//            throw new AnaphoraResolutionException("Error 3: Problem with external NLP tool: freeling",ex);
//        } catch (InterruptedException ex) {
//            Logger.getLogger(SpanishDefiniteDescription.class.getName()).log(Level.SEVERE, null, ex);
//            throw new AnaphoraResolutionException("Error 3: Problem with external NLP tool: freeling",ex);
//
//        }
        
        
        //procesamos el texto a partir de la salida de freeling
        
        //2.1 detectar sintagmas nominales dpe todas las frases distinguiendo si son dd y si es primera mención o no
        
        try {
            textWithNodesElement = XMLUtils.getElementNamed(documentElement, "TextWithNodes");
            detectNounPhrases(outputFreeling,textWithNodesElement.getTextContent());
            
        } catch (Exception ex) {
            throw new AnaphoraResolutionException("Error 3: Problem with external NLP tool: freeling",ex);
        }
        
        
        //sacamos las características de lo detectado y lo solucionamos
        TreeSet<Integer> node_offsets = new TreeSet<Integer>();
        ArrayList<Mention> ddsResolved = new ArrayList<Mention>();
        try {
            ddsResolved = extractFeaturesFromNounPhrasesAndResolve();
        } catch (Exception ex) {
            throw new AnaphoraResolutionException(ex);
        }
        
        
        //almacenamos el resultado en un archivo XML de GATE
         //1. rellanamos el nuevo annotationset
        for(Mention dd : ddsResolved){
//            if(dd.getAntecedent()!=null){ //esta resuelto
              if(dd.getAntecedentsSet()!=null && !dd.getAntecedentsSet().isEmpty()){  //esta resuelto
                  /*** añadimos los antecedentes ***/
                String idAntecedente = null;
                Collections.sort(dd.getAntecedentsSet());
                Iterator<Mention> iterator = dd.getAntecedentsSet().iterator();
                StringBuilder idsAntecedents = new StringBuilder();
                StringBuilder startNodeAntecedents = new StringBuilder();
                StringBuilder endNodeAntecedents = new StringBuilder(); 
                StringBuilder confidenceAntecedents = new StringBuilder();
                double currentConfidence = 0.0;
                do{
                    if(iterator.hasNext()){
                        Mention next = iterator.next();
                        currentConfidence = next.getConfidence();
                        if(currentConfidence>= minConfidence.getValue()){

                            if(!node_offsets.contains(next.getStartOffset()) 
                                && !node_offsets.contains(next.getEndOffset())){
                                Element antecedentElement = doc.createElement("Annotation");
                                idAntecedente = Integer.toString(minNewId);
                                antecedentElement.setAttribute("Id", minNewId+"");
                                if(dd.getAntecedent().getStartOffset()==-1){
                                    node_offsets.add(0);
                                    antecedentElement.setAttribute("StartNode", "0"); 
                                } else {
                                    node_offsets.add(next.getStartOffset());
                                    antecedentElement.setAttribute("StartNode", next.getStartOffset()+""); 
                                }
                                antecedentElement.setAttribute("EndNode", next.getEndOffset()+""); 
                                node_offsets.add(next.getEndOffset());
                                antecedentElement.setAttribute("Type", "DiscourseEntity");
                                asde.appendChild(antecedentElement); //"Discourse Entity markups");
                                minNewId++;
                            } else {
                                //sino es que este antecedente ya esta marcado pero 
                                // tengo que saber su id para no liarla

                                node_offsets.add(next.getStartOffset());
                                node_offsets.add(next.getEndOffset());//vuelvo a incluir los offsets para asegurarme que no se quedan sin incluir

                                NodeList annotations = XMLUtils.getElementsNamed(asde, "Annotation");

                                boolean enc = false;

                                for(int indice=0; indice< annotations.getLength() && !enc; indice++){
                                    Element item = (Element) annotations.item(indice);
                                    Integer startp = Integer.parseInt(item.getAttribute("StartNode"));
                                    Integer endp = Integer.parseInt(item.getAttribute("EndNode"));
                                    if(startp.equals(next.getStartOffset()) 
                                            && endp.equals(next.getEndOffset())){
                                        idAntecedente = item.getAttribute("Id");
                                        enc = true;
                                    }
                                }

                                if (!enc){
                                    System.err.println("¡OJO! POSIBLE BUG: No se encuentra la anotación de "
                                            + textWithNodesElement.getTextContent().substring(
                                            next.getStartOffset(), 
                                            next.getEndOffset()) 
                                            + " en la posición " + 
                                            next.getStartOffset() +"," 
                                            + next.getEndOffset());
                                }
                            }

                            idsAntecedents.append(idAntecedente).append("|");
                            startNodeAntecedents.append(next.getStartOffset()).append("|");
                            endNodeAntecedents.append(next.getEndOffset()).append("|");
                            confidenceAntecedents.append(next.getConfidence()).append("|");
                        }
                    }
                }while(iterator.hasNext() && //si hay siguiente elemento
                        currentConfidence>= minConfidence.getValue() && //si la confidence es mayor
                        allAlternatives); //si hay que mostrar más de una alternativa
                
                /*** añadimos la descripción definida ***/
                
                Element pronounElement = doc.createElement("Annotation");
                pronounElement.setAttribute("Id", minNewId+"");
                pronounElement.setAttribute("StartNode", dd.getStartOffset()+"");
                node_offsets.add(dd.getStartOffset());
                pronounElement.setAttribute("EndNode", dd.getEndOffset()+""); 
                node_offsets.add(dd.getEndOffset());
                pronounElement.setAttribute("Type", "DefiniteDescription");
                asde.appendChild(pronounElement);
                
                Element feature = doc.createElement("Feature");
                pronounElement.appendChild(feature);
                Element name = doc.createElement("Name");
                name.setAttribute("className", "java.lang.String");
                name.setTextContent("complexity");
                feature.appendChild(name);
                Element value = doc.createElement("Value");
                value.setAttribute("className", "java.lang.String");
//                value.setTextContent("0.85");
                value.setTextContent(Double.toString(complexity));
                feature.appendChild(value);
                
                /*** incluimos información de todos los antecedentes posibles ordenados de mayor a menor probabilidad ***/
                // solo si hay antecedentes que cumplan las condiciones!!
                if(startNodeAntecedents.length()>0)     {  
                    feature = doc.createElement("Feature");
                    pronounElement.appendChild(feature);
                    name = doc.createElement("Name");
                    name.setAttribute("className", "java.lang.String");
                    name.setTextContent("StartNodeAntecedent");
                    feature.appendChild(name);
                    value = doc.createElement("Value");
                    value.setAttribute("className", "java.lang.String");
                    value.setTextContent(startNodeAntecedents.substring(0, startNodeAntecedents.length()-1)); //quitamos el último |
    //                value.setTextContent(dd.getAntecedent().getStartOffset()+"");
                    feature.appendChild(value);

                    feature = doc.createElement("Feature");
                    pronounElement.appendChild(feature);
                    name = doc.createElement("Name");
                    name.setAttribute("className", "java.lang.String");
                    name.setTextContent("EndNodeAntecedent");
                    feature.appendChild(name);
                    value = doc.createElement("Value");
                    value.setAttribute("className", "java.lang.String");
    //                value.setTextContent(dd.getAntecedent().getEndOffset()+"");
                    value.setTextContent(endNodeAntecedents.substring(0, endNodeAntecedents.length()-1)); //quitamos el último |
                    feature.appendChild(value);

                    feature = doc.createElement("Feature");
                    pronounElement.appendChild(feature);
                    name = doc.createElement("Name");
                    name.setAttribute("className", "java.lang.String");
                    name.setTextContent("confidence");
                    feature.appendChild(name);
                    value = doc.createElement("Value");
                    value.setAttribute("className", "java.lang.String");
    //                value.setTextContent(dd.getConfidence()+"");
                    value.setTextContent(confidenceAntecedents.substring(0, confidenceAntecedents.length()-1)); //quitamos el último |
                    feature.appendChild(value);

                    feature = doc.createElement("Feature");
                    pronounElement.appendChild(feature);
                    name = doc.createElement("Name");
                    name.setAttribute("className", "java.lang.String");
                    name.setTextContent("AntecedentId");
                    feature.appendChild(name);
                    value = doc.createElement("Value");
                    value.setAttribute("className", "java.lang.String");
    //                value.setTextContent(idAntecedente);
                    value.setTextContent(idsAntecedents.substring(0, idsAntecedents.length()-1)); //quitamos el último |
                    feature.appendChild(value);
                }

                minNewId++;
                
            } else {
                Element pronounElement = doc.createElement("Annotation");
                pronounElement.setAttribute("Id", minNewId+"");
                pronounElement.setAttribute("StartNode", dd.getStartOffset()+"");
                node_offsets.add(dd.getStartOffset());
                pronounElement.setAttribute("EndNode", dd.getEndOffset()+""); 
                node_offsets.add(dd.getEndOffset());
                pronounElement.setAttribute("Type", "DefiniteDescription");
                
                Element feature = doc.createElement("Feature");
                pronounElement.appendChild(feature);
                Element name = doc.createElement("Name");
                name.setAttribute("className", "java.lang.String");
                name.setTextContent("complexity");
                feature.appendChild(name);
                Element value = doc.createElement("Value");
                value.setAttribute("className", "java.lang.String");
//                value.setTextContent("0.85");
                value.setTextContent(Double.toString(complexity));
                feature.appendChild(value);
                
                
                asde.appendChild(pronounElement);
                
                minNewId++;
            }
        }
        
        //modificar el gDocument para incluir las anotaciones:
        //los que ya tuvieramos y los de nuestras nuevas anotaciones,
        //teniendo en cuenta la salida de freeling para saber donde ponerlos
        try {
            addOffsetNodes(textWithNodesElement,node_offsets, doc);
        } catch(Exception ex){
            Logger.getLogger(SpanishDefiniteDescription.class.getName()).log(Level.SEVERE, null, ex);
            throw new AnaphoraResolutionException("Error 2: Incorrect offsets generation",ex);
        }

        try{
            //outputFreeling.delete(); //ahora que ya no necesito la salida de freeling, borro el fichero - se hace arriba

            newDoc = generateStringOutput(doc);
        } catch (Exception ex) {
            Logger.getLogger(SpanishDefiniteDescription.class.getName()).log(Level.SEVERE, null, ex);
            throw new AnaphoraResolutionException("Error 7: Problem generating output document",ex);

        } 
        
        return newDoc;
    }
    
    }
