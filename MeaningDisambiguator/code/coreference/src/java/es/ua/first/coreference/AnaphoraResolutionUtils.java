/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package es.ua.first.coreference;

import es.ua.first.coreference.util.Antecedent;
import es.upv.xmlutils.XMLUtils;
import java.io.*;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.TreeSet;
import java.util.logging.Level;
import java.util.logging.Logger;
import org.w3c.dom.Document;
import org.w3c.dom.Element;
import org.w3c.dom.NodeList;

/**
 * Common functions for AnaphoraResolution task
 * @author imoreno
 */
public class AnaphoraResolutionUtils {
    private static SpanishPronominalAnaphora pronominalResolver;
    private static SpanishZeroPronoun zeroResolver;
    private static SpanishDefiniteDescription ddResolver;
    public enum Threshold {
        ZERO (0.0),
        LOW (0.3) ,
        MEDIUM (0.6), 
        HIGH (0.9);
        
        public double value;
        
        Threshold(double val){
            this.value = val;
        }

        public double getValue() {
            return value;
        }

        public void setValue(double value) {
            this.value = value;
        }
        
    
    };
    
    public void initialize(String appPath) throws FileNotFoundException, Exception{
        
        pronominalResolver = new SpanishPronominalAnaphora(appPath);

        zeroResolver = new SpanishZeroPronoun(appPath);

        ddResolver = new SpanishDefiniteDescription(appPath);
        
    }
    
    protected static void addOffsetNodes(Element textWithNodesElement,TreeSet<Integer> node_offsets, Document doc) {
            
        //FileReader fr = new FileReader (outputFreeling);
        //BufferedReader br = new BufferedReader(fr);
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
                        if(offset>0){
                            aux = text.substring(start_offset, offset);
    //                    else 
    //                        aux = text.substring(start_offset);
                        textWithNodesElement.appendChild(doc.createTextNode(aux));
                        }
                        Element n = doc.createElement("Node");
                        n.setAttribute("id", offset+"");
                        textWithNodesElement.appendChild(n);
                        start_offset = offset;
                    }
                }
            }

            //añadimos el último fragmento de texto
            if (start_offset < text.length() && start_offset > 0){
                textWithNodesElement.appendChild(doc.createTextNode(text.substring(start_offset)));
            }
        }
    }
    
    protected static int getNextFreeID(Document doc){
        Element documentElement = doc.getDocumentElement();
        Element textWithNodesElement = XMLUtils.getElementNamed(documentElement, "TextWithNodes");
        //obtenemos el identificador para las nuevas anotaciones
        int minNewId = textWithNodesElement.getTextContent().length()+1;
        NodeList elementNamed = XMLUtils.getElementsNamed(documentElement, "AnnotationSet");
        for(int i=0; i<elementNamed.getLength(); i++){
            NodeList anotaciones = XMLUtils.getElementsNamed((Element)elementNamed.item(i), "Annotation");
            for(int j=0; j<anotaciones.getLength(); j++){
                Element e = (Element) anotaciones.item(j);
                int attribute = Integer.parseInt(e.getAttribute("Id"));
                if(minNewId<attribute)
                    minNewId = attribute +1;
            }
        }
        
        return minNewId+1;
    }
    
    protected static Element insertNewAnnotationSet(Document doc, String name){
        Element asde = doc.createElement("AnnotationSet");
        asde.setAttribute("Name", name);//"Definite Descriptions Anaphora markups");
        doc.getDocumentElement().appendChild(asde);
        
        return asde;
    }
    
    protected static String generateStringOutput(Document doc) throws IOException{
        File tmpFile = File.createTempFile("anaphoraresolution", "xml");
        XMLUtils.saveXML(doc, tmpFile.getAbsolutePath(), "UTF-8");

        BufferedReader brr = new BufferedReader(new FileReader(tmpFile));
        String line;
        StringBuilder sb = new StringBuilder();

        while((line=brr.readLine())!= null){
            sb.append(line); sb.append("\n");
        }
        
        tmpFile.delete();
        
        return sb.toString();
    }
     
    /**
     * executes freeling in intime and generates an output file with the 
     * shallow parsing of the input.
     * @param inputtext string containing the text to analyze.
     * @return the output file
     * @throws IOException
     * @throws InterruptedException 
     */
    protected synchronized static File runFreeling(String inputtext, String appPath) throws IOException, InterruptedException{
        
        //Generamos un fichero a partir del texto de entrada
        File tempFile = File.createTempFile("entrada",".txt");
        BufferedWriter out = new BufferedWriter(new FileWriter(tempFile));
        out.write(inputtext);
        out.close();
        
        //Generamos un fichero para almacenar la salida del comando
        File tempFile2 = File.createTempFile("salida",".txt");
        tempFile2.deleteOnExit();
        //out = new BufferedWriter(new FileWriter(tempFile2));
       
        
        //Ejecutamos el script que contiene el comando para ejecutar freeling
        String[] cd = { "/bin/sh", "-c", appPath + "/scripts/freeling.sh " + tempFile.getAbsolutePath() + " " + tempFile2.getAbsolutePath()};
        Process child  = Runtime.getRuntime().exec(cd, new String[0], new File(appPath + "scripts"));
        child.waitFor();
        
        //elimino el fichero temporal de entrada porque ya no lo necesito
        tempFile.delete();
        
        //Leemos la salida estándar producida por el comando
        /*java.io.BufferedReader r = new java.io.BufferedReader(new java.io.InputStreamReader(child.getInputStream()));
        String s = null;
        while ((s = r.readLine()) != null) {
            //System.out.println(s);
            out.write(s);
            out.newLine();
        }
               
        out.close();*/
        
        //Leememos la salida de error producida por el comando
        java.io.BufferedReader r2 = new java.io.BufferedReader(new java.io.InputStreamReader(child.getErrorStream()));
        String s = null;
        boolean excepcion = false;
        StringBuilder bferror = new StringBuilder();
        while ((s = r2.readLine()) != null) {
            System.err.println(s);
            excepcion=true;
            bferror.append(s).append("\n");
        }
        
        child.getOutputStream().close(); 
        child.getInputStream().close();
        child.getErrorStream().close();
        child.destroy();
        
        if(excepcion)
            throw new IOException(bferror.toString());
        
        return tempFile2;
    }
 
    protected synchronized static File runFreeling(String inputtext, String appPath, String outpf) throws IOException, InterruptedException{
        
        //Generamos un fichero a partir del texto de entrada
        File tempFile = File.createTempFile("entrada",".txt");
        BufferedWriter out = new BufferedWriter(new FileWriter(tempFile));
        out.write(inputtext);
        out.close();
        
        //Generamos un fichero para almacenar la salida del comando
        File tempFile2 = File.createTempFile("salida",".txt");
        tempFile2.deleteOnExit();
//        out = new BufferedWriter(new FileWriter(tempFile2));
       
        
        //Ejecutamos el script que contiene el comando para ejecutar freeling
        String[] cd = { "/bin/sh", "-c", appPath + "/scripts/freeling.sh " + outpf + " " + tempFile.getAbsolutePath() + " " + tempFile2.getAbsolutePath() };
        Process child  = Runtime.getRuntime().exec(cd, new String[0], new File(appPath + "scripts"));
        child.waitFor();
        
        //elimino el fichero temporal de entrada porque ya no lo necesito
        tempFile.delete();
        
        //Leemos la salida estándar producida por el comando
//        java.io.BufferedReader r = new java.io.BufferedReader(new java.io.InputStreamReader(child.getInputStream()));
//        String s = null;
//        while ((s = r.readLine()) != null) {
//            //System.out.println(s);
//            out.write(s);
//            out.newLine();
//        }
//               
//        out.close();
        
        //Leememos la salida de error producida por el comando
        java.io.BufferedReader r2 = new java.io.BufferedReader(new java.io.InputStreamReader(child.getErrorStream()));
        String s = null;
        boolean excepcion = false;
        StringBuilder bferror = new StringBuilder();
        while ((s = r2.readLine()) != null) {
            System.err.println(s);
            excepcion=true;
            bferror.append(s + "\n");
        }
        
        child.getOutputStream().close(); 
        child.getInputStream().close();
        child.getErrorStream().close();
        child.destroy();
        
        if(excepcion)
            throw new IOException(bferror.toString());
        
        return tempFile2;
    }
    
    protected static HashMap<Integer,ArrayList<Antecedent>> detectAntecedentsInSentence(int num_sentence, File ffreeling, String original) throws AnaphoraResolutionException{
         FileReader fr = null;
         BufferedReader br = null;
         HashMap<Integer,ArrayList<Antecedent>> antecedents = null;
         try {
            
            fr = new FileReader (ffreeling);
            br = new BufferedReader(fr);
                    
            // Lectura del fichero
            String linea;
            String patronOracion = "\\+grup-verb_\\[";
            String patronOracion2 = "S_\\[";
            String patronInicioSN = "\\s+\\+?grup-nom";
            int current_sentence = 0;
            int corchetes = 0;
            int start_offset = 0, end_offset = 0;
            
            Antecedent an = null;
            antecedents = new HashMap<Integer,ArrayList<Antecedent>>();
            boolean nucleo = false;
            boolean contarCorchetes = false;
            int num_token = 0;
            boolean lineaAnteriorVacia = false;
            boolean ignorarToken = false;
            while((linea=br.readLine())!=null){
                //para saber la oración por la que voy
                //para saber que he llegado al final de una oración, busco dos lineas vacias
                if(linea.matches(patronOracion2)){
                    current_sentence++;
                    num_token=0;
                }
                    
                
                //if(num_sentence > 0){ 
                    //procesar la anterior frase y la actual
                    if((num_sentence == current_sentence) || (num_sentence-1 == current_sentence)){
                        if(linea.contains("+(") || linea.contains("(")){
                            //if(!ignorarToken){
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
                                        //if(original.indexOf(tokens[i]+" ")!=-1)
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
                                    //if(o.equals("del") || o.equals("al")) //no va!
                                    //{    ignorarToken = true;
                                    //if(start_offset==-1)
                                    //    start_offset = 0;
                                    //end_offset = start_offset + o.length();
                                    //} else {
                                        end_offset = start_offset + aux[0].length();
                                    //}
                                }
                            //} else {
                            //    ignorarToken=false;
                            //}
                                
                            if(start_offset == -1 || end_offset ==-1){
                                throw new AnaphoraResolutionException("Error 2: Incorrect offsets generation with "+ num_token +"st token " + aux[0] + " in sentence " + current_sentence);
                            }
                        }
                        //if(linea.matches(patronInicioSN) && !contarCorchetes){ 
                        if(linea.contains("grup-nom") && !contarCorchetes){ 
                            //a partir de ahora hay que contar el numero de [ que se abren y ] que cierran
                            //System.out.println("Entro!");
                            corchetes = 1;
                            contarCorchetes = true;
                            an = new Antecedent();
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
                                            an.endPosition = end_offset;
                                            ArrayList<Antecedent> get = antecedents.get(current_sentence);
                                            if(get==null){
                                                get = new ArrayList<Antecedent>();
                                            } 
                                            get.add(an);
                                            antecedents.put(current_sentence, get);
                                        }
                                    }
                                }
                            }
                            
                            if(corchetes >=1){
                                
                                if(linea.contains("+n-") || linea.contains("psubj") || linea.contains("w-") || linea.contains("paton")){ //esto no se cumple para los sn compuestos de pronombres.
                                    nucleo = true;
                                }
                                
                                if(linea.contains("+(")){
                                    linea = linea.substring(linea.indexOf("+")+1, linea.length()-1);
                                    if(an!=null){
                                        an.words.add(linea);
                                        if(nucleo){
                                            an.core = linea;
                                            nucleo = false;
                                        }
                                        if(an.startPosition==-1){
                                            an.startPosition = start_offset;
                                        }
                                        
                                    }
                                }
                            
                            }
                                
                            
                            
                            
                        }
                    }
                    
                } 
              
        } catch (IOException ex) {
            throw new AnaphoraResolutionException("Error 3: Problem with external NLP tool: freeling",ex);
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
        
         return antecedents;
    }
    
    
    public static String resolveAnaphors(String gDocument, String appPath) throws AnaphoraResolutionException{
        String newDoc = gDocument;      
        Document doc = null;
        Element documentElement = null;
        Element textWithNodesElement = null;
        Element ase = null;
        Element asp = null;
        Element asd = null;
        int minNewId = -1;
        File outputFreeling = null;
        
        try {
           doc = XMLUtils.readXML(gDocument,"UTF8");
           documentElement = doc.getDocumentElement();
           textWithNodesElement = XMLUtils.getElementNamed(documentElement, "TextWithNodes");

            minNewId = getNextFreeID(doc);
            
            ase = insertNewAnnotationSet(doc, "Ellipsis Anaphora markups");
            asp = insertNewAnnotationSet(doc, "Pronominal Anaphora markups");
            asd = insertNewAnnotationSet(doc, "Definite Descriptions Anaphora markups");
            
        } catch(Exception e){
            throw new AnaphoraResolutionException("Error 6: Problem processing input document due to parsing problems",e); //error parsing gate format
        }
        
        try {
            outputFreeling = runFreeling(textWithNodesElement.getTextContent(), appPath);
        } catch (IOException ex) {
            Logger.getLogger(SpanishDefiniteDescription.class.getName()).log(Level.SEVERE, null, ex);
            throw new AnaphoraResolutionException("Error 3: Problem with external NLP tool: freeling",ex);
        } catch (InterruptedException ex) {
            Logger.getLogger(SpanishDefiniteDescription.class.getName()).log(Level.SEVERE, null, ex);
            throw new AnaphoraResolutionException("Error 3: Problem with external NLP tool: freeling",ex);

        }
       
        //llamamos a los 3 metodos que resuelven la anáfora
        //SpanishPronominalAnaphora pronominalResolver = new SpanishPronominalAnaphora(appPath);
        newDoc = pronominalResolver.resolveAnaphora(gDocument, outputFreeling, minNewId, asp, doc);
        
        try {
            doc = XMLUtils.readXML(newDoc,"UTF8");
            minNewId = getNextFreeID(doc);
            ase = XMLUtils.getElementByAttribute(doc.getDocumentElement(), "Name", "Ellipsis Anaphora markups");
        } catch(Exception e){
            
            throw new AnaphoraResolutionException("Error 6: Problem processing input document due to parsing problems",e); //error parsing gate format
        }
        //SpanishZeroPronoun zeroResolver = new SpanishZeroPronoun(appPath);
        
        newDoc = zeroResolver.resolveAnaphora(newDoc, outputFreeling, minNewId, ase,doc);

        try{
            doc = XMLUtils.readXML(newDoc,"UTF8");
            minNewId = getNextFreeID(doc);
            asd = XMLUtils.getElementByAttribute(doc.getDocumentElement(), "Name", "Definite Descriptions Anaphora markups");
        } catch(Exception e){
            throw new AnaphoraResolutionException("Error 6: Problem processing input document due to parsing problems",e); //error parsing gate format
        }
        //SpanishDefiniteDescription dd = new SpanishDefiniteDescription(appPath);
        newDoc = ddResolver.resolveAnaphora(newDoc, outputFreeling, minNewId, asd, doc);
            
        outputFreeling.delete();
        
        return newDoc;
    }
    
    public static String resolveAnaphors(String gDocument, String appPath,Threshold complexity, Threshold confidence, Boolean allAlternatives) throws AnaphoraResolutionException{
        String newDoc = gDocument;      
        Document doc = null;
        Element documentElement = null;
        Element textWithNodesElement = null;
        Element ase = null;
        Element asp = null;
        Element asd = null;
        int minNewId = -1;
        File outputFreeling = null;
        
        try {
           doc = XMLUtils.readXML(gDocument,"UTF8");
           documentElement = doc.getDocumentElement();
           textWithNodesElement = XMLUtils.getElementNamed(documentElement, "TextWithNodes");

            minNewId = getNextFreeID(doc);
            
            //este AS lo añadimos siempre
            asp = insertNewAnnotationSet(doc, "Pronominal Anaphora markups");
            
            //este AS lo añadimos si complexity es MEDIUM o LOW
            if(complexity.equals(Threshold.MEDIUM) || complexity.equals(Threshold.LOW)) {
                ase = insertNewAnnotationSet(doc, "Ellipsis Anaphora markups");
            }
            
            //este AS lo añadimos si complexity es LOW
            if(complexity.equals(Threshold.LOW)) {
                 asd = insertNewAnnotationSet(doc, "Definite Descriptions Anaphora markups");
            }
            
        } catch(Exception e){
            throw new AnaphoraResolutionException("Error 6: Problem processing input document due to parsing problems",e); //error parsing gate format
        }
        
        try {
            outputFreeling = runFreeling(textWithNodesElement.getTextContent(), appPath);
        } catch (IOException ex) {
            Logger.getLogger(SpanishDefiniteDescription.class.getName()).log(Level.SEVERE, null, ex);
            throw new AnaphoraResolutionException("Error 3: Problem with external NLP tool: freeling",ex);
        } catch (InterruptedException ex) {
            Logger.getLogger(SpanishDefiniteDescription.class.getName()).log(Level.SEVERE, null, ex);
            throw new AnaphoraResolutionException("Error 3: Problem with external NLP tool: freeling",ex);

        }
        
        //llamamos a los 3 metodos que resuelven la anáfora
        
        if(complexity.equals(Threshold.LOW)||complexity.equals(Threshold.MEDIUM)||complexity.equals(Threshold.HIGH)) {    
            //SpanishPronominalAnaphora pronominalResolver = new SpanishPronominalAnaphora(appPath);
            newDoc = pronominalResolver.resolveAnaphora(gDocument, outputFreeling, minNewId, asp, doc, allAlternatives, confidence);

            try {
                doc = XMLUtils.readXML(newDoc,"UTF8");
                minNewId = getNextFreeID(doc);
                ase = XMLUtils.getElementByAttribute(doc.getDocumentElement(), "Name", "Ellipsis Anaphora markups");
            } catch(Exception e){

                throw new AnaphoraResolutionException("Error 6: Problem processing input document due to parsing problems",e); //error parsing gate format
            }
        }
        
        if(complexity.equals(Threshold.MEDIUM) || complexity.equals(Threshold.LOW)) {
            //SpanishZeroPronoun zeroResolver = new SpanishZeroPronoun(appPath)
            newDoc = zeroResolver.resolveAnaphora(newDoc, outputFreeling, minNewId, ase,doc, allAlternatives, confidence);

            try{
                doc = XMLUtils.readXML(newDoc,"UTF8");
                minNewId = getNextFreeID(doc);
                asd = XMLUtils.getElementByAttribute(doc.getDocumentElement(), "Name", "Definite Descriptions Anaphora markups");
            } catch(Exception e){
                throw new AnaphoraResolutionException("Error 6: Problem processing input document due to parsing problems",e); //error parsing gate format
            }
        }
        
        if(complexity.equals(Threshold.LOW)){
            //SpanishDefiniteDescription dd = new SpanishDefiniteDescription(appPath);
            newDoc = ddResolver.resolveAnaphora(newDoc, outputFreeling, minNewId, asd, doc, allAlternatives, confidence);
        }    
        
        outputFreeling.delete();
        
        return newDoc;
    }

    
}
