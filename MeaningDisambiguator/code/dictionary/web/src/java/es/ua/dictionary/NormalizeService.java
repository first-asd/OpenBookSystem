///*
// * To change this template, choose Tools | Templates
// * and open the template in the editor.
// */
//package es.ua.dictionary;
//
//import com.fasterxml.jackson.core.JsonFactory;
//import com.fasterxml.jackson.core.JsonParseException;
//import com.fasterxml.jackson.core.JsonParser;
//import com.fasterxml.jackson.core.JsonToken;
//import es.ua.dictionary.ParamsJSON.Language;
//import es.ua.dictionary.ParamsJSON.TypeWords;
//import es.upv.xmlutils.XMLUtils;
//import java.io.BufferedReader;
//import java.io.BufferedWriter;
//import java.io.File;
//import java.io.FileInputStream;
//import java.io.FileNotFoundException;
//import java.io.FileReader;
//import java.io.FileWriter;
//import java.io.IOException;
//import java.io.InputStreamReader;
//import java.io.UnsupportedEncodingException;
//import java.util.ArrayList;
//import java.util.HashMap;
//import java.util.List;
//import java.util.Map;
//import java.util.Properties;
//import java.util.TreeSet;
//import java.util.logging.Level;
//import java.util.logging.Logger;
//import javax.jws.WebService;
//import javax.jws.WebMethod;
//import javax.jws.WebParam;
//import javax.servlet.ServletContext;
//import javax.xml.parsers.ParserConfigurationException;
//import net.sf.json.JSONArray;
//import net.sf.json.JSONObject;
//import net.sf.json.JSONSerializer;
//import org.apache.http.HttpEntity;
//import org.apache.http.HttpResponse;
//import org.apache.http.NameValuePair;
//import org.apache.http.client.ClientProtocolException;
//import org.apache.http.client.HttpClient;
//import org.apache.http.client.entity.UrlEncodedFormEntity;
//import org.apache.http.client.methods.HttpPost;
//import org.apache.http.impl.client.DefaultHttpClient;
//import org.apache.http.message.BasicNameValuePair;
//import org.w3c.dom.Document;
//import org.w3c.dom.Element;
//import org.w3c.dom.NodeList;
//import org.xml.sax.SAXException;
//
///**
// *
// * @author lcanales
// */
//@WebService(serviceName = "NormalizeService", targetNamespace = "http://first-asd.eu/service/")
//public class NormalizeService {
//
//    public static String webAppPath = null;
//    private static String configFile = "config/dictionary.properties";
//    private static Map<String, String> acronymnsES = null;
//    private static Map<String, String> acronymnsEN = null;
//    private static Map<String, String> oovBG = null;
//    private ArrayList<TypeWords> typeWords;
//    private Language language;
//    private String textAnalyze;
//    private Document doc = null;
//    private int minNewId;
//    private Element anotationsetDisam;
//    private TreeSet<Integer> node_offsets = null;
//
//    /**
//     * Method init
//     *
//     * @param servletContext
//     */
//    public static void init(ServletContext servletContext) throws NormalizeException {
//        try {
//            webAppPath = servletContext.getRealPath("/");
//
//            /* Fichero de propiedades */
//            FileInputStream in = null;
//            Properties defaultProps = new Properties();
//            in = new FileInputStream(webAppPath + configFile);
//            defaultProps.load(in);
//            in.close();
//
//            /* Cargamos los acronimos*/
//            acronymnsES = loadAcronyms(ParamsJSON.Language.ES, defaultProps);
//            System.out.println("FIRST WSNORMALIZE: Load List of acronyms ES");
//            acronymnsEN = loadAcronyms(ParamsJSON.Language.EN, defaultProps);
//            System.out.println("FIRST WSNORMALIZE: Load List of acronyms EN");
//
//            /* Cargamos diccionario OOV bg*/
//            oovBG = loadOOV(ParamsJSON.Language.BG, defaultProps);
//            System.out.println("FIRST WSNORMALIZE: DESPLIEGUE WS DISAMBIGUATE OK");
//
//        } catch (IOException ex) {
//            throw new NormalizeException(ex);
//        }
//    }
//
//    /**
//     * Method destroy
//     *
//     * @param servletContext
//     */
//    static void destroy(ServletContext servletContext) {
//    }
//
//    /**
//     * Web service operation
//     */
//    @WebMethod(operationName = "normalize")
//    public String normalize(@WebParam(name = "text") String text, @WebParam(name = "jsonParameters") String jsonParameters) throws NormalizeException {
//        try {
//            // obtain parameters
//            this.textAnalyze = text;
//            ParamsJSON params = parseJSON(jsonParameters);
//            this.typeWords = params.getTypeWords();
//            this.language = params.getLang();
//
//            // Creamos el documento Gate y obtenemos el siguiente identificador
//            readGateDocument();
//            minNewId = obtainNextId();
//
//            // Lista de palabras detectadas por Freeling o TreeTagger
//            List<Word> words = new ArrayList<Word>();
//
//            // Determinamos el script de Freeling 
//            String scriptFreeling = (language == ParamsJSON.Language.EN) ? "freeling_en.sh"
//                    : (language == ParamsJSON.Language.ES) ? "freeling_es.sh"
//                    : "treeTagger_bg.sh";
//
//            try {
//                // Procesamos el texto en FREELING o TREETAGER 
//                File outputScript = runScript(textAnalyze, scriptFreeling);
//
//                // Parseamos la salida Freeling o TreeTagger
//                if (language == ParamsJSON.Language.EN || language == ParamsJSON.Language.ES) {
//                    words = parseFreeling(outputScript);
//                } else {
//                    words = parseTreeTagger(outputScript);
//                }
//
//            } catch (InterruptedException ex) {
//                throw new NormalizeException(ex);
//            }
//
//            // Resolvemos el tipo de palabra que se nos indique en los parametros
//            for (TypeWords typeWord : this.typeWords) {
//                createAnnotationSet(typeWord);
//                switch (typeWord) {
//                    case ACRONYMS:
//                        acronyms(words);
//                        break;
//                    case OOV:
//                        outOfVocabulary(words);
//                        break;
//                    default:
//                        throw new NormalizeException(NormalizeException.ERROR3, typeWord.toString());
//                }
//            }
//
//            return XMLUtils.toString(doc);
//        } catch (IOException ex) {
//            throw new NormalizeException(ex);
//        }
//    }
//
//    /**
//     * Realizamos la deteccion de los acronimos a partir de las palabras
//     * detectadas en Freeling
//     *
//     * @param words
//     * @return
//     * @throws NormalizeException
//     */
//    private void acronyms(List<Word> words) throws NormalizeException {
//        String acronyms = "";                  // LISTA ESTÁ EN MAYUSCULA O MINUSCULA??????????????
////        try {
//        // Determinamos la lista en funcion del idioma
//        Map<String, String> listAcronyms = this.language == Language.ES ? acronymnsES : this.language == Language.EN ? acronymnsEN : null;
//
//        // Aun no esta disponible la lista de acronimos para el bulgaro
//        if (listAcronyms == null) {
//            throw new NormalizeException(NormalizeException.ERROR4);
//        }
//
//        // analizamos palabra a palabra
//        for (Word word : words) {
//            if (listAcronyms.containsKey(word.getWord())) {
//                word.setTypeWord(ParamsJSON.TypeWords.ACRONYMS.toString());
//                acronyms = createAnnotation(word, listAcronyms.get(word.getWord()));
//            }
//        }
//
//        // insertamos los Nodes
//        insertNodeGateDocument();
////            acronyms = XMLUtils.toString(doc);
////        } catch (IOException ex) {
////            throw new NormalizeException(ex);
////        }
////        return acronyms;
//    }
//
//    private void outOfVocabulary(List<Word> words) throws NormalizeException {
//        String oov = "";
////        try {
//        for (Word word : words) {
////                String normalizedToken = getNormalizedToken(word.getWord(), this.language);
//            if (!word.getPOS().startsWith("F") && !word.getPOS().startsWith("Z") && !word.getPOS().startsWith("W")) {
//                String normalizedToken = getNormalizedToken(word.getWord(), this.language).toLowerCase();
//                if (this.language != ParamsJSON.Language.BG) {
//                    normalizedToken = normalizedToken.substring(0, normalizedToken.length() - 1);
//                }
//
//                if (!normalizedToken.equals(word.getWord().toLowerCase())) { //la palabra ha sido normalizada
//                    word.setTypeWord(ParamsJSON.TypeWords.OOV.toString());
//                    oov = createAnnotation(word, normalizedToken);
//                }
//            }
//        }
//
//        // insertamos los Nodes
//        insertNodeGateDocument();
////            oov = XMLUtils.toString(doc);
////        } catch (IOException ex) {
////            throw new NormalizeException(ex);
////        }
////        return oov;
//    }
//
//    /**
//     * funciones para consultar OOV - de isa *
//     */
//    public static String getNormalizedToken(String token, ParamsJSON.Language lang) throws NormalizeException {
//        String normalized = token;
//        if (lang.equals(ParamsJSON.Language.ES) || lang.equals(ParamsJSON.Language.EN)) {
//            normalized = tenor(token, lang);
//        } else if (lang.equals(ParamsJSON.Language.BG)) {
//            normalized = consultOOVDictionaryBG(token);
//        } else {
//            throw new NormalizeException(NormalizeException.ERROR5);
//        }
//        return normalized;
//    }
//
//    /**
//     * Consultamos Tenor para normalizar
//     *
//     * @param token
//     * @param lang
//     * @return
//     */
//    private static String tenor(String token, ParamsJSON.Language lang) throws NormalizeException {
//        String normalized = token;
//        try {
//            String line;
//            BufferedReader reader;
//
//            // consultamos la web de Tenor
//            HttpClient httpClient = new DefaultHttpClient();
//            HttpPost method = new HttpPost("http://intime.dlsi.ua.es/tenor");
//            List<NameValuePair> nvps = new ArrayList<NameValuePair>();
//
//            // indicamos el idioma
//            if (lang.equals(ParamsJSON.Language.ES)) {
//                nvps.add(new BasicNameValuePair("op", "73N0R35")); //es: 73N0R35
//            } else {
//                if (lang.equals(ParamsJSON.Language.EN)) {
//                    nvps.add(new BasicNameValuePair("op", "73N0R3N")); //en: 73N0R3N
//                } else {
//                    throw new NormalizeException(NormalizeException.ERROR4);
//                }
//            }
//
//            // indicamos el token que queremos procesar
//            nvps.add(new BasicNameValuePair("text", token));
//            method.setEntity(new UrlEncodedFormEntity(nvps));
//
//            // llamamos a Tenor
//            HttpResponse response = httpClient.execute(method);
//            HttpEntity entity = response.getEntity();
//
//            // obtenemos la respuesta
//            reader = new BufferedReader(new InputStreamReader(entity.getContent()));
//            if ((line = reader.readLine()) != null) {
//                normalized = line;
//            }
//            reader.close();
//
//        } catch (UnsupportedEncodingException ex) {
//            throw new NormalizeException(ex);
//        } catch (ClientProtocolException ex) {
//            throw new NormalizeException(ex);
//        } catch (IOException ex) {
//            throw new NormalizeException(ex);
//        }
//        return normalized;
//    }
//
//    /**
//     * Consultamos una lista de terminos normalizados en el caso del Búlgaro
//     * (TENOR no esta disponible para BG).
//     *
//     * @param token
//     * @return
//     */
//    private static String consultOOVDictionaryBG(String token) {
//        String normalizado = oovBG.get(token);
//        return (normalizado != null) ? normalizado : token;
//    }
//
//    private String createAnnotation(Word word, String definition) throws NormalizeException {
//        String annotation = "";
//        try {
//            Element definitionElement = doc.createElement("Annotation");
//            String idDefinition = Integer.toString(minNewId);
//            definitionElement.setAttribute("Id", idDefinition);
//            definitionElement.setAttribute("StartNode", word.getStart_offset() + "");
//            definitionElement.setAttribute("EndNode", word.getEnd_offset() + "");
//            definitionElement.setAttribute("Type", "Definition");
//            anotationsetDisam.appendChild(definitionElement);
//
//            /* Add definition */
//            Element feature = doc.createElement("Feature");
//            definitionElement.appendChild(feature);
//            Element name = doc.createElement("Name");
//            name.setAttribute("className", "java.lang.String");
//            name.setTextContent("definition");
//            feature.appendChild(name);
//            Element value = doc.createElement("Value");
//            value.setAttribute("className", "java.lang.String");
//            value.setTextContent(definition);
//            feature.appendChild(value);
//
//            feature = doc.createElement("Feature");
//            definitionElement.appendChild(feature);
//            name = doc.createElement("Name");
//            name.setAttribute("className", "java.lang.String");
//            name.setTextContent("token");
//            feature.appendChild(name);
//            value = doc.createElement("Value");
//            value.setAttribute("className", "java.lang.String");
//            value.setTextContent(word.getWord().toUpperCase());
//            feature.appendChild(value);
//
//            minNewId++;
//            node_offsets.add(word.getStart_offset());
//            node_offsets.add(word.getEnd_offset());
//
//            annotation = XMLUtils.toString(doc);
//            return annotation;
//        } catch (IOException ex) {
//            throw new NormalizeException(ex);
//        }
//    }
//
//    /**
//     * Método en el que insertamos los nodos con los offset en el texto con
//     * formato GATE.
//     */
//    private void insertNodeGateDocument() {
//        Element documentElement = doc.getDocumentElement();
//        Element textWithNodesElement = XMLUtils.getElementNamed(documentElement, "TextWithNodes");
//
//        String text = textWithNodesElement.getTextContent();
//        textWithNodesElement.setAttribute("xml:space", "preserve");
//
//        //si hemos añadido alguna anotación, borramos el texto completo.
//        if (!node_offsets.isEmpty()) {
//
//            //añadimos los offsets que existan previamente
//            NodeList previousNodes = XMLUtils.getElementsNamed(textWithNodesElement, "Node");
//
//            for (int nodes = 0; nodes < previousNodes.getLength(); nodes++) {
//                Element n = (Element) previousNodes.item(nodes);
//                node_offsets.add(Integer.parseInt(n.getAttribute("id")));
//            }
//
//            //borramos el contenido previo en la sección textwithnodeselement 
//            textWithNodesElement.setTextContent("");
//
//            int start_offset = 0;
//            boolean inicio = true;
////            System.out.println(node_offsets.toString());
//            for (Integer offset : node_offsets) {
//                if (start_offset == 0 && inicio || start_offset >= 0 && start_offset != offset) {
//                    inicio = false;
//                    if (start_offset >= 0 && offset < text.length()) {
//                        String aux;
//                        if (offset > 0) {
//                            aux = text.substring(start_offset, offset);
//                            textWithNodesElement.appendChild(doc.createTextNode(aux));
//                        } /*else {
//                         aux = text.substring(start_offset);
//                         textWithNodesElement.appendChild(doc.createTextNode(aux));
//                         }*/
//
//                        Element n = doc.createElement("Node");
//                        n.setAttribute("id", offset + "");
//                        textWithNodesElement.appendChild(n);
//                        start_offset = offset;
//                    }
//                }
//            }
//
//            //añadimos el último fragmento de texto
//            if (start_offset < text.length() && start_offset > 0) {
//                textWithNodesElement.appendChild(doc.createTextNode(text.substring(start_offset)));
//            }
//        }
//    }
//
//    private List<Word> parseFreeling(File outFreeling) throws NormalizeException {
//        List<Word> words = new ArrayList<Word>();
//        try {
//            FileReader fr = null;
//            BufferedReader br = null;
//            String line = "";
//            String offsets = "0-0";
//
//            fr = new FileReader(outFreeling);
//            br = new BufferedReader(fr);
//            while ((line = br.readLine()) != null) {
//                if (!line.equals("")) {
//                    String[] part_line = line.split("\\s+");
//
//                    int posIds = part_line.length - 1;
//
//                    // word
//                    String wordText = part_line[0];
//
//                    // lemma
//                    String lemma = part_line[1];
////                    if (lemma.contains("+")) {
////                        String[] part_lemma = lemma.split("\\+");
////                        lemma = part_lemma[0];
////                    }
//
//                    if (!lemma.equals("s") && !lemma.equals("S")) {
//                        // POS
//                        String pos = part_line[2];
//                        if (pos.startsWith("J")) {
//                            pos = "A";
//                        }
//
//                        // start_off y end_off
//                        int end = Integer.parseInt(offsets.split("-")[1]);
//                        offsets = obtainOffset(wordText, end);
//                        int start_offset = Integer.parseInt(offsets.split("-")[0]);
//                        int end_offset = Integer.parseInt(offsets.split("-")[1]);
//
//                        Word word = new Word(lemma, pos, start_offset, end_offset, wordText);
//                        words.add(word);
//                    }
//                }
//            }
//            fr.close();
//            br.close();
//            outFreeling.delete();
//        } catch (IOException ex) {
//            throw new NormalizeException(ex);
//        }
//        return words;
//    }
//
//    /**
//     * Método en el que parseamos la salida de Tree-tagger para el búlgaro.
//     *
//     * @return Lista de palabras que detecta freeling, con la información
//     * morfólogica.
//     */
//    private List<Word> parseTreeTagger(File outTreeTagger) throws NormalizeException {
//        List<Word> words = new ArrayList<Word>();
//        try {
//            FileReader fr = null;
//            BufferedReader br = null;
//            String line = "";
//            String offsets = "0-0";
//            fr = new FileReader(outTreeTagger);
//            br = new BufferedReader(fr);
//            while ((line = br.readLine()) != null) {
//                if (!line.equals("")) {
//                    String[] part_line = line.split("\\s+");
//                    if (!part_line[0].equals("")) {
//
//                        // word
//                        String wordText = part_line[0];
//
//                        // lemma
//                        String lemma = part_line[2];
//                        if (lemma.contains("+")) {
//                            String[] part_lemma = lemma.split("+");
//                            lemma = part_lemma[0];
//                        }
//                        // pos
//                        String pos = part_line[1].substring(0, 1);
//
//                        // offsets
//                        int end = Integer.parseInt(offsets.split("-")[1]);
//                        offsets = obtainOffset(wordText, end);
//                        int start_offset = Integer.parseInt(offsets.split("-")[0]);
//                        int end_offset = Integer.parseInt(offsets.split("-")[1]);
//
//                        // Creamos la palabra y añadimos a la lista 
//                        Word word = new Word(wordText, pos, start_offset, end_offset, wordText);
//                        words.add(word);
//                    }
//                }
//            }
//            fr.close();
//            br.close();
//            outTreeTagger.delete();
//
//        } catch (IOException ex) {
//            throw new NormalizeException(ex);
//        }
//        return words;
//    }
//
//    /**
//     * Método en el que obtenemos el Offset de una palabra.
//     *
//     * @param word Linea que nos devuelve Freeling o Tree-Tagger, separada por
//     * palabras.
//     * @param end Método que nos indica el último offset que hemos calculado.
//     * @return String que contiene el offset donde empieza la palabra y donde
//     * termina.
//     */
//    private String obtainOffset(String word, int end) {
//
//        int start_offset = -1;
//        int end_offset = -1;
//
//        /* Detectamos si es multi-palabra */
//        if (word.contains("_")) {
//            start_offset = textAnalyze.indexOf(word.substring(0, word.indexOf("_")), end);
//            String[] tokens = word.split("_");
//            int tam = 0;
//            for (int i = 0; i < tokens.length; i++) {
//                tam += tokens[i].length();
//                if (textAnalyze.substring(start_offset + tam, start_offset + tam + 1).equals(" ")) {
//                    tam++;
//                }
//            }
//            end_offset = start_offset + tam;
//
//        } else {
//            start_offset = textAnalyze.indexOf(word, end);
//            end_offset = start_offset + word.length();
//        }
//
//        return (start_offset + "-" + end_offset);
//    }
//
//    /**
//     * Method to load the Acronyms for each language
//     *
//     * @param language
//     * @param defaultProps
//     * @return
//     * @throws NormalizeException
//     */
//    private static Map<String, String> loadAcronyms(Language language, Properties defaultProps) throws NormalizeException {
//        HashMap<String, String> listAcronyms = new HashMap<String, String>();
//        try {
//            BufferedReader readerAcronyms = null;
//            String file = null;
//
//            // Cargamos el fichero de los verbos mentales
//            if (language == Language.BG) {
//                file = defaultProps.getProperty("pathAcronymsBG");
//            } else if (language == Language.EN) {
//                file = defaultProps.getProperty("pathAcronymsEN");
//            } else {
//                file = defaultProps.getProperty("pathAcronymsES");
//            }
//
//            // Leemos el fichero que corresponda en funcion del idioma
//            File freqAcronyms = new File(file);
//            if (!freqAcronyms.exists()) {
//                throw new NormalizeException(NormalizeException.ERROR1, file);
//            }
//            readerAcronyms = new BufferedReader(new FileReader(freqAcronyms));
//            String line = "";
//            while ((line = readerAcronyms.readLine()) != null) {
//                String[] part_line = line.split(":");
//                // Acronimos - definicion
//                listAcronyms.put(part_line[0].trim(), part_line[1].trim());
//            }
//            readerAcronyms.close();
//        } catch (IOException ex) {
//            throw new NormalizeException(ex);
//        }
//        return listAcronyms;
//    }
//
//    /**
//     * Method to load out of vocabulary for Bulgarian language
//     *
//     * @param lang
//     * @param defaultProps
//     * @return
//     * @throws NormalizeException
//     */
//    private static Map<String, String> loadOOV(Language lang, Properties defaultProps) throws NormalizeException {
//        HashMap<String, String> oovbg = new HashMap<String, String>();
//        String path = null;
//
//        try {
//            if (lang == Language.BG) {
//                path = defaultProps.getProperty("pathOOVBG");
//            } else {
//                throw new NormalizeException(NormalizeException.ERROR1, path);
//            }
//            File fin = new File(path);
//            BufferedReader reader = null;
//
//            if (!fin.exists()) {
//                throw new NormalizeException(NormalizeException.ERROR1, path);
//            }
//
//            reader = new BufferedReader(new FileReader(fin));
//            String line;
//            while ((line = reader.readLine()) != null) {
//                String[] split = line.split(":");
//
//                oovbg.put(split[0].trim(), split[1].trim());
//            }
//            reader.close();
//
//        } catch (FileNotFoundException ex) {
//            throw new NormalizeException(ex);
//        } catch (IOException ex) {
//            throw new NormalizeException(ex);
//        }
//        return oovbg;
//    }
//
//    /**
//     * Método donde creamos el fichero GATE que devuelve el servicio web.
//     *
//     * @throws NormalizeException
//     */
//    private void readGateDocument() throws NormalizeException {
//        try {
//            doc = XMLUtils.readXML(textAnalyze, "UTF-8");
//            Element e = doc.getDocumentElement();
//            Element eText = XMLUtils.getElementNamed(e, "TextWithNodes");
//            textAnalyze = eText.getTextContent();
//
//            node_offsets = new TreeSet<Integer>();
//
//        } catch (IOException ex) {
//            throw new NormalizeException(ex);
//        } catch (ParserConfigurationException ex) {
//            throw new NormalizeException(NormalizeException.ERROR2, ex);
//        } catch (SAXException ex) {
//            throw new NormalizeException(NormalizeException.ERROR2, ex);
//        }
//    }
//
//    private void createAnnotationSet(TypeWords typeWord) {
//        //creamos el nuevos annotationset
//        Element e = doc.getDocumentElement();
//        this.anotationsetDisam = doc.createElement("AnnotationSet");
//        this.anotationsetDisam.setAttribute("Name", "Disambiguate markups " + typeWord.toString());
//        e.appendChild(this.anotationsetDisam);
//    }
//
//    /**
//     * Método en el que obtenemos el siguiente id, a partir del documento que
//     * nos pasan en la entrada. Es necesario obtenerlo porque puede ser que nos
//     * pasen un documento GATE, que ya tiene identificadores.
//     *
//     * @return int identificador que podemos utilizar
//     */
//    private int obtainNextId() {
//        Element documentElement = doc.getDocumentElement();
//        //obtenemos el identificador para las nuevas anotaciones
//        int minnewId = textAnalyze.length() + 1;
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
//    /**
//     * Método en que ejectuamos uno de los tres scripts (freeling_es,
//     * freeling_en, tree_tagger_bg). En el caso del español y del inglés,
//     * utilizamos Freeling para analizar el texto. Para el búlgaro, utilizamos
//     * Tree-Tagger.
//     *
//     * @param inputtext
//     * @param namescript
//     * @return
//     * @throws InterruptedException
//     * @throws DisambiguationException
//     */
//    private File runScript(String inputtext, String namescript) throws InterruptedException, NormalizeException {
//        File tempFileOutput = null;
//        try {
//            /* Generamos un fichero a partir del texto de entrada */
//            File tempFileInput = File.createTempFile("entrada", ".txt");
//            BufferedWriter out = new BufferedWriter(new FileWriter(tempFileInput));
//            out.write(inputtext);
//            out.close();
//
//            /* Generamos un fichero para almacenar la salida del comando */
//            tempFileOutput = File.createTempFile("salida", ".txt");
//            tempFileOutput.deleteOnExit();
//
//            /* Ejecutamos el script que contiene el comando para ejecutar freeling */
//            String[] cd = {"/bin/sh", "-c", webAppPath + "scripts/" + namescript + " " + tempFileInput.getAbsolutePath() + " MFS " + tempFileOutput.getAbsolutePath()};
////            String[] cd = {"/bin/sh", "-c", webAppPath + "scripts/" + namescript + " " + tempFileInput.getAbsolutePath() + " " + this.methodDisam + " " + tempFileOutput.getAbsolutePath()};
//
//            Process child = Runtime.getRuntime().exec(cd, new String[0], new File(webAppPath + "scripts"));
//            child.waitFor();
//
//            /* Elimino el fichero temporal de entrada porque ya no lo necesito */
//            tempFileInput.delete();
//
//            /* Leememos la salida de error producida por el comando */
//            java.io.BufferedReader r2 = new java.io.BufferedReader(new java.io.InputStreamReader(child.getErrorStream()));
//            String s = null;
//            boolean excepcion = false;
//            StringBuffer bferror = new StringBuffer();
//            while ((s = r2.readLine()) != null) {
//                System.err.println(s);
//                if (!namescript.equals("treeTagger_bg.sh")) {
//                    excepcion = true;
//                }
//                bferror.append(s + "\n");
//            }
//
//            child.getOutputStream().close();
//            child.getInputStream().close();
//            child.getErrorStream().close();
//            child.destroy();
//
//            if (excepcion) {
//                throw new IOException(bferror.toString());
//            }
//
//        } catch (IOException ex) {
//            throw new NormalizeException(ex);
//        }
//        return tempFileOutput;
//    }
//
//    private ParamsJSON parseJSON(String jsonParameters) throws NormalizeException {
//        ParamsJSON parameters = null;
//        ParamsJSON.Language lang = null;
////        ParamsJSON.MethodDisambiguation methodDisam = null;
////        ParamsJSON.Information retunInfo = null;
//        ArrayList<ParamsJSON.TypeWords> typeWords = new ArrayList<ParamsJSON.TypeWords>();
////        Integer numMaxDefinitions = null;
//
////        try {
//        JSONObject obj = (JSONObject) JSONSerializer.toJSON(jsonParameters);
//        String langJson = obj.getString("lang").toLowerCase();
//        lang = langJson.equals("es") ? ParamsJSON.Language.ES : langJson.equals("en") ? ParamsJSON.Language.EN : ParamsJSON.Language.BG;
//        JSONArray typeWordsJson = obj.getJSONArray("typeWords");
//        for (Object typeWord : typeWordsJson) {
//            if (typeWord.equals("OOV")) {
//                typeWords.add(ParamsJSON.TypeWords.OOV);
//            } else if (typeWord.equals("ACRONYMS")) {
//                typeWords.add(ParamsJSON.TypeWords.ACRONYMS);
//            } else {
//                throw new NormalizeException(NormalizeException.ERROR3, typeWord.toString());
//            }
//        }
//
////            int numDef = obj.getInt("numMaxDefinitions");
//        return parameters = new ParamsJSON(lang, typeWords);
//
//
////            // obtenemos una instancia de JsonFactory para crear el parser
////            JsonFactory factory = new JsonFactory();
////            JsonParser parser = factory.createParser(jsonParameters);
////
////            // analizamos hasta alcanzar el final de los parametros
////            while (!parser.isClosed()) {
////                JsonToken token = parser.nextToken();
////                // si es el ultimo token, acabamos de parsear
////                if (token == null) {
////                    break;
////                }
////
////                if (JsonToken.FIELD_NAME.equals(token) && "lang".equals(parser.getCurrentName())) {
////                    // obtenemos el valor
////                    String langJson = parser.nextToken().toString().toLowerCase();
////                    // Obtenenmos el valor en formato enumerado Language
////                    lang = langJson.equals("es") ? ParamsJSON.Language.ES : langJson.equals("en") ? ParamsJSON.Language.EN : ParamsJSON.Language.BG;
////
////                } else if (JsonToken.FIELD_NAME.equals(token) && "methodDisam".equals(parser.getCurrentName())) {
////                    // obtenemos el valor
////                    String methodJson = parser.nextValue().toString().toUpperCase();
////                    // Obtenemos el valor del enumerado MethodDisambiguation
////                    methodDisam = methodJson.equals("MFS") ? ParamsJSON.MethodDisambiguation.MFS : ParamsJSON.MethodDisambiguation.UKB;
////
////                } else if (JsonToken.FIELD_NAME.equals(token) && "returnInfo".equals(parser.getCurrentName())) {
////                    // obtenemos el valor
////                    String infoJson = parser.nextToken().toString().toUpperCase();
////                    // Obtenemos el valor del enumerado Information
////                    retunInfo = infoJson.equals("DEFINITIONS") ? ParamsJSON.Information.DEFINITIONS : infoJson.equals("DEFSYN") ? ParamsJSON.Information.DEFSYN : ParamsJSON.Information.SYNONYMS;
////
////                } else if (JsonToken.FIELD_NAME.equals(token) && "numMaxDefinitions".equals(parser.getCurrentName())) {
////                    // obtenemos el valor
////                    numMaxDefinitions = Integer.parseInt(parser.nextToken().toString());
////
////                } else if (JsonToken.FIELD_NAME.equals(token) && "typeWords".equals(parser.getCurrentName())) {
////                    // El primer token debe ser START_ARRAY ([)
////                    token = parser.nextToken();
////                    if (!JsonToken.START_ARRAY.equals(token)) {
////                        break;
////                    }
////                    // El siguiente token debe indicar el inicio del objeto START_OBJECT ({)
////                    token = parser.nextToken();
////                    if (!JsonToken.START_OBJECT.equals(token)) {
////                        break;
////                    }
////                    // Recorremos el array
////                    while (true) {
////                        token = parser.nextValue();
////                        if (token == null) {
////                            break;
////                        }
////                        if (JsonToken.VALUE_STRING.equals(token)) {
////                            System.out.println(parser.getText());
////                            if (parser.getText().equals("RARE")) {
////                                typeWords.add(ParamsJSON.TypeWords.RARE);
////                            } else if (parser.getText().equals("SPECIALIZED")) {
////                                typeWords.add(ParamsJSON.TypeWords.SPECIALIZED);
////                            } else if (parser.getText().equals("POLYSEMIC")) {
////                                typeWords.add(ParamsJSON.TypeWords.POLYSEMIC);
////                            } else if (parser.getText().equals("LONGWORDS")) {
////                                typeWords.add(ParamsJSON.TypeWords.LONGWORDS);
////                            } else if (parser.getText().equals("OOV")) {
////                                typeWords.add(ParamsJSON.TypeWords.OOV);
////                            } else if (parser.getText().equals("ACRONYMS")) {
////                                typeWords.add(ParamsJSON.TypeWords.ACRONYMS);
////                            } else {
////                                // excepcion
////                            }
////                        }
////                    }
//////                                        parameters = new ParamsJSON(lang, methodDisam, retunInfo, typeWords, numMaxDefinitions);
////
////                }
////            }
////        } catch (IOException ex) {
////            Logger.getLogger(NormalizeService.class
////                    .getName()).log(Level.SEVERE, null, ex);
////        }
//    }
//}
