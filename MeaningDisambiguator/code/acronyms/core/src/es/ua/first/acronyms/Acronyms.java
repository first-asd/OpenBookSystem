/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package es.ua.first.acronyms;

import es.upv.xmlutils.XMLUtils;
import gate.Annotation;
import gate.AnnotationSet;
import gate.Factory;
import gate.Gate;
import gate.creole.ResourceInstantiationException;
import gate.util.GateException;
import java.io.BufferedReader;
import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileReader;
import java.io.IOException;
import java.util.ArrayList;
import java.util.Collections;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import java.util.Properties;
import java.util.TreeSet;
import javax.xml.parsers.ParserConfigurationException;
import org.w3c.dom.Document;
import org.w3c.dom.Element;
import org.w3c.dom.NodeList;
import org.xml.sax.SAXException;

/**
 *
 * @author lcanales
 */
public class Acronyms {

    public static final String VERSION = "1.0";
    public static final String GATE = "GATE";
    public static final String TXT = "TXT";
    public static final String LANGEN = "en";
    public static final String LANGES = "es";
    public static final String LANGBG = "bg";
    public static final String DEFINITIONS = "DEFINITIONS";
    public static final String SYNONYMS = "SYNONYMS";
    public static final String DEFSYN = "DEFSYN";
    public static final String ACRONYMS = "ACRONYMS";
    private final Map<String, String> acronymsBG;
    private final Map<String, String> acronymsES;
    private final Map<String, String> acronymsEN;
    private final String fileSeparator = System.getProperty("file.separator");
    private final String delimiters = "[,\\.\\s\\(\\)_\\{\\}\n\"'\\:<>!¿¡?\\[\\]\\/«»;%-\\+=]+";

    public Acronyms(Properties defaultProps, String workingDir, String gatePath) throws IOException, GateException {
        // cargamos la listas de acronyms
        String pathAcronymsBG = workingDir + fileSeparator + defaultProps.getProperty("pathAcronymsBG");
        String pathAcronymsEN = workingDir + fileSeparator + defaultProps.getProperty("pathAcronymsEN");
        String pathAcronymsES = workingDir + fileSeparator + defaultProps.getProperty("pathAcronymsES");
        acronymsBG = loadAcronyms(LANGBG, pathAcronymsBG);
        acronymsES = loadAcronyms(LANGES, pathAcronymsES);
        acronymsEN = loadAcronyms(LANGEN, pathAcronymsEN);
        // Inicializamos GATE
        Gate.setGateHome(new File(gatePath));
        Gate.setSiteConfigFile(new File(Gate.getGateHome().getAbsolutePath() + "/gate.xml"));
        Gate.init();
        
    }

    //
    public String detectionAcronyms(String inputText, String langCode, String formatFileInput, String formatFileOutput, String workingDir) throws IOException, ParserConfigurationException, SAXException, ResourceInstantiationException {
        // Obtenemos el texto que debemos analizar
        String textToAnalyze = loadInputFile(inputText, formatFileInput);

        // Detectamos y resolvemos los acronimos (search)
        HashMap<String, Acronym> acronyms = detectionResolutionAcronyms(langCode, textToAnalyze, inputText);

        // Obtenemos la salida
        return obtainOutput(acronyms, formatFileOutput, formatFileInput, inputText, textToAnalyze);
    }

    private HashMap<String, Acronym> detectionResolutionAcronyms(String langCode, String textToAnalyze, String inputText) throws IOException, ResourceInstantiationException {
        if (langCode.equals(LANGBG)) {
            return detectionResolutionAcronymsBG(inputText);
        } else {
            return detectionResolutionAcronymsESEN(langCode, textToAnalyze);
        }
    }

    private HashMap<String, Acronym> detectionResolutionAcronymsESEN(String langCode, String textToAnalyze) {
        HashMap<String, Acronym> acronymsDetected = new HashMap<String, Acronym>();
        String offsets = "0-0";

        // Seleccionamos el tree (dependiendo del idioma)
        Map<String, String> acronyms = (langCode.equals(LANGBG)) ? acronymsBG
                : (langCode.equals(LANGEN)) ? acronymsEN : acronymsES;

        // Tokenizamos el texto
        String[] tokens = textToAnalyze.split(delimiters);
        for (String token : tokens) {
            // Comprobamos si es un acronimo
            if (acronyms.containsKey(token)) {
                // obtenemos la definicion del acronimo
                String wordText = token;
                String definition = acronyms.get(token);
                // obtenemos los offsets
                int end = Integer.parseInt(offsets.split("-")[1]);
                offsets = obtainOffset(textToAnalyze, wordText, end);
                int start_offset = Integer.parseInt(offsets.split("-")[0]);
                int end_offset = Integer.parseInt(offsets.split("-")[1]);
                // comprobamos si ya ha sido detectado anteriormente
                if (acronymsDetected.containsKey(wordText)) {
                    // modificamos la palabra(word) almacenada)
                    acronymsDetected.get(wordText).getStart_offset().add(start_offset);
                    acronymsDetected.get(wordText).getEnd_offset().add(end_offset);
                } else {
                    // start_off y end_off
                    List<Integer> start_offsets = new ArrayList<Integer>();
                    start_offsets.add(start_offset);
                    List<Integer> end_offsets = new ArrayList<Integer>();
                    end_offsets.add(end_offset);
                    acronymsDetected.put(wordText, new Acronym(wordText, start_offsets, end_offsets, definition));
                }
            }
        }
        return acronymsDetected;

    }

    private HashMap<String, Acronym> detectionResolutionAcronymsBG(String inputText) throws ResourceInstantiationException {
        HashMap<String, Acronym> acronyms = new HashMap<String, Acronym>();
        // cargamos el temporal
        gate.Document doc = gate.Factory.newDocument(inputText);
        AnnotationSet tokenBN = doc.getAnnotations("Tokenization").get("Token");
        for (Annotation token : tokenBN) {
            String wordText = token.getFeatures().get("string").toString();
            // Comprobamos si esta en la lista
            if (acronymsBG.containsKey(wordText)) {
                // obtenemos la definicion
                String definition = acronymsBG.get(wordText);
                // obtenemos los offsets
                int start_offset = token.getStartNode().getOffset().intValue();
                int end_offset = token.getEndNode().getOffset().intValue();
                // si lo tenemos en la lista
                if (acronyms.containsKey(wordText)) {
                    // modificamos la palabra(word) almacenada
                    acronyms.get(wordText).getStart_offset().add(start_offset);
                    acronyms.get(wordText).getEnd_offset().add(end_offset);
                } else {
                    //offsets
                    List<Integer> start_offset_v = new ArrayList<Integer>();
                    start_offset_v.add(start_offset);
                    List<Integer> end_offset_v = new ArrayList<Integer>();
                    end_offset_v.add(end_offset);
                    // Creamos la palabra y añadimos a la lista
                    Acronym word = new Acronym(wordText, start_offset_v, end_offset_v, definition);
                    acronyms.put(wordText, word);
                }
            }

        }
        Factory.deleteResource(doc);
        return acronyms;
    }

    private String obtainOutput(HashMap<String, Acronym> words, String formatOutput, String formatInput, String inputText, String textToAnalyze) throws IOException, ParserConfigurationException, SAXException {
        String output = "";
        if (formatOutput.equals(GATE)) {
            // Creamos el documento Gate y obtenemos el siguiente identificador
            Document gateDoc;
            int id = 1;
            if (formatInput.equals(TXT)) {
                String gate = convertPlainToGate(inputText);
                gateDoc = XMLUtils.readXML(gate, "UTF-8");
            } else {
                gateDoc = XMLUtils.readXML(inputText, "UTF-8");
                // Obtain a new Id
                id = obtainNextId(gateDoc, textToAnalyze);
            }
            // Create node offsets
            TreeSet<Integer> nodeOffsets = new TreeSet<Integer>();

            // 5 annotation sets y voy añadiendo (ver las diferentes opcioens)
            Element annotationSetMultiWords = createNewAnnot(gateDoc, "Disambiguate markups ACRONYMS");

            Iterator it = words.entrySet().iterator();
            while (it.hasNext()) {
                Map.Entry e = (Map.Entry) it.next();
                Acronym word = (Acronym) e.getValue();
                int idParent = id;
                for (int i = 0; i < word.getStart_offset().size(); i++) {
                    // comprobamos si es una referencia o una nueva instancia
                    Element annotationRare;
                    if (i > 0) {
                        annotationRare = createFeatureLink(gateDoc, idParent, id, word, i);
                    } else {
                        annotationRare = createFeatures(gateDoc, id, word, ACRONYMS, i);
                    }
                    annotationSetMultiWords.appendChild(annotationRare);

                    id++;
                }
                nodeOffsets.addAll(word.getStart_offset());
                nodeOffsets.addAll(word.getEnd_offset());
            }
            // Insetamos los Nodes
            insertNodeGateDocument(gateDoc, nodeOffsets);
            output = XMLUtils.toString(gateDoc);
        }
        return output;
    }

    private Element createNewAnnot(Document doc, String annotSetName) {
        //creamos el nuevos annotationset
        Element root = doc.getDocumentElement();
        Element anotationSetDisam = doc.createElement("AnnotationSet");
        anotationSetDisam.setAttribute("Name", annotSetName);
        root.appendChild(anotationSetDisam);
        return anotationSetDisam;
    }

    private Element createFeatureLink(Document gateDoc, int idParent, int id, Acronym word, int posOffset) {
        Element definitionElement = gateDoc.createElement("Annotation");
        String idDefinition = Integer.toString(id);
        definitionElement.setAttribute("Id", idDefinition);
        definitionElement.setAttribute("StartNode", word.getStart_offset().get(posOffset) + "");
        definitionElement.setAttribute("EndNode", word.getEnd_offset().get(posOffset) + "");
        definitionElement.setAttribute("Type", "Definition");
        // Add id parent
        Element feature = gateDoc.createElement("Feature");
        definitionElement.appendChild(feature);
        Element name = gateDoc.createElement("Name");
        name.setAttribute("className", "java.lang.String");
        name.setTextContent("wordIndexId");
        feature.appendChild(name);
        Element value = gateDoc.createElement("Value");
        value.setAttribute("className", "java.lang.String");
        value.setTextContent(String.valueOf(idParent));
        feature.appendChild(value);
        return definitionElement;
    }

    private Element createFeatures(Document gateDoc, int id, Acronym word, String typeWord, int posOffset) {
        Element definitionElement = gateDoc.createElement("Annotation");
        String idDefinition = Integer.toString(id);
        definitionElement.setAttribute("Id", idDefinition);
        definitionElement.setAttribute("StartNode", word.getStart_offset().get(posOffset) + "");
        definitionElement.setAttribute("EndNode", word.getEnd_offset().get(posOffset) + "");
        definitionElement.setAttribute("Type", "Definition");

        // Add definition
        Element feature = gateDoc.createElement("Feature");
        definitionElement.appendChild(feature);
        Element name = gateDoc.createElement("Name");
        name.setAttribute("className", "java.lang.String");
        name.setTextContent("definition");
        feature.appendChild(name);
        Element value = gateDoc.createElement("Value");
        value.setAttribute("className", "java.lang.String");
        value.setTextContent(word.getDefinition());
        feature.appendChild(value);


        // Add word
        feature = gateDoc.createElement("Feature");
        definitionElement.appendChild(feature);
        name = gateDoc.createElement("Name");
        name.setAttribute("className", "java.lang.String");
        name.setTextContent("token");
        feature.appendChild(name);
        value = gateDoc.createElement("Value");
        value.setAttribute("className", "java.lang.String");
        value.setTextContent(word.getAcronym());
        feature.appendChild(value);

        // Add typeWord
        feature = gateDoc.createElement("Feature");
        definitionElement.appendChild(feature);
        name = gateDoc.createElement("Name");
        name.setAttribute("className", "java.lang.String");
        name.setTextContent("typeToken");
        feature.appendChild(name);
        value = gateDoc.createElement("Value");
        value.setAttribute("className", "java.lang.String");
        value.setTextContent(typeWord);
        feature.appendChild(value);

        return definitionElement;
    }

    private void insertNodeGateDocument(Document gateDoc, TreeSet<Integer> nodeOffsets) {
        Element documentElement = gateDoc.getDocumentElement();
        Element textWithNodesElement = XMLUtils.getElementNamed(documentElement, "TextWithNodes");

        String text = textWithNodesElement.getTextContent();
        textWithNodesElement.setAttribute("xml:space", "preserve");

        //si hemos añadido alguna anotación, borramos el texto completo.
        if (!nodeOffsets.isEmpty()) {

            //añadimos los offsets que existan previamente
            NodeList previousNodes = XMLUtils.getElementsNamed(textWithNodesElement, "Node");

            for (int nodes = 0; nodes < previousNodes.getLength(); nodes++) {
                Element n = (Element) previousNodes.item(nodes);
                nodeOffsets.add(Integer.parseInt(n.getAttribute("id")));
            }

            //borramos el contenido previo en la sección textwithnodeselement 
            textWithNodesElement.setTextContent("");

            int start_offset = 0;
            boolean inicio = true;
//            System.out.println(node_offsets.toString());
            for (Integer offset : nodeOffsets) {
                if (start_offset == 0 && inicio || start_offset >= 0 && start_offset != offset) {
                    inicio = false;
                    if (start_offset >= 0 && offset <= text.length()) {
                        String aux;
                        if (offset > 0) {
                            aux = text.substring(start_offset, offset);
                            textWithNodesElement.appendChild(gateDoc.createTextNode(aux));
                        } /*else {
                         aux = text.substring(start_offset);
                         textWithNodesElement.appendChild(doc.createTextNode(aux));
                         }*/

                        Element n = gateDoc.createElement("Node");
                        n.setAttribute("id", offset + "");
                        textWithNodesElement.appendChild(n);
                        start_offset = offset;
                    }
                }
            }

            //añadimos el último fragmento de texto
            if (start_offset < text.length() && start_offset > 0) {
                textWithNodesElement.appendChild(gateDoc.createTextNode(text.substring(start_offset)));
            }
        }
    }

    private int obtainNextId(Document gateDoc, String textToAnalyze) {
        Element documentElement = gateDoc.getDocumentElement();
        //obtenemos el identificador para las nuevas anotaciones
        int minnewId = textToAnalyze.length() + 1;
        NodeList elementNamed = XMLUtils.getElementsNamed(documentElement, "AnnotationSet");
        for (int i = 0; i < elementNamed.getLength(); i++) {
            NodeList anotaciones = XMLUtils.getElementsNamed((Element) elementNamed.item(i), "Annotation");
            for (int j = 0; j < anotaciones.getLength(); j++) {
                Element e = (Element) anotaciones.item(j);
                int attribute = Integer.parseInt(e.getAttribute("Id"));
                if (minnewId < attribute) {
                    minnewId = attribute + 1;
                }
            }
        }
        return minnewId;
    }

    private static String convertPlainToGate(String text) {
        StringBuilder sb = new StringBuilder();
        sb.append("<?xml version='1.0' encoding='UTF-8'?>\n<GateDocument>\n<!-- The document's features-->\n");
        sb.append("<GateDocumentFeatures>\n<Feature>\n");
        sb.append("<Name className='java.lang.String'> MimeType</Name>\n");
        sb.append("<Value className='java.lang.String'> text/xml</Value>\n");
        sb.append("</Feature>\n</GateDocumentFeatures>");
        sb.append("<!-- The document content area with serialized nodes -->\n");
        sb.append("<TextWithNodes xml:space='preserve'>");
        sb.append(text);
        sb.append("\n");
        sb.append("</TextWithNodes>\n");
        sb.append("<AnnotationSet></AnnotationSet>\n<AnnotationSet Name='Original markups' ></AnnotationSet>\n");
        sb.append("</GateDocument>");
        return sb.toString();
    }

    private String loadInputFile(String inputText, String format) throws IOException, ParserConfigurationException, SAXException {
        if (format.equals(GATE)) {
            // Creamos el documento Gate y obtenemos el siguiente identificador
            Document gateDoc = XMLUtils.readXML(inputText, "UTF-8");
            // Obtain the gate text
            Element root = gateDoc.getDocumentElement();
            return XMLUtils.getElementNamed(root, "TextWithNodes").getTextContent();
        } else {
            return inputText;
        }
    }

    private Map<String, String> loadAcronyms(String langCode, String pathAcronyms) throws IOException {
        HashMap<String, String> acronyms = new HashMap<String, String>();
        try {
            // Leemos el fichero
            BufferedReader myReader;
            myReader = new BufferedReader(new FileReader(pathAcronyms));
            String line;
            while ((line = myReader.readLine()) != null) {
                String[] part_line = line.split(":");
                String acronym = part_line[0].trim();
                String def_acr = part_line[1].trim();
                acronyms.put(acronym, def_acr);
            }

        } catch (FileNotFoundException ex) {
            System.err.println(AcronymsException.ERROR1 + langCode);
        }
        return  Collections.synchronizedMap(acronyms);
    }

    private String obtainOffset(String textToAnalyze, String word, int end) {
        int start_offset = -1;
        int end_offset = -1;

        /* Detectamos si es multi-palabra */
        if (word.contains("_")) {
            start_offset = textToAnalyze.indexOf(word.substring(0, word.indexOf("_")), end);
            String[] tokens = word.split("_");
            int tam = 0;
            for (int i = 0; i < tokens.length; i++) {
                tam += tokens[i].length();
                if (textToAnalyze.substring(start_offset + tam, start_offset + tam + 1).equals(" ")) {
                    tam++;
                }
            }
            end_offset = start_offset + tam;

        } else {
            start_offset = textToAnalyze.indexOf(word, end);
            end_offset = start_offset + word.length();
        }
        return (start_offset + "-" + end_offset);
    }
}
//        Analyzer analyzer = new StandardAnalyzer(Version.LUCENE_34);
//        TokenStream stream = analyzer.tokenStream("", new StringReader(textToAnalyze));
//        CharTermAttribute termAtt = stream.getAttribute(CharTermAttribute.class);
//        while (stream.incrementToken()) {
//            System.out.println (new String(termAtt.buffer(), 0, termAtt.length()));
//        }
//  AÑADIR LIBRERIA LUCENE si se va a utilizar