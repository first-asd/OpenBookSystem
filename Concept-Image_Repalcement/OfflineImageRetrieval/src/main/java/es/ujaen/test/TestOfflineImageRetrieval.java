package es.ujaen.test;

import java.io.File;

import org.apache.commons.io.FileUtils;
import org.apache.log4j.Logger;

import es.ujaen.ImageRetrieval.GetImagesWS;



public class TestOfflineImageRetrieval {

	
	private static Logger logger = Logger.getLogger(TestOfflineImageRetrieval.class);

	
	
	
	private static String inputDirectory ="/opt/dist/008_first/Aggregator/inputFiles/";
	
	/*
	private static String gateInputFilePath =inputDirectory+"outputSpanish-1.xml";
	private static String disambiguatedFile=inputDirectory+"multiWordsSpanishImages-1.xml";
	private static String parameters = "{\"languageCode\":\"es\",\"imageRetrieval\":\"y\"}";
	*/
	
	
	private static String gateInputFilePath =inputDirectory+"inputEnglish-Test-OfflineImage.xml";
	private static String disambiguatedFile=inputDirectory+"multiWordsEnglishImages-Test.xml";
	private static String parameters = "{\"languageCode\":\"en\",\"imageRetrieval\":\"y\"}";
	
	
	
	
	public static void main(String[] args) throws Exception  {

		String gateInputString=FileUtils.readFileToString(new File(gateInputFilePath), "UTF-8");
		
		GetImagesWS offLineImage = new GetImagesWS ();
		String gateOutputString=offLineImage.addImages(gateInputString, parameters);
		//String gateOutputString=offLineImage.addImages(gateInputString, languageCode);
		
		logger.debug("Write file with images");
		FileUtils.write(new File(disambiguatedFile), gateOutputString, "UTF-8");
	}

}
