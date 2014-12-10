/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package es.ua.first.multiwords;

import es.ua.db.DatabaseException;
import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileReader;
import java.io.FileWriter;
import java.io.IOException;
import java.io.InputStream;
import java.util.ArrayList;
import java.util.Properties;
import javax.xml.parsers.ParserConfigurationException;
import net.didion.jwnl.JWNLException;
import org.xml.sax.SAXException;

/**
 *
 * @author lcanales
 */
public class MultiWordsMain {

    private static final String PROPERTY_FILE = "es/ua/first/config/multiwords.properties";

    /**
     * @param args the command line arguments
     */
    public static void main(String[] args) throws ArgumentException, IOException, FileNotFoundException, JWNLException, DatabaseException, DatabaseException, ParserConfigurationException, SAXException, MultiWordsException {
        // Parse the arguments
        ArgumentParser parser = new ArgumentParser(args);
        // Create and load default properties
        ClassLoader loader = MultiWordsMain.class.getClassLoader();
        InputStream is = loader.getResourceAsStream(PROPERTY_FILE);
        Properties defaultProps = new Properties();
        defaultProps.load(is);
        // Create the Disambiguation object
        MultiWords multiwords = new MultiWords(defaultProps, parser.getWorkingDir());
        // las listas se deben indicar en el archivo de propiedades 
//        String listMultiWords = loadInputText("/home/lcanales/multiWords/multiwords_EN.wn31.txt");
//        multiwords.setListMultiWords(listMultiWords, parser.getLangCode());
        // Load input text
        String inputText = loadInputText(parser.getInputFile());
        // Call disambiguate method
        long tiempoInicio = System.currentTimeMillis();
        String output = multiwords.multiwords(inputText, parser.getLangCode(), parser.getFormatInputFile(), parser.getFormatOutputFile(), parser.getWorkingDir());
        long totalTiempo = System.currentTimeMillis() - tiempoInicio;
        System.out.println("El tiempo de demora es :" + totalTiempo + " miliseg");
        // Store output text
        File fichBGout = new File(parser.getOutputFile());
        BufferedWriter writer = new BufferedWriter(new FileWriter(fichBGout));
        writer.write(output);
        writer.close();
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
         * Type of information returned by disambigation process: definitions,
         * synonyms or both.
         */
        private String informationReturned = "DEFSYN";
        /**
         * Directory of work.
         */
        private String workingDir = "./";
        /**
         * Format input file (GATE or TXT).
         */
        private String formatInputFile = "TXT";
        /**
         * Format output file (GATE or TXT).
         */
        private String formatOutputFile = "GATE";
        /**
         * Path instalation Freeling.
         */
        private String pathFreeling = "./";

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
                        System.out.println("GPLSI Proyect FIRST VERSION " + MultiWords.VERSION);
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
                    } else if (args[i].equals("-fl") || args[i].equals("--freeling")) {
                        if (++i > args.length) {
                            throw new ArgumentException("ARGUMENT ERROR: The arguments '-fl' or '--freeling' require indicate the Freeling path, where it's installed. "
                                    + "Please, run 'first.sh -h' or 'first.bat -h' for more information.");
                        }
                        pathFreeling = args[i];
                    } else {
                        throw new ArgumentException("ARGUMENT ERROR: The argument '" + args[i] + "' is not supported. "
                                + "Please, run 'first.sh -h' or 'first.bat -h' for more information.");
                    }
                }
            }
        }

        public String getInputFile() {
            return inputFile;
        }

        public String getOutputFile() {
            return outputFile;
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

        public String getInformationReturned() {
            return informationReturned;
        }

        public String getWorkingDir() {
            return workingDir;
        }

        public String getFormatInputFile() {
            return formatInputFile;
        }

        public String getFormatOutputFile() {
            return formatOutputFile;
        }

        public String getPathFreeling() {
            return pathFreeling;
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
