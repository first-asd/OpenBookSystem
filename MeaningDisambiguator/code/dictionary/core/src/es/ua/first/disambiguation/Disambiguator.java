///*
// * To change this license header, choose License Headers in Project Properties.
// * To change this template file, choose Tools | Templates
// * and open the template in the editor.
// */
//package es.ua.first.disambiguation;
//
//import es.ua.db.Database;
//import es.ua.db.DatabaseException;
//import es.ua.db.DatabasePool;
//import es.ua.db.MySQLDatabase;
//import es.ua.db.Query;
//import es.upv.xmlutils.XMLUtils;
//import it.uniroma1.lcl.babelnet.BabelNet;
//import it.uniroma1.lcl.babelnet.BabelNetConfiguration;
//import it.uniroma1.lcl.babelnet.BabelSynset;
//import java.io.BufferedReader;
//import java.io.BufferedWriter;
//import java.io.File;
//import java.io.FileInputStream;
//import java.io.FileNotFoundException;
//import java.io.FileReader;
//import java.io.FileWriter;
//import java.io.IOException;
//import java.math.BigDecimal;
//import java.net.URL;
//import java.sql.SQLException;
//import java.util.ArrayList;
//import java.util.HashMap;
//import java.util.List;
//import java.util.Map;
//import java.util.Properties;
//import java.util.TreeSet;
//import javax.xml.parsers.ParserConfigurationException;
//import net.didion.jwnl.JWNL;
//import net.didion.jwnl.JWNLException;
//import net.didion.jwnl.data.IndexWord;
//import net.didion.jwnl.data.POS;
//import net.didion.jwnl.data.Synset;
//import net.didion.jwnl.dictionary.Dictionary;
//import org.w3c.dom.Document;
//import org.w3c.dom.Element;
//import org.w3c.dom.NodeList;
//import org.xml.sax.SAXException;
//
///**
// *
// * @author jmgomez
// */
//public class Disambiguator {
//
//    public static final String VERSION = "3.0";
//    public static final String LANGEN = "en";
//    public static final String LANGES = "es";
//    public static final String LANGBG = "bg";
//    public static final String MFS = "MFS";
//    public static final String UKB = "UKB";
//    public static final String DEFINITIONS = "DEFINITIONS";
//    public static final String SYNONYMS = "SYNONYMS";
//    public static final String DEFSYN = "DEFSYN";
//    public static final String RARE = "RARE";
//    public static final String SPECIALIZED = "SPECIALIZED";
//    public static final String POLYSEMIC = "POLYSEMIC";
//    public static final String LONGWORDS = "LONGWORDS";
//    private static final String MENTALVERBS = "MENTALS VERBS";
//    private static final Double HIGH = 0.9;
//    private static final Double MEDIUM = 0.6;
//    private static final Double LOW = 0.3;
//    private static final Integer MAXLONGWORD = 7;
//    private static final Integer RANKLONGWORD = 10;
//    private final Dictionary wordNetDictionary;
//    private final DatabasePool pool;
//    private final BabelNet babelNet;
//    private Map<String, Integer> freqBG;
//    private Map<String, Integer> freqES;
//    private Map<String, Integer> freqEN;
//    private Map<String, String> mapping2030noum;
//    private Map<String, String> mapping2030adj;
//    private Map<String, String> mapping2030adv;
//    private Map<String, String> mapping2030verb;
//    private Map<String, String> WNDomanis;
//    private List<String> mentalVerbsES;
//    private List<String> mentalVerbsEN;
//    private List<String> mentalVerbsBG;
//    private static final String PROPERTY_FILE = "es/ua/first/config/babelnet.properties";
//
//    public Disambiguator(Properties defaultProps, String workingDir) throws JWNLException, DatabaseException, FileNotFoundException, IOException, DisambiguationException {
//        // Creamos una instancia de WordNet
//        String pathJWNL = defaultProps.getProperty("pathJWNL");
//        JWNL.initialize(new FileInputStream(pathJWNL));
//        wordNetDictionary = Dictionary.getInstance();
//        // Creamos la conexion a BD para consultar MWN
//        pool = createConnectionPool(defaultProps);
//        // Creamos la instancia a BabelNet
//        babelNet = createtBabelNet();
//        // Cargamos la lista de palabras frecuentes (EN, ES, BG)
//        freqBG = loadFreqWords(LANGBG, defaultProps, workingDir);
//        freqES = loadFreqWords(LANGES, defaultProps, workingDir);
//        freqEN = loadFreqWords(LANGEN, defaultProps, workingDir);
//        // Cargar fichero mapping de WordNet 2.0 a WordNet 3.0 y WN-Domains 
//        loadMapping2030(defaultProps, workingDir);
//        WNDomanis = loadDomains(defaultProps, workingDir);
//        // Cargamos las listas de mentalverbs (ES, EN, BG)
//        mentalVerbsES = loadMentalVerbs(LANGES, defaultProps, workingDir);
//        mentalVerbsBG = loadMentalVerbs(LANGBG, defaultProps, workingDir);
//        mentalVerbsEN = loadMentalVerbs(LANGEN, defaultProps, workingDir);
//    }
//
//    public String disambiguate(String pathInputFile, ArrayList<String> obstacles, String langCode, int numSenses, String methodDisambiguation, String informationReturned, String workingDir) throws IOException, ParserConfigurationException, SAXException, JWNLException, SQLException, DisambiguationException, InterruptedException, DatabaseException {
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
//        // Cargamos el fichero de entrada
//        String gateDocument = loadInputFile(pathInputFile);
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
//        File outputScript = runScript(textToAnalyze, scriptFreeling, methodDisambiguation, workingDir);
//
//        // Parseamos la salida Freeling o TreeTagger
//        List<Word> words;
//        if (langCode.equals(LANGEN) || langCode.equals(LANGES)) {
//            words = parseFreeling(textToAnalyze, outputScript, langCode, methodDisambiguation);
//        } else {
//            words = parseTreeTagger(textToAnalyze, outputScript);
//        }
//
//        // Obtenemos la lista de palabras frecuentes segun el idioma
//        Map<String, Integer> listFreq = (langCode.equals(LANGBG)) ? freqBG
//                : (langCode.equals(LANGEN)) ? freqEN : freqES;
//
//        for (String obs : obstacles) {
//            // Create annotation for this obstacle
//            Element annotationSetDisam = createNewAnnot(gateDoc, "Disambiguate markups " + obs);
//            if (obs.equals(RARE)) {
//                // Obtenemos la lista de mental verbs en funcion del idioma
//                List<String> listMentalVerbs = (langCode.equals(LANGBG)) ? mentalVerbsBG
//                        : (langCode.equals(LANGEN)) ? mentalVerbsEN : mentalVerbsES;
//                rareWords(gateDoc, annotationSetDisam, nodeOffsets, minNewId, words, listFreq, listMentalVerbs, langCode, methodDisambiguation, informationReturned, obs, numSenses);
//                return XMLUtils.toString(gateDoc);
//            } else if (obs.equals(SPECIALIZED)) {
//                // Obtenemos los WN-Domains
//                Map<String, String> listDomains = WNDomanis;
//                specializedWords(gateDoc, annotationSetDisam, nodeOffsets, minNewId, words, listDomains, listFreq, langCode, methodDisambiguation, informationReturned, obs, numSenses);
//                return XMLUtils.toString(gateDoc);
//            } else if (obs.equals(POLYSEMIC)) {
//                polysemicWords(gateDoc, annotationSetDisam, nodeOffsets, minNewId, words, langCode, methodDisambiguation, informationReturned, obs, numSenses);
//                return XMLUtils.toString(gateDoc);
//            } else if (obs.equals(LONGWORDS)) {
//                longWords(gateDoc, annotationSetDisam, nodeOffsets, minNewId, words, langCode, methodDisambiguation, informationReturned, obs, numSenses);
//                return XMLUtils.toString(gateDoc);
//            } else {
//                throw new DisambiguationException(DisambiguationException.ERROR3);
//            }
//        }
//
//        return null;
//    }
//
//    private static String convertPlain2Gate(String text) {
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
//
//    private DatabasePool createConnectionPool(Properties defaultProps) throws DatabaseException, NumberFormatException {
//        String dbhost = defaultProps.getProperty("dataBaseServer");
//        String dbuser = defaultProps.getProperty("dataBaseUser");
//        String dbpassw = defaultProps.getProperty("dataBasePassword");
//        String dbnameMWN = defaultProps.getProperty("dataBaseNameMWN");
//        int maxConnections = Integer.parseInt(defaultProps.getProperty("maxConnections"));
//        Database database = new MySQLDatabase(dbhost, dbuser, dbpassw, dbnameMWN);
//        return new DatabasePool(database, maxConnections);
//    }
//
//    private BabelNet createtBabelNet() {
//        /* Creamos una instancia de BN */
//        ClassLoader loader = Disambiguator.class.getClassLoader();
//        URL url = loader.getResource(PROPERTY_FILE);
//        BabelNetConfiguration bnc = BabelNetConfiguration.getInstance();
//        bnc.setConfigurationFile(new File(url.getFile()));
//        return BabelNet.getInstance();
//    }
//
//    private void loadMapping2030(Properties defaultProps, String workingDir) throws FileNotFoundException, IOException {
//        // Cargamos el mapping de adjetivos
//        String filemapping2030 = workingDir + defaultProps.getProperty("pathWNMappingAdj");
//        File mapping2030File = new File(filemapping2030);
//        mapping2030adj = new HashMap<String, String>();
//        BufferedReader readermapping2030 = new BufferedReader(new FileReader(mapping2030File));
//        String linemap2030;
//        while ((linemap2030 = readermapping2030.readLine()) != null) {
//            linemap2030 = linemap2030.trim();
//            String[] part_line = linemap2030.split("\\s+");
//            mapping2030adj.put(part_line[0], part_line[1]);
//        }
//        readermapping2030.close();
//
//        // Cargamos el maping de adverbios
//        filemapping2030 = defaultProps.getProperty("pathWNMappingAdv");
//        mapping2030File = new File(filemapping2030);
//        mapping2030adv = new HashMap<String, String>();
//        readermapping2030 = new BufferedReader(new FileReader(mapping2030File));
//        while ((linemap2030 = readermapping2030.readLine()) != null) {
//            linemap2030 = linemap2030.trim();
//            String[] part_line = linemap2030.split("\\s+");
//            mapping2030adv.put(part_line[0], part_line[1]);
//        }
//        readermapping2030.close();
//
//        // Cargamos los nombres
//        filemapping2030 = defaultProps.getProperty("pathWNMappingNoun");
//        mapping2030File = new File(filemapping2030);
//        mapping2030noum = new HashMap<String, String>();
//        readermapping2030 = new BufferedReader(new FileReader(mapping2030File));
//        while ((linemap2030 = readermapping2030.readLine()) != null) {
//            linemap2030 = linemap2030.trim();
//            String[] part_line = linemap2030.split("\\s+");
//            mapping2030noum.put(part_line[0], part_line[1]);
//        }
//        readermapping2030.close();
//
//        // Cargamos los verbos
//        filemapping2030 = defaultProps.getProperty("pathWNMappingVerb");
//        mapping2030File = new File(filemapping2030);
//        mapping2030verb = new HashMap<String, String>();
//        readermapping2030 = new BufferedReader(new FileReader(mapping2030File));
//        while ((linemap2030 = readermapping2030.readLine()) != null) {
//            linemap2030 = linemap2030.trim();
//            String[] part_line = linemap2030.split("\\s+");
//            mapping2030verb.put(part_line[0], part_line[1]);
//        }
//        readermapping2030.close();
//    }
//
//    private Map<String, String> loadDomains(Properties defaultProps, String workingDir) throws FileNotFoundException, IOException {
//        Map<String, String> domains;
//        String fileWNDom = workingDir + defaultProps.getProperty("pathWNDomains");
//        File DomainWNFile = new File(fileWNDom);
//        BufferedReader readerWNDomain = new BufferedReader(new FileReader(DomainWNFile));
//        domains = new HashMap<String, String>();
//        String lineWNDomain;
//        while ((lineWNDomain = readerWNDomain.readLine()) != null) {
//            lineWNDomain = lineWNDomain.trim();
//            String[] part_line = lineWNDomain.split("\\t+");
//            if (!part_line[1].contains("factotum")) {
//                String idWn20 = part_line[0].substring(0, part_line[0].length() - 2);
//                String pos = part_line[0].substring(part_line[0].length() - 1, part_line[0].length());
//                String idWn30 = "";
//                // Realizamos el mapping en funcion del POS
//                if (pos.equals("r")) {
//                    idWn30 = mapping2030adv.get(idWn20) + pos;
//                } else if (pos.equals("a")) {
//                    idWn30 = mapping2030adj.get(idWn20) + pos;
//                } else if (pos.equals("n")) {
//                    idWn30 = mapping2030noum.get(idWn20) + pos;
//                } else if (pos.equals("v")) {
//                    idWn30 = mapping2030verb.get(idWn20) + pos;
//                }
//                domains.put(idWn30, part_line[1].trim());
//            }
//        }
//        readerWNDomain.close();
//        return domains;
//    }
//
//    private Map<String, Integer> loadFreqWords(String langCode, Properties defaultProps, String workingDir) throws FileNotFoundException, IOException, DisambiguationException {
//        BufferedReader readerFreq;
//        String file = "";
//        int posIni = 0;
//        int posFin = 0;
//        int tamlist = 0;
//        int stopwords = 0;
//        Map<String, Integer> listFreq = new HashMap<String, Integer>();
//        if (langCode.equals(LANGBG)) {
//            file = workingDir + defaultProps.getProperty("pathFreqBG");
//            posIni = 0;
//            posFin = 1;
//            tamlist = 3258;
//        } else if (langCode.equals(LANGES)) {
//            file = workingDir + defaultProps.getProperty("pathFreqES");
////            posIni = 1;
////            posFin = 2;
//            posIni = 1;
//            posFin = 3;  // No guardamos su frecuencia porque al lemmatizar lo hemos perdido
//            tamlist = 3350;
//            stopwords = 352;
//        } else if (langCode.equals(LANGEN)) {
//            file = workingDir + defaultProps.getProperty("pathFreqEN");
////            posIni = 3;
////            posFin = 0;
//            posIni = 1;
//            posFin = 3; // No guardamos su frecuencia porque al lemmatizar lo hemos perdido
//            tamlist = 3570;
//            stopwords = 572;
//        } else {
//            throw new DisambiguationException(DisambiguationException.ERROR4);
//        }
//
//        File freqFile = new File(file);
//        readerFreq = new BufferedReader(new FileReader(freqFile));
//        String lineFreq = "";
//        int i = 0;
//        while ((lineFreq = readerFreq.readLine()) != null && listFreq.size() <= tamlist) {
//            if (listFreq.size() < stopwords) {
//                posIni = 0;
//            }
//            lineFreq = lineFreq.trim();
//            String[] part_line = lineFreq.split("\\s+");
//            // NO GUARDAMOS LA FRECUENCIA
//            listFreq.put(part_line[posIni].toLowerCase(), 1);
//            i++;
//        }
//        readerFreq.close();
//
//        return listFreq;
//    }
//
//    private List<String> loadMentalVerbs(String langCode, Properties defaultProps, String workingDir) throws FileNotFoundException, IOException {
//        List<String> listMentalVerbs = new ArrayList<String>();
//        BufferedReader readerMentalVerbs = null;
//        String file = null;
//
//        // Cargamos el fichero de los verbos mentales
//        if (langCode.equals(LANGBG)) {
//            file = workingDir + defaultProps.getProperty("pathMentalVerbsBG");
//        } else if (langCode.equals(LANGEN)) {
//            file = workingDir + defaultProps.getProperty("pathMentalVerbsEN");
//        } else {
//            file = workingDir + defaultProps.getProperty("pathMentalVerbsES");
//        }
//
//        // Leemos el fichero que corresponda en funcion del idioma
//        File freqFile = new File(file);
//        readerMentalVerbs = new BufferedReader(new FileReader(freqFile));
//        String line;
//        int i = 0;
//        while ((line = readerMentalVerbs.readLine()) != null) {
//            line = line.trim();
//            listMentalVerbs.add(line);
//            i++;
//        }
//        readerMentalVerbs.close();
//        return listMentalVerbs;
//    }
//
//    private int rareWords(Document gateDoc, Element annotationSetDisam, TreeSet<Integer> nodeOffsets, int id, List<Word> words, Map<String, Integer> listFreq, List<String> listMentalVerbs, String langCode, String methodDisambiguation, String informationReturned, String obstacle, int numSenses) throws JWNLException, IOException, SQLException, DisambiguationException, DatabaseException {
//        for (Word rareWord : words) {
//            /* Comprobamos MENTAL VERBS */
//            if (listMentalVerbs != null && listMentalVerbs.contains(rareWord.getLemma()) && rareWord.getPOS().equals("V")) {
//                rareWord.setTypeWord(MENTALVERBS);
//                rareWord.setComplexity(MEDIUM);
//                if (rareWord.getSenses() != null && rareWord.getSenses().size() > 0) {
//                    id = getDefinition(gateDoc, annotationSetDisam, nodeOffsets, id, rareWord, methodDisambiguation, langCode, numSenses, obstacle, informationReturned);
//                } else {
//                    id = addAnnotationEmpty(gateDoc, annotationSetDisam, nodeOffsets, id, rareWord);
//                }
//            } else {
//                /* Comprobamos LESS COMMON WORDS - RARE */
//                if (!listFreq.containsKey(rareWord.getLemma())) {
//                    rareWord.setTypeWord(RARE);
//                    rareWord.setComplexity(MEDIUM);
//                    if (rareWord.getSenses() != null && rareWord.getSenses().size() > 0) {
//                        id = getDefinition(gateDoc, annotationSetDisam, nodeOffsets, id, rareWord, methodDisambiguation, langCode, numSenses, obstacle, informationReturned);
//                    } else {
//                        // Aunque no tenga definición la marcamos (¿Añadimos un feature?)
//                        id = addAnnotationEmpty(gateDoc, annotationSetDisam, nodeOffsets, id, rareWord);
//                    }
//                }
//            }
//        }
//        insertNodeGateDocument(gateDoc, nodeOffsets);
//        return id;
//    }
//
//    private int specializedWords(Document gateDoc, Element annotationSetDisam, TreeSet<Integer> nodeOffsets, int id, List<Word> words, Map<String, String> listDomains, Map<String, Integer> listFreq, String langCode, String methodDisambiguation, String informationReturned, String obstacle, int numSenses) throws JWNLException, IOException, SQLException, DisambiguationException, DatabaseException {
//        boolean stop = false;
//        for (Word specializeWord : words) {
//            String pos = specializeWord.getPOS().toLowerCase();
//            /* Si la palabra no tiene idWordNet no se procesa */
//            if (specializeWord.getSenses() != null && specializeWord.getSenses().size() > 0) {
//                if (!listFreq.containsKey(specializeWord.getLemma()) && !specializeWord.getPOS().startsWith("R")) {
//                    for (int i = 0; i < specializeWord.getSenses().size() && !stop; i++) {
//                        String idWordNet = specializeWord.getSenses().get(i).split(":")[0];
//                        if (langCode.equals(LANGBG)) {
//                            if (listDomains.containsKey(idWordNet)) {
//                                specializeWord.setComplexity(HIGH);
//                                specializeWord.setTypeWord(SPECIALIZED);
//                                specializeWord.setDomains(listDomains.get(idWordNet));
//                                id = getDefinition(gateDoc, annotationSetDisam, nodeOffsets, id, specializeWord, methodDisambiguation, langCode, numSenses, obstacle, informationReturned);
//                                stop = true;
//                            }
//                        } else {
//                            // Realizamos el mapping del idBalkanet a la versión 3.0, porque esta en la 2.0
//                            // y la lista listDomain tiene los synsets en la versión 3.0
//                            String idBalkanet20 = idWordNet.split("-")[1];
//                            String idWn30 = "";
//                            if (pos.equals("r")) {
//                                idWn30 = mapping2030adv.get(idBalkanet20) + pos;
//                            } else if (pos.equals("a")) {
//                                idWn30 = mapping2030adj.get(idBalkanet20) + pos;
//                            } else if (pos.equals("n")) {
//                                idWn30 = mapping2030noum.get(idBalkanet20) + pos;
//                            } else if (pos.equals("v")) {
//                                idWn30 = mapping2030verb.get(idBalkanet20) + pos;
//                            }
//
//                            // Comprobamos si esta en la lista
//                            if (listDomains.containsKey(idWn30)) {
//                                specializeWord.setComplexity(HIGH);
//                                specializeWord.setTypeWord(SPECIALIZED);
//                                specializeWord.setDomains(listDomains.get(idWn30));
//                                id = getDefinition(gateDoc, annotationSetDisam, nodeOffsets, id, specializeWord, methodDisambiguation, langCode, numSenses, obstacle, informationReturned);
//                                stop = true;
//                            }
//                        }
//                    }
//                    stop = false;
//                }
//            }
//        }
//        insertNodeGateDocument(gateDoc, nodeOffsets);
//        return id;
//    }
//
//    private int polysemicWords(Document gateDoc, Element annotationSetDisam, TreeSet<Integer> nodeOffsets, int id, List<Word> words, String langCode, String methodDisambiguation, String informationReturned, String obstacle, int numSenses) throws JWNLException, IOException, SQLException, DisambiguationException, DatabaseException {
//        for (Word word : words) {
//            if (word.getSenses() != null && word.getSenses().size() > 1) {
//                word.setComplexity(LOW);
//                word.setTypeWord(POLYSEMIC);
//                id = getDefinition(gateDoc, annotationSetDisam, nodeOffsets, id, word, methodDisambiguation, langCode, numSenses, obstacle, informationReturned);
//            }
//        }
//        insertNodeGateDocument(gateDoc, nodeOffsets);
//        return id;
//    }
//
//    private int longWords(Document gateDoc, Element annotationSetDisam, TreeSet<Integer> nodeOffsets, int id, List<Word> words, String langCode, String methodDisambiguation, String informationReturned, String obstacle, int numSenses) throws JWNLException, IOException, SQLException, DisambiguationException, DatabaseException {
//        String ending = langCode.equals(LANGBG) ? "o" : langCode.equals(LANGEN) ? "ly" : "mente";
//        for (Word word : words) {
//            //Determinamos el complexity de la palabra
//            if (word.getWord().length() >= RANKLONGWORD) {
//                word.setComplexity(HIGH);
//            } else {
//                word.setComplexity(MEDIUM);
//            }
//
//            if (word.getWord().length() > MAXLONGWORD || word.getWord().endsWith(ending)) {
//                word.setTypeWord(LONGWORDS);
//                if (word.getSenses() != null && word.getSenses().size() > 0) {
//                    id = getDefinition(gateDoc, annotationSetDisam, nodeOffsets, id, word, methodDisambiguation, langCode, numSenses, obstacle, informationReturned);
//                } else {
//                    id = addAnnotationEmpty(gateDoc, annotationSetDisam, nodeOffsets, id, word);
//                }
//            }
//        }
//        insertNodeGateDocument(gateDoc, nodeOffsets);
//        return id;
//    }
//
//    private int getDefinition(Document gateDoc, Element annotationSetDisam, TreeSet<Integer> nodeOffsets, int id, Word word, String methodDisambiguation, String langCode, int numSenses, String obstacle, String informationReturned) throws JWNLException, IOException, SQLException, DisambiguationException, DatabaseException {
//        if (langCode.equals(LANGEN)) {
//            id = getDefinitionEN(gateDoc, annotationSetDisam, nodeOffsets, id, word, numSenses, informationReturned, obstacle);
//        } else if (langCode.equals(LANGES)) {
//            id = getDefinitionES(gateDoc, annotationSetDisam, nodeOffsets, id, word, numSenses, informationReturned, obstacle);
//        } else if (langCode.equals(LANGBG)) {
//            if (methodDisambiguation.equals(MFS)) {
//                id = getDefinitionBG(gateDoc, annotationSetDisam, nodeOffsets, id, word, numSenses, informationReturned, obstacle);
//            } else {
//                throw new DisambiguationException(DisambiguationException.ERROR12);
//            }
//        } else {
//            throw new DisambiguationException(DisambiguationException.ERROR4);
//        }
//        return id;
//    }
//
//    private int getDefinitionEN(Document gateDoc, Element annotationSetDisam, TreeSet<Integer> nodeOffsets, int id, Word word, int numSenses, String informationReturned, String obstacle) throws JWNLException {
//        String pos = word.getPOS().substring(0, 1);
//        Synset sn = null;
//        String synonymSingle;
//        int numSenseSyn = Integer.MAX_VALUE;
//        List<String> senses = word.getSenses();
//        StringBuilder definitionsAll = new StringBuilder();
//        StringBuilder synonymsAll = new StringBuilder();
//        StringBuilder synonymSimpleAll = new StringBuilder();
//        StringBuilder confidenceAll = new StringBuilder();
//        StringBuilder idWordNetAll = new StringBuilder();
//        String senseKey = "";
//
//        int iterator = Math.min(senses.size(), numSenses);
//        for (int j = 0; j < iterator; j++) {
//            String[] sense = senses.get(j).split(":");
//            Long idWordNet = Long.parseLong(sense[0].substring(0, sense[0].length() - 1));
//            pos = sense[0].substring(sense[0].length() - 1, sense[0].length()).toUpperCase();
//            idWordNetAll.append(sense[0]).append("|");
//            double confidence = Double.parseDouble(sense[1]);
//
//            /* Consutamos WordNet y obtenemos su id*/
//            if (pos.startsWith("N")) {
//                sn = wordNetDictionary.getSynsetAt(POS.NOUN, idWordNet);
//            } else if (pos.startsWith("V")) {
//                sn = wordNetDictionary.getSynsetAt(POS.VERB, idWordNet);
//            } else if (pos.startsWith("A") || (pos.startsWith("J"))) {
//                sn = wordNetDictionary.getSynsetAt(POS.ADJECTIVE, idWordNet);
//            } else if (pos.startsWith("R")) {
//                sn = wordNetDictionary.getSynsetAt(POS.ADVERB, idWordNet);
//            }
//
//            /* Obtenemos los sinonimos */
//            StringBuilder synonyms = new StringBuilder();
//            synonymSingle = "";
//            for (int i = 0; i < sn.getWords().length; i++) {
//                String synonym = sn.getWords()[i].getLemma();
//                if (i != sn.getWords().length - 1) {
//                    synonyms.append(synonym).append(", ");
//                } else {
//                    synonyms.append(synonym);
//                }
//
//                /* Obtenemos el sinónimo más simple */
//                if (!synonym.equals(word.getLemma())) {
//                    if (freqEN.containsKey(synonym)) {
//                        int sensesSyn = 0;
//                        if (pos.startsWith("N")) {
//                            sensesSyn = wordNetDictionary.lookupIndexWord(POS.NOUN, synonym).getSenseCount();
//                        } else if (pos.startsWith("V")) {
//                            sensesSyn = wordNetDictionary.lookupIndexWord(POS.VERB, synonym).getSenseCount();
//                        } else if (pos.startsWith("A") || (pos.startsWith("J"))) {
//                            sensesSyn = wordNetDictionary.lookupIndexWord(POS.ADJECTIVE, synonym).getSenseCount();
//                        } else if (pos.startsWith("R")) {
//                            sensesSyn = wordNetDictionary.lookupIndexWord(POS.ADVERB, synonym).getSenseCount();
//                        }
//                        if (numSenseSyn > sensesSyn) {
//                            numSenseSyn = sensesSyn;
//                            synonymSingle = synonym;
//                        } else if (numSenseSyn == sensesSyn) {
//                            synonymSingle = synonymSingle.length() > synonym.length() ? synonym : synonymSingle;
//                        }
//                    }
//                }
//            }
//
//            // Si no detectamos ningun sinonimo como simple, asignamos el mismo
//            if (synonymSingle.equals("")) {
//                synonymSingle = word.getLemma();
//            }
//
//            definitionsAll.append(sn.getGloss()).append("|");
//            synonymsAll.append(synonyms).append("|");
//            synonymSimpleAll.append(synonymSingle).append("|");
//            confidenceAll.append(confidence).append("|");
//
//            /* SENSE KEY -> solo lo utilizamos para evaluar la desambiguacion */
////                List<BabelSynset> bs2 = babelNet.getBabelSynsetsFromWordNetOffset(sense[0]);
////                if (bs2 != null && bs2.size() > 0) {
////                    BabelSynset bs22 = bs2.get(0);
////                    senseKey = bs22.getId();
//////                    List<BabelSense> sensesKey = bs22.getSenses(BabelSenseSource.WN);
//////                    
//////                    for (int i = 0; i < sensesKey.size(); i++) {
//////                        if (sensesKey.get(i).getLemma().equals(word.getLemma())) {
//////                            senseKey = sensesKey.get(i).getSensekey();
//////                        }
//////                    }
////                }
//        }
//
//        /* Create XML */
//        Element definitionElement = gateDoc.createElement("Annotation");
//        if (informationReturned.equals(DEFINITIONS) || informationReturned.equals(DEFSYN)) {
//            String idDefinition = Integer.toString(id);
//            definitionElement.setAttribute("Id", idDefinition);
//            definitionElement.setAttribute("StartNode", word.getStart_offset() + "");
//            definitionElement.setAttribute("EndNode", word.getEnd_offset() + "");
//            definitionElement.setAttribute("Type", "Definition");
//            annotationSetDisam.appendChild(definitionElement);
//
//            /* Add definition */
//            Element feature = gateDoc.createElement("Feature");
//            definitionElement.appendChild(feature);
//            Element name = gateDoc.createElement("Name");
//            name.setAttribute("className", "java.lang.String");
//            name.setTextContent("definition");
//            feature.appendChild(name);
//            Element value = gateDoc.createElement("Value");
//            value.setAttribute("className", "java.lang.String");
//            value.setTextContent(definitionsAll.toString());
//            feature.appendChild(value);
//
//            if (informationReturned.equals(SYNONYMS)) {
//                feature = gateDoc.createElement("Feature");
//                definitionElement.appendChild(feature);
//                name = gateDoc.createElement("Name");
//                name.setAttribute("className", "java.lang.String");
//                name.setTextContent("synonyms");
//                feature.appendChild(name);
//                value = gateDoc.createElement("Value");
//                value.setAttribute("className", "java.lang.String");
//                value.setTextContent(synonymsAll.toString());
//                feature.appendChild(value);
//            }
//
//        } else {
//            String idAntecedente = Integer.toString(id);
//            definitionElement.setAttribute("Id", idAntecedente);
//            definitionElement.setAttribute("StartNode", word.getStart_offset() + "");
//            definitionElement.setAttribute("EndNode", word.getEnd_offset() + "");
//            definitionElement.setAttribute("Type", "Synonyms");
//            annotationSetDisam.appendChild(definitionElement);
//
//            Element feature = gateDoc.createElement("Feature");
//            definitionElement.appendChild(feature);
//            Element name = gateDoc.createElement("Name");
//            name.setAttribute("className", "java.lang.String");
//            name.setTextContent("synonyms");
//            feature.appendChild(name);
//            Element value = gateDoc.createElement("Value");
//            value.setAttribute("className", "java.lang.String");
//            value.setTextContent(synonymSimpleAll.toString());
//            feature.appendChild(value);
//        }
//
//        Element feature = gateDoc.createElement("Feature");
//        definitionElement.appendChild(feature);
//        Element name = gateDoc.createElement("Name");
//        name.setAttribute("className", "java.lang.String");
//        name.setTextContent("token");
//        feature.appendChild(name);
//        Element value = gateDoc.createElement("Value");
//        value.setAttribute("className", "java.lang.String");
//        value.setTextContent(word.getWord());
//        feature.appendChild(value);
//
//        if (obstacle.equals(SPECIALIZED)) {
//            feature = gateDoc.createElement("Feature");
//            definitionElement.appendChild(feature);
//            name = gateDoc.createElement("Name");
//            name.setAttribute("className", "java.lang.String");
//            name.setTextContent("domains");
//            feature.appendChild(name);
//            value = gateDoc.createElement("Value");
//            value.setAttribute("className", "java.lang.String");
//            value.setTextContent(word.getDomains());
//            feature.appendChild(value);
//        }
//
//        feature = gateDoc.createElement("Feature");
//        definitionElement.appendChild(feature);
//        name = gateDoc.createElement("Name");
//        name.setAttribute("className", "java.lang.String");
//        name.setTextContent("synonym");
//        feature.appendChild(name);
//        value = gateDoc.createElement("Value");
//        value.setAttribute("className", "java.lang.String");
//        value.setTextContent(synonymSimpleAll.toString());
//        feature.appendChild(value);
//
//        feature = gateDoc.createElement("Feature");
//        definitionElement.appendChild(feature);
//        name = gateDoc.createElement("Name");
//        name.setAttribute("className", "java.lang.String");
//        name.setTextContent("idWN");
//        feature.appendChild(name);
//        value = gateDoc.createElement("Value");
//        value.setAttribute("className", "java.lang.String");
//        value.setTextContent(idWordNetAll.toString());
//        feature.appendChild(value);
//
////            feature = doc.createElement("Feature");
////            definitionElement.appendChild(feature);
////            name = doc.createElement("Name");
////            name.setAttribute("className", "java.lang.String");
////            name.setTextContent("senseKey");
////            feature.appendChild(name);
////            value = doc.createElement("Value");
////            value.setAttribute("className", "java.lang.String");
////            value.setTextContent(senseKey);
////            feature.appendChild(value);
//
//        feature = gateDoc.createElement("Feature");
//        definitionElement.appendChild(feature);
//        name = gateDoc.createElement("Name");
//        name.setAttribute("className", "java.lang.String");
//        name.setTextContent("typeToken");
//        feature.appendChild(name);
//        value = gateDoc.createElement("Value");
//        value.setAttribute("className", "java.lang.String");
//        value.setTextContent(word.getTypeWord());
//        feature.appendChild(value);
//
//        feature = gateDoc.createElement("Feature");
//        definitionElement.appendChild(feature);
//        name = gateDoc.createElement("Name");
//        name.setAttribute("className", "java.lang.String");
//        name.setTextContent("lemma");
//        feature.appendChild(name);
//        value = gateDoc.createElement("Value");
//        value.setAttribute("className", "java.lang.String");
//        value.setTextContent(word.getLemma());
//        feature.appendChild(value);
//
//        feature = gateDoc.createElement("Feature");
//        definitionElement.appendChild(feature);
//        name = gateDoc.createElement("Name");
//        name.setAttribute("className", "java.lang.String");
//        name.setTextContent("POS");
//        feature.appendChild(name);
//        value = gateDoc.createElement("Value");
//        value.setAttribute("className", "java.lang.String");
//        value.setTextContent(pos);
//        feature.appendChild(value);
//
//        feature = gateDoc.createElement("Feature");
//        definitionElement.appendChild(feature);
//        name = gateDoc.createElement("Name");
//        name.setAttribute("className", "java.lang.String");
//        name.setTextContent("complexity");
//        feature.appendChild(name);
//        value = gateDoc.createElement("Value");
//        value.setAttribute("className", "java.lang.String");
//        value.setTextContent(String.valueOf(word.getComplexity()));
//        feature.appendChild(value);
//
//        feature = gateDoc.createElement("Feature");
//        definitionElement.appendChild(feature);
//        name = gateDoc.createElement("Name");
//        name.setAttribute("className", "java.lang.String");
//        name.setTextContent("confidence");
//        feature.appendChild(name);
//        value = gateDoc.createElement("Value");
//        value.setAttribute("className", "java.lang.String");
//        value.setTextContent(confidenceAll.toString());
//        feature.appendChild(value);
//
//        id++;
//        nodeOffsets.add(word.getStart_offset());
//        nodeOffsets.add(word.getEnd_offset());
//        return id;
//    }
//
//    private int getDefinitionES(Document gateDoc, Element annotationSetDisam, TreeSet<Integer> nodeOffsets, int id, Word word, int numSenses, String informationReturned, String obstacle) throws SQLException, IOException, DatabaseException {
//        MySQLDatabase database = null;
//        String definitionES = "-";
//        String synonymSingle = "";
//        int numSenseSym = Integer.MAX_VALUE;
//        List<String> senses = word.getSenses();
//        String pos = "";
//        String posFree = word.getPOS().substring(0, 1);
//        StringBuilder definitionsAll = new StringBuilder();
//        StringBuilder synonymsAll = new StringBuilder();
//        StringBuilder synonymSimpleAll = new StringBuilder();
//        StringBuilder confidenceAll = new StringBuilder();
//        StringBuilder idWordNetAll = new StringBuilder();
//
//        // Pedimos una conexion
//        try {
//            database = (MySQLDatabase) pool.get();
//
//            // Obtenemos el pos
//            pos = (posFree.startsWith("N")) ? "n"
//                    : (posFree.startsWith("A")) ? "a"
//                    : (posFree.startsWith("V")) ? "v" : "r";
//
//            // Consultamos multiwordnet para cada uno de los SENTIDOS DE LA PALABRA 
//            int iterator = Math.min(senses.size(), numSenses);
//            for (int j = 0; j < iterator; j++) {
//                String[] sense = senses.get(j).split(":");
//                String idwnPos = sense[0];
//                String idWordNet = idwnPos.substring(0, idwnPos.length() - 1);  //eliminar el pos (n,v,a,r) porque en base de datos se consulta sin n
//                idWordNetAll.append(idwnPos).append("|");
//                double confidence = Double.parseDouble(sense[1]);
//                definitionES = "-";
//
//                /* Consultamos multi-wordnet*/
//                StringBuilder sbSynset = new StringBuilder("SELECT gloss FROM `wei_spa-30_synset` where offset like ? AND pos = ?");
//                Query qSynset = database.executeQuery(sbSynset.toString(), "%" + idWordNet + "%", pos);
//
////            PreparedStatement psSynset = database.prepareStatement(sbSynset.toString());
////            psSynset.setString(1, "%" + idWordNet + "%");
////            psSynset.setString(2, pos);
////            ResultSet rsSynset = psSynset.executeQuery();
//                if (qSynset.next()) {
//                    String gloss = qSynset.getField("gloss").toString();
//                    if (gloss.equals("NULL")) {
//                        /* Consultamos BabelNet*/
//                        List<BabelSynset> bs2 = babelNet.getBabelSynsetsFromWordNetOffset(idwnPos);
//                        if (bs2 != null && bs2.size() > 0) {
//                            BabelSynset bs22 = bs2.get(0);
//                            if (!bs22.getGlosses(it.uniroma1.lcl.jlt.util.Language.ES).isEmpty()) {
//                                definitionES = bs22.getGlosses(it.uniroma1.lcl.jlt.util.Language.ES).get(0).getGloss();
//                            }
//                        }
//                    } else {
//                        definitionES = gloss.replace("_", " ");
//                    }
//                } else {
//                    /* Consultamos BabelNet*/
//                    try {
//                        List<BabelSynset> bs2 = babelNet.getBabelSynsetsFromWordNetOffset(idwnPos);
//                        if (bs2 != null && bs2.size() > 0) {
//                            BabelSynset bs22 = bs2.get(0);
//                            if (!bs22.getGlosses(it.uniroma1.lcl.jlt.util.Language.ES).isEmpty()) {
//                                definitionES = bs22.getGlosses(it.uniroma1.lcl.jlt.util.Language.ES).get(0).getGloss();
//                            }
//                        }
//                    } catch (Exception e) {
//                        //No se encuentra en Babelnet el id que nos devuelve el mapping.
//                    }
//                }
//                qSynset.close();
////            psSynset.close();
////            rsSynset.close();
//
//                /* Obtenemos los sinónimos de MultiwordNet */
//                StringBuilder synonyms = new StringBuilder();
//                StringBuilder sbSynonyms = new StringBuilder("SELECT word FROM `wei_spa-30_variant` where offset like ? AND pos = ?");
//                Query qSynonyms = database.executeQuery(sbSynonyms.toString(), "%" + idWordNet + "%", pos);
////            PreparedStatement psSynonyms = database.prepareStatement(sbSynonyms.toString());
////            psSynonyms.setString(1, "%" + idWordNet + "%");
////            psSynonyms.setString(2, pos);
////            ResultSet rsSynonyms = psSynonyms.executeQuery();
//                // Inicializamos el synonymSimple al primero de ellos
//                synonymSingle = qSynonyms.next() ? qSynonyms.getField("word").toString().replace("_", " ") : "";
//                synonyms.append(synonymSingle).append(",");
//
//                while (qSynonyms.next()) {
//                    String synonym = qSynonyms.getField("word").toString().replace("_", " ");
//                    synonyms.append(synonym).append(",");
//
//                    /* Consultamos los sentidos del sinónimo, para elegir el más simple o sencillo */
//                    if (!synonym.equals(word.getLemma())) {
//                        if (freqES.containsKey(synonym)) {
//                            StringBuilder sbSenses = new StringBuilder("SELECT count(*) FROM `wei_spa-30_variant` where word = ? AND pos = ?");
//                            Query qSenses = database.executeQuery(sbSenses.toString(), synonym, pos);
////                        PreparedStatement psSenses = database.prepareStatement(sbSenses.toString());
////                        psSenses.setString(1, synonym);
////                        psSenses.setString(2, pos);
////                        ResultSet rsSenses = psSenses.executeQuery();
//
//                            // 1 criterio -> num sentidos | 2 criterio -> longitud
//                            if (qSenses.next()) {
////                                System.out.println(synonym + " " + rsSenses.getInt(1));
//                                Integer numSensesNow = ((BigDecimal) qSenses.getField(1)).intValue();
//                                if (numSenseSym > numSensesNow) {
//                                    numSenseSym = numSensesNow;
//                                    synonymSingle = synonym;
//                                } else if (numSenseSym == numSensesNow) {
//                                    synonymSingle = synonymSingle.length() > synonym.length() ? synonym : synonymSingle;
//                                }
//                            }
//
//                            // 1 criterio -> longitud | 2 criterio -> num sentidos
////                        if (rsSenses.next()) {
////                            System.out.println(synonym + " " + rsSenses.getInt(1));
////                            if (synonym.length() < synonymSingle.length()) {
////                                numSenseSym = rsSenses.getInt(1);
////                                synonymSingle = synonym;
////                            } else if (synonym.length() == synonymSingle.length()) {
////                                if (numSenseSym > rsSenses.getInt(1)) {
////                                    numSenseSym = rsSenses.getInt(1);
////                                    synonymSingle = synonym;
////                                } 
////                            }
////                        }
//
////                        psSenses.close();
////                        rsSenses.close();
//                            qSenses.close();
//                        }
//                    }
//                }
////            psSynonyms.close();
////            rsSynonyms.close();
//                qSynonyms.close();
//
//                // Si no hemos detectado sinonimo más simple, asignamos la palabra en sí
//                if (synonymSingle.equals("")) {
//                    synonymSingle = word.getLemma();
//                }
//
//                definitionsAll.append(definitionES).append("|");
//                // Elimino última coma
//                synonyms.replace(synonyms.length() - 1, synonyms.length(), "");
//                synonymsAll.append(synonyms).append("|");
//                synonymSimpleAll.append(synonymSingle).append("|");
//                confidenceAll.append(confidence).append("|");
//
//                /* Sense Key */
////                List<BabelSynset> bs2 = babelNet.getBabelSynsetsFromWordNetOffset(sense[0]);
////                if (bs2 != null && bs2.size() > 0) {
////                    BabelSynset synsetBN = bs2.get(0);
////                    senseKey = synsetBN.getId();
////                }
//            }
//        } finally {
//            database.close();
//            pool.release(database);
//        }
//
//        /* Creamos el documento GATE */
//        Element definitionElement = gateDoc.createElement("Annotation");
//        if (informationReturned.equals(DEFINITIONS) || informationReturned.equals(DEFSYN)) {
//            String idDefinition = Integer.toString(id);
//            definitionElement.setAttribute("Id", idDefinition);
//            definitionElement.setAttribute("StartNode", word.getStart_offset() + "");
//            definitionElement.setAttribute("EndNode", word.getEnd_offset() + "");
//            definitionElement.setAttribute("Type", "Definition");
//            annotationSetDisam.appendChild(definitionElement);
//
//            /* Add definition */
//            Element feature = gateDoc.createElement("Feature");
//            definitionElement.appendChild(feature);
//            Element name = gateDoc.createElement("Name");
//            name.setAttribute("className", "java.lang.String");
//            name.setTextContent("definition");
//            feature.appendChild(name);
//            Element value = gateDoc.createElement("Value");
//            value.setAttribute("className", "java.lang.String");
//            value.setTextContent(definitionsAll.toString());
//            feature.appendChild(value);
//
//            if (informationReturned.equals(DEFSYN)) {
//                feature = gateDoc.createElement("Feature");
//                definitionElement.appendChild(feature);
//                name = gateDoc.createElement("Name");
//                name.setAttribute("className", "java.lang.String");
//                name.setTextContent("synonyms");
//                feature.appendChild(name);
//                value = gateDoc.createElement("Value");
//                value.setAttribute("className", "java.lang.String");
//                value.setTextContent(synonymsAll.toString());
//                feature.appendChild(value);
//            }
//        } else {
//            String idAntecedente = Integer.toString(id);
//            definitionElement.setAttribute("Id", idAntecedente);
//            definitionElement.setAttribute("StartNode", word.getStart_offset() + "");
//            definitionElement.setAttribute("EndNode", word.getEnd_offset() + "");
//            definitionElement.setAttribute("Type", "Synonyms");
//            annotationSetDisam.appendChild(definitionElement);
//
//            Element feature = gateDoc.createElement("Feature");
//            definitionElement.appendChild(feature);
//            Element name = gateDoc.createElement("Name");
//            name.setAttribute("className", "java.lang.String");
//            name.setTextContent("synonyms");
//            feature.appendChild(name);
//            Element value = gateDoc.createElement("Value");
//            value.setAttribute("className", "java.lang.String");
//            value.setTextContent(synonymsAll.toString());
//            feature.appendChild(value);
//        }
//
//        Element feature = gateDoc.createElement("Feature");
//        definitionElement.appendChild(feature);
//        Element name = gateDoc.createElement("Name");
//        name.setAttribute("className", "java.lang.String");
//        name.setTextContent("token");
//        feature.appendChild(name);
//        Element value = gateDoc.createElement("Value");
//        value.setAttribute("className", "java.lang.String");
//        value.setTextContent(word.getWord());
//        feature.appendChild(value);
//
//        if (obstacle.equals(SPECIALIZED)) {
//            feature = gateDoc.createElement("Feature");
//            definitionElement.appendChild(feature);
//            name = gateDoc.createElement("Name");
//            name.setAttribute("className", "java.lang.String");
//            name.setTextContent("domains");
//            feature.appendChild(name);
//            value = gateDoc.createElement("Value");
//            value.setAttribute("className", "java.lang.String");
//            value.setTextContent(word.getDomains());
//            feature.appendChild(value);
//        }
//
//        feature = gateDoc.createElement("Feature");
//        definitionElement.appendChild(feature);
//        name = gateDoc.createElement("Name");
//        name.setAttribute("className", "java.lang.String");
//        name.setTextContent("synonym");
//        feature.appendChild(name);
//        value = gateDoc.createElement("Value");
//        value.setAttribute("className", "java.lang.String");
//        value.setTextContent(synonymSimpleAll.toString());
//        feature.appendChild(value);
//
//        feature = gateDoc.createElement("Feature");
//        definitionElement.appendChild(feature);
//        name = gateDoc.createElement("Name");
//        name.setAttribute("className", "java.lang.String");
//        name.setTextContent("idWN");
//        feature.appendChild(name);
//        value = gateDoc.createElement("Value");
//        value.setAttribute("className", "java.lang.String");
//        value.setTextContent(idWordNetAll.toString());
//        feature.appendChild(value);
//
//        /* Sense key - evaluacion - 1 solo sentido */
////            feature = doc.createElement("Feature");
////            definitionElement.appendChild(feature);
////            name = doc.createElement("Name");
////            name.setAttribute("className", "java.lang.String");
////            name.setTextContent("senseKey");
////            feature.appendChild(name);
////            value = doc.createElement("Value");
////            value.setAttribute("className", "java.lang.String");
////            value.setTextContent(senseKey);
////            feature.appendChild(value);
//
//        feature = gateDoc.createElement("Feature");
//        definitionElement.appendChild(feature);
//        name = gateDoc.createElement("Name");
//        name.setAttribute("className", "java.lang.String");
//        name.setTextContent("lemma");
//        feature.appendChild(name);
//        value = gateDoc.createElement("Value");
//        value.setAttribute("className", "java.lang.String");
//        value.setTextContent(word.getLemma());
//        feature.appendChild(value);
//
//        feature = gateDoc.createElement("Feature");
//        definitionElement.appendChild(feature);
//        name = gateDoc.createElement("Name");
//        name.setAttribute("className", "java.lang.String");
//        name.setTextContent("typeToken");
//        feature.appendChild(name);
//        value = gateDoc.createElement("Value");
//        value.setAttribute("className", "java.lang.String");
//        value.setTextContent(word.getTypeWord());
//        feature.appendChild(value);
//
//        feature = gateDoc.createElement("Feature");
//        definitionElement.appendChild(feature);
//        name = gateDoc.createElement("Name");
//        name.setAttribute("className", "java.lang.String");
//        name.setTextContent("POS");
//        feature.appendChild(name);
//        value = gateDoc.createElement("Value");
//        value.setAttribute("className", "java.lang.String");
//        value.setTextContent(posFree);
//        feature.appendChild(value);
//
//        feature = gateDoc.createElement("Feature");
//        definitionElement.appendChild(feature);
//        name = gateDoc.createElement("Name");
//        name.setAttribute("className", "java.lang.String");
//        name.setTextContent("complexity");
//        feature.appendChild(name);
//        value = gateDoc.createElement("Value");
//        value.setAttribute("className", "java.lang.String");
//        value.setTextContent(String.valueOf(word.getComplexity()));
//        feature.appendChild(value);
//
//        feature = gateDoc.createElement("Feature");
//        definitionElement.appendChild(feature);
//        name = gateDoc.createElement("Name");
//        name.setAttribute("className", "java.lang.String");
//        name.setTextContent("confidence");
//        feature.appendChild(name);
//        value = gateDoc.createElement("Value");
//        value.setAttribute("className", "java.lang.String");
//        value.setTextContent(confidenceAll.toString());
//        feature.appendChild(value);
//
//        id++;
//        nodeOffsets.add(word.getStart_offset());
//        nodeOffsets.add(word.getEnd_offset());
//        return id;
//    }
//
//    private int getDefinitionBG(Document gateDoc, Element annotationSetDisam, TreeSet<Integer> nodeOffsets, int id, Word word, int numSenses, String informationReturned, String obstacle) throws SQLException, DatabaseException {
//        MySQLDatabase database = null;
//        List<String> senses = word.getSenses();
//        StringBuilder definitionsAll = new StringBuilder();
//        StringBuilder synonymsAll = new StringBuilder();
//        StringBuilder synonymSimpleAll = new StringBuilder();
//        StringBuilder confidenceAll = new StringBuilder();
//        StringBuilder idWordNetAll = new StringBuilder();
//        try {
//            database = (MySQLDatabase) pool.get();
//            int iterator = Math.min(senses.size(), numSenses);
//            for (int j = 0; j < iterator; j++) {
//                String idBalkaNet = senses.get(j).split(":")[0];
//                String confidence = senses.get(j).split(":")[1];
//
//                // Consultamos balkanet BD
//                StringBuilder sbSynset = new StringBuilder(
//                        "SELECT definition, synonyms, word FROM balkanet_first.synsets where idWN=? and word=?");
//                Query query = database.executeQuery(sbSynset.toString(), idBalkaNet, word.getWord());
//
////            PreparedStatement psSynset = connectionUtils(sbSynset.toString());
////            psSynset.setString(1, idBalkaNet);
////            psSynset.setString(2, word.getWord());
//
////            ResultSet rsSynset = psSynset.executeQuery();
//                if (query.next()) {
//                    definitionsAll.append(query.getField("definition")).append("|");
//                    String synonymsBD = query.getField("synonyms").toString();
//                    synonymsAll.append(synonymsBD.substring(0, synonymsBD.length() - 1)).append("|");
//                    idWordNetAll.append(idBalkaNet).append("|");
//                    confidenceAll.append(confidence).append("|");
//                    String wordDB = query.getField("word").toString();
//
//                    /* Obtenemos el sinónimo más simple */
//                    String[] synonyms = synonymsBD.split(",");
//                    int numSensesMin = Integer.MAX_VALUE;
//                    String synonymSimple = "";
//                    for (int i = 0; i < synonyms.length; i++) {
//                        String synonym = synonyms[i];
//                        /* if sinonimo es distinta de la palabra que analizamos y es Frecuente*/
//                        if (!synonym.equals(wordDB) && freqBG.containsKey(synonym)) {
//                            StringBuilder sbSynsetSynonym = new StringBuilder(
//                                    "SELECT count(*) FROM balkanet_first.synsets where word=?");
//                            Query querySinonyms = database.executeQuery(sbSynsetSynonym.toString(), synonym);
////                        PreparedStatement psSynsetSynonym = database.prepareStatement(sbSynsetSynonym.toString());
////                        psSynsetSynonym.setString(1, synonym);
//
////                        ResultSet rsSynsetSynonym = psSynsetSynonym.executeQuery();
//                            if (querySinonyms.next()) {
//                                int numSensesNow = (Integer) querySinonyms.getField(1);
//                                if (numSensesNow < numSensesMin) {
//                                    numSensesMin = numSensesNow;
//                                    synonymSimple = synonym;
//                                } else if (numSensesNow == numSensesMin) {
//                                    synonymSimple = synonymSimple.length() > synonym.length() ? synonym : synonymSimple;
//                                }
//                            }
//                            querySinonyms.close();
////                        psSynsetSynonym.close();
////                        rsSynsetSynonym.close();
//                        }
//                    }
//
//                    /* Si no hay sinonimo más simple, devolvemos la palabra*/
//                    if (synonymSimple.equals("")) {
//                        synonymSimple = wordDB;
//                    }
//                    synonymSimpleAll.append(synonymSimple).append("|");
//                }
//                query.close();
////            psSynset.close();
////            rsSynset.close();
//            }
//        } finally {
//            database.close();
//            pool.release(database);
//        }
//
//        /* Generamos el documento GATE */
//        Element definitionElement = gateDoc.createElement("Annotation");
//        if (informationReturned.equals(DEFINITIONS) || informationReturned.equals(DEFSYN)) {
//            String idDefinition = Integer.toString(id);
//            definitionElement.setAttribute("Id", idDefinition);
//            definitionElement.setAttribute("StartNode", word.getStart_offset() + "");
//            definitionElement.setAttribute("EndNode", word.getEnd_offset() + "");
//            definitionElement.setAttribute("Type", "Definition");
//            annotationSetDisam.appendChild(definitionElement);
//
//            /* Add definition */
//            Element feature = gateDoc.createElement("Feature");
//            definitionElement.appendChild(feature);
//            Element name = gateDoc.createElement("Name");
//            name.setAttribute("className", "java.lang.String");
//            name.setTextContent("definition");
//            feature.appendChild(name);
//            Element value = gateDoc.createElement("Value");
//            value.setAttribute("className", "java.lang.String");
//            value.setTextContent(definitionsAll.toString());
//            feature.appendChild(value);
//
//            if (informationReturned.equals(DEFSYN)) {
//                feature = gateDoc.createElement("Feature");
//                definitionElement.appendChild(feature);
//                name = gateDoc.createElement("Name");
//                name.setAttribute("className", "java.lang.String");
//                name.setTextContent("synonyms");
//                feature.appendChild(name);
//                value = gateDoc.createElement("Value");
//                value.setAttribute("className", "java.lang.String");
//                value.setTextContent(synonymsAll.toString());
//                feature.appendChild(value);
//            }
//        } else {
//            String idAntecedente = Integer.toString(id);
//            definitionElement.setAttribute("Id", idAntecedente);
//            definitionElement.setAttribute("StartNode", word.getStart_offset() + "");
//            definitionElement.setAttribute("EndNode", word.getEnd_offset() + "");
//            definitionElement.setAttribute("Type", "Synonyms");
//            annotationSetDisam.appendChild(definitionElement);
//
//            Element feature = gateDoc.createElement("Feature");
//            definitionElement.appendChild(feature);
//            Element name = gateDoc.createElement("Name");
//            name.setAttribute("className", "java.lang.String");
//            name.setTextContent("synonyms");
//            feature.appendChild(name);
//            Element value = gateDoc.createElement("Value");
//            value.setAttribute("className", "java.lang.String");
//            value.setTextContent(synonymsAll.toString());
//            feature.appendChild(value);
//        }
//
//        Element feature = gateDoc.createElement("Feature");
//        definitionElement.appendChild(feature);
//        Element name = gateDoc.createElement("Name");
//        name.setAttribute("className", "java.lang.String");
//        name.setTextContent("token");
//        feature.appendChild(name);
//        Element value = gateDoc.createElement("Value");
//        value.setAttribute("className", "java.lang.String");
//        value.setTextContent(word.getWord());
//        feature.appendChild(value);
//
//        if (obstacle.equals(SPECIALIZED)) {
//            feature = gateDoc.createElement("Feature");
//            definitionElement.appendChild(feature);
//            name = gateDoc.createElement("Name");
//            name.setAttribute("className", "java.lang.String");
//            name.setTextContent("domains");
//            feature.appendChild(name);
//            value = gateDoc.createElement("Value");
//            value.setAttribute("className", "java.lang.String");
//            value.setTextContent(word.getDomains());
//            feature.appendChild(value);
//        }
//
//        feature = gateDoc.createElement("Feature");
//        definitionElement.appendChild(feature);
//        name = gateDoc.createElement("Name");
//        name.setAttribute("className", "java.lang.String");
//        name.setTextContent("synonym");
//        feature.appendChild(name);
//        value = gateDoc.createElement("Value");
//        value.setAttribute("className", "java.lang.String");
//        value.setTextContent(synonymSimpleAll.toString());
//        feature.appendChild(value);
//
//        feature = gateDoc.createElement("Feature");
//        definitionElement.appendChild(feature);
//        name = gateDoc.createElement("Name");
//        name.setAttribute("className", "java.lang.String");
//        name.setTextContent("idWN");
//        feature.appendChild(name);
//        value = gateDoc.createElement("Value");
//        value.setAttribute("className", "java.lang.String");
//        value.setTextContent(idWordNetAll.toString());
//        feature.appendChild(value);
//
//        /* Sense key - evaluacion - 1 solo sentido */
////            feature = doc.createElement("Feature");
////            definitionElement.appendChild(feature);
////            name = doc.createElement("Name");
////            name.setAttribute("className", "java.lang.String");
////            name.setTextContent("senseKey");
////            feature.appendChild(name);
////            value = doc.createElement("Value");
////            value.setAttribute("className", "java.lang.String");
////            value.setTextContent(senseKey);
////            feature.appendChild(value);
//
//        feature = gateDoc.createElement("Feature");
//        definitionElement.appendChild(feature);
//        name = gateDoc.createElement("Name");
//        name.setAttribute("className", "java.lang.String");
//        name.setTextContent("lemma");
//        feature.appendChild(name);
//        value = gateDoc.createElement("Value");
//        value.setAttribute("className", "java.lang.String");
//        value.setTextContent(word.getLemma());
//        feature.appendChild(value);
//
//        feature = gateDoc.createElement("Feature");
//        definitionElement.appendChild(feature);
//        name = gateDoc.createElement("Name");
//        name.setAttribute("className", "java.lang.String");
//        name.setTextContent("typeToken");
//        feature.appendChild(name);
//        value = gateDoc.createElement("Value");
//        value.setAttribute("className", "java.lang.String");
//        value.setTextContent(word.getTypeWord());
//        feature.appendChild(value);
//
//        feature = gateDoc.createElement("Feature");
//        definitionElement.appendChild(feature);
//        name = gateDoc.createElement("Name");
//        name.setAttribute("className", "java.lang.String");
//        name.setTextContent("POS");
//        feature.appendChild(name);
//        value = gateDoc.createElement("Value");
//        value.setAttribute("className", "java.lang.String");
//        value.setTextContent(word.getPOS());
//        feature.appendChild(value);
//
//        feature = gateDoc.createElement("Feature");
//        definitionElement.appendChild(feature);
//        name = gateDoc.createElement("Name");
//        name.setAttribute("className", "java.lang.String");
//        name.setTextContent("complexity");
//        feature.appendChild(name);
//        value = gateDoc.createElement("Value");
//        value.setAttribute("className", "java.lang.String");
//        value.setTextContent(String.valueOf(word.getComplexity()));
//        feature.appendChild(value);
//
//        feature = gateDoc.createElement("Feature");
//        definitionElement.appendChild(feature);
//        name = gateDoc.createElement("Name");
//        name.setAttribute("className", "java.lang.String");
//        name.setTextContent("confidence");
//        feature.appendChild(name);
//        value = gateDoc.createElement("Value");
//        value.setAttribute("className", "java.lang.String");
//        value.setTextContent(confidenceAll.toString());
//        feature.appendChild(value);
//
//        id++;
//        nodeOffsets.add(word.getStart_offset());
//        nodeOffsets.add(word.getEnd_offset());
//        return id;
//    }
//
//    private int addAnnotationEmpty(Document gateDoc, Element annotationSetDisam, TreeSet<Integer> nodeOffsets, int id, Word word) {
//        // Añadimos un annotation con la informacion básica: token y pos
//        Element definitionElement = gateDoc.createElement("Annotation");
//        String idDefinition = Integer.toString(id);
//        definitionElement.setAttribute("Id", idDefinition);
//        definitionElement.setAttribute("StartNode", word.getStart_offset() + "");
//        definitionElement.setAttribute("EndNode", word.getEnd_offset() + "");
//        definitionElement.setAttribute("Type", "Definition");
//        annotationSetDisam.appendChild(definitionElement);
//
//        /* Add definition */
//        Element feature = gateDoc.createElement("Feature");
//        definitionElement.appendChild(feature);
//        Element name = gateDoc.createElement("Name");
//        name.setAttribute("className", "java.lang.String");
//        name.setTextContent("definition");
//        feature.appendChild(name);
//        Element value = gateDoc.createElement("Value");
//        value.setAttribute("className", "java.lang.String");
//        value.setTextContent("");
//        feature.appendChild(value);
//
//        /* Add synonyms */
//        feature = gateDoc.createElement("Feature");
//        definitionElement.appendChild(feature);
//        name = gateDoc.createElement("Name");
//        name.setAttribute("className", "java.lang.String");
//        name.setTextContent("synonyms");
//        feature.appendChild(name);
//        value = gateDoc.createElement("Value");
//        value.setAttribute("className", "java.lang.String");
//        value.setTextContent("");
//        feature.appendChild(value);
//
//        /* Add synonym simple */
//        feature = gateDoc.createElement("Feature");
//        definitionElement.appendChild(feature);
//        name = gateDoc.createElement("Name");
//        name.setAttribute("className", "java.lang.String");
//        name.setTextContent("synonym");
//        feature.appendChild(name);
//        value = gateDoc.createElement("Value");
//        value.setAttribute("className", "java.lang.String");
//        value.setTextContent("");
//        feature.appendChild(value);
//
//        /* Add word */
//        feature = gateDoc.createElement("Feature");
//        definitionElement.appendChild(feature);
//        name = gateDoc.createElement("Name");
//        name.setAttribute("className", "java.lang.String");
//        name.setTextContent("token");
//        feature.appendChild(name);
//        value = gateDoc.createElement("Value");
//        value.setAttribute("className", "java.lang.String");
//        value.setTextContent(word.getWord());
//        feature.appendChild(value);
//
//        /* Add id */
//        feature = gateDoc.createElement("Feature");
//        definitionElement.appendChild(feature);
//        name = gateDoc.createElement("Name");
//        name.setAttribute("className", "java.lang.String");
//        name.setTextContent("idWN");
//        feature.appendChild(name);
//        value = gateDoc.createElement("Value");
//        value.setAttribute("className", "java.lang.String");
//        value.setTextContent("");
//        feature.appendChild(value);
//
//        /* Add Lemma */
//        feature = gateDoc.createElement("Feature");
//        definitionElement.appendChild(feature);
//        name = gateDoc.createElement("Name");
//        name.setAttribute("className", "java.lang.String");
//        name.setTextContent("lemma");
//        feature.appendChild(name);
//        value = gateDoc.createElement("Value");
//        value.setAttribute("className", "java.lang.String");
//        value.setTextContent(word.getLemma());
//        feature.appendChild(value);
//
//        /* Add TypeToken */
//        feature = gateDoc.createElement("Feature");
//        definitionElement.appendChild(feature);
//        name = gateDoc.createElement("Name");
//        name.setAttribute("className", "java.lang.String");
//        name.setTextContent("typeToken");
//        feature.appendChild(name);
//        value = gateDoc.createElement("Value");
//        value.setAttribute("className", "java.lang.String");
//        value.setTextContent(word.getTypeWord());
//        feature.appendChild(value);
//
//        /* Add POS */
//        String posFree = word.getPOS().substring(0, 1);
//        feature = gateDoc.createElement("Feature");
//        definitionElement.appendChild(feature);
//        name = gateDoc.createElement("Name");
//        name.setAttribute("className", "java.lang.String");
//        name.setTextContent("POS");
//        feature.appendChild(name);
//        value = gateDoc.createElement("Value");
//        value.setAttribute("className", "java.lang.String");
//        value.setTextContent(posFree);
//        feature.appendChild(value);
//
//        /* Add Complexity */
//        feature = gateDoc.createElement("Feature");
//        definitionElement.appendChild(feature);
//        name = gateDoc.createElement("Name");
//        name.setAttribute("className", "java.lang.String");
//        name.setTextContent("complexity");
//        feature.appendChild(name);
//        value = gateDoc.createElement("Value");
//        value.setAttribute("className", "java.lang.String");
//        value.setTextContent(String.valueOf(word.getComplexity()));
//        feature.appendChild(value);
//
//        /* Add Confidence */
//        feature = gateDoc.createElement("Feature");
//        definitionElement.appendChild(feature);
//        name = gateDoc.createElement("Name");
//        name.setAttribute("className", "java.lang.String");
//        name.setTextContent("confidence");
//        feature.appendChild(name);
//        value = gateDoc.createElement("Value");
//        value.setAttribute("className", "java.lang.String");
//        value.setTextContent("0.0");
//        feature.appendChild(value);
//
//        id++;
//        nodeOffsets.add(word.getStart_offset());
//        nodeOffsets.add(word.getEnd_offset());
//
//        return id;
//    }
//
//    private void insertNodeGateDocument(Document gateDoc, TreeSet<Integer> nodeOffsets) {
//        Element documentElement = gateDoc.getDocumentElement();
//        Element textWithNodesElement = XMLUtils.getElementNamed(documentElement, "TextWithNodes");
//
//        String text = textWithNodesElement.getTextContent();
//        textWithNodesElement.setAttribute("xml:space", "preserve");
//
//        //si hemos añadido alguna anotación, borramos el texto completo.
//        if (!nodeOffsets.isEmpty()) {
//
//            //añadimos los offsets que existan previamente
//            NodeList previousNodes = XMLUtils.getElementsNamed(textWithNodesElement, "Node");
//
//            for (int nodes = 0; nodes < previousNodes.getLength(); nodes++) {
//                Element n = (Element) previousNodes.item(nodes);
//                nodeOffsets.add(Integer.parseInt(n.getAttribute("id")));
//            }
//
//            //borramos el contenido previo en la sección textwithnodeselement 
//            textWithNodesElement.setTextContent("");
//
//            int start_offset = 0;
//            boolean inicio = true;
////            System.out.println(node_offsets.toString());
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
//
//            //añadimos el último fragmento de texto
//            if (start_offset < text.length() && start_offset > 0) {
//                textWithNodesElement.appendChild(gateDoc.createTextNode(text.substring(start_offset)));
//            }
//        }
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
//    private List<Word> parseFreeling(String textToAnalyze, File outFreeling, String langCode, String methodDisambiguation) throws IOException, JWNLException, DisambiguationException {
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
//                int posIds = part_line.length - 1;
//                // POS
//                String pos = part_line[2];
//                if (!pos.startsWith("NP")) {
//                    /* Sólo almacenamos: NOMBRES, VERBOS, ADVERBIOS Y ADJETIVOS */
//                    if (pos.startsWith("N") || pos.startsWith("V")
//                            || pos.startsWith("A") || pos.startsWith("R")) {
//                        // word
//                        String wordText = part_line[0];
//                        // lemma
//                        String lemma = part_line[1];
//                        if (lemma.contains("+")) {
//                            String[] part_lemma = lemma.split("\\+");
//                            lemma = part_lemma[0];
//                        }
//                        // Si el lemma es (s) es que es genitivo sajon y si lo procesamos lo detecta como palabra rara
//                        if (!lemma.equals("s") && !lemma.equals("S")) {
//                            // lista de sentidos - idwordnet
//                            List<String> senses = new ArrayList<String>();
//                            if (!part_line[posIds].equals("-")) {
//                                // EN: Si esta en WN, MFS y EN, buscamos en WordNet directamente
//                                if (methodDisambiguation.equals(MFS) && langCode.equals(LANGEN)) {
//                                    senses = consultWordNet(lemma, pos);
//                                    if (senses.size() > 0) {
//                                        String idWordNet = senses.get(0).split(":")[0];
//                                        pos = idWordNet.substring(idWordNet.length() - 1, idWordNet.length()).toUpperCase();
//                                    }
//                                } else {
//                                    String[] sensesFree = part_line[posIds].split("/");
//                                    float numSentidos = sensesFree.length;
//                                    float normalizar = 1f;
//
//                                    // Obtenemos el valor de normalizacion para confidence (MFS)
//                                    if (methodDisambiguation.equals(MFS)) {
//                                        for (int i = 1; i <= sensesFree.length; i++) {
//                                            normalizar += (numSentidos - i) / numSentidos;
//                                        }
//                                    }
//                                    for (int i = 0; i < sensesFree.length; i++) {
//                                        String freq = null;
//                                        if (methodDisambiguation.equals(MFS)) {
//                                            freq = Double.toString(((numSentidos - i) / numSentidos) / normalizar);
//                                        } else {
//                                            Double freqDouble = Double.parseDouble(sensesFree[i].split(":")[1]);
//                                            freq = Double.toString(freqDouble);
//                                        }
//                                        String idwn = sensesFree[i].split(":")[0].replace("-", "");
//                                        senses.add(idwn + ":" + freq);
//                                    }
//                                }
//                            }
//                            // start_off y end_off
//                            int end = Integer.parseInt(offsets.split("-")[1]);
//                            offsets = obtainOffset(textToAnalyze, wordText, end);
//                            int start_offset = Integer.parseInt(offsets.split("-")[0]);
//                            int end_offset = Integer.parseInt(offsets.split("-")[1]);
//                            Word word = new Word(lemma, pos, senses, start_offset, end_offset, wordText);
//                            words.add(word);
//                        }
//                    }
//                }
//            }
//        }
//        fr.close();
//        br.close();
//        outFreeling.delete();
//        return words;
//    }
//
//    private List<String> consultWordNet(String lemma, String pos) throws JWNLException, DisambiguationException {
//        List<String> senses = new ArrayList<String>();
//        IndexWord word = null;
//
//        /* Consutamos WordNet y obtenemos su id*/
//        if (pos.startsWith("N")) {
//            word = wordNetDictionary.lookupIndexWord(POS.NOUN, lemma);
//        } else if (pos.startsWith("V")) {
//            word = wordNetDictionary.lookupIndexWord(POS.VERB, lemma);
//        } else if (pos.startsWith("A") || (pos.startsWith("J"))) {
//            word = wordNetDictionary.lookupIndexWord(POS.ADJECTIVE, lemma);
//        } else if (pos.startsWith("R")) {
//            word = wordNetDictionary.lookupIndexWord(POS.ADVERB, lemma);
//        }
//
//        if (word != null) {
//            Synset[] synsets = word.getSenses();
//            if (synsets.length <= 0) {
//                throw new DisambiguationException(DisambiguationException.ERROR10, lemma);
//            } else {
//                String posId = pos.substring(0, 1).toLowerCase();
//                float normalizar = 1f;
//                float numSentidos = synsets.length;
//
//                // Calculamos el valor de normalizacion para el confidence
//                for (int j = 1; j <= numSentidos; j++) {
//                    normalizar += (numSentidos - j) / numSentidos;
//                }
//
//                // Recorremos todos los sentidos
//                for (int i = 0; i < synsets.length; i++) {
//                    // Obtenemos el idWN
//                    long idWordNet = synsets[i].getOffset();
//                    StringBuilder idWordNetString = new StringBuilder(String.valueOf(idWordNet));
//                    while (idWordNetString.length() < 8) {
//                        idWordNetString.insert(0, "0");
//                    }
//                    String idwn = idWordNetString + posId;
//                    // Obtenemos el confidence
//                    String freq = Double.toString(((numSentidos - i) / numSentidos) / normalizar);
//                    senses.add(idwn + ":" + freq);
//                }
//            }
//        }
//        return senses;
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
//    private List<Word> parseTreeTagger(String textToAnalyze, File outTreeTagger) throws IOException, SQLException, DatabaseException {
//        List<Word> words = new ArrayList<Word>();
//        FileReader fr;
//        BufferedReader br;
//        String line;
//        String offsets = "0-0";
//        List<String> senses;
//        fr = new FileReader(outTreeTagger);
//        br = new BufferedReader(fr);
//        while ((line = br.readLine()) != null) {
//            if (!line.equals("")) {
//                String[] part_line = line.split("\\s+");
//                // word
//                String wordText = part_line[0];
//                // POS
//                String pos = part_line[1];
//                if (!wordText.equals("")) {
//                    /* No procesamos los nombres propios*/
//                    if (!pos.startsWith("Np")) {
//                        /* Sólo almacenamos: NOMBRES, VERBOS, ADVERBIOS Y ADJETIVOS */
//                        if (pos.startsWith("N") || pos.startsWith("V")
//                                || pos.startsWith("A") || pos.startsWith("D")) {
//                            // lemma
//                            String lemma = part_line[2];
//                            if (lemma.contains("+")) {
//                                String[] part_lemma = lemma.split("\\+");
//                                lemma = part_lemma[0];
//                            }
//
//                            // offsets
//                            int end = Integer.parseInt(offsets.split("-")[1]);
//                            offsets = obtainOffset(textToAnalyze, wordText, end);
//                            int start_offset = Integer.parseInt(offsets.split("-")[0]);
//                            int end_offset = Integer.parseInt(offsets.split("-")[1]);
//
//                            // Obtenemos la lista de sentidos consultando balkanet
//                            senses = consultBalkanet(wordText, pos);
//
//                            // Creamos la palabra y añadimos a la lista
//                            Word word = new Word(wordText, pos, senses, start_offset, end_offset, wordText);
//                            words.add(word);
//                        }
//                    }
//                }
//            }
//        }
//        fr.close();
//        br.close();
//        outTreeTagger.delete();
//        return words;
//    }
//
//    private List<String> consultBalkanet(String lemma, String pos) throws SQLException, DatabaseException {
//        MySQLDatabase database = null;
//        List<String> idSynsets = new ArrayList<String>();
//        List<String> idSyn_conf = new ArrayList<String>();
//
//        try {
//            // Obtenemos la conexion
//            database = (MySQLDatabase) pool.get();
//            float normalizar = 1f;
//            String posBalkanet = pos.substring(0, 1).toLowerCase();
//
//            // Consultamos balkanet BD
//            StringBuilder sbSynset = new StringBuilder(
//                    "SELECT idWN FROM balkanet_first.synsets where word=? AND pos=?");
//            Query qSynset = database.executeQuery(sbSynset.toString(), lemma, posBalkanet);
////            PreparedStatement psSynset = database.prepareStatement(sbSynset.toString());
////            psSynset.setString(1, lemma);
////            psSynset.setString(2, posBalkanet);
////            ResultSet rsSynset = psSynset.executeQuery();
//            while (qSynset.next()) {
//                String idWN = qSynset.getField("idWN").toString();
//                idSynsets.add(idWN);
//            }
////            psSynset.close();
////            rsSynset.close();
//
//            /* Obtenemos el confidence */
//            float numSentidos = idSynsets.size();
//
//            // Calculamos el valor de normalizacion para el confidence
//            for (int j = 1; j <= numSentidos; j++) {
//                normalizar += (numSentidos - j) / numSentidos;
//            }
//
//            // Recorremos todos los sentidos
//            for (int i = 0; i < idSynsets.size(); i++) {
//                // Obtenemos el confidence
//                String freq = Double.toString(((numSentidos - i) / numSentidos) / normalizar);
//                idSyn_conf.add(idSynsets.get(i) + ":" + freq);
//            }
//
//            return idSyn_conf;
//        } finally {
//            database.close();
//            pool.release(database);
//        }
//    }
//
//    private File runScript(String textToAnalyze, String namescript, String methodDisambiguation, String workingDir) throws IOException, InterruptedException {
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
//        String[] cd = {"/bin/sh", "-c", "scripts/" + namescript + " " + tempFileInput.getAbsolutePath() + " " + methodDisambiguation + " " + tempFileOutput.getAbsolutePath()};
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
//    private String loadInputFile(String gateDocument) throws FileNotFoundException, IOException {
//        // Leemos el fichero de entrada
//        FileReader fr = new FileReader(gateDocument);
//        BufferedReader br = new BufferedReader(fr);
//        StringBuilder sb = new StringBuilder();
//        String line;
//        while ((line = br.readLine()) != null) {
//            sb.append(line).append("\n");
//        }
//        return sb.toString();
//    }
//}
