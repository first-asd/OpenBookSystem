/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package es.ua.first.disambiguation;

import es.ua.db.Database;
import es.ua.db.DatabaseException;
import es.ua.db.DatabasePool;
import es.ua.db.MySQLDatabase;
import es.ua.db.Query;
import es.upv.xmlutils.XMLUtils;
import gate.Annotation;
import gate.AnnotationSet;
import gate.Factory;
import gate.Gate;
import gate.creole.ResourceInstantiationException;
import gate.util.GateException;
import it.uniroma1.lcl.babelnet.BabelNet;
import it.uniroma1.lcl.babelnet.BabelNetConfiguration;
import it.uniroma1.lcl.babelnet.BabelSynset;
import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.FileReader;
import java.io.FileWriter;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.math.BigDecimal;
import java.net.URL;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.Collections;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import java.util.Properties;
import java.util.Set;
import java.util.TreeSet;
import javax.xml.parsers.ParserConfigurationException;
import jdbm.RecordManager;
import jdbm.RecordManagerFactory;
import jdbm.btree.BTree;
import net.didion.jwnl.JWNL;
import net.didion.jwnl.JWNLException;
import net.didion.jwnl.data.IndexWord;
import net.didion.jwnl.data.POS;
import net.didion.jwnl.data.Synset;
import net.didion.jwnl.dictionary.Dictionary;
import org.w3c.dom.Document;
import org.w3c.dom.Element;
import org.w3c.dom.NodeList;
import org.xml.sax.SAXException;


/**
 *
 * @author lcanales
 */
public class Disambiguator2 {

    public static final String VERSION = "3.0";
    public static final String LANGEN = "en";
    public static final String LANGES = "es";
    public static final String LANGBG = "bg";
    public static final String MFS = "MFS";
    public static final String UKB = "UKB";
    public static final String DEFINITIONS = "DEFINITIONS";
    public static final String SYNONYMS = "SYNONYMS";
    public static final String DEFSYN = "DEFSYN";
    public static final String RARE = "RARE";
    public static final String SPECIALIZED = "SPECIALIZED";
    public static final String POLYSEMIC = "POLYSEMIC";
    public static final String LONGWORDS = "LONGWORDS";
    public static final String MENTALVERBS = "MENTALVERBS";
    public static final String GATE = "GATE";
    public static final String TXT = "TXT";
    public static final String FREELING = "FREELING";
    public static final String WORDNET = "WORDNET";
    private static final Double HIGH = 0.9;
    private static final Double MEDIUM = 0.6;
    private static final Double LOW = 0.3;
    private static final Integer MAXLONGWORD = 7;
    private static final Integer RANKLONGWORD = 10;
    private final Dictionary wordNetDictionary;
    private final DatabasePool pool;
    private final BabelNet babelNet;
    private final String freelingPath;
    private final String treeTaggerPath;
    private final Map<String, Integer> freqBG;
    private final Map<String, Integer> freqES;
    private final Map<String, Integer> freqEN;
    private final Map<String, String> mapping2030noum;
    private final Map<String, String> mapping2030adj;
    private final Map<String, String> mapping2030adv;
    private final Map<String, String> mapping2030verb;
    private final Map<String, String> WNDomanis;
    private Set<String> mentalVerbsES;
    private Set<String> mentalVerbsEN;
    private Set<String> mentalVerbsBG;
    private static final String BABELNET_PROPERTY_FILE = "es/ua/first/config/babelnet.properties";
    private static final String FREELING_SPLITTER_FILE = "config/splitter_first.dat";
    private final String fileSeparator = System.getProperty("file.separator");
    private static final String DATABASE = "database/first";

    public Disambiguator2(Properties defaultProps, String workingDir, String babelnetPath, String freelingPath, String treeTaggerPath, String gatePath) throws JWNLException, FileNotFoundException, DatabaseException, IOException, DisambiguationException, ParserConfigurationException, SAXException, GateException {
        // Almacenamos la ruta de Freeling y Tree-tagger
        this.freelingPath = freelingPath;
        this.treeTaggerPath = treeTaggerPath;
        // Creamos un fichero temporal de las propiedades de JWNL
        File fileTempJWNL = loadJWNLProperties(workingDir, defaultProps);
        // Le decimos que inicialice JWNL desde este fichero.
        JWNL.initialize(new FileInputStream(fileTempJWNL));
        wordNetDictionary = Dictionary.getInstance();
        // Creamos la conexion a BD para consultar MWN
        pool = createConnectionPool(defaultProps);
        // Creamos la instancia a BabelNet
        babelNet = createBabelNet(babelnetPath);
        // Cargamos la lista de palabras frecuentes (EN, ES, BG)
        freqBG = loadFreqWords(LANGBG, defaultProps, workingDir);
        freqES = loadFreqWords(LANGES, defaultProps, workingDir);
        freqEN = loadFreqWords(LANGEN, defaultProps, workingDir);
        // Cargar fichero mapping de WordNet 2.0 a WordNet 3.0 y WN-Domains
        MapFile adj = new MapFile(workingDir + fileSeparator + DATABASE, "mapping2030adj");
//        mapping2030adj = Collections.synchronizedMap(adj.getMap());
        mapping2030adj = Collections.synchronizedMap(new HashMap());
        MapFile adv = new MapFile(workingDir + fileSeparator + DATABASE, "mapping2030adv");
//        mapping2030adv = Collections.synchronizedMap(adv.getMap());
        mapping2030adv = Collections.synchronizedMap(new HashMap());
        MapFile noum = new MapFile(workingDir + fileSeparator + DATABASE, "mapping2030noum");
//        mapping2030noum = Collections.synchronizedMap(noum.getMap());
        mapping2030noum = Collections.synchronizedMap(new HashMap());
        MapFile verb = new MapFile(workingDir + fileSeparator + DATABASE, "mapping2030verb");
//        mapping2030verb = Collections.synchronizedMap(verb.getMap());
        mapping2030verb = Collections.synchronizedMap(new HashMap());
        if (adj.isEmpty() || adv.isEmpty() || noum.isEmpty() || verb.isEmpty()) {
            loadMapping2030(mapping2030adj, mapping2030adv, mapping2030noum, mapping2030verb, defaultProps, workingDir);
            adj.commit();
            adv.commit();
            noum.commit();
            verb.commit();
        }
        WNDomanis = loadDomains(defaultProps, workingDir);
        // Cargamos las listas de mentalverbs (ES, EN, BG)
        mentalVerbsES = loadMentalVerbs(LANGES, defaultProps, workingDir);
        mentalVerbsBG = loadMentalVerbs(LANGBG, defaultProps, workingDir);
        mentalVerbsEN = loadMentalVerbs(LANGEN, defaultProps, workingDir);
        // Inicializamos GATE
        Gate.setGateHome(new File(gatePath));
        Gate.setSiteConfigFile(new File(Gate.getGateHome().getAbsolutePath() + "/gate.xml"));
        Gate.init();
    }

    public String disambiguate(String inputText, ArrayList<String> obstacles, String langCode, int numSenses, String methodDisambiguation, String informationReturned, String formatFileInput, String formatFileOutput, String systemDisam, String workingDir) throws IOException, ParserConfigurationException, SAXException, JWNLException, SQLException, DisambiguationException, InterruptedException, DatabaseException, ResourceInstantiationException {
        // Obtenemos el texto que debemos analizar
        String textToAnalyze = loadInputFile(inputText, formatFileInput);

        // Analizamos el texto para obtener su lemma, pos, etc.
        HashMap<String, Word> words = languageAnalyzers(inputText, textToAnalyze, workingDir, langCode, methodDisambiguation);

        // Desambiguamos : DEFINIR LOS MÉTODOS PERMITIDOS
        disambiguateWords(words, systemDisam, langCode);

        // Realizamos la detección
        detectionObstacles(words, obstacles, langCode);

        // Obtenemos las definiciones y sinonimos
        resolutionObtacles(words, langCode, numSenses);

        // Generamos y devolvemos la salida
        return obtainOutput(obstacles, words, formatFileOutput, formatFileInput, inputText, textToAnalyze, informationReturned, numSenses);
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

    private DatabasePool createConnectionPool(Properties defaultProps) throws DatabaseException, NumberFormatException {
        String dbhost = defaultProps.getProperty("dataBaseServer");
        String dbuser = defaultProps.getProperty("dataBaseUser");
        String dbpassw = defaultProps.getProperty("dataBasePassword");
        String dbnameMWN = defaultProps.getProperty("dataBaseNameMWN");
        int maxConnections = Integer.parseInt(defaultProps.getProperty("maxConnections"));
        Database database = new MySQLDatabase(dbhost, dbuser, dbpassw, dbnameMWN);
        return new DatabasePool(database, maxConnections);
    }

    private BabelNet createBabelNet(String babelnetPath) throws IOException {
        // creamos una instacia de la configuracion de babelnet
        BabelNetConfiguration bnc = BabelNetConfiguration.getInstance();
        File confBabelNet;
        // Si nos indican una ruta de babelnet distinta creamos un fichero temporal
        if (babelnetPath != null && !babelnetPath.equals("")) {
            // Creamos el fichero temporal
            confBabelNet = File.createTempFile("babelnet", ".properties");
            OutputStream out = new FileOutputStream(confBabelNet);
            // Cargamos el properties por defecto
            Properties propBabelnet = new Properties();
            InputStream in = getClass().getClassLoader().getResourceAsStream(BABELNET_PROPERTY_FILE);
            propBabelnet.load(in);
            // Cambiamos la propiedad
            propBabelnet.setProperty("babelnet.dir", babelnetPath);
            // Guardamos el cambio
            propBabelnet.store(out, "");
            // Cerramos los stream
            in.close();
            out.close();

        } else {
            ClassLoader loader = Disambiguator2.class.getClassLoader();
            URL url = loader.getResource(BABELNET_PROPERTY_FILE);
            confBabelNet = new File(url.getFile());
        }
        bnc.setConfigurationFile(confBabelNet);
        return BabelNet.getInstance();
    }

    private void loadMapping2030(Map<String, String> mapping2030adj, Map<String, String> mapping2030adv, Map<String, String> mapping2030noum, Map<String, String> mapping2030verb, Properties defaultProps, String workingDir) throws FileNotFoundException, IOException {


        // Cargamos el mapping de adjetivos
        String filemapping2030 = workingDir + defaultProps.getProperty("pathWNMappingAdj");
        File mapping2030File = new File(filemapping2030);
        BufferedReader readermapping2030 = new BufferedReader(new FileReader(mapping2030File));
        String linemap2030;
        while ((linemap2030 = readermapping2030.readLine()) != null) {
            linemap2030 = linemap2030.trim();
            String[] part_line = linemap2030.split("\\s+");
            mapping2030adj.put(part_line[0], part_line[1]);
        }
        readermapping2030.close();

        // Cargamos el maping de adverbios
        filemapping2030 = workingDir + defaultProps.getProperty("pathWNMappingAdv");
        mapping2030File = new File(filemapping2030);
        readermapping2030 = new BufferedReader(new FileReader(mapping2030File));
        while ((linemap2030 = readermapping2030.readLine()) != null) {
            linemap2030 = linemap2030.trim();
            String[] part_line = linemap2030.split("\\s+");
            mapping2030adv.put(part_line[0], part_line[1]);
        }
        readermapping2030.close();

        // Cargamos los nombres
        filemapping2030 = workingDir + defaultProps.getProperty("pathWNMappingNoun");
        mapping2030File = new File(filemapping2030);
        readermapping2030 = new BufferedReader(new FileReader(mapping2030File));
        while ((linemap2030 = readermapping2030.readLine()) != null) {
            linemap2030 = linemap2030.trim();
            String[] part_line = linemap2030.split("\\s+");
            mapping2030noum.put(part_line[0], part_line[1]);
        }
        readermapping2030.close();

        // Cargamos los verbos
        filemapping2030 = workingDir + defaultProps.getProperty("pathWNMappingVerb");
        mapping2030File = new File(filemapping2030);
        readermapping2030 = new BufferedReader(new FileReader(mapping2030File));
        while ((linemap2030 = readermapping2030.readLine()) != null) {
            linemap2030 = linemap2030.trim();
            String[] part_line = linemap2030.split("\\s+");
            mapping2030verb.put(part_line[0], part_line[1]);
        }
        readermapping2030.close();
    }

    private Map<String, String> loadDomains(Properties defaultProps, String workingDir) throws FileNotFoundException, IOException {
        Map<String, String> domains;
        String fileWNDom = workingDir + defaultProps.getProperty("pathWNDomains");
        File DomainWNFile = new File(fileWNDom);
        BufferedReader readerWNDomain = new BufferedReader(new FileReader(DomainWNFile));
        domains = new HashMap<String, String>();
        String lineWNDomain;
        while ((lineWNDomain = readerWNDomain.readLine()) != null) {
            lineWNDomain = lineWNDomain.trim();
            String[] part_line = lineWNDomain.split("\\t+");
            if (!part_line[1].contains("factotum")) {
                String idWn20 = part_line[0].substring(0, part_line[0].length() - 2);
                String pos = part_line[0].substring(part_line[0].length() - 1, part_line[0].length());
                String idWn30 = "";
                // Realizamos el mapping en funcion del POS
                if (pos.equals("r")) {
                    idWn30 = mapping2030adv.get(idWn20) + pos;
                } else if (pos.equals("a") || pos.equals("j") || pos.equals("s")) {
                    idWn30 = mapping2030adj.get(idWn20) + "a";
                } else if (pos.equals("n")) {
                    idWn30 = mapping2030noum.get(idWn20) + pos;
                } else if (pos.equals("v")) {
                    idWn30 = mapping2030verb.get(idWn20) + pos;
                }
                // hay algunos que no tienen conversion a la version 3.0
                if (!idWn30.equals("")) {
                    domains.put(idWn30, part_line[1].trim());
                }
            }
        }
        readerWNDomain.close();
        return Collections.synchronizedMap(domains);
    }

    private Map<String, Integer> loadFreqWords(String langCode, Properties defaultProps, String workingDir) throws FileNotFoundException, IOException, DisambiguationException {
        BufferedReader readerFreq;
        String file = "";
        int posIni = 0;
        int tamlist = 0;

        // Determinamos el idioma de la lista que debemos cargar
        if (langCode.equals(LANGBG)) {
            file = workingDir + fileSeparator + defaultProps.getProperty("pathFreqBG");
            posIni = 1;
            tamlist = 3258;
        } else if (langCode.equals(LANGES)) {
            file = workingDir + fileSeparator + defaultProps.getProperty("pathFreqES");
            posIni = 1;
            tamlist = 3354;
        } else if (langCode.equals(LANGEN)) {
            file = workingDir + fileSeparator + defaultProps.getProperty("pathFreqEN");
            posIni = 1;
            tamlist = 3618;
        } else {
            throw new DisambiguationException(DisambiguationException.ERROR4);
        }
        Map<String, Integer> listFreq = new HashMap();
        // Cargamos el fichero de palabras frecuencias para el idioma dado
        File freqFile = new File(file);
        readerFreq = new BufferedReader(new FileReader(freqFile));
        String lineFreq;
        while ((lineFreq = readerFreq.readLine()) != null && listFreq.size() <= tamlist) {
            lineFreq = lineFreq.trim();
            String[] part_line = lineFreq.split("\\s+");
            listFreq.put(part_line[posIni].toLowerCase(), 1);
        }
        readerFreq.close();

//        if (langCode.equals(LANGES)) {
//            Iterator it = listFreq.entrySet().iterator();
//            while (it.hasNext()) {
//                Map.Entry e = (Map.Entry) it.next();
//                System.out.println(e.getKey());
//            }
//        }
        return Collections.synchronizedMap(listFreq);
    }

    private Set<String> loadMentalVerbs(String langCode, Properties defaultProps, String workingDir) throws FileNotFoundException, IOException {
        Set<String> listMentalVerbs = new HashSet<String>();
        BufferedReader readerMentalVerbs;
        String file;

        // Cargamos el fichero de los verbos mentales
        if (langCode.equals(LANGBG)) {
            file = workingDir + fileSeparator + defaultProps.getProperty("pathMentalVerbsBG");
        } else if (langCode.equals(LANGEN)) {
            file = workingDir + fileSeparator + defaultProps.getProperty("pathMentalVerbsEN");
        } else {
            file = workingDir + fileSeparator + defaultProps.getProperty("pathMentalVerbsES");
        }

        // Leemos el fichero que corresponda en funcion del idioma
        File freqFile = new File(file);
        readerMentalVerbs = new BufferedReader(new FileReader(freqFile));
        String line;
        int i = 0;
        while ((line = readerMentalVerbs.readLine()) != null) {
            line = line.trim();
            listMentalVerbs.add(line);
            i++;
        }
        readerMentalVerbs.close();
        return Collections.synchronizedSet(listMentalVerbs);
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

    private HashMap<String, Word> languageAnalyzers(String inputText, String textToAnalyze, String workingDir, String langCode, String methodDisambiguation) throws IOException, InterruptedException, ResourceInstantiationException {
        File outputScript;
        HashMap<String, Word> words;
        if (langCode.equals(LANGEN)) {
            outputScript = runScript(textToAnalyze, "freeling_en.sh", methodDisambiguation, workingDir, this.freelingPath);
            words = parseFreeling(textToAnalyze, outputScript, langCode, methodDisambiguation);

        } else if (langCode.equals(LANGES)) {
            outputScript = runScript(textToAnalyze, "freeling_es.sh", methodDisambiguation, workingDir, this.freelingPath);
            words = parseFreeling(textToAnalyze, outputScript, langCode, methodDisambiguation);

        } else {
            // Obtenemos del GATE original porque sabemos que esta procesado por el Aggregator
            words = obtainTokenFromGate(inputText);
            // Si utilizamos Tree-Tagger
//            nameScript = "treeTagger_bg.sh";
//            pathLangAnalyzer = this.treeTaggerPath;
//            outputScript = runScript(textToAnalyze, nameScript, methodDisambiguation, workingDir, pathLangAnalyzer);
//            words = parseTreeTagger(textToAnalyze, outputScript);
        }

        return words;
    }

    synchronized private File runScript(String textToAnalyze, String nameScript, String methodDisambiguation, String workingDir, String pathLangAnalyzer) throws IOException, InterruptedException {
        // Generamos un fichero a partir del texto de entrada 
        File tempFileInput = File.createTempFile("entrada", ".txt");
        BufferedWriter out = new BufferedWriter(new FileWriter(tempFileInput));
        out.write(textToAnalyze);
        out.close();

        // Generamos un fichero para almacenar la salida del comando
        File tempFileOutput = File.createTempFile("salida", ".txt");
        tempFileOutput.deleteOnExit();

        // Ejecutamos el script que contiene el comando para ejecutar freeling
        String[] cd = {"/bin/sh", "-c", "scripts/" + nameScript + " " + tempFileInput.getAbsolutePath() + " " + methodDisambiguation + " " + tempFileOutput.getAbsolutePath() + " " + pathLangAnalyzer + " " + workingDir + FREELING_SPLITTER_FILE};
        Process child = Runtime.getRuntime().exec(cd, new String[0], new File(workingDir));
        child.waitFor();

        // Elimino el fichero temporal de entrada
        tempFileInput.delete();

        // Leememos la salida de error producida por el comando 
        java.io.BufferedReader r2 = new java.io.BufferedReader(new java.io.InputStreamReader(child.getErrorStream()));
        String s;
        boolean excepcion = false;
        StringBuilder bferror = new StringBuilder();
        while ((s = r2.readLine()) != null) {
            System.err.println(s);
            if (!nameScript.equals("treeTagger_bg.sh")) {
                excepcion = true;
            }
            bferror.append(s).append("\n");
        }
        child.getOutputStream().close();
        child.getInputStream().close();
        child.getErrorStream().close();
        child.destroy();

        if (excepcion) {
            throw new IOException(bferror.toString());
        }
        return tempFileOutput;
    }

    private HashMap<String, Word> parseFreeling(String textToAnalyze, File outputScript, String langCode, String methodDisambiguation) throws IOException {
        HashMap<String, Word> words = new HashMap<String, Word>();
        FileReader fr;
        BufferedReader br;
        String line;
        boolean previusVerb = false;
        String offsets = "0-0";
        fr = new FileReader(outputScript);
        br = new BufferedReader(fr);
        while ((line = br.readLine()) != null) {
            if (!line.equals("")) {
                String[] part_line = line.split("\\s+");
                int posIds = part_line.length - 1;
                // POS
                String pos = part_line[2];
                if (!pos.startsWith("NP")) {
                    if ((langCode.equals(LANGES) && !pos.startsWith("VA") && !pos.startsWith("VS")) || (langCode.equals(LANGEN) && !part_line[1].equals("be") && !part_line[1].equals("have") && !part_line[1].equals("do"))) {
                        // Sólo almacenamos: NOMBRES, VERBOS, ADVERBIOS Y ADJETIVOS
                        if (pos.startsWith("N") || pos.startsWith("V")
                                || pos.startsWith("A") || pos.startsWith("R") || pos.startsWith("J")) {
                            // word
                            String wordText = part_line[0];
                            // lemma
                            String lemma = part_line[1];
                            if (lemma.contains("+")) {
                                String[] part_lemma = lemma.split("\\+");
                                lemma = part_lemma[0];
                            }
                            // comprobamos si el pos es J, si es así lo cambiamos a R, porque en WN domains los adjetivos están etiquetados con R
                            if (pos.startsWith("J")) {
                                pos = "A";
                            }

                            // si ya contiene la palabra, obtenemos su offset
                            if (words.containsKey(wordText)) {
                                // obtenemos el offset
                                int end = Integer.parseInt(offsets.split("-")[1]);
                                offsets = obtainOffset(textToAnalyze, wordText, end);
                                int start_offset = Integer.parseInt(offsets.split("-")[0]);
                                int end_offset = Integer.parseInt(offsets.split("-")[1]);
                                // modificamos la palabra(word) almacenada)
                                words.get(wordText).getStart_offset().add(start_offset);
                                words.get(wordText).getEnd_offset().add(end_offset);
                            } else {
                                // Si el lemma es (s) es que es genitivo sajon y si lo procesamos lo detecta como palabra rara
                                if (!lemma.equals("s") && !lemma.equals("S")) {
                                    // obtenemos la lista de sentidos - idwordnet
                                    List<String> senses = new ArrayList<String>();
                                    List<String> confidence = new ArrayList<String>();
                                    if (!part_line[posIds].equals("-")) {
                                        String[] sensesFree = part_line[posIds].split("/");
                                        float numSentidos = sensesFree.length;
                                        float normalizar = 1f;
                                        // Obtenemos el valor de normalizacion para confidence (MFS)
                                        if (methodDisambiguation.equals(MFS)) {
                                            for (int i = 1; i <= sensesFree.length; i++) {
                                                normalizar += (numSentidos - i) / numSentidos;
                                            }
                                        }
                                        // Calculamos la conficence en el caso del MFS
                                        for (int i = 0; i < sensesFree.length; i++) {
                                            String freq;
                                            if (methodDisambiguation.equals(MFS)) {
                                                freq = Double.toString(((numSentidos - i) / numSentidos) / normalizar);
                                            } else {
                                                Double freqDouble = Double.parseDouble(sensesFree[i].split(":")[1]);
                                                freq = Double.toString(freqDouble);
                                            }
                                            String idwn = sensesFree[i].split(":")[0].replace("-", "");
                                            confidence.add(freq);
                                            senses.add(idwn);
                                        }
                                    }
                                    // start_off y end_off
                                    int end = Integer.parseInt(offsets.split("-")[1]);
                                    offsets = obtainOffset(textToAnalyze, wordText, end);
                                    List<Integer> start_offset = new ArrayList<Integer>();
                                    start_offset.add(Integer.parseInt(offsets.split("-")[0]));
                                    List<Integer> end_offset = new ArrayList<Integer>();
                                    end_offset.add(Integer.parseInt(offsets.split("-")[1]));
//                                    words.put(wordText + offsets.split("-")[0], new Word(wordText, lemma, pos, start_offset, end_offset, senses, confidence));
                                    words.put(wordText, new Word(wordText, lemma, pos, start_offset, end_offset, senses, confidence));
                                }
                            }
                        }
                    }
                }
            }
        }
        fr.close();
        br.close();
        outputScript.delete();
        return words;
    }

    private HashMap<String, Word> obtainTokenFromGate(String inputText) throws ResourceInstantiationException {
        HashMap<String, Word> words = new HashMap<String, Word>();
        // cargamos el temporal
        gate.Document doc = gate.Factory.newDocument(inputText);
        AnnotationSet tokenBN = doc.getAnnotations("Tokenization").get("Token");
        for (Annotation token : tokenBN) {
            String pos = token.getFeatures().get("POS").toString();
            // Comprobamos los verbos auxiliares
            if (!pos.startsWith("Np") && !pos.startsWith("Vx")
                    && !pos.startsWith("Vy") && !pos.startsWith("Vi")) {
                if (pos.startsWith("V") || pos.startsWith("A") || pos.startsWith("N") || pos.startsWith("D")) {
                    String wordText = token.getFeatures().get("string").toString();
                    // obtenemos los offsets
                    int start_offset = token.getStartNode().getOffset().intValue();
                    int end_offset = token.getEndNode().getOffset().intValue();
                    // si lo tenemos en la lista
                    if (words.containsKey(wordText)) {
                        // modificamos la palabra(word) almacenada
                        words.get(wordText).getStart_offset().add(start_offset);
                        words.get(wordText).getEnd_offset().add(end_offset);
                    } else {
                        // lemma
                        String lemma = token.getFeatures().get("lemma").toString();
                        //offsets
                        List<Integer> start_offset_v = new ArrayList<Integer>();
                        start_offset_v.add(start_offset);
                        List<Integer> end_offset_v = new ArrayList<Integer>();
                        end_offset_v.add(end_offset);
                        // Creamos la palabra y añadimos a la lista
                        Word word = new Word(wordText, lemma, pos, start_offset_v, end_offset_v);
                        words.put(wordText, word);
                    }
                }
            }
        }
        Factory.deleteResource(doc);
        return words;
    }

    private HashMap<String, Word> parseTreeTagger(String textToAnalyze, File outputScript) throws FileNotFoundException, IOException {
        HashMap<String, Word> words = new HashMap<String, Word>();
        FileReader fr;
        BufferedReader br;
        String line;
        String offsets = "0-0";
        List<String> senses;
        fr = new FileReader(outputScript);
        br = new BufferedReader(fr);
        while ((line = br.readLine()) != null) {
            if (!line.equals("")) {
                String[] part_line = line.split("\\s+");
                // word
                String wordText = part_line[0];
                // POS
                String pos = part_line[1];
                if (!wordText.equals("")) {
                    /* No procesamos los nombres propios*/
                    if (!pos.startsWith("Np") && !pos.startsWith("Vx")
                            && !pos.startsWith("Vy") && !pos.startsWith("Vi")) {
                        /* Sólo almacenamos: NOMBRES, VERBOS, ADVERBIOS Y ADJETIVOS */
                        if (pos.startsWith("N") || pos.startsWith("V")
                                || pos.startsWith("A") || pos.startsWith("D")) {
                            // obtenemos los offsets
                            int end = Integer.parseInt(offsets.split("-")[1]);
                            offsets = obtainOffset(textToAnalyze, wordText, end);
                            if (words.containsKey(wordText)) {
                                int start_offset = Integer.parseInt(offsets.split("-")[0]);
                                int end_offset = Integer.parseInt(offsets.split("-")[1]);
                                // modificamos la palabra(word) almacenada
                                words.get(wordText).getStart_offset().add(start_offset);
                                words.get(wordText).getEnd_offset().add(end_offset);
                            } else {
                                // lemma
                                String lemma = part_line[2];
                                if (lemma.contains("+")) {
                                    String[] part_lemma = lemma.split("\\+");
                                    lemma = part_lemma[0];
                                }
                                //offsets
                                List<Integer> start_offset = new ArrayList<Integer>();
                                start_offset.add(Integer.parseInt(offsets.split("-")[0]));
                                List<Integer> end_offset = new ArrayList<Integer>();
                                end_offset.add(Integer.parseInt(offsets.split("-")[1]));

                                // Creamos la palabra y añadimos a la lista
                                Word word = new Word(wordText, wordText, pos, start_offset, end_offset);
                                words.put(wordText, word);
                            }
                        }
                    }
                }
            }
        }
        fr.close();
        br.close();
        outputScript.delete();
        return words;
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

    private void disambiguateWords(HashMap<String, Word> words, String method, String langCode) throws DisambiguationException, JWNLException, DatabaseException {
        if (method.equals(WORDNET)) {
            if (langCode.equals(LANGES)) {
                consultMultiWordNet(words);
            } else if (langCode.equals(LANGEN)) {
                consultWordNet(words);
            } else if (langCode.equals(LANGBG)) {
                consultBalkanet(words);
            }
        } else if (method.equals(FREELING)) {
            if (langCode.equals(LANGBG)) {
                throw new DisambiguationException(DisambiguationException.ERROR5);
            }
        }
    }

    private void consultWordNet(HashMap<String, Word> words) throws JWNLException, DisambiguationException {
        for (Map.Entry<String, Word> e : words.entrySet()) {
            // obtenemos una palabra
            Word wordAnalyze = (Word) e.getValue();
            List<String> senses = new ArrayList<String>();
            List<String> confidence = new ArrayList<String>();
            String pos = wordAnalyze.getPOS().substring(0, 1);
            IndexWord word = null;
            // Consutamos WordNet y obtenemos su id
            synchronized (wordNetDictionary) {
                if (pos.startsWith("N")) {
                    word = wordNetDictionary.lookupIndexWord(POS.NOUN, wordAnalyze.getLemma());
                } else if (pos.startsWith("V")) {
                    word = wordNetDictionary.lookupIndexWord(POS.VERB, wordAnalyze.getLemma());
                } else if (pos.startsWith("A") || (pos.startsWith("J"))) {
                    word = wordNetDictionary.lookupIndexWord(POS.ADJECTIVE, wordAnalyze.getLemma());
                } else if (pos.startsWith("R")) {
                    word = wordNetDictionary.lookupIndexWord(POS.ADVERB, wordAnalyze.getLemma());
                }
            }
            // Si la palabra está en WordNet
            if (word != null) {
                Synset[] synsets = word.getSenses();
                if (synsets.length <= 0) {
                    throw new DisambiguationException(DisambiguationException.ERROR10, word.getLemma());
                } else {
                    String posId = pos.substring(0, 1).toLowerCase();
                    float normalizar = 1f;
                    float numSentidos = synsets.length;
                    // Calculamos el valor de normalizacion para el confidence
                    for (int j = 1; j <= numSentidos; j++) {
                        normalizar += (numSentidos - j) / numSentidos;
                    }
                    // Recorremos todos los sentidos
                    for (int i = 0; i < synsets.length; i++) {
                        // Obtenemos el idWN
                        long idWordNet = synsets[i].getOffset();
                        StringBuilder idWordNetString = new StringBuilder(String.valueOf(idWordNet));
                        while (idWordNetString.length() < 8) {
                            idWordNetString.insert(0, "0");
                        }
                        String idwn = idWordNetString + posId;
                        // Obtenemos el confidence
                        String freq = Double.toString(((numSentidos - i) / numSentidos) / normalizar);
                        senses.add(idwn);
                        confidence.add(freq);
                    }
                    wordAnalyze.setIdSenses(senses);
                    wordAnalyze.setConfSenses(confidence);
                }
            }
        }
    }

    private void consultBalkanet(HashMap<String, Word> words) throws DatabaseException {
        // Obtenemos la conexion
        Database database = pool.get();
        try {
            // Consultamos todas las palabras
            for (Map.Entry<String, Word> e : words.entrySet()) {
                // obtenemos una palabra
                Word wordAnalyze = (Word) e.getValue();
                String posBalkanet = wordAnalyze.getPOS().substring(0, 1).toLowerCase();
                List<String> senses = new ArrayList<String>();
                List<String> senses20 = new ArrayList<String>();
                List<String> confidence = new ArrayList<String>();

                // Consultamos balkanet BD
                StringBuilder sbSynset = new StringBuilder(
                        "SELECT idWN FROM balkanet_first.synsets where word=? AND pos=? ORDER BY sense");
                Query qSynset = database.executeQuery(sbSynset.toString(), wordAnalyze.getLemma(), posBalkanet);
                while (qSynset.next()) {
                    String idWN = qSynset.getField("idWN").toString();
                    senses20.add(idWN);
                    if (idWN.startsWith("ENG20")) {
                        String[] part_line = idWN.split("-");
                        String idWN20 = part_line[1];
                        // mapeamos a wn30
                        if (posBalkanet.equals("r")) {
                            idWN = mapping2030adv.get(idWN20) + posBalkanet;
                        } else if (posBalkanet.equals("a")) {
                            idWN = mapping2030adj.get(idWN20) + posBalkanet;
                        } else if (posBalkanet.equals("n")) {
                            idWN = mapping2030noum.get(idWN20) + posBalkanet;
                        } else if (posBalkanet.equals("v")) {
                            idWN = mapping2030verb.get(idWN20) + posBalkanet;
                        }
                    }
                    senses.add(idWN);
                }
                qSynset.close();

                // Calculamos el confidence
                float normalizar = 1f;
                float numSentidos = senses.size();

                // Calculamos el valor de normalizacion para el confidence
                for (int j = 1; j <= numSentidos; j++) {
                    normalizar += (numSentidos - j) / numSentidos;
                }

                // Recorremos todos los sentidos
                for (int i = 0; i < senses.size(); i++) {
                    // Obtenemos el confidence
                    String freq = Double.toString(((numSentidos - i) / numSentidos) / normalizar);
                    confidence.add(freq);
                }

                // Asignamos los nuevos idWordNet y confidence
                wordAnalyze.setIdSenses(senses);
                wordAnalyze.setIdSenses20(senses20);
                wordAnalyze.setConfSenses(confidence);
            }
        } finally {
            // Liberamos la conexion
            pool.release(database);
        }
    }

    private void consultMultiWordNet(HashMap<String, Word> words) throws DatabaseException {
        // Obtenemos la conexion
        Database database = pool.get();
        try {
            // Consultamos todas las palabras
            for (Map.Entry<String, Word> e : words.entrySet()) {
                // obtenemos una palabra
                Word wordAnalyze = (Word) e.getValue();
                String posMultiWordNet = wordAnalyze.getPOS().substring(0, 1).toLowerCase();
                List<String> senses = new ArrayList<String>();
                List<String> confidence = new ArrayList<String>();

                // Consultamos MultiWordNet
                StringBuilder sbSynset = new StringBuilder(
                        "SELECT offset FROM `wei_spa-30_variant` where word = ? AND pos = ? ORDER BY sense"); //Ordenar por sense
                Query qSynset = database.executeQuery(sbSynset.toString(), wordAnalyze.getLemma(), posMultiWordNet);
                while (qSynset.next()) {
                    String offsetMCR = qSynset.getField("offset").toString();
                    String offset = offsetMCR.split("-")[2] + offsetMCR.split("-")[3];
                    senses.add(offset);
                }
                qSynset.close();

                // Calculamos el confidence
                float normalizar = 1f;
                float numSentidos = senses.size();

                // Calculamos el valor de normalizacion para el confidence
                for (int j = 1; j <= numSentidos; j++) {
                    normalizar += (numSentidos - j) / numSentidos;
                }

                // Recorremos todos los sentidos
                for (int i = 0; i < senses.size(); i++) {
                    // Obtenemos el confidence
                    String freq = Double.toString(((numSentidos - i) / numSentidos) / normalizar);
                    confidence.add(freq);
                }

                // Asignamos los nuevos idWordNet y confidence
                wordAnalyze.setIdSenses(senses);
                wordAnalyze.setConfSenses(confidence);
            }
        } finally {
            // Liberamos la conexion
            pool.release(database);
        }
    }

    private void detectionObstacles(HashMap<String, Word> words, ArrayList<String> obstacles, String langCode) throws DisambiguationException {
        // Obtenemos la lista de mental verbs en funcion del idioma
        Set<String> listMentalVerbs = (langCode.equals(LANGBG)) ? mentalVerbsBG
                : (langCode.equals(LANGEN)) ? mentalVerbsEN : mentalVerbsES;
        // Obtenemos la lista de palabras frecuentes segun el idioma
        Map<String, Integer> listFreq = (langCode.equals(LANGBG)) ? freqBG
                : (langCode.equals(LANGEN)) ? freqEN : freqES;
        // Obtenemos los WN-Domains
        Map<String, String> listDomains = WNDomanis;

        // Detectamos todos los obstaculos indicados
        for (String obstacle : obstacles) {
            if (obstacle.equals(RARE)) {
                detectionRareWords(words, listFreq);
            } else if (obstacle.equals(SPECIALIZED)) {
                detectionSpecializedWords(words, listDomains, listFreq);
            } else if (obstacle.equals(POLYSEMIC)) {
                detectionPolysemicWords(words);
            } else if (obstacle.equals(LONGWORDS)) {
                detectionLongWords(words, langCode);
            } else if (obstacle.equals(MENTALVERBS)) {
                detectionMentalVerbs(words, listMentalVerbs);
            } else {
                throw new DisambiguationException(DisambiguationException.ERROR3);
            }
        }
    }

    private void detectionRareWords(HashMap<String, Word> words, Map<String, Integer> listFreq) {
        Iterator it = words.entrySet().iterator();
        while (it.hasNext()) {
            Map.Entry e = (Map.Entry) it.next();
            Word word = (Word) e.getValue();
            if (!listFreq.containsKey(word.getLemma())) {
                word.setComplexity(MEDIUM);
                word.setIsRare(true);
            }
        }
    }

    private void detectionSpecializedWords(HashMap<String, Word> words, Map<String, String> listDomains, Map<String, Integer> listFreq) {
        Iterator it = words.entrySet().iterator();
        while (it.hasNext()) {
            Map.Entry e = (Map.Entry) it.next();
            Word word = (Word) e.getValue();            // Si la palabra no tiene idWordNet no se procesa
            if (word.getIdSenses() != null && word.getIdSenses().size() > 0) {
                if (!listFreq.containsKey(word.getLemma()) && !word.getPOS().startsWith("R")) {
                    String firstSense = word.getIdSenses().get(0);
                    if (listDomains.containsKey(firstSense)) {
                        word.setDomains(listDomains.get(firstSense));
                        word.setComplexity(HIGH);
                        word.setIsSpecialized(true);
                    }
                }
            }
        }
    }

    private void detectionPolysemicWords(HashMap<String, Word> words) {
        Iterator it = words.entrySet().iterator();
        while (it.hasNext()) {
            Map.Entry e = (Map.Entry) it.next();
            Word word = (Word) e.getValue();
            if (word.getIdSenses() != null && word.getIdSenses().size() > 1) {
                word.setComplexity(LOW);
                word.setIsPolysemic(true);
            }
        }
    }

    private void detectionLongWords(HashMap<String, Word> words, String langCode) {
        String ending = langCode.equals(LANGBG) ? "o" : langCode.equals(LANGEN) ? "ly" : "mente";
        Iterator it = words.entrySet().iterator();
        while (it.hasNext()) {
            Map.Entry e = (Map.Entry) it.next();
            Word word = (Word) e.getValue();
            if (word.getWord().length() > MAXLONGWORD || word.getWord().endsWith(ending)) {
                //Determinamos el complexity de la palabra
                if (word.getWord().length() >= RANKLONGWORD) {
                    word.setComplexity(HIGH);
                } else {
                    word.setComplexity(MEDIUM);
                }
                // Marcamos como palabra larga
                word.setIsLongWord(true);
            }
        }
    }

    private void detectionMentalVerbs(HashMap<String, Word> words, Set<String> listMentalVerbs) {
        Iterator it = words.entrySet().iterator();
        while (it.hasNext()) {
            Map.Entry e = (Map.Entry) it.next();
            Word word = (Word) e.getValue();
            if (listMentalVerbs != null && listMentalVerbs.contains(word.getLemma()) && word.getPOS().startsWith("V")) {
                word.setComplexity(MEDIUM);
                word.setIsMentalVerb(true);
            }
        }
    }

    private void resolutionObtacles(HashMap<String, Word> words, String langCode, int numMaxSenses) throws JWNLException, DatabaseException, IOException {
        if (langCode.equals(LANGES)) {
            resolveObstaclesES(words, numMaxSenses);
        } else if (langCode.equals(LANGEN)) {
            resolveObstaclesEN(words, numMaxSenses);
        } else if (langCode.equals(LANGBG)) {
            resolveObstaclesBG(words, numMaxSenses);
        }
    }

    private void resolveObstaclesEN(HashMap<String, Word> words, int numMaxSenses) throws JWNLException {
        for (Map.Entry<String, Word> e : words.entrySet()) {
            // obtenemos una palabra
            Word word = (Word) e.getValue();
            Synset sn = null;
            StringBuilder definitionsAll = new StringBuilder();
            StringBuilder synonymsAll = new StringBuilder();
            StringBuilder synonymSimpleAll = new StringBuilder();
            List<String> senses = word.getIdSenses();

            int iterator = Math.min(senses.size(), numMaxSenses);
            Set<String> synonymsSet = new HashSet<String>();
            for (int j = 0; j < iterator; j++) {
                String sense = senses.get(j);
                Long idWordNet = Long.parseLong(sense.substring(0, sense.length() - 1));
                String pos = sense.substring(sense.length() - 1, sense.length()).toUpperCase();
                word.setPOS(pos);
                // Consutamos WordNet y obtenemos su id
                synchronized (wordNetDictionary) {
                    if (pos.startsWith("N")) {
                        sn = wordNetDictionary.getSynsetAt(POS.NOUN, idWordNet);
                    } else if (pos.startsWith("V")) {
                        sn = wordNetDictionary.getSynsetAt(POS.VERB, idWordNet);
                    } else if (pos.startsWith("A") || (pos.startsWith("J"))) {
                        sn = wordNetDictionary.getSynsetAt(POS.ADJECTIVE, idWordNet);
                    } else if (pos.startsWith("R")) {
                        sn = wordNetDictionary.getSynsetAt(POS.ADVERB, idWordNet);
                    }
                }

                /* Obtenemos los sinonimos */
                String synonymSingle = "";
                int numSenseSyn = Integer.MAX_VALUE;
                for (int i = 0; i < sn.getWords().length; i++) {
                    String synonym;
                    if (!sn.getWords()[i].getLemma().equals(word.getLemma())) {
                        synonym = sn.getWords()[i].getLemma().replace("_", " ");
                        synonymsSet.add(synonym);

                        // Obtenemos el sinónimo más simple
                        int sensesSyn = 0;
                        synchronized (wordNetDictionary) {
                            if (pos.startsWith("N")) {
                                sensesSyn = wordNetDictionary.lookupIndexWord(POS.NOUN, synonym).getSenseCount();
                            } else if (pos.startsWith("V")) {
                                sensesSyn = wordNetDictionary.lookupIndexWord(POS.VERB, synonym).getSenseCount();
                            } else if (pos.startsWith("A") || (pos.startsWith("J"))) {
                                sensesSyn = wordNetDictionary.lookupIndexWord(POS.ADJECTIVE, synonym).getSenseCount();
                            } else if (pos.startsWith("R")) {
                                sensesSyn = wordNetDictionary.lookupIndexWord(POS.ADVERB, synonym).getSenseCount();
                            }
                        }
                        if (numSenseSyn > sensesSyn) {
                            numSenseSyn = sensesSyn;
                            synonymSingle = synonym;
                        } else if (numSenseSyn == sensesSyn) {
                            synonymSingle = synonymSingle.length() > synonym.length() ? synonym : synonymSingle;
                        }
                    }
                }

                synonymSimpleAll.append(synonymSingle).append("|");
                definitionsAll.append(sn.getGloss()).append("|");
            }
            // Obtenemos la lista de sinónimos
            for (String syn : synonymsSet) {
                synonymsAll.append(syn).append("|");
            }
            // Asignamos la resolución a la palabra
            word.setDefintions(definitionsAll.toString());
            word.setSynonyms(synonymsAll.toString());
            word.setSynonymSimple(synonymSimpleAll.toString());
        }
    }

    private void resolveObstaclesES(HashMap<String, Word> words, int numMaxSenses) throws DatabaseException, IOException {
        // Pedimos una conexion
        Database database = pool.get();
        try {
            for (Map.Entry<String, Word> e : words.entrySet()) {
                // obtenemos una palabra
                Word word = (Word) e.getValue();
                StringBuilder definitionsAll = new StringBuilder();
                StringBuilder synonymsAll = new StringBuilder();
                StringBuilder synonymSimpleAll = new StringBuilder();
                String pos = word.getPOS().substring(0, 1).toLowerCase();

                // Recorremos los sentidos asociados a esa palabra
                List<String> senses = word.getIdSenses();
                int iterator = Math.min(senses.size(), numMaxSenses);
                Set<String> synonymsSet = new HashSet<String>();
                for (int j = 0; j < iterator; j++) {
                    String idWNCompleto = senses.get(j);
                    String idWN = idWNCompleto.substring(0, idWNCompleto.length() - 1);
                    String definitionES = "";

                    // Consultamos multi-wordnet
                    StringBuilder sbSynset = new StringBuilder("SELECT gloss FROM `wei_spa-30_synset` where offset like ? AND pos = ?");
                    Query qSynset = database.executeQuery(sbSynset.toString(), "%" + idWN + "%", pos);
                    if (qSynset.next() && !qSynset.getField("gloss").toString().equals("NULL")) {
                        String gloss = qSynset.getField("gloss").toString();
                        definitionES = gloss.replace("_", " ");
                    } else {
                        // Consultamos BabelNet
                        List<BabelSynset> bs2 = babelNet.getBabelSynsetsFromWordNetOffset(idWNCompleto);
                        if (bs2 != null && bs2.size() > 0) {
                            BabelSynset bs22 = bs2.get(0);
                            if (!bs22.getGlosses(it.uniroma1.lcl.jlt.util.Language.ES).isEmpty()) {
                                definitionES = bs22.getGlosses(it.uniroma1.lcl.jlt.util.Language.ES).get(0).getGloss();
                            }
                        }
                    }
                    qSynset.close();

                    // Obtenemos los sinónimos de MultiwordNet 
                    StringBuilder sbSynonyms = new StringBuilder("SELECT word FROM `wei_spa-30_variant` where offset like ? AND pos = ?");
                    Query qSynonyms = database.executeQuery(sbSynonyms.toString(), "%" + idWN + "%", pos);

                    // Inicializamos el synonymSimple al primero de ellos
                    String synonymSingle = "";
                    int numSenseSym = Integer.MAX_VALUE;
                    while (qSynonyms.next()) {
                        if (!qSynonyms.getField("word").toString().equals(word.getLemma())) {
                            String synonym = qSynonyms.getField("word").toString().replace("_", " ");
                            synonymsSet.add(synonym);

                            // Consultamos los sentidos del sinónimo, para elegir el más simple o sencillo
                            StringBuilder sbSenses = new StringBuilder("SELECT count(*) FROM `wei_spa-30_variant` where word = ? AND pos = ?");
                            Query qSenses = database.executeQuery(sbSenses.toString(), synonym, pos);

                            // 1 criterio -> num sentidos | 2 criterio -> longitud
                            if (qSenses.next()) {
                                Integer numSensesNow = ((BigDecimal) qSenses.getField(1)).intValue();
                                if (numSenseSym > numSensesNow) {
                                    numSenseSym = numSensesNow;
                                    synonymSingle = synonym;
                                } else if (numSenseSym == numSensesNow) {
                                    synonymSingle = synonymSingle.length() > synonym.length() ? synonym : synonymSingle;
                                }
                            }
                            qSenses.close();

                            // 1 criterio -> longitud | 2 criterio -> num sentidos
                            //                        if (rsSenses.next()) {
                            //                            System.out.println(synonym + " " + rsSenses.getInt(1));
                            //                            if (synonym.length() < synonymSingle.length()) {
                            //                                numSenseSym = rsSenses.getInt(1);
                            //                                synonymSingle = synonym;
                            //                            } else if (synonym.length() == synonymSingle.length()) {
                            //                                if (numSenseSym > rsSenses.getInt(1)) {
                            //                                    numSenseSym = rsSenses.getInt(1);
                            //                                    synonymSingle = synonym;
                            //                                } 
                            //                            }
                            //                        }
                        }
                    }
                    qSynonyms.close();

                    definitionsAll.append(definitionES).append("|");
                    synonymSimpleAll.append(synonymSingle).append("|");
                }
                // Obtenemos la lista de sinónimos
                for (String syn : synonymsSet) {
                    synonymsAll.append(syn).append("|");
                }
                // Asignamos a la palabra su definicion y sinonimos
                word.setDefintions(definitionsAll.toString());
                word.setSynonyms(synonymsAll.toString());
                word.setSynonymSimple(synonymSimpleAll.toString());
            }
        } finally {
            // Liberamos la conexion
            pool.release(database);
        }
    }

    private void resolveObstaclesBG(HashMap<String, Word> words, int numMaxSenses) throws DatabaseException {
        Database database = pool.get();
        try {
            for (Map.Entry<String, Word> e : words.entrySet()) {
                // obtenemos una palabra
                Word word = (Word) e.getValue();
                StringBuilder definitionsAll = new StringBuilder();
                StringBuilder synonymsAll = new StringBuilder();
                StringBuilder synonymSimpleAll = new StringBuilder();

                List<String> senses = word.getIdSenses20();
                int iterator = Math.min(senses.size(), numMaxSenses);
                Set<String> synonymsSet = new HashSet<String>();
                for (int j = 0; j < iterator; j++) {
                    String idBalkaNet = senses.get(j);

                    // Consultamos balkanet BD
                    StringBuilder sbSynset = new StringBuilder(
                            "SELECT definition, synonyms, word FROM balkanet_first.synsets where idWN=? and word=? and pos=?");
                    Query query = database.executeQuery(sbSynset.toString(), idBalkaNet, word.getLemma(), word.getPOS().substring(0, 1).toLowerCase());
                    String synonymsBD;
                    String definitions = "";
                    String synonymSimple = "";
                    if (query.next()) {
                        synonymsBD = query.getField("synonyms").toString();
                        String wordDB = query.getField("word").toString();
                        definitions = query.getField("definition").toString();

                        // Obtenemos el sinónimo más simple
                        String[] synonyms = synonymsBD.split(",");
                        int numSensesMin = Integer.MAX_VALUE;
                        for (int i = 0; i < synonyms.length; i++) {
                            if (!synonyms[i].equals(word.getLemma())) {
                                String synonym = synonyms[i].replace("_", " ");
                                synonymsSet.add(synonym);
                                // if sinonimo es distinta de la palabra que analizamos y es Frecuente
                                if (!synonym.equals(wordDB)) {
                                    StringBuilder sbSynsetSynonym = new StringBuilder(
                                            "SELECT count(*) FROM balkanet_first.synsets where word=?");
                                    Query querySinonyms = database.executeQuery(sbSynsetSynonym.toString(), synonym);
                                    if (querySinonyms.next()) {
                                        Integer numSensesNow = ((BigDecimal) querySinonyms.getField(1)).intValue();
                                        if (numSensesNow < numSensesMin) {
                                            numSensesMin = numSensesNow;
                                            synonymSimple = synonym;
                                        } else if (numSensesNow == numSensesMin) {
                                            synonymSimple = synonymSimple.length() > synonym.length() ? synonym : synonymSimple;
                                        }
                                    }
                                    querySinonyms.close();
                                }
                            }
                            //                        else {
                            //                            synonymsBD = synonymsBD.replaceFirst(synonym + ",", "");
                            //                        }
                        }
                    }

                    // Añadimos los campos vacios con |
                    synonymSimpleAll.append(synonymSimple).append("|");
                    definitionsAll.append(definitions).append("|");
                    query.close();

                    // Eliminamos la coma
                    //                if (synonymsBD.length() > 0 && synonymsBD.substring(synonymsBD.length() - 1, synonymsBD.length()).equals(",")) {
                    //                    synonymsBD = synonymsBD.substring(0, synonymsBD.length() - 1);
                    //                }
                    //                synonymsAll.append(synonymsBD).append("|");
                }
                // Obtenemos la lista de sinónimos
                for (String syn : synonymsSet) {
                    synonymsAll.append(syn).append("|");
                }
                // Asignamos a la palabra su definicion y sinonimos
                word.setDefintions(definitionsAll.toString());
                word.setSynonyms(synonymsAll.toString());
                word.setSynonymSimple(synonymSimpleAll.toString());
            }
        } finally {
            // Liberamos la conexion
            pool.release(database);
        }
    }

    private String obtainOutput(ArrayList<String> obstacles, HashMap<String, Word> words, String formatOutput, String formatInput, String inputText, String textToAnalyze, String infoReturn, int numMaxDef) throws IOException, ParserConfigurationException, SAXException {
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
            Element annotationSetRare = null;
            Element annotationSetSpec = null;
            Element annotationSetPoly = null;
            Element annotationSetLong = null;
            Element annotationSetMent = null;
            if (obstacles.contains(RARE)) {
                annotationSetRare = createNewAnnot(gateDoc, "Disambiguate markups RARE");
            }
            if (obstacles.contains(SPECIALIZED)) {
                annotationSetSpec = createNewAnnot(gateDoc, "Disambiguate markups SPECIALIZED");
            }
            if (obstacles.contains(POLYSEMIC)) {
                annotationSetPoly = createNewAnnot(gateDoc, "Disambiguate markups POLYSEMIC");
            }
            if (obstacles.contains(LONGWORDS)) {
                annotationSetLong = createNewAnnot(gateDoc, "Disambiguate markups LONGWORDS");
            }
            if (obstacles.contains(MENTALVERBS)) {
                annotationSetMent = createNewAnnot(gateDoc, "Disambiguate markups MENTAL VERBS");
            }


            for (Map.Entry<String, Word> e : words.entrySet()) {
                Word word = (Word) e.getValue();
                int idParent = id;
                for (int i = 0; i < word.getStart_offset().size(); i++) {
                    // obtenems la caract de idWN y confidence
                    String idWordNetAll = obtainStringfromList(word.getIdSenses(), numMaxDef);
                    String confidenceAll = obtainStringfromList(word.getConfSenses(), numMaxDef);
                    // creamos las caracteristicas de la palabra en GATE
                    if (word.isIsRare()) {
                        Element annotationRare;
                        if (i > 0) {
                            annotationRare = createFeatureLink(gateDoc, idParent, id, word, i);
                        } else {
                            annotationRare = createFeatures(gateDoc, id, word, infoReturn, idWordNetAll, confidenceAll, RARE, i);
                        }
                        annotationSetRare.appendChild(annotationRare);
                    }
                    if (word.isIsSpecialized()) {
                        Element annotationSpec;
                        if (i > 0) {
                            annotationSpec = createFeatureLink(gateDoc, idParent, id, word, i);
                        } else {
                            annotationSpec = createFeatures(gateDoc, id, word, infoReturn, idWordNetAll, confidenceAll, SPECIALIZED, i);
                        }
                        // Add domains
                        Element feature = gateDoc.createElement("Feature");
                        annotationSpec.appendChild(feature);
                        Element name = gateDoc.createElement("Name");
                        name.setAttribute("className", "java.lang.String");
                        name.setTextContent("domains");
                        feature.appendChild(name);
                        Element value = gateDoc.createElement("Value");
                        value.setAttribute("className", "java.lang.String");
                        value.setTextContent(word.getDomains());
                        feature.appendChild(value);

                        // Add a specialized detection
                        annotationSetSpec.appendChild(annotationSpec);
                    }
                    if (word.isIsPolysemic()) {
                        Element annotationPoly;
                        if (i > 0) {
                            annotationPoly = createFeatureLink(gateDoc, idParent, id, word, i);
                        } else {
                            annotationPoly = createFeatures(gateDoc, id, word, infoReturn, idWordNetAll, confidenceAll, POLYSEMIC, i);
                        }
                        annotationSetPoly.appendChild(annotationPoly);
                    }
                    if (word.isIsLongWord()) {
                        Element annotationLong;
                        if (i > 0) {
                            annotationLong = createFeatureLink(gateDoc, idParent, id, word, i);
                        } else {
                            annotationLong = createFeatures(gateDoc, id, word, infoReturn, idWordNetAll, confidenceAll, LONGWORDS, i);
                        }
                        annotationSetLong.appendChild(annotationLong);
                    }
                    if (word.isIsMentalVerb()) {
                        Element annotationMentalVerb;
                        if (i > 0) {
                            annotationMentalVerb = createFeatureLink(gateDoc, idParent, id, word, i);
                        } else {
                            annotationMentalVerb = createFeatures(gateDoc, id, word, infoReturn, idWordNetAll, confidenceAll, MENTALVERBS, i);
                        }
                        annotationSetMent.appendChild(annotationMentalVerb);
                    }
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

    private Element createFeatures(Document gateDoc, int id, Word word, String infoReturned, String idWordNetAll, String confidenceAll, String typeWord, int posOffset) {
        Element definitionElement = gateDoc.createElement("Annotation");
        if (infoReturned.equals(DEFINITIONS) || infoReturned.equals(DEFSYN)) {
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
            value.setTextContent(word.getDefintions());
            feature.appendChild(value);

            if (infoReturned.equals(DEFSYN)) {
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
            }
        } else {
            String idAntecedente = Integer.toString(id);
            definitionElement.setAttribute("Id", idAntecedente);
            definitionElement.setAttribute("StartNode", word.getStart_offset() + "");
            definitionElement.setAttribute("EndNode", word.getEnd_offset() + "");
            definitionElement.setAttribute("Type", "Synonyms");
            // Add synonyms
            Element feature = gateDoc.createElement("Feature");
            definitionElement.appendChild(feature);
            Element name = gateDoc.createElement("Name");
            name.setAttribute("className", "java.lang.String");
            name.setTextContent("synonyms");
            feature.appendChild(name);
            Element value = gateDoc.createElement("Value");
            value.setAttribute("className", "java.lang.String");
            value.setTextContent(word.getSynonyms());
            feature.appendChild(value);
        }

        // Add word
        Element feature = gateDoc.createElement("Feature");
        definitionElement.appendChild(feature);
        Element name = gateDoc.createElement("Name");
        name.setAttribute("className", "java.lang.String");
        name.setTextContent("token");
        feature.appendChild(name);
        Element value = gateDoc.createElement("Value");
        value.setAttribute("className", "java.lang.String");
        value.setTextContent(word.getWord());
        feature.appendChild(value);

        // Add simple synonym
        feature = gateDoc.createElement("Feature");
        definitionElement.appendChild(feature);
        name = gateDoc.createElement("Name");
        name.setAttribute("className", "java.lang.String");
        name.setTextContent("synonym");
        feature.appendChild(name);
        value = gateDoc.createElement("Value");
        value.setAttribute("className", "java.lang.String");
        value.setTextContent(word.getSynonymSimple());
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

        // Add idWordNet
        feature = gateDoc.createElement("Feature");
        definitionElement.appendChild(feature);
        name = gateDoc.createElement("Name");
        name.setAttribute("className", "java.lang.String");
        name.setTextContent("idWN");
        feature.appendChild(name);
        value = gateDoc.createElement("Value");
        value.setAttribute("className", "java.lang.String");
        value.setTextContent(idWordNetAll);
        feature.appendChild(value);

//            feature = doc.createElement("Feature");
//            definitionElement.appendChild(feature);
//            name = doc.createElement("Name");
//            name.setAttribute("className", "java.lang.String");
//            name.setTextContent("senseKey");
//            feature.appendChild(name);
//            value = doc.createElement("Value");
//            value.setAttribute("className", "java.lang.String");
//            value.setTextContent(senseKey);
//            feature.appendChild(value);

        // Add Lemma
        feature = gateDoc.createElement("Feature");
        definitionElement.appendChild(feature);
        name = gateDoc.createElement("Name");
        name.setAttribute("className", "java.lang.String");
        name.setTextContent("lemma");
        feature.appendChild(name);
        value = gateDoc.createElement("Value");
        value.setAttribute("className", "java.lang.String");
        value.setTextContent(word.getLemma());
        feature.appendChild(value);

        // Add POS
        feature = gateDoc.createElement("Feature");
        definitionElement.appendChild(feature);
        name = gateDoc.createElement("Name");
        name.setAttribute("className", "java.lang.String");
        name.setTextContent("POS");
        feature.appendChild(name);
        value = gateDoc.createElement("Value");
        value.setAttribute("className", "java.lang.String");
//        value.setTextContent(word.getPOS());
        value.setTextContent(word.getPOS().substring(0, 1));
        feature.appendChild(value);

        // Add Complexity
        feature = gateDoc.createElement("Feature");
        definitionElement.appendChild(feature);
        name = gateDoc.createElement("Name");
        name.setAttribute("className", "java.lang.String");
        name.setTextContent("complexity");
        feature.appendChild(name);
        value = gateDoc.createElement("Value");
        value.setAttribute("className", "java.lang.String");
        value.setTextContent(String.valueOf(word.getComplexity()));
        feature.appendChild(value);

        // Add confidence
        feature = gateDoc.createElement("Feature");
        definitionElement.appendChild(feature);
        name = gateDoc.createElement("Name");
        name.setAttribute("className", "java.lang.String");
        name.setTextContent("confidence");
        feature.appendChild(name);
        value = gateDoc.createElement("Value");
        value.setAttribute("className", "java.lang.String");
        value.setTextContent(confidenceAll);
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

    private String obtainStringfromList(List<String> lists, int max) {
        StringBuilder listString = new StringBuilder();
        int iterator = Math.min(lists.size(), max);
        for (int i = 0; i < iterator; i++) {
            listString.append(lists.get(i)).append("|");
        }
        return listString.toString();
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
    // IMPRIMIR WN DOMAINS
//        MySQLDatabase database = (MySQLDatabase) pool.get();
//        Iterator it = WNDomanis.entrySet().iterator();
//        while (it.hasNext()) {
//            Map.Entry e = (Map.Entry) it.next();
//            // obtenemos palabra de wn (en)
//            String idWNTemp = (String) e.getKey();
//            String pos = idWNTemp.substring(idWNTemp.length() - 1, idWNTemp.length());
//            String idWNS = idWNTemp.substring(0, idWNTemp.length() - 1);
//            Long idWN = Long.valueOf(idWNS);
//            Synset sn = null;
//            if (pos.startsWith("n")) {
//                sn = wordNetDictionary.getSynsetAt(POS.NOUN, idWN);
//            } else if (pos.startsWith("v")) {
//                sn = wordNetDictionary.getSynsetAt(POS.VERB, idWN);
//            } else if (pos.startsWith("a") || (pos.startsWith("j"))) {
//                sn = wordNetDictionary.getSynsetAt(POS.ADJECTIVE, idWN);
//            } else if (pos.startsWith("r")) {
//                sn = wordNetDictionary.getSynsetAt(POS.ADVERB, idWN);
//            }
//            String words = "";
//            for (int i = 0; i < sn.getWordsSize(); i++) {
//                words += sn.getWord(i).getLemma() + " ";
//            }
//            System.out.println(e.getKey() + "||" + words + "||" + e.getValue());
    // Consultamos multi-wordnet
//            StringBuilder sbSynset = new StringBuilder("SELECT word FROM `wei_spa-30_variant` where offset like ? AND pos = ?");
//            Query qSynset = database.executeQuery(sbSynset.toString(), "%" + idWNS + "%", pos);
//            while (qSynset.next()) {
//                words += qSynset.getField("word").toString() + " ";
//            }
//            qSynset.close();
//            System.out.println(e.getKey() + "||" + words + "||" + e.getValue());
//        }
//        database.close();
//        pool.release(database);
    // CLONAR EL NODE
//    Element annotationRare = (Element) annotation.cloneNode(true);
//                        // Add TypeWord
//                        Element feature = gateDoc.createElement("Feature");
//                        annotationRare.appendChild(feature);
//                        Element name = gateDoc.createElement("Name");
//                        name.setAttribute("className", "java.lang.String");
//                        name.setTextContent("typeToken");
//                        feature.appendChild(name);
//                        Element value = gateDoc.createElement("Value");
//                        value.setAttribute("className", "java.lang.String");
//                        value.setTextContent(RARE);
//                        feature.appendChild(value);

    public void close() throws IOException {
        MapFile.close();
    }
}
class MapFile<K, V> {

    static private RecordManager recordManager;
    private final BTree tree;
    private boolean empty;
//        private static final String BTREE_NAME = "disambiguacion"; 

    public MapFile(String database, String btreeName) throws IOException {
        if (recordManager == null) {
            // open database and setup an object cache
            recordManager = RecordManagerFactory.createRecordManager(database, new Properties());
        }
        // try to reload an existing B+Tree
        long recid = recordManager.getNamedObject(btreeName);

        if (recid != 0) {
            tree = BTree.load(recordManager, recid);
            empty = false;
        } else {
            // create a new B+Tree data structure and use a StringComparator
            tree = BTree.createInstance(recordManager);
            recordManager.setNamedObject(btreeName, tree.getRecid());
            empty = true;
        }
    }

    Map<K, V> getMap() throws IOException {
        return tree.asMap();
    }

    void commit() throws IOException {
        recordManager.commit();
    }
    
    static void close() throws IOException {
        recordManager.close();
    }

    boolean isEmpty() {
        return empty;
    }
}