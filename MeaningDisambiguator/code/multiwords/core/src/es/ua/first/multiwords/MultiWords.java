/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package es.ua.first.multiwords;

import es.ua.db.Database;
import es.ua.db.DatabaseException;
import es.ua.db.DatabasePool;
import es.ua.db.MySQLDatabase;
import es.ua.db.Query;
import es.upv.xmlutils.XMLUtils;
import java.io.BufferedReader;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.FileReader;
import java.io.IOException;
import java.util.ArrayList;
import java.util.Collection;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import java.util.Properties;
import java.util.Set;
import java.util.TreeSet;
import javax.xml.parsers.ParserConfigurationException;
import net.didion.jwnl.JWNL;
import net.didion.jwnl.JWNLException;
import net.didion.jwnl.data.IndexWord;
import net.didion.jwnl.data.POS;
import net.didion.jwnl.data.Synset;
import net.didion.jwnl.dictionary.Dictionary;
import org.ahocorasick.trie.Emit;
import org.ahocorasick.trie.Trie;
import org.w3c.dom.Document;
import org.w3c.dom.Element;
import org.w3c.dom.NodeList;
import org.xml.sax.SAXException;

/**
 *
 * @author lcanales
 */
public class MultiWords {

    public static final String VERSION = "1.0";
    public static final String GATE = "GATE";
    public static final String TXT = "TXT";
    public static final String LANGEN = "en";
    public static final String LANGES = "es";
    public static final String LANGBG = "bg";
    public static final String DEFINITIONS = "DEFINITIONS";
    public static final String SYNONYMS = "SYNONYMS";
    public static final String DEFSYN = "DEFSYN";
    public static final String MULTIWORD = "MULTIWORD";
    public static final String MULTIWORDEXPRESSION = "multiWordExpression";
    private final String pathMultiWordBG;
    private final String pathMultiWordEN;
    private final String pathMultiWordES;
    private final Trie multiwordsES;
    private final Trie multiwordsEN;
    private final Trie multiwordsBG;
    private final Dictionary wordNetDictionary;
    private final DatabasePool pool;

    public MultiWords(Properties defaultProps, String workingDir) throws FileNotFoundException, IOException, JWNLException, DatabaseException, ParserConfigurationException, SAXException, MultiWordsException {
        // Creamos un fichero temporal de las propiedades de JWNL
        File fileTempJWNL = loadJWNLProperties(workingDir, defaultProps);
        // Le decimos que inicialice JWNL desde este fichero.
        JWNL.initialize(new FileInputStream(fileTempJWNL));
        wordNetDictionary = Dictionary.getInstance();
        // Creamos la conexion a BD para consultar MWN
        pool = createConnectionPool(defaultProps);
        // Cargamos la lista de palabras frecuentes (EN, ES, BG)
//        pathMultiWordBG = workingDir + fileSeparator + defaultProps.getProperty("pathMultiWordsBG");
//        pathMultiWordEN = workingDir + fileSeparator + defaultProps.getProperty("pathMultiWordsEN");
//        pathMultiWordES = workingDir + fileSeparator + defaultProps.getProperty("pathMultiWordsES");
        pathMultiWordBG = defaultProps.getProperty("pathMultiWordsBG");
        pathMultiWordEN = defaultProps.getProperty("pathMultiWordsEN");
        pathMultiWordES = defaultProps.getProperty("pathMultiWordsES");
        multiwordsBG = loadMultiWords(LANGBG, pathMultiWordBG);
        multiwordsES = loadMultiWords(LANGES, pathMultiWordES);
        multiwordsEN = loadMultiWords(LANGEN, pathMultiWordEN);
    }

//    public void setListMultiWords(String listMultiWords, String langCode) throws IOException, MultiWordsException {
//
//        // Determinamos el idioma
//        String file = "";
//        if (langCode.equals(LANGBG)) {
//            file = pathMultiWordBG;
//        } else if (langCode.equals(LANGEN)) {
//            file = pathMultiWordEN;
//        } else if (langCode.equals(LANGES)) {
//            file = pathMultiWordES;
//        } else {
//            throw new MultiWordsException(MultiWordsException.ERROR1, langCode);
//        }
//
//        // Leo la lista y almaceno en el fichero /resources/multiword
//        StringBuilder multiwords = new StringBuilder();
//        String[] listMW = listMultiWords.split("\n");
//        for (String multiword : listMW) {
//            multiword = multiword.trim();
//            if (multiword.length() > 0) {
//                multiwords.append(multiword).append("\n");
//            }
//        }
//
//        // Almacenamos en el fichero
//        File fichMW = new File(file);
//        BufferedWriter writer = new BufferedWriter(new FileWriter(fichMW));
//        writer.write(multiwords.toString());
//        writer.close();
//
//        // Volvemos a esa lista
//        if (langCode.equals(LANGBG)) {
//            multiwordsBG = loadMultiWords(LANGBG, pathMultiWordBG);
//        } else if (langCode.equals(LANGEN)) {
//            multiwordsEN = loadMultiWords(LANGEN, pathMultiWordEN);
//        } else if (langCode.equals(LANGES)) {
//            multiwordsES = loadMultiWords(LANGES, pathMultiWordES);
//        } else {
//            throw new MultiWordsException(MultiWordsException.ERROR1, langCode);
//        }
////        System.out.println("Lista cargada");
//
//    }

    public String multiwords(String inputText, String langCode, String formatFileInput, String formatFileOutput, String workingDir) throws IOException, ParserConfigurationException, SAXException, DatabaseException, JWNLException, MultiWordsException {

        // Obtenemos el texto que debemos analizar
        String textToAnalyze = loadInputFile(inputText, formatFileInput);

        // Cargamos la lista (sino no se carga desde multiwords)
//        if (langCode.equals(LANGBG) && multiwordsBG == null) {
//            multiwordsBG = loadMultiWords(LANGBG, pathMultiWordBG);
//        } else if (langCode.equals(LANGEN) && multiwordsEN == null) {
//            multiwordsEN = loadMultiWords(LANGEN, pathMultiWordEN);
//        } else if (langCode.equals(LANGES) && multiwordsES == null) {
//            multiwordsES = loadMultiWords(LANGES, pathMultiWordES);
//        }

        // Seleccionamos el tree (dependiendo del idioma)
        Trie multiwords = (langCode.equals(LANGBG)) ? multiwordsBG
                : (langCode.equals(LANGEN)) ? multiwordsEN : multiwordsES;
        if (multiwords == null) { // si no se habia cargado, lanzamos una excepcion
            throw new MultiWordsException(MultiWordsException.ERROR1 + langCode);
        }
        
        // Detectamos las multiwords (search)
        HashMap<String, Word> multiWords = detectionMultiWords(langCode, textToAnalyze, multiwords);

        // Resolvemos las multi-words detectadas (definicion y sinonimos)
        resolutionMultiWords(multiWords, langCode);

        // Obtenemos la salida
        return obtainOutput(multiWords, formatFileOutput, formatFileInput, inputText, textToAnalyze);
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

    private HashMap<String, Word> detectionMultiWords(String langCode, String textToAnalyze, Trie multiwords) throws MultiWordsException {
        HashMap<String, Word> multiWords = new HashMap<String, Word>();

       // Detectamos las multiwords
        Collection<Emit> emits;
        synchronized (multiwords) {
            emits = multiwords.parseText(textToAnalyze);
        }
        // Obtenemos la informacion de cada multi-word
        for (Emit e : emits) {
            String wordText = e.getKeyword();
            int start_offset = e.getStart();
            int end_offset = e.getEnd() + 1;
            if (multiWords.containsKey(wordText)) {
                // modificamos la palabra(word) almacenada)
                multiWords.get(wordText).getStart_offset().add(start_offset);
                multiWords.get(wordText).getEnd_offset().add(end_offset);
            } else {
                // start_off y end_off
                List<Integer> start_offsets = new ArrayList<Integer>();
                start_offsets.add(start_offset);
                List<Integer> end_offsets = new ArrayList<Integer>();
                end_offsets.add(end_offset);
                multiWords.put(wordText, new Word(wordText, start_offsets, end_offsets));
            }
        }


        return multiWords;
    }

    private void resolutionMultiWords(HashMap<String, Word> multiWords, String langCode) throws DatabaseException, JWNLException {
        if (langCode.equals(LANGES)) {
            resolveMultiWordsES(multiWords);
        } else if (langCode.equals(LANGEN)) {
            resolveMultiWordsEN(multiWords);
        } else if (langCode.equals(LANGBG)) {
            resolveMultiWordsBG(multiWords);
        }
    }

    private void resolveMultiWordsES(HashMap<String, Word> multiWords) throws DatabaseException {
        // Pedimos una conexion
        Database database = pool.get();
        try {
            // Resolvemos todas las multiwords
            Iterator iter = multiWords.entrySet().iterator();
            for (Map.Entry e : multiWords.entrySet()) {
                // obtenemos una palabra
                Word word = (Word) e.getValue();
                String definition = "";
                StringBuilder synonymsAll = new StringBuilder();
                Set<String> synonymsSet = new HashSet<String>();
                String multiword = word.getWord().replace(" ", "_");

                // Obtenemos definicion y sinonimos de la palabra
                StringBuilder sbVariant = new StringBuilder("SELECT offset, pos FROM `wei_spa-30_variant` where word = ? where sense=1");
                Query qVariant = database.executeQuery(sbVariant.toString(), multiword);
                if (qVariant.next()) {
                    String offset = qVariant.getField("offset").toString();
                    String pos = qVariant.getField("pos").toString();

                    // Obtenemos la definicion
                    StringBuilder sbSynset = new StringBuilder("SELECT gloss FROM `wei_spa-30_synset` where offset like ? AND pos = ?");
                    Query qSynset = database.executeQuery(sbSynset.toString(), "%" + offset + "%", pos);
                    if (qSynset.next()) {
                        String gloss = qSynset.getField("gloss").toString();
                        definition = gloss.replace("_", " ");
                    }
                    qSynset.close();

                    // Obtenemos los sinonimos
                    StringBuilder sbSynonyms = new StringBuilder("SELECT word FROM `wei_spa-30_variant` where offset like ? AND pos = ?");
                    Query qSynonyms = database.executeQuery(sbSynonyms.toString(), "%" + offset + "%", pos);
                    while (qSynonyms.next()) {
                        if (!qSynonyms.getField("word").toString().equals(multiword)) {
                            String synonym = qSynonyms.getField("word").toString().replace("_", " ");
                            synonymsSet.add(synonym);
                        }
                    }
                    qSynonyms.close();

                }
                qVariant.close();

                // Obtenemos la lista de sinónimos
                for (String syn : synonymsSet) {
                    synonymsAll.append(syn).append("|");
                }
                // Asignamos a la palabra su definicion y sinonimos
                word.setDefintions(definition);
                word.setSynonyms(synonymsAll.toString());
            }
        } finally {
            // Liberamos la conexion
            pool.release(database);
        }
    }

    private void resolveMultiWordsEN(HashMap<String, Word> multiWords) throws JWNLException {
        for (Map.Entry e : multiWords.entrySet()) {
            // obtenemos una palabra
            Word wordAnalyze = (Word) e.getValue();
            IndexWord word;
            // Consutamos WordNet (no conocemos su pos, así que hay que probar)
            synchronized (wordNetDictionary) {
                try {
                    word = wordNetDictionary.lookupIndexWord(POS.NOUN, wordAnalyze.getWord());
                } catch (JWNLException ex) {
                    try {
                        word = wordNetDictionary.lookupIndexWord(POS.VERB, wordAnalyze.getWord());
                    } catch (JWNLException ex1) {
                        try {
                            word = wordNetDictionary.lookupIndexWord(POS.ADJECTIVE, wordAnalyze.getWord());
                        } catch (JWNLException ex2) {
                            word = wordNetDictionary.lookupIndexWord(POS.ADVERB, wordAnalyze.getWord());
                        }
                    }
                }
            }

            // Si la palabra está en WordNet
            if (word != null) {
                if (word.getSenses().length > 0) {
                    Synset first_synset = word.getSenses()[0];
                    String gloss = first_synset.getGloss();
                    StringBuilder synonyms = new StringBuilder();
                    for (net.didion.jwnl.data.Word word1 : first_synset.getWords()) {
                        String synonym = word1.getLemma().replace("_", " ");
                        if (!synonym.equals(wordAnalyze.getWord())) {
                            synonyms.append(synonym).append("|");
                        }
                    }
                    wordAnalyze.setDefintions(gloss);
                    wordAnalyze.setSynonyms(synonyms.toString());
                }
            }
        }
    }

    private void resolveMultiWordsBG(HashMap<String, Word> multiWords) throws DatabaseException {
        Database database = pool.get();
            try {
            for (Map.Entry e : multiWords.entrySet()) {
                // obtenemos una palabra
                Word word = (Word) e.getValue();
                StringBuilder definitionsAll = new StringBuilder();
                StringBuilder synonymsAll = new StringBuilder();
                Set<String> synonymsSet = new HashSet<String>();

                // Consultamos balkanet BD
                StringBuilder sbSynset = new StringBuilder(
                        "SELECT definition, synonyms FROM balkanet_first.synsets where word=?");
                Query query = database.executeQuery(sbSynset.toString(), word.getWord());
                String synonymsBD;
                String definitions = "";
                if (query.next()) {
                    synonymsBD = query.getField("synonyms").toString();
                    definitions = query.getField("definition").toString();

                    // Obtenemos el sinónimo más simple
                    String[] synonyms = synonymsBD.split(",");
                    for (String syn : synonyms) {
                        if (!syn.equals(word.getWord())) {
                            String synonym = syn.replace("_", " ");
                            synonymsSet.add(synonym);
                        }
                    }
                }

                // Añadimos los campos vacios con |
                definitionsAll.append(definitions).append("|");
                query.close();

                // Obtenemos la lista de sinónimos
                for (String syn : synonymsSet) {
                    synonymsAll.append(syn).append("|");
                }
                // Asignamos a la palabra su definicion y sinonimos
                word.setDefintions(definitionsAll.toString());
                word.setSynonyms(synonymsAll.toString());
            }
        } finally {
            // Liberamos la conexion
            pool.release(database);
        }
    }

    private String obtainOutput(HashMap<String, Word> words, String formatOutput, String formatInput, String inputText, String textToAnalyze) throws IOException, ParserConfigurationException, SAXException {
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
            Element annotationSetMultiWords = createNewAnnot(gateDoc, "Disambiguate markups MULTIWORDS");

            Iterator it = words.entrySet().iterator();
            while (it.hasNext()) {
                Map.Entry e = (Map.Entry) it.next();
                Word word = (Word) e.getValue();
                int idParent = id;
                for (int i = 0; i < word.getStart_offset().size(); i++) {
                    // comprobamos si es una referencia o una nueva instancia
                    Element annotationRare;
                    if (i > 0) {
                        annotationRare = createFeatureLink(gateDoc, idParent, id, word, i);
                    } else {
                        annotationRare = createFeatures(gateDoc, id, word, MULTIWORDEXPRESSION, i);
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

    private Element createFeatureLink(Document gateDoc, int idParent, int id, Word word, int posOffset) {
        Element definitionElement = gateDoc.createElement("Annotation");
        String idDefinition = Integer.toString(id);
        definitionElement.setAttribute("Id", idDefinition);
        definitionElement.setAttribute("StartNode", word.getStart_offset().get(posOffset) + "");
        definitionElement.setAttribute("EndNode", word.getEnd_offset().get(posOffset) + "");
        definitionElement.setAttribute("Type", MULTIWORD);
        //definitionElement.setAttribute("Type", "Definition");
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

    private Element createFeatures(Document gateDoc, int id, Word word, String typeWord, int posOffset) {
        Element definitionElement = gateDoc.createElement("Annotation");
        String idDefinition = Integer.toString(id);
        definitionElement.setAttribute("Id", idDefinition);
        definitionElement.setAttribute("StartNode", word.getStart_offset().get(posOffset) + "");
        definitionElement.setAttribute("EndNode", word.getEnd_offset().get(posOffset) + "");
        definitionElement.setAttribute("Type", MULTIWORD);
        //definitionElement.setAttribute("Type", "Definition");

        // Add definition
        Element feature = gateDoc.createElement("Feature");
        definitionElement.appendChild(feature);
        Element name = gateDoc.createElement("Name");
        name.setAttribute("className", "java.lang.String");
        name.setTextContent("definition");
        feature.appendChild(name);
        Element value = gateDoc.createElement("Value");
        value.setAttribute("className", "java.lang.String");
        value.setTextContent(word.getDefintions());
        feature.appendChild(value);

        // Add synonyms
        feature = gateDoc.createElement("Feature");
        definitionElement.appendChild(feature);
        name = gateDoc.createElement("Name");
        name.setAttribute("className", "java.lang.String");
        name.setTextContent("synonyms");
        feature.appendChild(name);
        value = gateDoc.createElement("Value");
        value.setAttribute("className", "java.lang.String");
        value.setTextContent(word.getSynonyms());
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
        value.setTextContent(word.getWord());
        feature.appendChild(value);

        // Add typeWord
        feature = gateDoc.createElement("Feature");
        definitionElement.appendChild(feature);
        name = gateDoc.createElement("Name");
        name.setAttribute("className", "java.lang.String");
        name.setTextContent("type");
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

    private DatabasePool createConnectionPool(Properties defaultProps) throws DatabaseException, NumberFormatException {
        String dbhost = defaultProps.getProperty("dataBaseServer");
        String dbuser = defaultProps.getProperty("dataBaseUser");
        String dbpassw = defaultProps.getProperty("dataBasePassword");
        String dbnameMWN = defaultProps.getProperty("dataBaseNameMWN");
        int maxConnections = Integer.parseInt(defaultProps.getProperty("maxConnections"));
        Database database = new MySQLDatabase(dbhost, dbuser, dbpassw, dbnameMWN);
        return new DatabasePool(database, maxConnections);
    }

    private File loadJWNLProperties(String workingDir, Properties defaultProps) throws IOException, FileNotFoundException, ParserConfigurationException, SAXException {
        String pathJWNL = workingDir + defaultProps.getProperty("pathJWNL");
        String pathWN = workingDir + defaultProps.getProperty("pathWN");
        // Creamos un fichero temporal que contendra la ruta real del dictionary_path
        File fpropWN = File.createTempFile("wn_file_properties", ".xml");
        // Leemos el fichero wn_file_properties por defecto
        Document doc = XMLUtils.loadXML(pathJWNL);
        Element e = XMLUtils.searchElementByAttribute(doc.getDocumentElement(), "name", "dictionary_path");
        // Cambiamos el parametro dictionary_path
        e.setAttribute("value", pathWN);
        // Guardamos el fichero con el cambio en el fichero temporal
        XMLUtils.saveXML(doc, fpropWN.getAbsolutePath(), "UTF-8");
        // Devolvemos el fichero temporal
        return fpropWN.getAbsoluteFile();
    }

    private synchronized Trie loadMultiWords(String langCode, String file) throws IOException, MultiWordsException {
        Trie trie = null;
        try {
            // Leemos el fichero
            BufferedReader myReader;
            myReader = new BufferedReader(new FileReader(file));
            String term;
            int i = 0;
            trie = new Trie().onlyWholeWords().caseInsensitive();
            while ((term = myReader.readLine()) != null) {
                trie.addKeyword(term);
                i++;
            }

        } catch (FileNotFoundException ex) {
            System.err.println(MultiWordsException.ERROR1 + langCode);
        }
        return trie;
    }
}
