/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package es.ua.first;

import de.tudarmstadt.ukp.wikipedia.api.exception.WikiApiException;
import de.tudarmstadt.ukp.wikipedia.api.exception.WikiInitializationException;
import es.ua.db.DatabaseException;
import es.ua.first.dictionary.DictionaryException;
import es.ua.first.disambiguation.DisambiguationException;
import es.ua.first.disambiguation.Disambiguator2;
import es.ua.first.exception.BadParamException;
import es.ua.first.normalization.NormalizeException;
import gate.creole.ResourceInstantiationException;
import gate.util.GateException;
import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileReader;
import java.io.FileWriter;
import java.io.IOException;
import java.io.InputStream;
import java.net.MalformedURLException;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.Properties;
import javax.xml.parsers.ParserConfigurationException;
import net.didion.jwnl.JWNLException;
import org.xml.sax.SAXException;

/**
 *
 * @author lcanales
 */
public class First {

    private static final String PROPERTY_FILE = "es/ua/first/config/dictionary.properties";

    /**
     * @param args the command line arguments
     * @throws java.io.IOException
     * @throws es.ua.first.dictionary.DictionaryException
     * @throws
     * de.tudarmstadt.ukp.wikipedia.api.exception.WikiInitializationException
     * @throws javax.xml.parsers.ParserConfigurationException
     */
    public static void main(String[] args) throws IOException, DictionaryException, WikiInitializationException, WikiApiException, ParserConfigurationException, ArgumentException, BadParamException, JWNLException, FileNotFoundException, DatabaseException, SAXException, SQLException, DisambiguationException, InterruptedException, MalformedURLException, NormalizeException, ResourceInstantiationException, GateException {
        // Parse the arguments
        ArgumentParser parser = new ArgumentParser(args);
        // Check at least one OBSTACLES exists
        if (parser.getObstacles() == null || parser.getObstacles().isEmpty()) {
            throw new BadParamException("ERROR: Must be indicated at least one OBSTACLE. "
                    + "Please, run 'first.sh -h' or 'first.bat -h' for more information.");
        }
        // Check Freeling
        try {
            Runtime.getRuntime().exec(parser.getPathFreeling() + "/bin/analyzer");
        } catch (Exception e) {
            throw new ArgumentException("ARGUMENT ERROR: The arguments '-fl' or '--freeling' require a file. "
                    + "Please, run 'first.sh -h' or 'first.bat -h' for more information.");
        }
        // Create and load default properties
        ClassLoader loader = First.class.getClassLoader();
        InputStream is = loader.getResourceAsStream(PROPERTY_FILE);
        Properties defaultProps = new Properties();
        defaultProps.load(is);
        // Create the Disambiguation object
        Disambiguator2 disam = new Disambiguator2(defaultProps, parser.getWorkingDir(), parser.getPathBabelNet(), parser.getPathFreeling(), parser.getPathTreeTagger(), parser.getPathGate());
        // Load input text
        String inputText = loadInputText(parser.getInputFile());
        // Call disambiguate method
        long tiempoInicio = System.currentTimeMillis();
        String output = disam.disambiguate(inputText, parser.getObstacles(), parser.getLangCode(), parser.getNumSenses(), parser.getMethodDisambiguation(), parser.getInformationReturned(), parser.getFormatInputFile(), parser.getFormatOutputFile(), parser.getSystemDisam(), parser.getWorkingDir());
        long totalTiempo = System.currentTimeMillis() - tiempoInicio;
        System.out.println("El tiempo de demora es :" + totalTiempo + " miliseg");
        // Store output text
        File fichBGout = new File(parser.getOutputFile());
        BufferedWriter writer = new BufferedWriter(new FileWriter(fichBGout));
        writer.write(output);
        writer.close();
        // Create the Dictionary object
//        Dictionary dict = new Dictionary(defaultProps);
//        WiktionaryParser eswiktionary = dict.getEsWiktionary();
//        System.out.println(XMLUtils.toString(eswiktionary.getDefinitions("ratón")));
        // Create the normalization object
//        Normalizator norm = new Normalizator(defaultProps, parser.getWorkingDir());
//        System.out.println(norm.normalize(parser.getInputFile(), parser.getObstacles(), parser.getLangCode(), parser.getWorkingDir()));
    }

    private static String loadInputText(String pathInputFile) throws FileNotFoundException, IOException {
        StringBuilder textFile = new StringBuilder();
        BufferedReader reader;
        reader = new BufferedReader(new FileReader(pathInputFile));
        String line;
        while ((line = reader.readLine()) != null) {
            textFile.append(line).append("\n");
        }
        reader.close();
        return textFile.toString();
    }

    /**
     * Argument parser.
     */
    private static class ArgumentParser {

        /**
         * Obstacles that resolve.
         */
        private ArrayList<String> obstacles = new ArrayList<String>();
        /**
         * The input file.
         */
        private String inputFile = null;
        /**
         * The output file.
         */
        private String outputFile = null;
        /**
         * Word that resolve.
         */
        private String word;
        /**
         * The language code of input file.
         */
        private String langCode;
        /**
         * Number max of senses that returns the process.
         */
        private int numSenses = 1;
        /**
         * Method of disambiguation used by disambiguation process.
         */
        private String methodDisambiguation = "MFS";
        /**
         * Type of information returned by disambigation process: definitions,
         * synonyms or both.
         */
        private String informationReturned = "DEFSYN";
        /**
         * Directory of work.
         */
        private String workingDir = "./";
        /**
         * System of Disambiguation (WORDNET or FREELING) used by disambiguation
         * process.
         */
        private String systemDisam = "WORDNET";
        /**
         * Format input file (GATE or TXT).
         */
        private String formatInputFile = "TXT";
        /**
         * Format output file (GATE or TXT).
         */
        private String formatOutputFile = "GATE";
        /**
         * Path instalation BabelNet.
         */
        private String pathBabelNet;
        /**
         * Path instalation Freeling.
         */
        private String pathFreeling = "./";
        /**
         * Path instalation Tree-tagger.
         */
        private String pathTreeTagger;
        /**
         * Path instalation GATE.
         */
        private String pathGate;

        /**
         * Parser the application arguments.
         *
         * @param args An array with the application arguments.
         */
        public ArgumentParser(String args[]) throws ArgumentException {
            for (int i = 0; i < args.length; i++) {
                if (args[i].startsWith("-")) {
                    if (args[i].equals("-h") || args[i].equals("--help")) {
//                        usage();
                        System.exit(0);
                    } else if (args[i].equals("-v") || args[i].equals("--version")) {
                        System.out.println("GPLSI Proyect FIRST VERSION " + Disambiguator2.VERSION);
                        System.exit(0);
                    } else if (args[i].equals("-i") || args[i].equals("--input")) {
                        if (++i > args.length) {
                            throw new ArgumentException("ARGUMENT ERROR: The arguments '-i' or '--input' require a file. "
                                    + "Please, run 'first.sh -h' or 'first.bat -h' for more information.");
                        }
                        inputFile = args[i];
                    } else if (args[i].equals("-o") || args[i].equals("--output")) {
                        if (++i > args.length) {
                            throw new ArgumentException("ARGUMENT ERROR: The arguments '-o' or '--output' require a file. "
                                    + "Please, run 'first.sh -h' or 'first.bat -h' for more information.");
                        }
                        outputFile = args[i];
                    } else if (args[i].equals("-l") || args[i].equals("--lang")) {
                        if (++i > args.length) {
                            throw new ArgumentException("ARGUMENT ERROR: The arguments '-l' or '--lang' require a language code (like es, en, bg, ...) "
                                    + "Please, run 'first.sh -h' or 'first.bat -h' for more information.");
                        }
                        langCode = args[i];
                    } else if (args[i].equals("-w") || args[i].equals("--word")) {
                        if (++i > args.length) {
                            throw new ArgumentException("ARGUMENT ERROR: The arguments '-w' or '--word' require a word. "
                                    + "Please, run 'first.sh -h' or 'first.bat -h' for more information.");
                        }
                        word = args[i];
                    } else if (args[i].equals("-m") || args[i].equals("--maxsenses")) {
                        if (++i > args.length) {
                            throw new ArgumentException("ARGUMENT ERROR: The arguments '-m' or '--maxsenses' require the number of maximum senses"
                                    + "Please, run 'first.sh -h' or 'first.bat -h' for more information.");
                        }
                        numSenses = Integer.parseInt(args[i]);
                    } else if (args[i].equals("-d") || args[i].equals("--dismethod")) {
                        if (++i > args.length) {
                            throw new ArgumentException("ARGUMENT ERROR: The arguments '-d' or '--dismethod' require indicate the name of disambiguation method (like MFS or UKB)."
                                    + "Please, run 'first.sh -h' or 'first.bat -h' for more information.");
                        }
                        methodDisambiguation = args[i];
                    } else if (args[i].equals("-r") || args[i].equals("--inforeturn")) {
                        if (++i > args.length) {
                            throw new ArgumentException("ARGUMENT ERROR: The arguments '-r' or '--inforeturn' require indicate the type of information returned by disambigation process (like definitions, synonyms or both)."
                                    + "Please, run 'first.sh -h' or 'first.bat -h' for more information.");
                        }
                        informationReturned = args[i];
                    } else if (args[i].equals("-W") || args[i].equals("--workingdir")) {
                        if (++i > args.length) {
                            throw new ArgumentException("ARGUMENT ERROR: The arguments '-W' or '--workingdir' require indicate the working directory."
                                    + "Please, run 'first.sh -h' or 'first.bat -h' for more information.");
                        }
                        workingDir = args[i];
                    } else if (args[i].equals("-s") || args[i].equals("--systemdisam")) {
                        if (++i > args.length) {
                            throw new ArgumentException("ARGUMENT ERROR: The arguments '-s' or '--systemdisam' require indicate that system you want to use by disambigation process (like WORDNET or FREELING)."
                                    + "Please, run 'first.sh -h' or 'first.bat -h' for more information.");
                        }
                        systemDisam = args[i];
                    } else if (args[i].equals("-fi") || args[i].equals("--formatinputfile")) {
                        if (++i > args.length) {
                            throw new ArgumentException("ARGUMENT ERROR: The arguments '-fi' or '--formatinputfile' require require indicate the format of input file (like GATE or TXT)."
                                    + "Please, run 'first.sh -h' or 'first.bat -h' for more information.");
                        }
                        formatInputFile = args[i];
                    } else if (args[i].equals("-fo") || args[i].equals("--formatoutputfile")) {
                        if (++i > args.length) {
                            throw new ArgumentException("ARGUMENT ERROR: The arguments '-fo' or '--formatoutputfile' require indicate the format of output file (like GATE or TXT). "
                                    + "Please, run 'first.sh -h' or 'first.bat -h' for more information.");
                        }
                        formatOutputFile = args[i];
                    } else if (args[i].equals("-bn") || args[i].equals("--babelnet")) {
                        if (++i > args.length) {
                            throw new ArgumentException("ARGUMENT ERROR: The arguments '-bn' or '--babelnet' require indicate the BabelNet path, where it's installed. "
                                    + "Please, run 'first.sh -h' or 'first.bat -h' for more information.");
                        }
                        pathBabelNet = args[i];
                    } else if (args[i].equals("-fl") || args[i].equals("--freeling")) {
                        if (++i > args.length) {
                            throw new ArgumentException("ARGUMENT ERROR: The arguments '-fl' or '--freeling' require indicate the Freeling path, where it's installed. "
                                    + "Please, run 'first.sh -h' or 'first.bat -h' for more information.");
                        }
                        pathFreeling = args[i];
                    } else if (args[i].equals("-g") || args[i].equals("--gate")) {
                        if (++i > args.length) {
                            throw new ArgumentException("ARGUMENT ERROR: The arguments '-g' or '--gate' require indicate the GATE path, where it's installed. "
                                    + "Please, run 'first.sh -h' or 'first.bat -h' for more information.");
                        }
                        pathGate = args[i];
//                    } else if (args[i].equals("-tt") || args[i].equals("--treetagger")) {
//                        if (++i > args.length) {
//                            throw new ArgumentException("ARGUMENT ERROR: The arguments '-tt' or '--treetagger' require indicate the TreeTagger path, where it's installed. "
//                                    + "Please, run 'first.sh -h' or 'first.bat -h' for more information.");
//                        }
//                        pathTreeTagger = args[i];
                    } else {
                        throw new ArgumentException("ARGUMENT ERROR: The argument '" + args[i] + "' is not supported. "
                                + "Please, run 'first.sh -h' or 'first.bat -h' for more information.");
                    }
                } else {
                    obstacles.add(args[i]);
                }
            }
        }

        public String getPathGate() {
            return pathGate;
        }

        public String getPathTreeTagger() {
            return pathTreeTagger;
        }

        public String getOutputFile() {
            return outputFile;
        }

        public String getFormatInputFile() {
            return formatInputFile;
        }

        public String getFormatOutputFile() {
            return formatOutputFile;
        }

        public String getPathBabelNet() {
            return pathBabelNet;
        }

        public String getPathFreeling() {
            return pathFreeling;
        }

        public String getWorkingDir() {
            return workingDir;
        }

        public ArrayList<String> getObstacles() {
            return obstacles;
        }

        public String getInputFile() {
            return inputFile;
        }

        public String getWord() {
            return word;
        }

        public String getLangCode() {
            return langCode;
        }

        public int getNumSenses() {
            return numSenses;
        }

        public String getMethodDisambiguation() {
            return methodDisambiguation;
        }

        public String getInformationReturned() {
            return informationReturned;
        }

        public String getSystemDisam() {
            return systemDisam;
        }
    }

    /**
     * Argument exception handler.
     */
    private static class ArgumentException extends Exception {

        /**
         * Create a exception with a message.
         *
         * @param msg The error message.
         */
        public ArgumentException(String msg) {
            super(msg);
        }
    }
}
