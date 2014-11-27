package es.ujaen.test;
import java.io.File;

import org.apache.commons.io.FileUtils;

import es.ujaen.sinai.first.BasicProcessing;
import es.ujaen.sinai.first.MultiWordDetection;

/**
 * @author Eduard 
 */

public class TestMatchMultipleWords {
	
	private static String outputDirectory ="/opt/dist/008_first/MultiWordDetection/outputFiles/";
	
	/*
	private static String gateInputFilePath =TestMatchMultipleWords.class.getResource("/input/bg/Pcheli.xml").getPath();
	private static String processedFile = outputDirectory +"Pcheli-Output.xml";
	private static String parameters = "{\"languageCode\":\"bg\",\"multiWordDetection\":\"y\"}";
	*/
	
	private static String gateInputFilePath = outputDirectory +"texto1.xml";
	private static String processedFile = outputDirectory +"texto1-Output.xml";
	private static String parameters = "{\"languageCode\":\"es\"}";

/*
	private static String gateInputFilePath = TestMatchMultipleWords.class.getResource("/input/en/inputEnglish-1.xml").getPath();
	private static String processedFile = outputDirectory +"outputEnglish-1-Processed.xml";
	private static String parameters = "{\"languageCode\":\"en\",\"multiWordDetection\":\"y\",\"idiomDetection\":\"y\"}";
*/
	public static void main(String[] args) throws Exception {
		    String gateInputString=FileUtils.readFileToString(new File(gateInputFilePath ), "UTF-8");
			MultiWordDetection app = new MultiWordDetection();
			
			String gateOutputString=app.getMultiWords(gateInputString, parameters);
			FileUtils.write(new File(processedFile), gateOutputString, "UTF-8");
	}

}
