package es.ujaen.test;

import java.io.File;
import java.io.IOException;
import java.util.Iterator;

import org.apache.commons.io.FileUtils;
import org.apache.log4j.Logger;

import es.ujaen.aggregator.AggregatorWS;

/***
 * Process Multiple Files read from a directory with the Aggregator .. 
 * @author Eduard
 */




public class TestBatchProcessing {
	
	private static String inputDirectory ="/opt/dist/008_first/Aggregator/testInputFiles/";
	private static String outputDirectory ="/opt/dist/008_first/Aggregator/testOutputFiles/";
	
	private static String parameters = "{\"languageCode\":\"es\",\"multiWordDetection\":\"y\",\"idiomDetection\":\"y\"}";
	
	private static Logger logger = Logger.getLogger(TestBatchProcessing.class);
	
	
	private static String getGateInputString (String currentInputFilePath)
	{
		String gateInputDocumentString="";
		try {
			String text=FileUtils.readFileToString(new File(currentInputFilePath), "UTF-8");
			String begxml="<?xml version='1.0' encoding='UTF-8'?>";
			String docFeatures="<GateDocumentFeatures>\n</GateDocumentFeatures>";
			String textWithNodes="<TextWithNodes>\n"+text+"</TextWithNodes>";
			
			gateInputDocumentString=begxml+"\n<GateDocument>\n"+docFeatures+"\n"+textWithNodes+"\n</GateDocument>";
			
		} catch (IOException e) {
			
			logger.error("Error reading file",e);
		}
		
		return gateInputDocumentString;
	}
	
	public static void main(String[] args) throws Exception
	{
		String [] extensions ={"txt"};
		Iterator <File> itFile=FileUtils.iterateFiles(new File (inputDirectory), extensions, false);
		AggregatorWS batchAggregator = new AggregatorWS();
		while (itFile.hasNext())
		{
			File currentInputFile=itFile.next();
			String currentInputFileName=currentInputFile.getName();
			String currentInputFilePath=inputDirectory+currentInputFileName;
			String gateInputDocumentString=getGateInputString (currentInputFilePath);
			
			
			logger.error("Process the current File: "+currentInputFilePath);
			String outputDocumentString=batchAggregator.aggregate(gateInputDocumentString, parameters);
			String currentOutputFilePath=outputDirectory+currentInputFileName+".xml";
			
			logger.error("Write the File: "+currentOutputFilePath);
			FileUtils.write(new File(currentOutputFilePath), outputDocumentString, "UTF-8");
			
			
		}
	}
	

}
