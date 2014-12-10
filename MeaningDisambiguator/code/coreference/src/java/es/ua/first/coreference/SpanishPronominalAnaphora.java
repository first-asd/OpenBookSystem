/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package es.ua.first.coreference;

import es.ua.first.coreference.util.AnaphoricExpresion;
import es.ua.first.coreference.util.Antecedent;
import es.upv.xmlutils.XMLUtils;
import java.io.*;
import java.util.ArrayList;
import java.util.Collections;
import java.util.HashMap;
import java.util.Iterator;
import java.util.Set;
import java.util.TreeSet;
import java.util.logging.Level;
import java.util.logging.Logger;
import org.w3c.dom.Document;
import org.w3c.dom.Element;
import org.w3c.dom.NodeList;
import weka.classifiers.Classifier;
import weka.core.Attribute;
import weka.core.Instance;
import weka.core.Instances;

/**
 *
 * @author imoreno
 */
class SpanishPronominalAnaphora extends AnaphoraResolutionUtils implements AnaphoraResolutionInterface {
    private String appPath;
    private HashMap<Integer,ArrayList<AnaphoricExpresion>> pronous;
    Set<String> funcionesSintacticasPP, palabrasPP, lemasPP;
    int sentencesSize;
    Classifier cpersonal, cdemonstrative, cindefinite, cinterrogative, crelative; //modelos
    Instances dpersonal, ddemonstrative, dindefinite, dinterrogative, drelative; //info de las cabeceras
    
    private static final double complexity = 0.9;
    
    public SpanishPronominalAnaphora(String path) throws FileNotFoundException, Exception {
            appPath = path;
            sentencesSize = 0;
            //cargamos los modelos y las cabeceras
            Object obj_exp[] =  weka.core.SerializationHelper.readAll(path+"models/VFI_ppersonal.model");
            cpersonal = (Classifier)obj_exp[0];
            dpersonal = (Instances) obj_exp[1];
            
            obj_exp = weka.core.SerializationHelper.readAll(path+"models/VFI_pdem.model");
            cdemonstrative = (Classifier)obj_exp[0];
            ddemonstrative = (Instances) obj_exp[1];
            
            obj_exp = weka.core.SerializationHelper.readAll(path+"models/VFI_pindef.model");
            cindefinite = (Classifier)obj_exp[0];
            dindefinite = (Instances) obj_exp[1];
            
            obj_exp = weka.core.SerializationHelper.readAll(path+"models/VFI_pint.model");
            cinterrogative = (Classifier)obj_exp[0];
            dinterrogative = (Instances) obj_exp[1];
            
            obj_exp = weka.core.SerializationHelper.readAll(path+"models/VFI_prelativo.model");
            crelative = (Classifier)obj_exp[0];
            drelative = (Instances) obj_exp[1];

            
            
            
           // throw new Exception ("Error code 4: Problem with external machine learning tool, Weka: Model not loaded",ex);
        
    }

    
//    private boolean annotatePronoun(AnaphoricExpresion pronoun, int pronoun_index, File outputFreeling, String originalText){ // Document docXML, Element annotationSetAnphora, Element annotationSetDiscourseEntities){
//        boolean res = false;
//        
//        return res;
//    }
    
    public String resolveAnaphora(String gDocument) throws AnaphoraResolutionException {
        String newDoc = gDocument;
        Document doc = null;
        Element documentElement = null;
        Element textWithNodesElement = null;
        Element asde = null;
        int minNewId = -1;
        
        try {
            doc = XMLUtils.readXML(gDocument,"UTF8");
            documentElement = doc.getDocumentElement();
            textWithNodesElement = XMLUtils.getElementNamed(documentElement, "TextWithNodes");
            
            //obtenemos el identificador para las nuevas anotaciones
            minNewId = textWithNodesElement.getTextContent().length()+1;
            NodeList elementNamed = XMLUtils.getElementsNamed(documentElement, "AnnotationSet");
            for(int i=0; i<elementNamed.getLength(); i++){
                NodeList anotaciones = XMLUtils.getElementsNamed((Element)elementNamed.item(i), "Annotation");
                for(int j=0; j<anotaciones.getLength(); j++){
                    Element e = (Element) anotaciones.item(j);
                    int attribute = Integer.getInteger(e.getAttribute("Id"));
                    if(minNewId<attribute)
                        minNewId = attribute +1;
                }
            }
            //creamos los dos nuevos annotationset
            asde = doc.createElement("AnnotationSet");
            asde.setAttribute("Name", "Pronominal Anaphora markups");
            
            //Element asa = doc.createElement("AnnotationSet");
            //asa.setAttribute("name", "Anaphora markups");
            
            //documentElement.appendChild(asa);
            documentElement.appendChild(asde);
        } catch(Exception e){
            throw new AnaphoraResolutionException("Error 6: Problem processing input document due to parsing problems",e); //error parsing gate format
        }
        
        
        File outputFreeling = null;
        try {
            outputFreeling = runFreeling(textWithNodesElement.getTextContent(), appPath);
        } catch (IOException ex) {
            Logger.getLogger(SpanishPronominalAnaphora.class.getName()).log(Level.SEVERE, null, ex);
            throw new AnaphoraResolutionException("Error 3: Problem with external NLP tool: freeling",ex);
        } catch (InterruptedException ex) {
            Logger.getLogger(SpanishPronominalAnaphora.class.getName()).log(Level.SEVERE, null, ex);
            throw new AnaphoraResolutionException("Error 3: Problem with external NLP tool: freeling",ex);

        }
            
        //1. partir en frases
        //numero de frases: no va
        //sentencesSize = getSentencesCount(outputFreeling.getAbsolutePath());

        //2.1 detectar pronombres de todas las frases - se repite para cada tipo de pronombre
        pronous =  new HashMap<Integer, ArrayList<AnaphoricExpresion>>();
        try {
            detectPronominalAnaphoricExpressions("P", "P", outputFreeling,textWithNodesElement.getTextContent());
            detectPronominalAnaphoricExpressions("P", "D", outputFreeling,textWithNodesElement.getTextContent());
            detectPronominalAnaphoricExpressions("P", "I", outputFreeling,textWithNodesElement.getTextContent());
            detectPronominalAnaphoricExpressions("P", "T", outputFreeling,textWithNodesElement.getTextContent());
            detectPronominalAnaphoricExpressions("P", "R", outputFreeling,textWithNodesElement.getTextContent());

        } catch (Exception ex) {
            Logger.getLogger(SpanishPronominalAnaphora.class.getName()).log(Level.SEVERE, null, ex);
            throw new AnaphoraResolutionException("Error 3: Problem with external NLP tool: freeling",ex);
        }
        
        
            //ArrayList<Integer> node_offsets = new ArrayList<Integer>();
            TreeSet<Integer> node_offsets = new TreeSet<Integer>();
            //2. para cada frase:
            for(Integer i : pronous.keySet()){
                //2.2 para cada pronombre
                ArrayList<AnaphoricExpresion> prons = pronous.get(i);
                boolean continuar = true;
                for(int j=0; j<prons.size(); j++){
                    AnaphoricExpresion pronoun = prons.get(j);
                    //annotatePronoun(pronoun, i, outputFreeling, textWithNodesElement.getTextContent()); //, doc, asa, asde);
                    //2.2.2 Generar características ML
                    String llinea = pronoun.word.substring(pronoun.word.indexOf("+("));
                    String [] aux = llinea.split("\\s+");
                    try{
                        Instance ins;
                        continuar = true;
                        if(aux[2].charAt(1)=='P'){
                            ins = new Instance(15);
                            ins.setDataset(dpersonal);
                            ins.setMissing(14);
                        } else {
                            ins = new Instance(16);
                            ins.setMissing(15);
                            switch(aux[2].charAt(1)){
                                case 'D': ins.setDataset(ddemonstrative);
                                        break;
                                case 'I': ins.setDataset(dindefinite); break;
                                case 'T' : ins.setDataset(dinterrogative); break;
                                case 'R' : ins.setDataset(drelative);    break;
                                default : continuar = false;
                                            break;
                            }
                        }

                        if(continuar){
                            //características del pronombre
                            Character persona = aux[2].charAt(2);
                            if (persona.equals('0'))
                                ins.setMissing(3);
                            else
                                ins.setValue(3, persona.toString()); //persona

                            String genero = Character.toString(aux[2].charAt(3));
                            if (genero.equals("0"))
                                ins.setMissing(2);
                            else{
                                genero = (genero.equals("N"))? "c":genero.toLowerCase();
                                //System.out.println("Pronombre " + llinea + " -> genero = " + genero);
                                ins.setValue(2, genero); //genero
                            }

                            String numero = Character.toString(aux[2].charAt(4));
                            if(numero.equals("0"))
                                ins.setMissing(1);
                            else {
                                numero = (numero.equals("N"))? "C":numero;
                                ins.setValue(1, numero.toLowerCase()); //numero
                            }

                            String sf = getSemEvalMapping(pronoun.syntactic_function);
                            if(sf!=null)
                                ins.setValue(0, sf); //funcion sintactica
                            else
                                ins.setMissing(0);

                            //2.2.1 detectar sus posibles antecedentes.
                            HashMap<Integer,ArrayList<Antecedent>> antecedents = null;
                            try {
                                antecedents = detectAntecedentsInSentence(i,outputFreeling, textWithNodesElement.getTextContent());
                            }catch(Exception ex){
                                throw new AnaphoraResolutionException("Error 5: Problem with external machine learning tool, weka: Incorrect value features",ex);
                            }

                            //System.out.println("Resolviendo el pronombre " + pronoun.word + "("+ pronoun.position + " - "+ pronoun.endPosition +")...." + antecedents.size());
                            for(int oracion: antecedents.keySet()){
                                //System.out.println("Posibles antecedentes en oracion "+ oracion+ ":");
                                for(Antecedent ant : antecedents.get(oracion)){
                                    //System.out.println("+ " + ant.core + " (" + ant.startPosition + " - " + ant.endPosition + ")");
                                    if(pronoun.endPosition > ant.startPosition ){ //tiene que estar antes del pronombre
                                        //2.2.2 Generar características ML del antecedente
                                        
                                        
                                        
                                        

                                        if(ant.core!=null){
                                                String [] aux2 = ant.core.split("\\s+");
                                                Attribute token = ins.attribute(4);
                                                boolean existToken = token.indexOfValue(aux2[0])!=-1; //conozco este token si su índice no es -1
                                                if(!existToken)
                                                    ins.setMissing(4); //palabra: es desconocido en entrenamiento
                                                else
                                                    ins.setValue(token, aux2[0]);

                                                Attribute lemma = ins.attribute(5);
                                                boolean existLemma = lemma.indexOfValue(aux2[2])!=-1;
                                                if(!existLemma)
                                                    ins.setMissing(5); //lema: es desconocido en entrenamiento
                                                else
                                                    ins.setValue(lemma, aux2[1]);
                                                
                                                if('N'==aux2[2].charAt(0)){
                                                    String numero2 = Character.toString(aux2[2].charAt(3));
                                                    numero2 = (numero2.equals("N")|| numero2.equals("0"))? "c":numero2.toLowerCase();
                                                    ins.setValue(6, numero2); //numero
                                                    String genero2 = Character.toString(aux2[2].charAt(2));
                                                    genero2 = (genero2.equals("0"))? "c":genero2.toLowerCase();
                                                    ins.setValue(7, genero2); //genero
                                                    /*Character persona2 = aux2[2].charAt(1);
                                                    if(persona2.equals('0'))
                                                        ins.setValue(8, "3"); //persona
                                                    else
                                                        ins.setValue(8, persona2.toString()); //persona
                                                */
                                                    ins.setMissing(8); //los nombres no tienen persona
                                                    if(aux2[2].charAt(1)!='P'){
                                                        //tenemos en cuenta la en del nombre
                                                        String ne_nombre = aux2[2].substring(5, 6);
                                                        //other,org,loc,person,date,number
                                                        if(ne_nombre.equals("SP"))
                                                                ne_nombre = "person";
                                                        else if(ne_nombre.startsWith("G"))
                                                            ne_nombre = "loc";
                                                        else if(ne_nombre.startsWith("O"))
                                                            ne_nombre = "org";
                                                        else ne_nombre ="other";
                                                        ins.setValue(9, ne_nombre);
                                                    }

                                                    //2.2.2 Generar características ML que relacionan a ambos
                                                    int dist = ant.startPosition - pronoun.position;
                                                    if(i>oracion)
                                                        dist = ant.startPosition + pronoun.position;
                                                    if(aux[2].charAt(1)=='P'){
                                                        ins.setValue(9, dist);
                                                        ins.setValue(10, (i==oracion)? 1: 0);
                                                        ins.setValue(11, (numero.equals(numero2))? 2: 0);
                                                        ins.setValue(12, (genero.equals(genero2))? 2: 0);
                                                        ins.setValue(13, 0);
                                                    } else{
                                                        ins.setValue(10, dist);
                                                        ins.setValue(11, (i==oracion)? 1: 0);
                                                        ins.setValue(12, (numero.equals(numero2))? 2: 0);
                                                        ins.setValue(13, (genero.equals(genero2))? 2: 0);
                                                        ins.setValue(14, 0);
                                                    }



                                                    //2.2.3 Obtener la clasificación con ML según el tipo de pronombre
                                                    double[] res;
                                                    switch(aux[2].charAt(1)){
                                                        case 'P':
                                                            res = cpersonal.distributionForInstance(ins);
                                                            break;
                                                        case 'D':
                                                            res = cdemonstrative.distributionForInstance(ins);
                                                            break;
                                                        case 'I':  res = cindefinite.distributionForInstance(ins);
                                                            break;
                                                        case 'T': res = cinterrogative.distributionForInstance(ins); break;
                                                        case 'R': res = crelative.distributionForInstance(ins); break;
                                                        default:
                                                            res = new double [] {0,0};
                                                    }
                                                    //*** ¿qué pasa si hay varios que la resuelven? Eso no lo puedo controlar en el entrenamiento. Aquí me quedaría con el último
                                                    if(res[0]< res[1]){
                                                        ant.confidence = res[1];
                                                        pronoun.antecedentsSet.add(ant); //aunque no tenga mayor probabilidad, me lo guardo
                                                        //si he encontrado uno con mayor probabilidad me lo guardo
                                                        if(pronoun.antecedent==null || (pronoun.antecedent!=null && pronoun.antecedent.confidence <= res[1]) ){
                                                            pronoun.antecedent = ant;
                                                            prons.set(j,pronoun);
                                                            pronous.put(i, prons);
                                                            //System.out.print("*");
                                                        } 
                                                    }  
                                                    //System.out.println("Probabilidad Si_ser_antecedente: " + res[1]);
                                                }
                                        }

                                    }
                                }
                            }

                            //añadimos al xml el resultado de ml

                            /*** añadir antecedenteS ***/
                            if(pronoun.antecedentsSet!=null && !pronoun.antecedentsSet.isEmpty()){
                                //if(pronoun.antecedent!=null){
                                Collections.sort(pronoun.antecedentsSet); //se ordena por confidence
                               
                                Iterator<Antecedent> iterator =  pronoun.getUniqueAntecedents().iterator(); //pronoun.antecedentsSet.iterator();
                                StringBuilder idsAntecedents = new StringBuilder();
                                StringBuilder startNodeAntecedents = new StringBuilder();
                                StringBuilder endNodeAntecedents = new StringBuilder(); 
                                StringBuilder confidenceAntecedents = new StringBuilder();
                                StringBuilder chain = new StringBuilder();
                                while(iterator.hasNext()){ //convertir a iterator y actualizar este código
                                    Antecedent next = iterator.next();
                                    
                                    String idAntecedente = null;
                                    if(!node_offsets.contains(next.startPosition) && !node_offsets.contains(next.endPosition)){
                                        Element antecedentElement = doc.createElement("Annotation");
                                        idAntecedente = Integer.toString(minNewId);
                                        
                                        antecedentElement.setAttribute("Id", minNewId+"");
                                        antecedentElement.setAttribute("StartNode", next.startPosition+""); 
                                        if(next.startPosition==-1)
                                            node_offsets.add(0);//esto no tiene sentido
                                        else 
                                            node_offsets.add(next.startPosition);
                                        antecedentElement.setAttribute("EndNode", next.endPosition+""); 
                                        node_offsets.add(next.endPosition);
                                        antecedentElement.setAttribute("Type", "DiscourseEntity");
                                        asde.appendChild(antecedentElement); //"Discourse Entity markups");
                                        minNewId++;
                                        
                                    } //sino es que este antecedente ya esta marcado pero 
                                    // tengo que saber su id para no liarla
                                    else {
                                        NodeList annotations = XMLUtils.getElementsNamed(asde, "Annotation");

                                        boolean enc = false;

                                        for(int indice=0; indice< annotations.getLength() && !enc; indice++){
                                            Element item = (Element) annotations.item(indice);
                                            Integer startp = Integer.parseInt(item.getAttribute("StartNode"));
                                            Integer endp = Integer.parseInt(item.getAttribute("EndNode"));
                                            if(startp.equals(next.startPosition) && endp.equals(next.endPosition)){
                                                idAntecedente = item.getAttribute("Id");
                                                enc = true;
                                            }
                                        }

                                        if (!enc){
                                            System.err.println("¡OJO! POSIBLE BUG: No se encuentra la anotación de " + textWithNodesElement.getTextContent().substring(next.startPosition, next.endPosition) + " en la posición " + next.startPosition +"," + next.endPosition);
                                        }

                                    }
                                    idsAntecedents.append(idAntecedente).append("|");
                                    startNodeAntecedents.append(next.startPosition).append("|");
                                    endNodeAntecedents.append(next.endPosition).append("|");
                                    confidenceAntecedents.append(next.confidence).append("|");
                                    chain.append(textWithNodesElement.getTextContent().substring(next.startPosition, next.endPosition)).append('|');
                                    
                                }
                                
                                /*** añadir pronombre ***/
                                Element pronounElement = doc.createElement("Annotation");
                                pronounElement.setAttribute("Id", minNewId+"");
                                pronounElement.setAttribute("StartNode", pronoun.position+"");
                                node_offsets.add(pronoun.position);
                                pronounElement.setAttribute("EndNode", pronoun.endPosition+""); 
                                node_offsets.add(pronoun.endPosition);
                                pronounElement.setAttribute("Type", "PronounAnaphora");
    //                            asa.appendChild(pronounElement); //Pronouns
                                asde.appendChild(pronounElement);
                                
                                Element feature = doc.createElement("Feature");
                                pronounElement.appendChild(feature);
                                Element name = doc.createElement("Name");
                                name.setAttribute("className", "java.lang.String");
                                name.setTextContent("complexity");
                                feature.appendChild(name);
                                Element value = doc.createElement("Value");
                                value.setAttribute("className", "java.lang.String");
                                value.setTextContent(Double.toString(complexity));
//                                value.setTextContent("0.85");
                                feature.appendChild(value);

                                /*** añadir todos la info de los antecedentes de mayor a menor confidence y con una confidence > 0.5***/
                                feature = doc.createElement("Feature");
                                pronounElement.appendChild(feature);
                                name = doc.createElement("Name");
                                name.setAttribute("className", "java.lang.String");
                                name.setTextContent("StartNodeAntecedent");
                                feature.appendChild(name);
                                value = doc.createElement("Value");
                                value.setAttribute("className", "java.lang.String");
//                                value.setTextContent(pronoun.antecedent.startPosition+"");
                                value.setTextContent(startNodeAntecedents.substring(0, startNodeAntecedents.length()-1)); //quitamos el último |
//                                value.setTextContent(pronoun.antecedent.startPosition+"");
                                feature.appendChild(value);

                                feature = doc.createElement("Feature");
                                pronounElement.appendChild(feature);
                                name = doc.createElement("Name");
                                name.setAttribute("className", "java.lang.String");
                                name.setTextContent("EndNodeAntecedent");
                                feature.appendChild(name);
                                value = doc.createElement("Value");
                                value.setAttribute("className", "java.lang.String");
//                                value.setTextContent(pronoun.antecedent.endPosition+"");
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
//                                value.setTextContent(pronoun.antecedent.confidence+"");
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
//                                value.setTextContent(idAntecedente);
                                value.setTextContent(idsAntecedents.substring(0, idsAntecedents.length()-1)); //quitamos el último |
                                feature.appendChild(value);
                                
                                feature = doc.createElement("Feature");
                                pronounElement.appendChild(feature);
                                name = doc.createElement("Name");
                                name.setAttribute("className", "java.lang.String");
                                name.setTextContent("chain");
                                feature.appendChild(name);
                                value = doc.createElement("Value");
                                value.setAttribute("className", "java.lang.String");
//                                value.setTextContent(idAntecedente);
                                value.setTextContent(chain.substring(0, chain.length()-1)); //quitamos el último |
                                feature.appendChild(value);


                                minNewId++;
                            } else {
                                Element pronounElement = doc.createElement("Annotation");
                                pronounElement.setAttribute("Id", minNewId+"");
                                pronounElement.setAttribute("StartNode", pronoun.position+"");
                                node_offsets.add(pronoun.position);
                                pronounElement.setAttribute("EndNode", pronoun.endPosition+""); 
                                node_offsets.add(pronoun.endPosition);
                                pronounElement.setAttribute("Type", "PronounAnaphora");
    //                            asa.appendChild(pronounElement); //Pronouns
                                
                                Element feature = doc.createElement("Feature");
                                pronounElement.appendChild(feature);
                                Element name = doc.createElement("Name");
                                name.setAttribute("className", "java.lang.String");
                                name.setTextContent("complexity");
                                feature.appendChild(name);
                                Element value = doc.createElement("Value");
                                value.setAttribute("className", "java.lang.String");
                                value.setTextContent(Double.toString(complexity));
//                                value.setTextContent("0.85");
                                feature.appendChild(value);
                                

                                asde.appendChild(pronounElement);
                                minNewId++;
                            }

                        }

                    } catch(Exception ex){
                        //weka
                        Logger.getLogger(SpanishPronominalAnaphora.class.getName()).log(Level.SEVERE, null, ex);
                        throw new AnaphoraResolutionException("Error 5: Problem with external machine learning tool, weka: Incorrect value features",ex);

                    }
                } 
            }
            // FIN - se repite para cada tipo de pronombre
            //modificar el gDocument para incluir las anotaciones:
            //tengamos ya algun Node o no, los vamos a añadir todos
            //teniendo en cuenta la salida de freeling para saber donde ponerlos
            try {
                
            FileReader fr = new FileReader (outputFreeling);
            BufferedReader br = new BufferedReader(fr);
            String text = textWithNodesElement.getTextContent();
            //String [] splitted = text.split("\\s+");
            //StringBuilder newText = new StringBuilder();
            textWithNodesElement.setAttribute("xml:space", "preserve");
            //si hemos añadido alguna anotación, borramos el texto completo.
            if(!node_offsets.isEmpty()){
                
                //añadimos los offsets que existan previamente
                NodeList previousNodes = XMLUtils.getElementsNamed(textWithNodesElement, "Node");

                for(int nodes=0; nodes< previousNodes.getLength(); nodes++){
                    Element n = (Element) previousNodes.item(nodes);
                    node_offsets.add(Integer.parseInt(n.getAttribute("id")));
                }
                
                //borramos el contenido previo en la sección textwithnodeselement 
                textWithNodesElement.setTextContent("");
                        
                int start_offset = 0; boolean inicio = true;
                for(Integer offset: node_offsets){
                    if(start_offset==0 && inicio || start_offset>=0 && start_offset!=offset){
                        inicio = false;
                    if(start_offset >=0 && offset <text.length()){
                        String aux;
                        if(offset>0)
                            aux = text.substring(start_offset, offset);
                        else 
                            aux = text.substring(start_offset);
                        textWithNodesElement.appendChild(doc.createTextNode(aux));
                        Element n = doc.createElement("Node");
                        n.setAttribute("id", offset+"");
                        textWithNodesElement.appendChild(n);
                        start_offset = offset;
                    }
                    }

                    //System.out.println("El texto ahora es: "+ textWithNodesElement.getTextContent() + "---");
                    //System.out.println("----------------------------");
                }

                //añadimos el último fragmento de texto
                if (start_offset < text.length() && start_offset > 0){
                    textWithNodesElement.appendChild(doc.createTextNode(text.substring(start_offset)));
                }
            }
            } catch(Exception ex){
                Logger.getLogger(SpanishPronominalAnaphora.class.getName()).log(Level.SEVERE, null, ex);
                throw new AnaphoraResolutionException("Error 2: Incorrect offsets generation",ex);
            }
            
        try{
            outputFreeling.delete(); //ahora que ya no necesito la salida de freeling, borro el fichero

            File tmpFile = File.createTempFile("anaphoraresolution", "xml");
            XMLUtils.saveXML(doc, tmpFile.getAbsolutePath(), "UTF-8");

            BufferedReader brr = new BufferedReader(new FileReader(tmpFile));
            String line;
            StringBuilder sb = new StringBuilder();

            while((line=brr.readLine())!= null){
                sb.append(line); sb.append("\n");
            }
            newDoc = sb.toString();
            tmpFile.delete();
               
               
            
        } catch (Exception ex) {
            Logger.getLogger(SpanishPronominalAnaphora.class.getName()).log(Level.SEVERE, null, ex);
            throw new AnaphoraResolutionException("Error 7: Problem generating output document",ex);

        } 
        
        return newDoc;
        
    }
    
//    private static HashMap<Integer,ArrayList<Antecedent>> detectAntecedentsInSentence(int num_sentence, AnaphoricExpresion pronoun, File ffreeling, String original) throws Exception{
//         FileReader fr = null;
//         BufferedReader br = null;
//         HashMap<Integer,ArrayList<Antecedent>> antecedents = null;
//         try {
//            
//            fr = new FileReader (ffreeling);
//            br = new BufferedReader(fr);
//                    
//            // Lectura del fichero
//            String linea;
//            String patronOracion = "\\+grup-verb_\\[";
//            String patronOracion2 = "S_\\[";
//            String patronInicioSN = "\\s+\\+?grup-nom";
//            int current_sentence = 0;
//            int corchetes = 0;
//            int start_offset = 0, end_offset = 0;
//            
//            Antecedent an = null;
//            antecedents = new HashMap<Integer,ArrayList<Antecedent>>();
//            boolean nucleo = false;
//            boolean contarCorchetes = false;
//            int num_token = 0;
//            boolean lineaAnteriorVacia = false;
//            boolean ignorarToken = false;
//            while((linea=br.readLine())!=null){
//                //para saber la oración por la que voy
//                //para saber que he llegado al final de una oración, busco dos lineas vacias
////                if(linea.isEmpty()){
////                    //System.out.println("Linea Vacia");
////                    if( lineaAnteriorVacia){
////                        //System.out.println("2 Linea Vacia");
////                    //if(linea.matches(patronOracion) ){
////                        current_sentence++;
////                        num_token = 0;
////                    } else 
////                         lineaAnteriorVacia=true;
////                } else {
////                    
////                     lineaAnteriorVacia = false;
////                }
//                if(linea.matches(patronOracion2)){
//                    current_sentence++;
//                    num_token=0;
//                }
//                    
//                
//                //if(num_sentence > 0){ 
//                    //procesar la anterior frase y la actual
//                    if((num_sentence == current_sentence) || (num_sentence-1 == current_sentence)){
//                        if(linea.contains("+(") || linea.contains("(")){
//                            //if(!ignorarToken){
//                                num_token++;
//                                String llinea = linea.substring(linea.indexOf("+(")+2).trim();
//                                if(!linea.contains("+("))
//                                    llinea = linea.substring(linea.indexOf("(")+1).trim();
//                                String [] aux = llinea.split("\\s+");
//                                if(aux[0].contains("_")){
//                                    start_offset = original.indexOf(aux[0].substring(0, aux[0].indexOf("_")), end_offset);
//                                    String [] tokens = aux[0].split("_");
//                                    int tam = 0;
//                                    for(int i=0; i<tokens.length; i++){
//                                        tam += tokens[i].length();
//                                        //if(original.indexOf(tokens[i]+" ")!=-1)
//                                        if(original.substring(start_offset + tam, start_offset + tam +1).equals(" "))
//                                            tam++;
//                                    }
//                                    end_offset = start_offset + tam;
//                                    //System.out.println(aux[0] + " ->" + start_offset + ", " + end_offset);
//                                } else {
//                                    start_offset = original.indexOf(aux[0], end_offset);
//                                    int offset_espacio = original.indexOf(" ", start_offset+1);
//                                    if(offset_espacio>= original.length() || offset_espacio==-1)
//                                        offset_espacio = original.length()-1;
//                                    //System.out.println(aux[0] + " ->" + start_offset + ", " + offset_espacio);
//                                    String o = original.substring(start_offset, offset_espacio);
//                                    if(offset_espacio==start_offset)
//                                        o = original.substring(start_offset);
//                                    //if(o.equals("del") || o.equals("al")) //no va!
//                                    //{    ignorarToken = true;
//                                    //if(start_offset==-1)
//                                    //    start_offset = 0;
//                                    //end_offset = start_offset + o.length();
//                                    //} else {
//                                        end_offset = start_offset + aux[0].length();
//                                    //}
//                                }
//                            //} else {
//                            //    ignorarToken=false;
//                            //}
//                                
//                            if(start_offset == -1 || end_offset ==-1){
//                                throw new Exception("Error 2: Incorrect offsets generation with "+ num_token +"st token " + aux[0] + " in sentence " + current_sentence);
//                            }
//                        }
//                        //if(linea.matches(patronInicioSN) && !contarCorchetes){ 
//                        if(linea.contains("grup-nom") && !contarCorchetes){ 
//                            //a partir de ahora hay que contar el numero de [ que se abren y ] que cierran
//                            //System.out.println("Entro!");
//                            corchetes = 1;
//                            contarCorchetes = true;
//                            an = new Antecedent();
//                            //an.startPosition = start_offset;//num_token+1;
//                        } else {
//                            if(contarCorchetes){
//                                if(linea.endsWith("[")){
//                                    corchetes++;
//                                } else {
//                                    if(linea.endsWith("]")){
//                                        corchetes--;
//                                        if(corchetes==0) { //fin del sn
//                                            contarCorchetes = false;
//                                            an.endPosition = end_offset;
//                                            ArrayList<Antecedent> get = antecedents.get(current_sentence);
//                                            if(get==null){
//                                                get = new ArrayList<Antecedent>();
//                                            } 
//                                            get.add(an);
//                                            antecedents.put(current_sentence, get);
//                                        }
//                                    }
//                                }
//                            }
//                            
//                            if(corchetes >=1){
//                                
//                                if(linea.contains("+n-") || linea.contains("psubj") || linea.contains("w-") || linea.contains("paton")){ //esto no se cumple para los sn compuestos de pronombres.
//                                    nucleo = true;
//                                }
//                                
//                                if(linea.contains("+(")){
//                                    linea = linea.substring(linea.indexOf("+")+1, linea.length()-1);
//                                    if(an!=null){
//                                        an.words.add(linea);
//                                        if(nucleo){
//                                            an.core = linea;
//                                            nucleo = false;
//                                        }
//                                        if(an.startPosition==-1){
//                                            an.startPosition = start_offset;
//                                        }
//                                        
//                                    }
//                                }
//                            
//                            }
//                                
//                            
//                            
//                            
//                        }
//                    }
//                    
//                } 
//                //mirar la frase actual
//            //} 
//             
//    //        //en la propia oracion, miramos solo lo que este antes del pronombre
//    //        int indexPronoun;
//    //        ArrayList<String> antecedents = new ArrayList<String>();
//    //         
//    //        if(sentences.size()==1){ //hemos leido una oración
//    //            if(num_sentence==1){ //entonces solo procesamos la que hemos leido
//    //            String [] infoPronoun = pronoun.split("\t");
//    //            indexPronoun = Integer.parseInt(infoPronoun[0])-1;
//    //            
//    //            for(int i=indexPronoun-1; i>0; i-- ){ 
//    //                //buscamos los sn(el nucleo) y los suj
//    //                //TO-DO: sacar los diferentes sn, ej: el naufragio del submarino nuclear kursk, el naufragio, submarino nuclear kursk
//    //                String [] aux = sentences.get(0).words.get(i).split("\t");
//    //
//    //                if(!aux[1].equals("_"))
//    //                    if(aux[10].equals("sn") || aux[10].equals("suj")){
//    //                        antecedents.add(sentences.get(0).words.get(i));
//    //                    }
//    //            }
//    //            
//    //            }
//    //        } else { //hemos leido más de una oración, 
//    //            //sacamos los antecedentes de la oración que nos indiquen
//    //            if(num_sentence==1){
//    //                String [] infoPronoun = pronoun.split("\t");
//    //                indexPronoun = Integer.parseInt(infoPronoun[0])-1;
//    //            } else {
//    //                indexPronoun = sentences.get(num_sentence).words.size()-1;
//    //            }
//    //
//    //
//    //
//    //            for(int i=indexPronoun-1; i>0; i-- ){ 
//    //                //buscamos los sn(el nucleo) y los suj
//    //                //TO-DO: sacar los diferentes sn, ej: el naufragio del submarino nuclear kursk, el naufragio, submarino nuclear kursk
//    //                String [] aux = sentences.get(num_sentence).words.get(i).split("\t");
//    //                if(!aux[1].equals("_"))
//    //                    if(aux[10].equals("sn") || aux[10].equals("suj")){
//    //                        antecedents.add(sentences.get(num_sentence).words.get(i));
//    //                    }
//    //            }
//    //        }
//            
//            
//           
//        } catch (IOException ex) {
//            Logger.getLogger(SpanishPronominalAnaphora.class.getName()).log(Level.SEVERE, null, ex);
//        } finally{
//                // En el finally cerramos el fichero, para asegurarnos
//                // que se cierra tanto si todo va bien como si salta 
//                // una excepcion.
//                try{                    
//                    if( null != fr ){   
//                    fr.close();     
//                    }                  
//                }catch (Exception e2){ 
//                    e2.printStackTrace();
//                }
//            }
//        
//         return antecedents;
//    }
//    
//    /**
//     * executes freeling in intime and generates an output file with the 
//     * shallow parsing of the input.
//     * @param inputtext string containing the text to analyze.
//     * @return the output file
//     * @throws IOException
//     * @throws InterruptedException 
//     */
//    private File runFreeling(String inputtext) throws IOException, InterruptedException{
//        
//        //Generamos un fichero a partir del texto de entrada
//        File tempFile = File.createTempFile("entrada",".txt");
//        //tempFile.deleteOnExit();
//        BufferedWriter out = new BufferedWriter(new FileWriter(tempFile));
//        out.write(inputtext);
//        out.close();
//        
//        //Generamos un fichero para almacenar la salida del comando
//        File tempFile2 = File.createTempFile("salida",".txt");
//        tempFile2.deleteOnExit();
//        //out = new BufferedWriter(new FileWriter(tempFile2));
//       
//        
//        //Ejecutamos el script que contiene el comando para ejecutar freeling
////        String[] cd = { "/bin/sh", "-c", appPath + "scripts/freeling.sh " + tempFile.getAbsolutePath() };
////        String cd = "freeling.sh " + tempFile.getAbsolutePath();
//        String[] cd = { "/bin/sh", "-c", appPath + "/scripts/freeling.sh " + tempFile.getAbsolutePath() + " " + tempFile2.getAbsolutePath()};
//        Process child  = Runtime.getRuntime().exec(cd, new String[0], new File(appPath + "scripts"));
////        Process child  = Runtime.getRuntime().exec(cd);
//        child.waitFor();
//        
//        //elimino el fichero temporal de entrada porque ya no lo necesito
//        tempFile.delete();
//        
//        //Leemos la salida estándar producida por el comando
//        /*java.io.BufferedReader r = new java.io.BufferedReader(new java.io.InputStreamReader(child.getInputStream()));
//        String s = null;
//        while ((s = r.readLine()) != null) {
//            //System.out.println(s);
//            out.write(s);
//            out.newLine();
//        }
//               
//        out.close();*/
//        
//        //Leememos la salida de error producida por el comando
//        java.io.BufferedReader r2 = new java.io.BufferedReader(new java.io.InputStreamReader(child.getErrorStream()));
//        String s = null;
//        boolean excepcion = false;
//        StringBuilder bferror = new StringBuilder();
//        while ((s = r2.readLine()) != null) {
//            System.err.println(s);
//            excepcion=true;
//            bferror.append(s).append("\n");
//        }
//        
//        child.getOutputStream().close(); 
//        child.getInputStream().close();
//        child.getErrorStream().close();
//        child.destroy();
//        
//        if(excepcion)
//            throw new IOException(bferror.toString());
//        
//        return tempFile2;
//    }
//    
    
    private void detectPronominalAnaphoricExpressions(String tag, String type, File ffreeling, String original) throws Exception {
        ArrayList<AnaphoricExpresion> prons = new ArrayList<AnaphoricExpresion>();
        if(tag.equals("P")){
            int contador = 0;
            
            //buscamos expresiones anaforicas de tipo pronominal
            //en todas la oraciones
            //expresion para buscar los pronombres de un tipo
            //grep "[[:space:]]$tag$type[A-Z0-9]\{6\}[[:space:]]-)$
            //problema: no sé de que oracion es!!!
            //solucion: leer linea a linea el fichero y ejecutar el comando grep (más lento pero me permite saber donde estoy)

            //1. leemos el fichero de salida de freeling linea a linea
            FileReader fr = null;
            BufferedReader br = null;
            int current_sentence = 0;
            int num_token = 0;
            int start_offset=0, end_offset=0;
            String patron = tag + type; 
            String patronOracion = "\\+grup-verb_\\[";
            String patronOracion2 = "S_\\[";
            String lineaAnterior = null;
            boolean lineaAnteriorVacia = false;
            try {
                // Apertura del fichero y creacion de BufferedReader 
                fr = new FileReader (ffreeling);
                br = new BufferedReader(fr);
                boolean primeraOracion = true;
                // Lectura del fichero
                String linea;
                while((linea=br.readLine())!=null){
                    
                    //para saber que he llegado al final de una oración, busco dos lineas vacias
                    //if(linea.isEmpty()){
                        //System.out.println("Linea Vacia");
                        //if( lineaAnteriorVacia){ 
                        if(linea.matches(patronOracion2)){
                            //System.out.println("2 Linea Vacia");
                            num_token = 0;
                            if(primeraOracion){
                                primeraOracion = false;
                            } else {
                                ArrayList<AnaphoricExpresion> get = pronous.get(current_sentence);
                                if(get==null)
                                    get = new ArrayList<AnaphoricExpresion>();
                                get.addAll(prons);
                                pronous.put(current_sentence, get);
                                prons = new ArrayList<AnaphoricExpresion>();
                            }
                            current_sentence++;
                        } 
//                        else 
//                            lineaAnteriorVacia=true;
//                    } else {
//
//                        lineaAnteriorVacia = false;
//                    }
                                            
                    if(linea.contains("+(")){
                        num_token++;
                        String llinea = linea.substring(linea.indexOf("+(")+2);
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
                                    
                        } else{
                            start_offset = original.indexOf(aux[0], end_offset);
                            end_offset = start_offset + aux[0].length();  
                        }
                        //original = original.substring(end_offset);
                        
                    
                        //if(llinea.contains(tag+type)){
                        if(aux.length == 4 && aux[2].startsWith(patron)){
                       
                            contador++;
                            //linea = linea.substring(linea.indexOf("+"));
                            //String [] aux = linea.split("\\s+");
                            lineaAnterior = lineaAnterior.trim();
                            if(lineaAnterior.endsWith("_[")){
                                if(lineaAnterior.startsWith("+"))
                                    lineaAnterior = lineaAnterior.substring(lineaAnterior.indexOf("+"));
                                
                                prons.add(new AnaphoricExpresion(linea, start_offset, end_offset, lineaAnterior));
                                //System.out.println(linea + "en oración " + current_sentence);
                            }
                        }
                        
                        if(start_offset == -1 || end_offset ==-1){
                            throw new Exception("Error 2: Incorrect offsets generation with "+ num_token +"st token " + aux[0] + " in sentence " + current_sentence);
                        }
                    }
                    
                    lineaAnterior = linea;
                }
                
                //metemos la última oración
                ArrayList<AnaphoricExpresion> get = pronous.get(current_sentence);
                if(get==null)
                    get = new ArrayList<AnaphoricExpresion>();
                get.addAll(prons);
                pronous.put(current_sentence, get);
                current_sentence++;

            //int current_sentence = 0;
            //for(String w: sentences.get(lastIndex).words){
            //    String cols[] = w.split("\t");
            //    String[] fpron = cols[6].split("\\|");
        
              //  if(cols[4].equals(tag) && cols[6].startsWith("postype=personal")){//hemos encontrado un pronombre - se podria usar cols[5]
                    
                //    prons.add(w);
                //    System.out.println("#Expresion anaforica encontrada personal# " + cols[1]);
                //}
            //}
            
            }
            catch(Exception e){
                e.printStackTrace();
            }finally{
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

            //System.out.println(tag+type + " " + contador);

        }
     
      
        
        //return prons;
    }

    private String getSemEvalMapping(String syntactic_function) {
        
        if(syntactic_function.contains("+"))
            syntactic_function = syntactic_function.substring(syntactic_function.indexOf("+"));
        if(syntactic_function.contains("_["))
            syntactic_function = syntactic_function.substring(0,syntactic_function.indexOf("_["));
        
        if(syntactic_function.startsWith("a-a"))
            return "sa";
        if (syntactic_function.startsWith("a-"))
            return "a";
        
        if(syntactic_function.equals("sadv") || syntactic_function.equals("coord") 
                || syntactic_function.equals("prep") 
                || syntactic_function.equals("relatiu"))
            return syntactic_function;
        
        if(syntactic_function.equals("cuantif") || 
                syntactic_function.equals("adv-interrog") || 
                syntactic_function.equals("neg"))
            return "r";
        
        if(syntactic_function.startsWith("conj"))
            return "conj";
        
        if (syntactic_function.startsWith("grup-complex-spec-") || 
                syntactic_function.startsWith("j-") || 
                syntactic_function.startsWith("espec-ms-E") || 
                syntactic_function.startsWith("dem-") || 
                syntactic_function.startsWith("espec-") || 
                syntactic_function.startsWith("exc-") || 
                syntactic_function.startsWith("indef-") || 
                syntactic_function.startsWith("int-") || 
                syntactic_function.startsWith("quant-") || 
                syntactic_function.startsWith("pos-"))
            return "d";
        
        if(syntactic_function.startsWith("grup-nom"))
            return "grup.nom";
        
        if(syntactic_function.startsWith("n-") || 
                 syntactic_function.startsWith("nom-"))
            return "grup.nom";
        
        if(syntactic_function.startsWith("sn"))
            return "sn";
        
        if(syntactic_function.startsWith("w-"))
            return "n";
        
        if(syntactic_function.startsWith("num"))
            return "z";
        
        if(syntactic_function.startsWith("grup-sp") ||
                syntactic_function.startsWith("sp-") || 
                syntactic_function.startsWith("prepc-ms"))
            return "prep";
        
        if(syntactic_function.startsWith("prel") || 
                syntactic_function.startsWith("quien") || 
                syntactic_function.startsWith("cual") || 
                syntactic_function.startsWith("quien")|| 
                syntactic_function.startsWith("quien") || syntactic_function.startsWith("subord-rel"))
            return "relatiu";
        
        if(syntactic_function.startsWith("paton") || 
                syntactic_function.startsWith("pdem") || 
                syntactic_function.startsWith("pindef") || 
                syntactic_function.startsWith("pinterrog") ||
                syntactic_function.startsWith("pnum") || 
                syntactic_function.startsWith("ptonic") || 
                syntactic_function.startsWith("pposs")|| 
                syntactic_function.startsWith("cuyo") ||
                syntactic_function.startsWith("pron"))
            return "p";
        
        if(syntactic_function.startsWith("psubj"))
            return "suj";
        
        
         if(syntactic_function.endsWith("aux") || 
                syntactic_function.endsWith("-ser") || 
                syntactic_function.equals("grup-verb") || 
                syntactic_function.equals("v-hacer-3p"))
            return "v";
         
         if( syntactic_function.endsWith("pas") || 
                syntactic_function.endsWith("pass") || 
                syntactic_function.equals("vser"))
             return "pass";
         
         if( syntactic_function.startsWith("forma-") ||
                syntactic_function.startsWith("ger") ||
                syntactic_function.endsWith("inf") ||
                syntactic_function.startsWith("parti"))
             return "S";
         
        return null;
        
    }

    public String resolveAnaphora(String text, File outputFreeling, int nextID, Element as, Document doc) throws AnaphoraResolutionException {
        String newDoc = text;
        Element documentElement = null;
        Element textWithNodesElement = null;
        Element asde = as;
        int minNewId = nextID;
        
        try {
            documentElement = doc.getDocumentElement();
            textWithNodesElement = XMLUtils.getElementNamed(documentElement, "TextWithNodes");
            
        } catch(Exception e){
            throw new AnaphoraResolutionException("Error 6: Problem processing input document due to parsing problems",e); //error parsing gate format
        }
                   
        //1. partir en frases
        //numero de frases: no va
        //sentencesSize = getSentencesCount(outputFreeling.getAbsolutePath());

        //2.1 detectar pronombres de todas las frases - se repite para cada tipo de pronombre
        pronous =  new HashMap<Integer, ArrayList<AnaphoricExpresion>>();
        try {
            detectPronominalAnaphoricExpressions("P", "P", outputFreeling,textWithNodesElement.getTextContent());
            detectPronominalAnaphoricExpressions("P", "D", outputFreeling,textWithNodesElement.getTextContent());
            detectPronominalAnaphoricExpressions("P", "I", outputFreeling,textWithNodesElement.getTextContent());
            detectPronominalAnaphoricExpressions("P", "T", outputFreeling,textWithNodesElement.getTextContent());
            detectPronominalAnaphoricExpressions("P", "R", outputFreeling,textWithNodesElement.getTextContent());

        } catch (Exception ex) {
            Logger.getLogger(SpanishPronominalAnaphora.class.getName()).log(Level.SEVERE, null, ex);
            throw new AnaphoraResolutionException("Error 3: Problem with external NLP tool: freeling",ex);
        }
        
        
            //ArrayList<Integer> node_offsets = new ArrayList<Integer>();
            TreeSet<Integer> node_offsets = new TreeSet<Integer>();
            //2. para cada frase:
            for(Integer i : pronous.keySet()){
                //2.2 para cada pronombre
                ArrayList<AnaphoricExpresion> prons = pronous.get(i);
                boolean continuar = true;
                for(int j=0; j<prons.size(); j++){
                    AnaphoricExpresion pronoun = prons.get(j);
                    //annotatePronoun(pronoun, i, outputFreeling, textWithNodesElement.getTextContent()); //, doc, asa, asde);
                    //2.2.2 Generar características ML
                    String llinea = pronoun.word.substring(pronoun.word.indexOf("+("));
                    String [] aux = llinea.split("\\s+");
                    try{
                        Instance ins;
                        continuar = true;
                        if(aux[2].charAt(1)=='P'){
                            ins = new Instance(15);
                            ins.setDataset(dpersonal);
                            ins.setMissing(14);
                        } else {
                            ins = new Instance(16);
                            ins.setMissing(15);
                            switch(aux[2].charAt(1)){
                                case 'D': ins.setDataset(ddemonstrative);
                                        break;
                                case 'I': ins.setDataset(dindefinite); break;
                                case 'T' : ins.setDataset(dinterrogative); break;
                                case 'R' : ins.setDataset(drelative);    break;
                                default : continuar = false;
                                            break;
                            }
                        }

                        if(continuar){
                            //características del pronombre
                            Character persona = aux[2].charAt(2);
                            if (persona.equals('0'))
                                ins.setMissing(3);
                            else
                                ins.setValue(3, persona.toString()); //persona

                            String genero = Character.toString(aux[2].charAt(3));
                            if (genero.equals("0"))
                                ins.setMissing(2);
                            else{
                                genero = (genero.equals("N"))? "c":genero.toLowerCase();
                                //System.out.println("Pronombre " + llinea + " -> genero = " + genero);
                                ins.setValue(2, genero); //genero
                            }

                            String numero = Character.toString(aux[2].charAt(4));
                            if(numero.equals("0"))
                                ins.setMissing(1);
                            else {
                                numero = (numero.equals("N"))? "C":numero;
                                ins.setValue(1, numero.toLowerCase()); //numero
                            }

                            String sf = getSemEvalMapping(pronoun.syntactic_function);
                            if(sf!=null)
                                ins.setValue(0, sf); //funcion sintactica
                            else
                                ins.setMissing(0);

                            //2.2.1 detectar sus posibles antecedentes.
                            HashMap<Integer,ArrayList<Antecedent>> antecedents = null;
                            try {
                                antecedents = detectAntecedentsInSentence(i,outputFreeling, textWithNodesElement.getTextContent());
                            }catch(Exception ex){
                                throw new AnaphoraResolutionException("Error 5: Problem with external machine learning tool, weka: Incorrect value features",ex);
                            }

                            //System.out.println("Resolviendo el pronombre " + pronoun.word + "("+ pronoun.position + " - "+ pronoun.endPosition +")...." + antecedents.size());
                            for(int oracion: antecedents.keySet()){
                                //System.out.println("Posibles antecedentes en oracion "+ oracion+ ":");
                                for(Antecedent ant : antecedents.get(oracion)){
                                    //System.out.println("+ " + ant.core + " (" + ant.startPosition + " - " + ant.endPosition + ")");
                                    if(pronoun.endPosition > ant.startPosition ){ //tiene que estar antes del pronombre
                                        //2.2.2 Generar características ML del antecedente
                                        
                                        if(ant.core!=null){
                                                String [] aux2 = ant.core.split("\\s+");
                                                Attribute token = ins.attribute(4);
                                                boolean existToken = token.indexOfValue(aux2[0])!=-1; //conozco este token si su índice no es -1
                                                if(!existToken)
                                                    ins.setMissing(4); //palabra: es desconocido en entrenamiento
                                                else
                                                    ins.setValue(token, aux2[0]);

                                                Attribute lemma = ins.attribute(5);
                                                boolean existLemma = lemma.indexOfValue(aux2[2])!=-1;
                                                if(!existLemma)
                                                    ins.setMissing(5); //lema: es desconocido en entrenamiento
                                                else
                                                    ins.setValue(lemma, aux2[1]);
                                                
                                                if('N'==aux2[2].charAt(0)){
                                                    String numero2 = Character.toString(aux2[2].charAt(3));
                                                    numero2 = (numero2.equals("N")|| numero2.equals("0"))? "c":numero2.toLowerCase();
                                                    ins.setValue(6, numero2); //numero
                                                    String genero2 = Character.toString(aux2[2].charAt(2));
                                                    genero2 = (genero2.equals("0"))? "c":genero2.toLowerCase();
                                                    ins.setValue(7, genero2); //genero
                                                    /*Character persona2 = aux2[2].charAt(1);
                                                    if(persona2.equals('0'))
                                                        ins.setValue(8, "3"); //persona
                                                    else
                                                        ins.setValue(8, persona2.toString()); //persona
                                                */
                                                    ins.setMissing(8); //los nombres no tienen persona
                                                    if(aux2[2].charAt(1)!='P'){
                                                        //tenemos en cuenta la en del nombre
                                                        String ne_nombre = aux2[2].substring(5, 6);
                                                        //other,org,loc,person,date,number
                                                        if(ne_nombre.equals("SP"))
                                                                ne_nombre = "person";
                                                        else if(ne_nombre.startsWith("G"))
                                                            ne_nombre = "loc";
                                                        else if(ne_nombre.startsWith("O"))
                                                            ne_nombre = "org";
                                                        else ne_nombre ="other";
                                                        Attribute ne = ins.attribute(9);
                                                        if(ne.indexOfValue(ne_nombre)!=-1)
                                                            ins.setValue(9, ne_nombre);
                                                        else
                                                            ins.setMissing(ne);
                                                    }

                                                    //2.2.2 Generar características ML que relacionan a ambos
                                                    int dist = ant.startPosition - pronoun.position;
                                                    if(i>oracion)
                                                        dist = ant.startPosition + pronoun.position;
                                                    if(aux[2].charAt(1)=='P'){
                                                        ins.setValue(9, dist);
                                                        ins.setValue(10, (i==oracion)? 1: 0);
                                                        ins.setValue(11, (numero.equals(numero2))? 2: 0);
                                                        ins.setValue(12, (genero.equals(genero2))? 2: 0);
                                                        ins.setValue(13, 0);
                                                    } else{
                                                        ins.setValue(10, dist);
                                                        ins.setValue(11, (i==oracion)? 1: 0);
                                                        ins.setValue(12, (numero.equals(numero2))? 2: 0);
                                                        ins.setValue(13, (genero.equals(genero2))? 2: 0);
                                                        ins.setValue(14, 0);
                                                    }



                                                    //2.2.3 Obtener la clasificación con ML según el tipo de pronombre
                                                    double[] res;
                                                    switch(aux[2].charAt(1)){
                                                        case 'P':
                                                            res = cpersonal.distributionForInstance(ins);
                                                            break;
                                                        case 'D':
                                                            res = cdemonstrative.distributionForInstance(ins);
                                                            break;
                                                        case 'I':  res = cindefinite.distributionForInstance(ins);
                                                            break;
                                                        case 'T': res = cinterrogative.distributionForInstance(ins); break;
                                                        case 'R': res = crelative.distributionForInstance(ins); break;
                                                        default:
                                                            res = new double [] {0,0};
                                                    }
                                                    //*** ¿qué pasa si hay varios que la resuelven? Eso no lo puedo controlar en el entrenamiento. Aquí me quedaría con el último
                                                    if(res[0]< res[1]){
                                                        ant.confidence = res[1]; 
                                                        pronoun.antecedentsSet.add(ant); //aunque no tenga mayor probabilidad, me lo guardo
                                                        //si he encontrado uno con mayor probabilidad me lo guardo
                                                        if(pronoun.antecedent==null || (pronoun.antecedent!=null && pronoun.antecedent.confidence <= res[1]) ){
                                                            pronoun.antecedent = ant;
                                                            prons.set(j,pronoun);
                                                            pronous.put(i, prons);
                                                            //System.out.print("*");
                                                        } 
                                                    }  
                                                    //System.out.println("Probabilidad Si_ser_antecedente: " + res[1]);
                                                }
                                        }

                                    }
                                }
                            }

                            //añadimos al xml el resultado de ml

                            /*** añadir antecedenteS ***/
                            if(pronoun.antecedentsSet!=null && !pronoun.antecedentsSet.isEmpty()){
                                //if(pronoun.antecedent!=null){
                                Collections.sort(pronoun.antecedentsSet);
                                Iterator<Antecedent> iterator = pronoun.getUniqueAntecedents().iterator(); // pronoun.antecedentsSet.iterator();
                                StringBuilder idsAntecedents = new StringBuilder();
                                StringBuilder startNodeAntecedents = new StringBuilder();
                                StringBuilder endNodeAntecedents = new StringBuilder(); 
                                StringBuilder confidenceAntecedents = new StringBuilder();
                                StringBuilder chain = new StringBuilder();
                                while(iterator.hasNext()){ 
                                    Antecedent next = iterator.next();
                                    
                                    String idAntecedente = null;
                                    if(!node_offsets.contains(next.startPosition) && !node_offsets.contains(next.endPosition)){
                                        Element antecedentElement = doc.createElement("Annotation");
                                        idAntecedente = Integer.toString(minNewId);
                                        
                                        antecedentElement.setAttribute("Id", minNewId+"");
                                        antecedentElement.setAttribute("StartNode", next.startPosition+""); 
                                        if(next.startPosition==-1)
                                            node_offsets.add(0);
                                        else 
                                            node_offsets.add(next.startPosition);
                                        antecedentElement.setAttribute("EndNode", next.endPosition+""); 
                                        node_offsets.add(next.endPosition);
                                        antecedentElement.setAttribute("Type", "DiscourseEntity");
                                        asde.appendChild(antecedentElement); //"Discourse Entity markups");
                                        minNewId++;
                                    } //sino es que este antecedente ya esta marcado pero 
                                    // tengo que saber su id para no liarla
                                    else {
                                        NodeList annotations = XMLUtils.getElementsNamed(asde, "Annotation");

                                        boolean enc = false;

                                        for(int indice=0; indice< annotations.getLength() && !enc; indice++){
                                            Element item = (Element) annotations.item(indice);
                                            Integer startp = Integer.parseInt(item.getAttribute("StartNode"));
                                            Integer endp = Integer.parseInt(item.getAttribute("EndNode"));
                                            if(startp.equals(next.startPosition) && endp.equals(next.endPosition)){
                                                idAntecedente = item.getAttribute("Id");
                                                enc = true;
                                            }
                                        }

                                        if (!enc){
                                            System.err.println("¡OJO! POSIBLE BUG: No se encuentra la anotación de " + textWithNodesElement.getTextContent().substring(next.startPosition, next.endPosition) + " en la posición " + next.startPosition +"," + next.endPosition);
                                        }

                                    }
                                    idsAntecedents.append(idAntecedente).append("|");
                                    startNodeAntecedents.append(next.startPosition).append("|");
                                    endNodeAntecedents.append(next.endPosition).append("|");
                                    confidenceAntecedents.append(next.confidence).append("|");
                                    chain.append(textWithNodesElement.getTextContent().substring(next.startPosition, next.endPosition)).append('|');
                                    
                                }
                                
                                /*** añadir pronombre ***/
                                Element pronounElement = doc.createElement("Annotation");
                                pronounElement.setAttribute("Id", minNewId+"");
                                pronounElement.setAttribute("StartNode", pronoun.position+"");
                                node_offsets.add(pronoun.position);
                                pronounElement.setAttribute("EndNode", pronoun.endPosition+""); 
                                node_offsets.add(pronoun.endPosition);
                                pronounElement.setAttribute("Type", "PronounAnaphora");
    //                            asa.appendChild(pronounElement); //Pronouns
                                asde.appendChild(pronounElement);
                                
                                Element feature = doc.createElement("Feature");
                                pronounElement.appendChild(feature);
                                Element name = doc.createElement("Name");
                                name.setAttribute("className", "java.lang.String");
                                name.setTextContent("complexity");
                                feature.appendChild(name);
                                Element value = doc.createElement("Value");
                                value.setAttribute("className", "java.lang.String");
                                value.setTextContent(Double.toString(complexity));
//                                value.setTextContent("0.85");
                                feature.appendChild(value);

                                /*** añadir todos la info de los antecedentes de mayor a menor confidence y con una confidence > 0.5***/
                                feature = doc.createElement("Feature");
                                pronounElement.appendChild(feature);
                                name = doc.createElement("Name");
                                name.setAttribute("className", "java.lang.String");
                                name.setTextContent("StartNodeAntecedent");
                                feature.appendChild(name);
                                value = doc.createElement("Value");
                                value.setAttribute("className", "java.lang.String");
//                                value.setTextContent(pronoun.antecedent.startPosition+"");
                                value.setTextContent(startNodeAntecedents.substring(0, startNodeAntecedents.length()-1)); //quitamos el último |
                                feature.appendChild(value);

                                feature = doc.createElement("Feature");
                                pronounElement.appendChild(feature);
                                name = doc.createElement("Name");
                                name.setAttribute("className", "java.lang.String");
                                name.setTextContent("EndNodeAntecedent");
                                feature.appendChild(name);
                                value = doc.createElement("Value");
                                value.setAttribute("className", "java.lang.String");
//                                value.setTextContent(pronoun.antecedent.endPosition+"");
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
//                                value.setTextContent(pronoun.antecedent.confidence+"");
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
//                                value.setTextContent(idAntecedente);
                                value.setTextContent(idsAntecedents.substring(0, idsAntecedents.length()-1)); //quitamos el último |
                                feature.appendChild(value);
                                
                                feature = doc.createElement("Feature");
                                pronounElement.appendChild(feature);
                                name = doc.createElement("Name");
                                name.setAttribute("className", "java.lang.String");
                                name.setTextContent("chain");
                                feature.appendChild(name);
                                value = doc.createElement("Value");
                                value.setAttribute("className", "java.lang.String");
//                                value.setTextContent(idAntecedente);
                                value.setTextContent(chain.substring(0, chain.length()-1)); //quitamos el último |
                                feature.appendChild(value);

                                minNewId++;
                            } else {
                                Element pronounElement = doc.createElement("Annotation");
                                pronounElement.setAttribute("Id", minNewId+"");
                                pronounElement.setAttribute("StartNode", pronoun.position+"");
                                node_offsets.add(pronoun.position);
                                pronounElement.setAttribute("EndNode", pronoun.endPosition+""); 
                                node_offsets.add(pronoun.endPosition);
                                pronounElement.setAttribute("Type", "PronounAnaphora");
    //                            asa.appendChild(pronounElement); //Pronouns
                                
                                Element feature = doc.createElement("Feature");
                                pronounElement.appendChild(feature);
                                Element name = doc.createElement("Name");
                                name.setAttribute("className", "java.lang.String");
                                name.setTextContent("complexity");
                                feature.appendChild(name);
                                Element value = doc.createElement("Value");
                                value.setAttribute("className", "java.lang.String");
                                value.setTextContent(Double.toString(complexity));
//                                value.setTextContent("0.85");
                                feature.appendChild(value);
                                

                                asde.appendChild(pronounElement);
                                minNewId++;
                            }

                        }

                    } catch(Exception ex){
                        //weka
                        Logger.getLogger(SpanishPronominalAnaphora.class.getName()).log(Level.SEVERE, null, ex);
                        throw new AnaphoraResolutionException("Error 5: Problem with external machine learning tool, weka: Incorrect value features",ex);

                    }
                } 
            }
            // FIN - se repite para cada tipo de pronombre
            //modificar el gDocument para incluir las anotaciones:
            //tengamos ya algun Node o no, los vamos a añadir todos
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
            
            
//            try {
//                
//            FileReader fr = new FileReader (outputFreeling);
//            BufferedReader br = new BufferedReader(fr);
//            String text = textWithNodesElement.getTextContent();
//            //String [] splitted = text.split("\\s+");
//            //StringBuilder newText = new StringBuilder();
//            textWithNodesElement.setAttribute("xml:space", "preserve");
//            //si hemos añadido alguna anotación, borramos el texto completo.
//            if(!node_offsets.isEmpty()){
//                
//                //añadimos los offsets que existan previamente
//                NodeList previousNodes = XMLUtils.getElementsNamed(textWithNodesElement, "Node");
//
//                for(int nodes=0; nodes< previousNodes.getLength(); nodes++){
//                    Element n = (Element) previousNodes.item(nodes);
//                    node_offsets.add(Integer.parseInt(n.getAttribute("id")));
//                }
//                
//                //borramos el contenido previo en la sección textwithnodeselement 
//                textWithNodesElement.setTextContent("");
//                        
//                int start_offset = 0; boolean inicio = true;
//                for(Integer offset: node_offsets){
//                    if(start_offset==0 && inicio || start_offset>=0 && start_offset!=offset){
//                        inicio = false;
//                    if(start_offset >=0 && offset <text.length()){
//                        String aux;
//                        if(offset>0)
//                            aux = text.substring(start_offset, offset);
//                        else 
//                            aux = text.substring(start_offset);
//                        textWithNodesElement.appendChild(doc.createTextNode(aux));
//                        Element n = doc.createElement("Node");
//                        n.setAttribute("id", offset+"");
//                        textWithNodesElement.appendChild(n);
//                        start_offset = offset;
//                    }
//                    }
//
//                    //System.out.println("El texto ahora es: "+ textWithNodesElement.getTextContent() + "---");
//                    //System.out.println("----------------------------");
//                }
//
//                //añadimos el último fragmento de texto
//                if (start_offset < text.length() && start_offset > 0){
//                    textWithNodesElement.appendChild(doc.createTextNode(text.substring(start_offset)));
//                }
//            }
//            } catch(Exception ex){
//                Logger.getLogger(SpanishPronominalAnaphora.class.getName()).log(Level.SEVERE, null, ex);
//                throw new AnaphoraResolutionException("Error 2: Incorrect offsets generation",ex);
//            }
//            
//        try{
//            outputFreeling.delete(); //ahora que ya no necesito la salida de freeling, borro el fichero
//
//            File tmpFile = File.createTempFile("anaphoraresolution", "xml");
//            XMLUtils.saveXML(doc, tmpFile.getAbsolutePath(), "UTF-8");
//
//            BufferedReader brr = new BufferedReader(new FileReader(tmpFile));
//            String line;
//            StringBuilder sb = new StringBuilder();
//
//            while((line=brr.readLine())!= null){
//                sb.append(line); sb.append("\n");
//            }
//            newDoc = sb.toString();
//            tmpFile.delete();
//               
//               
//            
//        } catch (Exception ex) {
//            Logger.getLogger(SpanishPronominalAnaphora.class.getName()).log(Level.SEVERE, null, ex);
//            throw new AnaphoraResolutionException("Error 7: Problem generating output document",ex);
//
//        } 
        
        return newDoc;
    }

    public String resolveAnaphora(String text, File outputFreeling, int nextID, Element as, Document doc, Boolean allAlternatives, Threshold minConfidence) throws AnaphoraResolutionException {
        String newDoc = text;
        Element documentElement = null;
        Element textWithNodesElement = null;
        Element asde = as;
        int minNewId = nextID;
        
        try {
            documentElement = doc.getDocumentElement();
            textWithNodesElement = XMLUtils.getElementNamed(documentElement, "TextWithNodes");
            
        } catch(Exception e){
            throw new AnaphoraResolutionException("Error 6: Problem processing input document due to parsing problems",e); //error parsing gate format
        }
                   
        //1. partir en frases
        //numero de frases: no va
        //sentencesSize = getSentencesCount(outputFreeling.getAbsolutePath());

        //2.1 detectar pronombres de todas las frases - se repite para cada tipo de pronombre
        pronous =  new HashMap<Integer, ArrayList<AnaphoricExpresion>>();
        try {
            detectPronominalAnaphoricExpressions("P", "P", outputFreeling,textWithNodesElement.getTextContent());
            detectPronominalAnaphoricExpressions("P", "D", outputFreeling,textWithNodesElement.getTextContent());
            detectPronominalAnaphoricExpressions("P", "I", outputFreeling,textWithNodesElement.getTextContent());
            detectPronominalAnaphoricExpressions("P", "T", outputFreeling,textWithNodesElement.getTextContent());
            detectPronominalAnaphoricExpressions("P", "R", outputFreeling,textWithNodesElement.getTextContent());

        } catch (Exception ex) {
            Logger.getLogger(SpanishPronominalAnaphora.class.getName()).log(Level.SEVERE, null, ex);
            throw new AnaphoraResolutionException("Error 3: Problem with external NLP tool: freeling",ex);
        }
        
        
            //ArrayList<Integer> node_offsets = new ArrayList<Integer>();
            TreeSet<Integer> node_offsets = new TreeSet<Integer>();
            //2. para cada frase:
            for(Integer i : pronous.keySet()){
                //2.2 para cada pronombre
                ArrayList<AnaphoricExpresion> prons = pronous.get(i);
                boolean continuar = true;
                for(int j=0; j<prons.size(); j++){
                    AnaphoricExpresion pronoun = prons.get(j);
                    //annotatePronoun(pronoun, i, outputFreeling, textWithNodesElement.getTextContent()); //, doc, asa, asde);
                    //2.2.2 Generar características ML
                    String llinea = pronoun.word.substring(pronoun.word.indexOf("+("));
                    String [] aux = llinea.split("\\s+");
                    try{
                        Instance ins;
                        continuar = true;
                        if(aux[2].charAt(1)=='P'){
                            ins = new Instance(15);
                            ins.setDataset(dpersonal);
                            ins.setMissing(14);
                        } else {
                            ins = new Instance(16);
                            ins.setMissing(15);
                            switch(aux[2].charAt(1)){
                                case 'D': ins.setDataset(ddemonstrative);
                                        break;
                                case 'I': ins.setDataset(dindefinite); break;
                                case 'T' : ins.setDataset(dinterrogative); break;
                                case 'R' : ins.setDataset(drelative);    break;
                                default : continuar = false;
                                            break;
                            }
                        }

                        if(continuar){
                            //características del pronombre
                            Character persona = aux[2].charAt(2);
                            if (persona.equals('0'))
                                ins.setMissing(3);
                            else
                                ins.setValue(3, persona.toString()); //persona

                            String genero = Character.toString(aux[2].charAt(3));
                            if (genero.equals("0"))
                                ins.setMissing(2);
                            else{
                                genero = (genero.equals("N"))? "c":genero.toLowerCase();
                                //System.out.println("Pronombre " + llinea + " -> genero = " + genero);
                                ins.setValue(2, genero); //genero
                            }

                            String numero = Character.toString(aux[2].charAt(4));
                            if(numero.equals("0"))
                                ins.setMissing(1);
                            else {
                                numero = (numero.equals("N"))? "C":numero;
                                ins.setValue(1, numero.toLowerCase()); //numero
                            }

                            String sf = getSemEvalMapping(pronoun.syntactic_function);
                            if(sf!=null)
                                ins.setValue(0, sf); //funcion sintactica
                            else
                                ins.setMissing(0);

                            //2.2.1 detectar sus posibles antecedentes.
                            HashMap<Integer,ArrayList<Antecedent>> antecedents = null;
                            try {
                                antecedents = detectAntecedentsInSentence(i,outputFreeling, textWithNodesElement.getTextContent());
                            }catch(Exception ex){
                                throw new AnaphoraResolutionException("Error 5: Problem with external machine learning tool, weka: Incorrect value features",ex);
                            }

                            //System.out.println("Resolviendo el pronombre " + pronoun.word + "("+ pronoun.position + " - "+ pronoun.endPosition +")...." + antecedents.size());
                            for(int oracion: antecedents.keySet()){
                                //System.out.println("Posibles antecedentes en oracion "+ oracion+ ":");
                                for(Antecedent ant : antecedents.get(oracion)){
                                    //System.out.println("+ " + ant.core + " (" + ant.startPosition + " - " + ant.endPosition + ")");
                                    if(pronoun.endPosition > ant.startPosition ){ //tiene que estar antes del pronombre
                                        //2.2.2 Generar características ML del antecedente
                                        
                                        if(ant.core!=null){
                                                String [] aux2 = ant.core.split("\\s+");
                                                Attribute token = ins.attribute(4);
                                                boolean existToken = token.indexOfValue(aux2[0])!=-1; //conozco este token si su índice no es -1
                                                if(!existToken)
                                                    ins.setMissing(4); //palabra: es desconocido en entrenamiento
                                                else
                                                    ins.setValue(token, aux2[0]);

                                                Attribute lemma = ins.attribute(5);
                                                boolean existLemma = lemma.indexOfValue(aux2[2])!=-1;
                                                if(!existLemma)
                                                    ins.setMissing(5); //lema: es desconocido en entrenamiento
                                                else
                                                    ins.setValue(lemma, aux2[1]);
                                                
                                                if('N'==aux2[2].charAt(0)){
                                                    String numero2 = Character.toString(aux2[2].charAt(3));
                                                    numero2 = (numero2.equals("N")|| numero2.equals("0"))? "c":numero2.toLowerCase();
                                                    ins.setValue(6, numero2); //numero
                                                    String genero2 = Character.toString(aux2[2].charAt(2));
                                                    genero2 = (genero2.equals("0"))? "c":genero2.toLowerCase();
                                                    ins.setValue(7, genero2); //genero
                                                    /*Character persona2 = aux2[2].charAt(1);
                                                    if(persona2.equals('0'))
                                                        ins.setValue(8, "3"); //persona
                                                    else
                                                        ins.setValue(8, persona2.toString()); //persona
                                                */
                                                    ins.setMissing(8); //los nombres no tienen persona
                                                    if(aux2[2].charAt(1)!='P'){
                                                        //tenemos en cuenta la en del nombre
                                                        String ne_nombre = aux2[2].substring(5, 6);
                                                        //other,org,loc,person,date,number
                                                        if(ne_nombre.equals("SP"))
                                                                ne_nombre = "person";
                                                        else if(ne_nombre.startsWith("G"))
                                                            ne_nombre = "loc";
                                                        else if(ne_nombre.startsWith("O"))
                                                            ne_nombre = "org";
                                                        else ne_nombre ="other";
                                                        Attribute ne = ins.attribute(9);
                                                        if(ne.indexOfValue(ne_nombre)!=-1)
                                                            ins.setValue(9, ne_nombre);
                                                        else
                                                            ins.setMissing(ne);
                                                    }

                                                    //2.2.2 Generar características ML que relacionan a ambos
                                                    int dist = ant.startPosition - pronoun.position;
                                                    if(i>oracion)
                                                        dist = ant.startPosition + pronoun.position;
                                                    if(aux[2].charAt(1)=='P'){
                                                        ins.setValue(9, dist);
                                                        ins.setValue(10, (i==oracion)? 1: 0);
                                                        ins.setValue(11, (numero.equals(numero2))? 2: 0);
                                                        ins.setValue(12, (genero.equals(genero2))? 2: 0);
                                                        ins.setValue(13, 0);
                                                    } else{
                                                        ins.setValue(10, dist);
                                                        ins.setValue(11, (i==oracion)? 1: 0);
                                                        ins.setValue(12, (numero.equals(numero2))? 2: 0);
                                                        ins.setValue(13, (genero.equals(genero2))? 2: 0);
                                                        ins.setValue(14, 0);
                                                    }



                                                    //2.2.3 Obtener la clasificación con ML según el tipo de pronombre
                                                    double[] res;
                                                    switch(aux[2].charAt(1)){
                                                        case 'P':
                                                            res = cpersonal.distributionForInstance(ins);
                                                            break;
                                                        case 'D':
                                                            res = cdemonstrative.distributionForInstance(ins);
                                                            break;
                                                        case 'I':  res = cindefinite.distributionForInstance(ins);
                                                            break;
                                                        case 'T': res = cinterrogative.distributionForInstance(ins); break;
                                                        case 'R': res = crelative.distributionForInstance(ins); break;
                                                        default:
                                                            res = new double [] {0,0};
                                                    }
                                                    //*** ¿qué pasa si hay varios que la resuelven? Eso no lo puedo controlar en el entrenamiento. Aquí me quedaría con el último
                                                    if(res[0]< res[1]){
                                                        ant.confidence = res[1]; 
                                                        pronoun.antecedentsSet.add(ant); //aunque no tenga mayor probabilidad, me lo guardo
                                                        //si he encontrado uno con mayor probabilidad me lo guardo
                                                        if(pronoun.antecedent==null || (pronoun.antecedent!=null && pronoun.antecedent.confidence <= res[1]) ){
                                                            pronoun.antecedent = ant;
                                                            prons.set(j,pronoun);
                                                            pronous.put(i, prons);
                                                            //System.out.print("*");
                                                        } 
                                                    }  
                                                    //System.out.println("Probabilidad Si_ser_antecedente: " + res[1]);
                                                }
                                        }

                                    }
                                }
                            }

                            //añadimos al xml el resultado de ml

                            /*** añadir antecedenteS ***/
                            if(pronoun.antecedentsSet!=null && !pronoun.antecedentsSet.isEmpty()){
                                //if(pronoun.antecedent!=null){
                                Collections.sort(pronoun.antecedentsSet);
                                Iterator<Antecedent> iterator = pronoun.getUniqueAntecedents().iterator(); // pronoun.antecedentsSet.iterator();
                                StringBuilder idsAntecedents = new StringBuilder();
                                StringBuilder startNodeAntecedents = new StringBuilder();
                                StringBuilder endNodeAntecedents = new StringBuilder(); 
                                StringBuilder confidenceAntecedents = new StringBuilder();
                                StringBuilder chain = new StringBuilder();
                                double currentConfidence = 0.0;
                                do {
                                    
                                    if(iterator.hasNext()){
                                        Antecedent next = iterator.next();
                                        currentConfidence = next.confidence;
                                        if(currentConfidence>=minConfidence.getValue()){
                                            String idAntecedente = null;
                                            if(!node_offsets.contains(next.startPosition) && !node_offsets.contains(next.endPosition)){
                                                Element antecedentElement = doc.createElement("Annotation");
                                                idAntecedente = Integer.toString(minNewId);

                                                antecedentElement.setAttribute("Id", minNewId+"");
                                                antecedentElement.setAttribute("StartNode", next.startPosition+""); 
                                                if(next.startPosition==-1)
                                                    node_offsets.add(0);
                                                else 
                                                    node_offsets.add(next.startPosition);
                                                antecedentElement.setAttribute("EndNode", next.endPosition+""); 
                                                node_offsets.add(next.endPosition);
                                                antecedentElement.setAttribute("Type", "DiscourseEntity");
                                                asde.appendChild(antecedentElement); //"Discourse Entity markups");
                                                minNewId++;
                                            } //sino es que este antecedente ya esta marcado pero 
                                            // tengo que saber su id para no liarla
                                            else {
                                                NodeList annotations = XMLUtils.getElementsNamed(asde, "Annotation");

                                                boolean enc = false;

                                                for(int indice=0; indice< annotations.getLength() && !enc; indice++){
                                                    Element item = (Element) annotations.item(indice);
                                                    Integer startp = Integer.parseInt(item.getAttribute("StartNode"));
                                                    Integer endp = Integer.parseInt(item.getAttribute("EndNode"));
                                                    if(startp.equals(next.startPosition) && endp.equals(next.endPosition)){
                                                        idAntecedente = item.getAttribute("Id");
                                                        enc = true;
                                                    }
                                                }

                                                if (!enc){
                                                    System.err.println("¡OJO! POSIBLE BUG: No se encuentra la anotación de " + textWithNodesElement.getTextContent().substring(next.startPosition, next.endPosition) + " en la posición " + next.startPosition +"," + next.endPosition);
                                                }

                                            }

                                            idsAntecedents.append(idAntecedente).append("|");
                                            startNodeAntecedents.append(next.startPosition).append("|");
                                            endNodeAntecedents.append(next.endPosition).append("|");
                                            confidenceAntecedents.append(next.confidence).append("|");
                                            chain.append(textWithNodesElement.getTextContent().substring(next.startPosition, next.endPosition)).append('|');
                                        }
                                    }
                                }while(iterator.hasNext() && //si hay siguiente elemento
                                        currentConfidence>=minConfidence.getValue() && //si la confidence es mayor
                                        allAlternatives); //si hay que mostrar más de una alternativa
                                
                                
                                /*** añadir pronombre ***/
                                Element pronounElement = doc.createElement("Annotation");
                                pronounElement.setAttribute("Id", minNewId+"");
                                pronounElement.setAttribute("StartNode", pronoun.position+"");
                                node_offsets.add(pronoun.position);
                                pronounElement.setAttribute("EndNode", pronoun.endPosition+""); 
                                node_offsets.add(pronoun.endPosition);
                                pronounElement.setAttribute("Type", "PronounAnaphora");
    //                            asa.appendChild(pronounElement); //Pronouns
                                asde.appendChild(pronounElement);
                                
                                Element feature = doc.createElement("Feature");
                                pronounElement.appendChild(feature);
                                Element name = doc.createElement("Name");
                                name.setAttribute("className", "java.lang.String");
                                name.setTextContent("complexity");
                                feature.appendChild(name);
                                Element value = doc.createElement("Value");
                                value.setAttribute("className", "java.lang.String");
                                value.setTextContent(Double.toString(complexity));
//                                value.setTextContent("0.85");
                                feature.appendChild(value);

                                /*** añadir todos la info de los antecedentes de mayor a menor confidence y con una confidence > 0.5***/
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
    //                                value.setTextContent(pronoun.antecedent.startPosition+"");                        
                                    value.setTextContent(startNodeAntecedents.substring(0, startNodeAntecedents.length()-1)); //quitamos el último |

                                    feature.appendChild(value);

                                    feature = doc.createElement("Feature");
                                    pronounElement.appendChild(feature);
                                    name = doc.createElement("Name");
                                    name.setAttribute("className", "java.lang.String");
                                    name.setTextContent("EndNodeAntecedent");
                                    feature.appendChild(name);
                                    value = doc.createElement("Value");
                                    value.setAttribute("className", "java.lang.String");
    //                                value.setTextContent(pronoun.antecedent.endPosition+"");
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
    //                                value.setTextContent(pronoun.antecedent.confidence+"");
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
    //                                value.setTextContent(idAntecedente);
                                    value.setTextContent(idsAntecedents.substring(0, idsAntecedents.length()-1)); //quitamos el último |
                                    feature.appendChild(value);

                                    feature = doc.createElement("Feature");
                                    pronounElement.appendChild(feature);
                                    name = doc.createElement("Name");
                                    name.setAttribute("className", "java.lang.String");
                                    name.setTextContent("chain");
                                    feature.appendChild(name);
                                    value = doc.createElement("Value");
                                    value.setAttribute("className", "java.lang.String");
    //                                value.setTextContent(idAntecedente);
                                    value.setTextContent(chain.substring(0, chain.length()-1)); //quitamos el último |
                                    feature.appendChild(value);
                                }
                                minNewId++;
                            } else {
                                Element pronounElement = doc.createElement("Annotation");
                                pronounElement.setAttribute("Id", minNewId+"");
                                pronounElement.setAttribute("StartNode", pronoun.position+"");
                                node_offsets.add(pronoun.position);
                                pronounElement.setAttribute("EndNode", pronoun.endPosition+""); 
                                node_offsets.add(pronoun.endPosition);
                                pronounElement.setAttribute("Type", "PronounAnaphora");
    //                            asa.appendChild(pronounElement); //Pronouns
                                
                                Element feature = doc.createElement("Feature");
                                pronounElement.appendChild(feature);
                                Element name = doc.createElement("Name");
                                name.setAttribute("className", "java.lang.String");
                                name.setTextContent("complexity");
                                feature.appendChild(name);
                                Element value = doc.createElement("Value");
                                value.setAttribute("className", "java.lang.String");
                                value.setTextContent(Double.toString(complexity));
//                                value.setTextContent("0.85");
                                feature.appendChild(value);
                                

                                asde.appendChild(pronounElement);
                                minNewId++;
                            }

                        }

                    } catch(Exception ex){
                        //weka
                        Logger.getLogger(SpanishPronominalAnaphora.class.getName()).log(Level.SEVERE, null, ex);
                        throw new AnaphoraResolutionException("Error 5: Problem with external machine learning tool, weka: Incorrect value features",ex);

                    }
                } 
            }
            // FIN - se repite para cada tipo de pronombre
            //modificar el gDocument para incluir las anotaciones:
            //tengamos ya algun Node o no, los vamos a añadir todos
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
            
            
//            try {
//                
//            FileReader fr = new FileReader (outputFreeling);
//            BufferedReader br = new BufferedReader(fr);
//            String text = textWithNodesElement.getTextContent();
//            //String [] splitted = text.split("\\s+");
//            //StringBuilder newText = new StringBuilder();
//            textWithNodesElement.setAttribute("xml:space", "preserve");
//            //si hemos añadido alguna anotación, borramos el texto completo.
//            if(!node_offsets.isEmpty()){
//                
//                //añadimos los offsets que existan previamente
//                NodeList previousNodes = XMLUtils.getElementsNamed(textWithNodesElement, "Node");
//
//                for(int nodes=0; nodes< previousNodes.getLength(); nodes++){
//                    Element n = (Element) previousNodes.item(nodes);
//                    node_offsets.add(Integer.parseInt(n.getAttribute("id")));
//                }
//                
//                //borramos el contenido previo en la sección textwithnodeselement 
//                textWithNodesElement.setTextContent("");
//                        
//                int start_offset = 0; boolean inicio = true;
//                for(Integer offset: node_offsets){
//                    if(start_offset==0 && inicio || start_offset>=0 && start_offset!=offset){
//                        inicio = false;
//                    if(start_offset >=0 && offset <text.length()){
//                        String aux;
//                        if(offset>0)
//                            aux = text.substring(start_offset, offset);
//                        else 
//                            aux = text.substring(start_offset);
//                        textWithNodesElement.appendChild(doc.createTextNode(aux));
//                        Element n = doc.createElement("Node");
//                        n.setAttribute("id", offset+"");
//                        textWithNodesElement.appendChild(n);
//                        start_offset = offset;
//                    }
//                    }
//
//                    //System.out.println("El texto ahora es: "+ textWithNodesElement.getTextContent() + "---");
//                    //System.out.println("----------------------------");
//                }
//
//                //añadimos el último fragmento de texto
//                if (start_offset < text.length() && start_offset > 0){
//                    textWithNodesElement.appendChild(doc.createTextNode(text.substring(start_offset)));
//                }
//            }
//            } catch(Exception ex){
//                Logger.getLogger(SpanishPronominalAnaphora.class.getName()).log(Level.SEVERE, null, ex);
//                throw new AnaphoraResolutionException("Error 2: Incorrect offsets generation",ex);
//            }
//            
//        try{
//            outputFreeling.delete(); //ahora que ya no necesito la salida de freeling, borro el fichero
//
//            File tmpFile = File.createTempFile("anaphoraresolution", "xml");
//            XMLUtils.saveXML(doc, tmpFile.getAbsolutePath(), "UTF-8");
//
//            BufferedReader brr = new BufferedReader(new FileReader(tmpFile));
//            String line;
//            StringBuilder sb = new StringBuilder();
//
//            while((line=brr.readLine())!= null){
//                sb.append(line); sb.append("\n");
//            }
//            newDoc = sb.toString();
//            tmpFile.delete();
//               
//               
//            
//        } catch (Exception ex) {
//            Logger.getLogger(SpanishPronominalAnaphora.class.getName()).log(Level.SEVERE, null, ex);
//            throw new AnaphoraResolutionException("Error 7: Problem generating output document",ex);
//
//        } 
        
        return newDoc;
    }

    
}
