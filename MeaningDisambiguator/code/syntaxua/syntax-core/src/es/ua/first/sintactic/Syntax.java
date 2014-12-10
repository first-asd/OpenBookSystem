/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package es.ua.first.sintactic;

import es.ua.first.sintactic.Sentence.Adversative;
import static es.ua.first.sintactic.Sentence.Adversative.SINO;
import static es.ua.first.sintactic.Sentence.Adversative.SINO_QUE;
import static es.ua.first.sintactic.Sentence.Adversative.MAS;
import static es.ua.first.sintactic.Sentence.NumberWords;
import static es.ua.first.sintactic.Syntax.VERSION;
import es.upv.xmlutils.XMLUtils;
import gate.Annotation;
import gate.AnnotationSet;
import gate.Document;
import gate.Factory;
import gate.FeatureMap;
import gate.Gate;
import gate.creole.ResourceInstantiationException;
import gate.util.GateException;
import gate.util.InvalidOffsetException;
import gate.util.SimpleFeatureMapImpl;
import java.io.BufferedReader;
import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.FileReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.PrintStream;
import java.nio.charset.Charset;
import java.util.ArrayList;
import java.util.Date;
import java.util.Iterator;
import java.util.logging.Level;
import java.util.logging.Logger;
import java.util.regex.Matcher;
import java.util.regex.Pattern;
import javax.xml.parsers.ParserConfigurationException;
import javax.xml.stream.XMLStreamException;
import org.xml.sax.SAXException;

/**
 * Detects long sentences (>=15 words) and detects + resolves adversative conjunctions.
 * @author imoreno
 */
public class Syntax {
    
     /** The application version. */
    static public final String VERSION = "1.0.0";
   
    
    
    
    /**
     * Performs sintactic simplification from a Gate Document
     * @param args the command line arguments
     * @throws 
     */
    public static void main(String[] args) {
        try {
            // Parse the arguments
            long lStartTime = new Date().getTime();
            Syntax.ArgumentParser parser = new Syntax.ArgumentParser(args);
            // Get the character encoding
            String encoding = (parser.getEncoding() == null) ? 
            Charset.forName(System.getProperty("file.encoding")).name():
            parser.getEncoding();
            
            // Get the input file
            String file = parser.getInputFile();
            BufferedReader br;
            if(file == null) {
                br = new BufferedReader(new InputStreamReader(System.in, encoding)); //read the standar output
            } else {
                br = new BufferedReader(new FileReader(file)); //the input file
            }
            
            
             //Obtain the output file
            String outputFile = parser.getOutputFile();
            PrintStream print = (outputFile == null) ? 
                    System.out : 
                    new PrintStream(new FileOutputStream(outputFile));
             long lEndTime = new Date().getTime();
            System.out.println("Ellapsed time parsing and setting parameters: " + (lEndTime - lStartTime));
           
            // Create a new Syntax instance
            lStartTime = new Date().getTime();
            SintacticSimplificator ss = new SintacticSimplificator(parser.getGatePath());
            lEndTime = new Date().getTime();
            System.out.println("Ellapsed time loading a new SintacticSimplicator: " + (lEndTime - lStartTime));
           
            
            
            //simplify
            lStartTime = new Date().getTime();
            String result = ss.simplifyAdversativeConjunctionAndDetectLongSentences(br,parser.getLanguage(), parser.getAdversatives(), parser.getLongSentences(), parser.getSizeLongSentences() );
            lEndTime = new Date().getTime();
            System.out.println("Ellapsed time simplifiying: " + (lEndTime - lStartTime));
            
            // Print the results in the specifed file
            lStartTime = new Date().getTime();
            org.w3c.dom.Document gateDocumentResult = XMLUtils.readXML(result);
            XMLUtils.printXML(print, gateDocumentResult, encoding);
            lEndTime = new Date().getTime();
            System.out.println("Ellapsed time saving output: " + (lEndTime - lStartTime));
            
            
        } catch (ResourceInstantiationException ex) {
            System.err.println(ex.getMessage());
        } catch (InvalidOffsetException ex) {
            System.err.println(ex.getMessage());
        } catch (IOException ex) {
            System.err.println(ex.getMessage());
        } catch (GateException ex) {
           System.err.println(ex.getMessage());
        } catch (Syntax.ArgumentException ex) {
            System.err.println(ex.getMessage());
        } catch (ParserConfigurationException ex) {
            System.err.println(ex.getMessage());
        } catch (SAXException ex) {
            System.err.println(ex.getMessage());
        } catch (SintacticSimplificationException ex) {
            System.err.println(ex.getMessage());
        }
      
        

    }
    
     /** Print the usage. */
    private static void usage() {
        System.out.println("Linux usage:");
        System.out.println("\t./syntax.sh [Options]");
        System.out.println("\t./syntax.sh -h");
        System.out.println("\t./syntax.sh -v");
        System.out.println();
        System.out.println("Windows usage:");
        System.out.println("\t./syntax.bat [Options]");
        System.out.println("\t./syntax.bat -h");
        System.out.println("\t./syntax.bat -v");
        System.out.println();
        System.out.println("Generate a Gate XML in the standard output or a file with sintactic simplification performed for a GATE document in Spanish");
        System.out.println();
        System.out.println("Where:");
        System.out.println("\t-h, --help\tShow this help.");
        System.out.println("\t-v, --version\tShow the application version.");
        System.out.println();
        System.out.println("Options:");
        System.out.println("\t-e, --encoding ENC\tSet the character encoding for input and output operations.");
        System.out.println("\t-i, --input FILE\tThe Gate XML input file to extract its keywords.");
        System.out.println("\t\t\t\tIf this option is not set, then the standard input is used.");
        System.out.println("\t-o, --output FILE\tThe Gate XML output file to store the result Gate XML document.");
        System.out.println("\t\t\t\tIf this option is not set then the standard output is used.");
        System.out.println("\t-l, --language LANG\t The Gate XML input file's language.");
        System.out.println("\t\t\t\tThis parameter is obligatory. Supported languages are: es.");
        System.out.println("\t-a, --adversatives [true|yes|t|y|no|false|n|f]\t Indicates if advseratives should be tackled. By default, yes.");
        System.out.println("\t-s, --longSentences [true|yes|t|y|no|false|n|f]\t Indicates if long sentences should be tackled. By default, yes.");
        System.out.println("\t-ss, --sizelongsentences [long|LONG|l|L|medium|MEDUIM|m|M]\t Indicates which number of words should be employed to detect long sentences (medium, 15 or more words; long, 20 or more words).");
        System.out.println("\t-g, --gatePath DIR\t Indicates where gate is located.");
    }
    
    /** Argument exception handler. */
    private static class ArgumentException extends Exception {
        /**
         * Create a exception with a message.
         * @param msg The error message.
         */
        public ArgumentException(String msg) {
            super(msg);
        }
    }
    
    
    /** Argument parser. */
    private static class ArgumentParser {
       
        /** The XML document encoding. **/
        private String encoding = null;
        /** The output file. **/
        private String outputFile = null;
        /** The input file. **/
        private String inputFile = null;
        /** If adversatives should be tackled **/
        private Boolean adversatives = null;
        /** If long sentences should be tackled **/
        private Boolean longSentences = null;
        /** If much long sentences should be tackled **/
        private Boolean sizeLongSentence = null;        
        /** The language of the document **/
        private String language = null;
        /** Path where GATE is **/
        private String gatePath = null;

        public Boolean getAdversatives() {
            return adversatives;
        }

        public Boolean getLongSentences() {
            return longSentences;
        }
        public NumberWords getSizeLongSentences() {
            if (sizeLongSentence) {return NumberWords.WORDS20;} 
            else {return NumberWords.WORDS15;}
        }
        
        /**
         * Parser the application arguments.
         * @param args An array with the application arguments.
         */
        public ArgumentParser(String args[]) throws Syntax.ArgumentException {
            for(int i = 0; i < args.length; i++) {
                if(args[i].startsWith("-")) {
                    if(args[i].equals("-h") || args[i].equals("--help")) {
                        usage();
                        System.exit(0);
                    } else if(args[i].equals("-v") || args[i].equals("--version")) {
                        System.out.println("FIRST SINTACTIC SIMPLIFICATOR VERSION " + VERSION);
                        System.exit(0);
                    } else if(args[i].equals("-e") || args[i].equals("--encoding")) {
                        if(++i > args.length) {
                            throw new Syntax.ArgumentException("ARGUMENT ERROR: The arguments '-e' or '--encoding' require an encoding value. "
                                    + "Please, run 'rae.sh -h' or 'rae.bat -h' for more information.");
                        }
                        encoding = args[i];
                    } else if (args[i].equals("-o") || args[i].equals("--output")) {
                        if(++i > args.length) {
                            throw new Syntax.ArgumentException("ARGUMENT ERROR: The arguments '-o' or '--output' require a file. "
                                    + "Please, run 'rae.sh -h' or 'rae.bat -h' for more information.");
                        }
                        outputFile = args[i];
                    } else if (args[i].equals("-i") || args[i].equals("--input")) {
                        if(++i > args.length) {
                            throw new Syntax.ArgumentException("ARGUMENT ERROR: The arguments '-i' or '--input' require a file. "
                                    + "Please, run 'rae.sh -h' or 'rae.bat -h' for more information.");
                        }
                        inputFile = args[i];
                    } else if (args[i].equals("-l") || args[i].equals("--language")) {
                        if(++i > args.length) {
                            throw new Syntax.ArgumentException("ARGUMENT ERROR: The arguments '-l' or '--language' require a file's language. "
                                    + "Please, run 'rae.sh -h' or 'rae.bat -h' for more information.");
                        }
                        language = args[i];
                    } else if (args[i].equals("-a") || args[i].equals("--adversatives")) {
                        
                        if(++i > args.length) {
                            throw new Syntax.ArgumentException("ARGUMENT ERROR: The arguments '-a' or '--adversatives' require a file's language. "
                                    + "Please, run 'rae.sh -h' or 'rae.bat -h' for more information.");
                        }
                        if(args[i].equalsIgnoreCase("yes") || args[i].equalsIgnoreCase("true") || args[i].equalsIgnoreCase("y") || args[i].equalsIgnoreCase("t") ){
                            adversatives = true;
                        } else {
                            adversatives = false;
                        }
                    } else if (args[i].equals("-s") || args[i].equals("--longsentences")) {
                         if(++i > args.length) {
                            throw new Syntax.ArgumentException("ARGUMENT ERROR: The arguments '-s' or '--longsentences' require a specific parameter. "
                                    + "Please, run 'rae.sh -h' or 'rae.bat -h' for more information.");
                        }
                        if(args[i].equalsIgnoreCase("yes") || args[i].equalsIgnoreCase("true") || args[i].equalsIgnoreCase("y") || args[i].equalsIgnoreCase("t") ){
                            longSentences = true;
                        } else {
                            longSentences = false;
                        }
                    } else if (args[i].equals("-ss") || args[i].equals("--sizelongsentences")) {
                         if(++i > args.length) {
                            throw new Syntax.ArgumentException("ARGUMENT ERROR: The arguments '-ss' or '--sizelongsentences' require a specific parameter. "
                                    + "Please, run 'rae.sh -h' or 'rae.bat -h' for more information.");
                        }
                        if(args[i].equalsIgnoreCase("long") || args[i].equalsIgnoreCase("LONG") || args[i].equalsIgnoreCase("l") || args[i].equalsIgnoreCase("L") ){
                            sizeLongSentence = true;
                        } else if (args[i].equalsIgnoreCase("medium") || args[i].equalsIgnoreCase("MEDIUM") || args[i].equalsIgnoreCase("m") || args[i].equalsIgnoreCase("M") ){
                            sizeLongSentence = false;
                        } else {
                            throw new Syntax.ArgumentException("ARGUMENT ERROR: The arguments '-ss' or '--sizelongsentences' require a specific parameter. "
                                    + "Please, run 'rae.sh -h' or 'rae.bat -h' for more information.");                            
                        }
                    } else if (args[i].equals("-g") || args[i].equals("-gatepath") ){
                        if(++i > args.length) {
                            throw new Syntax.ArgumentException("ARGUMENT ERROR: The arguments '-g' or '--gatepath' require a specific parameter. "
                                    + "Please, run 'rae.sh -h' or 'rae.bat -h' for more information.");
                        }
                        gatePath = args[i];
                    }
                    else {
                        throw new Syntax.ArgumentException("ARGUMENT ERROR: The argument '" + args[i] + "' is not supported. "
                                + "Please, run 'rae.sh -h' or 'rae.bat -h' for more information.");
                        }
                } 
//                else {
//                    terms.add(args[i]);
//                }
            }
            
            
            /** default values **/
            if(adversatives==null){
                adversatives = true;
            }
           
            if(longSentences==null){
                longSentences = true;
            }
        }

        public String getGatePath() {
            return gatePath;
        }

        /** 
         * @return the XML encoding.
         */
        private String getEncoding() {
            return encoding;
        }

        /**
         * @return the output file to write the results. If none is defined then
         * return null.
         */
        public String getOutputFile() {
            return outputFile;
        }

        /**
         * @return the input file to read the document to extract keywords. If none is defined
         * then return null.
         */
        public String getInputFile() throws Syntax.ArgumentException {
            if(inputFile!=null)
                return inputFile;
            else {
                throw new Syntax.ArgumentException("ARGUMENT ERROR: Using the standard input or the arguments '-i' or '--input' are required."
                                    + "Please, run 'rae.sh -h' or 'rae.bat -h' for more information.");
            }
        }

       

        /**
         * @return the language of the documents. If none is defined then return null
         */
        public String getLanguage() throws Syntax.ArgumentException {
            if(language!=null)
                return language;
            else{
                 throw new Syntax.ArgumentException("ARGUMENT ERROR: The arguments '-l' or '--language' are mandatory."
                                    + "Please, run 'syntax.sh -h' or 'syntax.bat -h' for more information.");
            }
        }
        
        
    }
    
    
    
   
    
}
    
    
  