package es.ujaen.test;

import java.io.File;

import org.apache.commons.io.FileUtils;
import org.apache.log4j.Logger;

import es.ujaen.first.summarizer.Summarize;

public class TestSummarize {
	

	private static String outputDirectory ="/opt/dist/008_first/Summarizer/outputFiles/";
	private static String gateInputFilePath =TestSummarize.class.getResource("/input/en/inputEnglish-1.xml").getPath();
	private static String summarizedFile = outputDirectory +"outputEnglishSummarized-1.xml";
	private static String parameters = "{\"languageCode\":\"es\",\"summarization.nSentences\":\"3\"}";

	
	/*
	private static String outputDirectory ="/opt/dist/008_first/Summarizer/outputFiles/";
	private static String gateInputFilePath =TestSummarize.class.getResource("/input/es/Isabel/example_text7_segment3.xml").getPath();
	private static String summarizedFile = outputDirectory +"outputSpanishSummarized-1.xml";
	private static String languageCode = "es";
   */
	
/*	
	private static String outputDirectory ="/opt/dist/008_first/Summarizer/outputFiles/";
	private static String gateInputFilePath =TestSummarize.class.getResource("/input/bg/annieEmpty.xml").getPath();
	private static String summarizedFile = outputDirectory +"outputBulgarianSummarized.xml";
	private static String parameters = "{\"languageCode\":\"bg\",\"summarization\":\"y\"}";
	*/
	
	private static Logger logger = Logger.getLogger(TestSummarize.class);
	
	public static void main(String[] args) throws Exception {
		
		Summarize sm = new Summarize ();
		String gateInputString=FileUtils.readFileToString(new File(gateInputFilePath ), "UTF-8");
		String gateOutputString=sm.summarize(gateInputString, parameters);
		
		logger.debug("Write the Summarized File:");
		
		FileUtils.write(new File(summarizedFile), gateOutputString, "UTF-8");	
	}

}
