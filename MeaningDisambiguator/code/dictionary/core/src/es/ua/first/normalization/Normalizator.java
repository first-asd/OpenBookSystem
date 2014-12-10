///*
// * To change this template, choose Tools | Templates
// * and open the template in the editor.
// */
//package es.ua.first.normalization;
//
//import es.ua.first.disambiguation.DisambiguationException;
//import es.ua.first.disambiguation.Word;
//import es.upv.xmlutils.XMLUtils;
//import java.io.BufferedInputStream;
//import java.io.BufferedReader;
//import java.io.BufferedWriter;
//import java.io.File;
//import java.io.FileNotFoundException;
//import java.io.FileReader;
//import java.io.FileWriter;
//import java.io.IOException;
//import java.io.InputStream;
//import java.io.InputStreamReader;
//import java.io.OutputStream;
//import java.net.HttpURLConnection;
//import java.net.MalformedURLException;
//import java.net.URL;
//import java.util.ArrayList;
//import java.util.HashMap;
//import java.util.List;
//import java.util.Map;
//import java.util.Properties;
//import java.util.TreeSet;
//import javax.xml.parsers.ParserConfigurationException;
//import org.w3c.dom.Document;
//import org.w3c.dom.Element;
//import org.w3c.dom.NodeList;
//import org.xml.sax.SAXException;
//
///**
// *
// * @author lcanales
// */
//public class Normalizator {
//
//    private static final String OOV = "OOV";
//    private static final String ACRONYMS = "ACRONYMS";
//    private static final String LANGES = "es";
//    private static final String LANGEN = "en";
//    private static final String LANGBG = "bg";
//    private Map<String, String> acronymnsES;
//    private Map<String, String> acronymnsEN;
//    private Map<String, String> oovBG;
//
//    public Normalizator(Properties defaultProps, String workingDir) throws FileNotFoundException, IOException {
//        // Cargamos los acronimos
//        acronymnsES = loadAcronyms(LANGES, defaultProps, workingDir);
//        acronymnsEN = loadAcronyms(LANGEN, defaultProps, workingDir);
//        // Cargamos diccionario OOV bg
//        oovBG = loadOOVBG(defaultProps, workingDir);
//    }
//
//    public String normalize(String pathInputFile, ArrayList<String> obstacles, String langCode, String workingDir) throws IOException, ParserConfigurationException, SAXException, DisambiguationException, InterruptedException, MalformedURLException, NormalizeException {
//        // NO ES GATE
//        String line;
//        StringBuilder textFile = new StringBuilder();
//        BufferedReader reader;
//        reader = new BufferedReader(new FileReader(pathInputFile));
//        while ((line = reader.readLine()) != null) {
//            textFile.append(line).append("\n");
//        }
//        reader.close();
//        String gateDocument = convertPlain2Gate(textFile.toString());
//
//        // Creamos el documento Gate y obtenemos el siguiente identificador
//        Document gateDoc = XMLUtils.readXML(gateDocument, "UTF-8");
//        // Obtain the gate text
//        Element root = gateDoc.getDocumentElement();
//        String textToAnalyze = XMLUtils.getElementNamed(root, "TextWithNodes").getTextContent();
//        // Create node offsets
//        TreeSet<Integer> nodeOffsets = new TreeSet<Integer>();
//        // Obtain a new Id
//        int minNewId = obtainNextId(gateDoc, textToAnalyze);
//
//        // Determinamos el script de Freeling
//        String scriptFreeling = (langCode.equals(LANGEN)) ? "freeling_en.sh"
//                : (langCode.equals(LANGES)) ? "freeling_es.sh"
//                : "treeTagger_bg.sh";
//
//        // Ejecutamos el script de FREELING o TREETAGER
//        File outputScript = runScript(textToAnalyze, scriptFreeling, workingDir);
//
//        // Parseamos la salida Freeling o TreeTagger
//        List<Word> words;
//        if (langCode.equals(LANGEN) || langCode.equals(LANGES)) {
//            words = parseFreeling(textToAnalyze, outputScript);
//        } else {
//            words = parseTreeTagger(textToAnalyze, outputScript);
//        }
//
//        for (String obstacle : obstacles) {
//            // Create annotation for this obstacle
//            Element annotationSetDisam = createNewAnnot(gateDoc, "Disambiguate markups " + obstacle);
//            if (obstacle.equals(OOV)) {
//                oov(gateDoc, annotationSetDisam, nodeOffsets, minNewId, words, langCode, obstacle);
//                return XMLUtils.toString(gateDoc);
//            } else if (obstacle.equals(ACRONYMS)) {
//                acronyms(gateDoc, annotationSetDisam, nodeOffsets, minNewId, words, langCode, obstacle);
//                return XMLUtils.toString(gateDoc);
//            } else {
//                throw new DisambiguationException(DisambiguationException.ERROR3);
//            }
//        }
//
//        return "";
//    }
//
//    private Map<String, String> loadAcronyms(String langCode, Properties defaultProps, String workingDir) throws FileNotFoundException, IOException {
//        HashMap<String, String> listAcronyms = new HashMap<String, String>();
//        BufferedReader readerAcronyms;
//        String file;
//        // Cargamos el fichero de los verbos mentales
//        if (langCode.equals(LANGBG)) {
//            file = workingDir + defaultProps.getProperty("pathAcronymsBG");
//        } else if (langCode.equals(LANGEN)) {
//            file = workingDir + defaultProps.getProperty("pathAcronymsEN");
//        } else {
//            file = workingDir + defaultProps.getProperty("pathAcronymsES");
//        }
//        // Leemos el fichero que corresponda en funcion del idioma
//        File freqAcronyms = new File(file);
//        readerAcronyms = new BufferedReader(new FileReader(freqAcronyms));
//        String line;
//        while ((line = readerAcronyms.readLine()) != null) {
//            String[] part_line = line.split(":");
//            // Acronimos - definicion
//            listAcronyms.put(part_line[0].trim(), part_line[1].trim());
//        }
//        readerAcronyms.close();
//        return listAcronyms;
//    }
//
//    private Map<String, String> loadOOVBG(Properties defaultProps, String workingDir) throws FileNotFoundException, IOException {
//        HashMap<String, String> oovbg = new HashMap<String, String>();
//        String file = workingDir + defaultProps.getProperty("pathOOVBG");
//        File fin = new File(file);
//        BufferedReader reader;
//        reader = new BufferedReader(new FileReader(fin));
//        String line;
//        while ((line = reader.readLine()) != null) {
//            String[] split = line.split(":");
//            oovbg.put(split[0].trim(), split[1].trim());
//        }
//        reader.close();
//        return oovbg;
//    }
//
//    private int obtainNextId(Document gateDoc, String textToAnalyze) {
//        Element documentElement = gateDoc.getDocumentElement();
//        //obtenemos el identificador para las nuevas anotaciones
//        int minnewId = textToAnalyze.length() + 1;
//        NodeList elementNamed = XMLUtils.getElementsNamed(documentElement, "AnnotationSet");
//        for (int i = 0; i < elementNamed.getLength(); i++) {
//            NodeList anotaciones = XMLUtils.getElementsNamed((Element) elementNamed.item(i), "Annotation");
//            for (int j = 0; j < anotaciones.getLength(); j++) {
//                Element e = (Element) anotaciones.item(j);
//                int attribute = Integer.parseInt(e.getAttribute("Id"));
//                if (minnewId < attribute) {
//                    minnewId = attribute + 1;
//                }
//            }
//        }
//        return minnewId;
//    }
//
//    private File runScript(String textToAnalyze, String namescript, String workingDir) throws IOException, InterruptedException {
//        // Generamos un fichero a partir del texto de entrada 
//        File tempFileInput = File.createTempFile("entrada", ".txt");
//        BufferedWriter out = new BufferedWriter(new FileWriter(tempFileInput));
//        out.write(textToAnalyze);
//        out.close();
//
//        // Generamos un fichero para almacenar la salida del comando
//        File tempFileOutput = File.createTempFile("salida", ".txt");
//        tempFileOutput.deleteOnExit();
//
//        // Ejecutamos el script que contiene el comando para ejecutar freeling
//        String[] cd = {"/bin/sh", "-c", "scripts/" + namescript + " " + tempFileInput.getAbsolutePath() + " MFS " + tempFileOutput.getAbsolutePath()};
//        Process child = Runtime.getRuntime().exec(cd, new String[0], new File(workingDir));
//        child.waitFor();
//
//        // Elimino el fichero temporal de entrada
//        tempFileInput.delete();
//
//        // Leememos la salida de error producida por el comando 
//        java.io.BufferedReader r2 = new java.io.BufferedReader(new java.io.InputStreamReader(child.getErrorStream()));
//        String s;
//        boolean excepcion = false;
//        StringBuilder bferror = new StringBuilder();
//        while ((s = r2.readLine()) != null) {
//            System.err.println(s);
//            if (!namescript.equals("treeTagger_bg.sh")) {
//                excepcion = true;
//            }
//            bferror.append(s).append("\n");
//        }
//        child.getOutputStream().close();
//        child.getInputStream().close();
//        child.getErrorStream().close();
//        child.destroy();
//
//        if (excepcion) {
//            throw new IOException(bferror.toString());
//        }
//        return tempFileOutput;
//    }
//
//    private List<Word> parseFreeling(String textToAnalyze, File outFreeling) throws FileNotFoundException, IOException {
//        List<Word> words = new ArrayList<Word>();
//        FileReader fr;
//        BufferedReader br;
//        String line;
//        String offsets = "0-0";
//        fr = new FileReader(outFreeling);
//        br = new BufferedReader(fr);
//        while ((line = br.readLine()) != null) {
//            if (!line.equals("")) {
//                String[] part_line = line.split("\\s+");
//                // word
//                String wordText = part_line[0];
//                // lemma
//                String lemma = part_line[1];
//                if (lemma.contains("+")) {
//                    String[] part_lemma = lemma.split("\\+");
//                    lemma = part_lemma[0];
//                }
//                if (!lemma.equals("s") && !lemma.equals("S")) {
//                    // POS
//                    String pos = part_line[2];
//                    if (pos.startsWith("J")) {
//                        pos = "A";
//                    }
//                    // start_off y end_off
//                    int end = Integer.parseInt(offsets.split("-")[1]);
//                    offsets = obtainOffset(textToAnalyze, wordText, end);
//                    int start_offset = Integer.parseInt(offsets.split("-")[0]);
//                    int end_offset = Integer.parseInt(offsets.split("-")[1]);
//
//                    Word word = new Word(lemma, pos, start_offset, end_offset, wordText);
//                    words.add(word);
//                }
//            }
//        }
//        fr.close();
//        br.close();
//        outFreeling.delete();
//        return words;
//    }
//
//    private String obtainOffset(String textToAnalyze, String word, int end) {
//        int start_offset = -1;
//        int end_offset = -1;
//
//        /* Detectamos si es multi-palabra */
//        if (word.contains("_")) {
//            start_offset = textToAnalyze.indexOf(word.substring(0, word.indexOf("_")), end);
//            String[] tokens = word.split("_");
//            int tam = 0;
//            for (int i = 0; i < tokens.length; i++) {
//                tam += tokens[i].length();
//                if (textToAnalyze.substring(start_offset + tam, start_offset + tam + 1).equals(" ")) {
//                    tam++;
//                }
//            }
//            end_offset = start_offset + tam;
//
//        } else {
//            start_offset = textToAnalyze.indexOf(word, end);
//            end_offset = start_offset + word.length();
//        }
//        return (start_offset + "-" + end_offset);
//    }
//
//    private List<Word> parseTreeTagger(String textToAnalyze, File outTreeTagger) throws FileNotFoundException, IOException {
//        List<Word> words = new ArrayList<Word>();
//        FileReader fr;
//        BufferedReader br;
//        String line;
//        String offsets = "0-0";
//        fr = new FileReader(outTreeTagger);
//        br = new BufferedReader(fr);
//        while ((line = br.readLine()) != null) {
//            if (!line.equals("")) {
//                String[] part_line = line.split("\\s+");
//                if (!part_line[0].equals("")) {
//                    // word
//                    String wordText = part_line[0];
//                    // lemma
//                    String lemma = part_line[2];
//                    if (lemma.contains("+")) {
//                        String[] part_lemma = lemma.split("+");
//                        lemma = part_lemma[0];
//                    }
//                    // pos
//                    String pos = part_line[1].substring(0, 1);
//                    // offsets
//                    int end = Integer.parseInt(offsets.split("-")[1]);
//                    offsets = obtainOffset(textToAnalyze, wordText, end);
//                    int start_offset = Integer.parseInt(offsets.split("-")[0]);
//                    int end_offset = Integer.parseInt(offsets.split("-")[1]);
//
//                    // Creamos la palabra y añadimos a la lista 
//                    Word word = new Word(wordText, pos, start_offset, end_offset, wordText);
//                    words.add(word);
//                }
//            }
//        }
//        fr.close();
//        br.close();
//        outTreeTagger.delete();
//        return words;
//    }
//
//    private Element createNewAnnot(Document doc, String annotSetName) {
//        //creamos el nuevos annotationset
//        Element root = doc.getDocumentElement();
//        Element anotationSetDisam = doc.createElement("AnnotationSet");
//        anotationSetDisam.setAttribute("Name", annotSetName);
//        root.appendChild(anotationSetDisam);
//        return anotationSetDisam;
//    }
//
//    private int oov(Document gateDoc, Element annotationSetDisam, TreeSet<Integer> nodeOffsets, int id, List<Word> words, String langCode, String obstacle) throws MalformedURLException, IOException, NormalizeException {
//        for (Word word : words) {
//            String normalizedToken = getNormalizedToken(word.getWord(), langCode).toLowerCase();
//            if (normalizedToken.length() > 1) {
//                normalizedToken = normalizedToken.substring(0, normalizedToken.length() - 1);
//            }
//            if (!normalizedToken.equals(word.getWord().toLowerCase())) {
//                word.setTypeWord(OOV);
//                id = createAnnotation(gateDoc, annotationSetDisam, nodeOffsets, id, word, normalizedToken);
//            }
//        }
//        return id;
//    }
//
//    public String getNormalizedToken(String token, String langCode) throws MalformedURLException, IOException, NormalizeException {
//        String normalized = token;
//        if (langCode.equals(LANGES) || langCode.equals(LANGEN)) {
//            normalized = tenor(token, langCode);
//        } else if (langCode.equals(LANGBG)) {
//            normalized = consultOOVDictionaryBG(token);
//        } else {
//            throw new NormalizeException(DisambiguationException.ERROR4);
//        }
//        return normalized;
//    }
//
//    private String tenor(String token, String langCode) throws MalformedURLException, IOException, NormalizeException {
//        String normalized = token;
//        // Consultamos a la web de TENOR
//        URL url = new URL("http://intime.dlsi.ua.es/tenor");
//        HttpURLConnection connection = (sun.net.www.protocol.http.HttpURLConnection) url.openConnection();
//        connection.setDoOutput(true);
//        connection.setDoInput(true);
//        // Indicamos el idioma y el token a procesar
//        OutputStream outputStream = connection.getOutputStream();
//        if (langCode.equals(LANGES)) {
//            outputStream.write(("text=" + token + "&op=73N0R35").getBytes());
//        } else if (langCode.equals(LANGEN)) {
//            outputStream.write(("text=" + token + "&op=73N0R3N").getBytes());
//        } else {
//            throw new NormalizeException(DisambiguationException.ERROR4);
//        }
//        // Llamamos a TENOR
//        connection.connect();
//        // Obtenemos la respuesta
//        InputStream inputStream = connection.getInputStream();
//        StringBuilder sb = new StringBuilder();
//        BufferedInputStream bis = new BufferedInputStream(inputStream);
//        InputStreamReader ris = new InputStreamReader(bis, "UTF-8");
//        char[] buffer = new char[1024];
//        while (ris.ready()) {
//            int len = ris.read(buffer);
//            sb.append(buffer, 0, len);
//        }
//        ris.close();
//        normalized = sb.toString();
//        return normalized;
//    }
//
//    private String consultOOVDictionaryBG(String token) {
//        String normalizado = oovBG.get(token);
//        return (normalizado != null) ? normalizado : token;
//    }
//
//    private int createAnnotation(Document gateDoc, Element annotationSetDisam, TreeSet<Integer> nodeOffsets, int id, Word word, String normalizedToken) {
//        Element definitionElement = gateDoc.createElement("Annotation");
//        String idDefinition = Integer.toString(id);
//        definitionElement.setAttribute("Id", idDefinition);
//        definitionElement.setAttribute("StartNode", word.getStart_offset() + "");
//        definitionElement.setAttribute("EndNode", word.getEnd_offset() + "");
//        definitionElement.setAttribute("Type", "Definition");
//        annotationSetDisam.appendChild(definitionElement);
//
//        // Add definition
//        Element feature = gateDoc.createElement("Feature");
//        definitionElement.appendChild(feature);
//        Element name = gateDoc.createElement("Name");
//        name.setAttribute("className", "java.lang.String");
//        name.setTextContent("definition");
//        feature.appendChild(name);
//        Element value = gateDoc.createElement("Value");
//        value.setAttribute("className", "java.lang.String");
//        value.setTextContent(normalizedToken);
//        feature.appendChild(value);
//        // Add Token
//        feature = gateDoc.createElement("Feature");
//        definitionElement.appendChild(feature);
//        name = gateDoc.createElement("Name");
//        name.setAttribute("className", "java.lang.String");
//        name.setTextContent("token");
//        feature.appendChild(name);
//        value = gateDoc.createElement("Value");
//        value.setAttribute("className", "java.lang.String");
//        value.setTextContent(word.getWord().toUpperCase());
//        feature.appendChild(value);
//
//        id++;
//        nodeOffsets.add(word.getStart_offset());
//        nodeOffsets.add(word.getEnd_offset());
//        return id;
//    }
//
//    private int acronyms(Document gateDoc, Element annotationSetDisam, TreeSet<Integer> nodeOffsets, int id, List<Word> words, String langCode, String obstacle) throws NormalizeException {
//        // Determinamos la lista en funcion del idioma
//        Map<String, String> listAcronyms = langCode.equals(LANGES) ? acronymnsES : langCode.equals(LANGEN) ? acronymnsEN : null;
//        // Aun no esta disponible la lista de acronimos para el bulgaro
//        if (listAcronyms == null) {
//            throw new NormalizeException(NormalizeException.ERROR4);
//        }
//        // analizamos palabra a palabra
//        for (Word word : words) {
//            if (listAcronyms.containsKey(word.getWord())) {
//                word.setTypeWord(ACRONYMS);
//                id = createAnnotation(gateDoc, annotationSetDisam, nodeOffsets, id, word, listAcronyms.get(word.getWord()));
//            }
//        }
//        // insertamos los Nodes
//        insertNodeGateDocument(gateDoc, nodeOffsets);
//        return id;
//    }
//
//    private void insertNodeGateDocument(Document gateDoc, TreeSet<Integer> nodeOffsets) {
//        Element documentElement = gateDoc.getDocumentElement();
//        Element textWithNodesElement = XMLUtils.getElementNamed(documentElement, "TextWithNodes");
//        String text = textWithNodesElement.getTextContent();
//        textWithNodesElement.setAttribute("xml:space", "preserve");
//        //si hemos añadido alguna anotación, borramos el texto completo.
//        if (!nodeOffsets.isEmpty()) {
//            //añadimos los offsets que existan previamente
//            NodeList previousNodes = XMLUtils.getElementsNamed(textWithNodesElement, "Node");
//            for (int nodes = 0; nodes < previousNodes.getLength(); nodes++) {
//                Element n = (Element) previousNodes.item(nodes);
//                nodeOffsets.add(Integer.parseInt(n.getAttribute("id")));
//            }
//            //borramos el contenido previo en la sección textwithnodeselement 
//            textWithNodesElement.setTextContent("");
//            int start_offset = 0;
//            boolean inicio = true;
//            for (Integer offset : nodeOffsets) {
//                if (start_offset == 0 && inicio || start_offset >= 0 && start_offset != offset) {
//                    inicio = false;
//                    if (start_offset >= 0 && offset < text.length()) {
//                        String aux;
//                        if (offset > 0) {
//                            aux = text.substring(start_offset, offset);
//                            textWithNodesElement.appendChild(gateDoc.createTextNode(aux));
//                        } /*else {
//                         aux = text.substring(start_offset);
//                         textWithNodesElement.appendChild(doc.createTextNode(aux));
//                         }*/
//
//                        Element n = gateDoc.createElement("Node");
//                        n.setAttribute("id", offset + "");
//                        textWithNodesElement.appendChild(n);
//                        start_offset = offset;
//                    }
//                }
//            }
//            //añadimos el último fragmento de texto
//            if (start_offset < text.length() && start_offset > 0) {
//                textWithNodesElement.appendChild(gateDoc.createTextNode(text.substring(start_offset)));
//            }
//        }
//    }
//
//    private String convertPlain2Gate(String text) {
//        StringBuilder sb = new StringBuilder();
//        sb.append("<?xml version='1.0' encoding='UTF-8'?>\n<GateDocument>\n<!-- The document's features-->\n");
//        sb.append("<GateDocumentFeatures>\n<Feature>\n");
//        sb.append("<Name className='java.lang.String'> MimeType</Name>\n");
//        sb.append("<Value className='java.lang.String'> text/xml</Value>\n");
//        sb.append("</Feature>\n</GateDocumentFeatures>");
//        sb.append("<!-- The document content area with serialized nodes -->\n");
//        sb.append("<TextWithNodes xml:space='preserve'>");
//        sb.append(text);
//        sb.append("\n");
//        sb.append("</TextWithNodes>\n");
//        sb.append("<AnnotationSet></AnnotationSet>\n<AnnotationSet Name='Original markups' ></AnnotationSet>\n");
//        sb.append("</GateDocument>");
//
//        return sb.toString();
//    }
//}
