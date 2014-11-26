package es.ujaen.test;

import java.io.File;
import java.rmi.RemoteException;

import org.apache.commons.io.FileUtils;
import org.apache.log4j.Logger;

import ujaen.es.clients.FormatExceptionException;
import es.ujaen.clients.CoreferenceEnglishClient;

public class TestEnglishCoreference {
	
	private static String inputDirectory ="/opt/dist/008_first/Aggregator/inputFiles/";
	private static String outputDirectory ="/opt/dist/008_first/Aggregator/inputFiles/";
	
	private static String parameters = "{\"languageCode\":\"en\", \"coref.setName\":\"Coreference\"}";
	

	private static Logger logger = Logger.getLogger(TestEnglishCoreference.class);
	private static  int connectionReadTimeout=5*60*1000 ; 
	
	
	private static String getEnglishCoreferenceResults(String gateInputString, String languageCode) throws RemoteException, FormatExceptionException 
	{
		
		CoreferenceEnglishClient cec = new CoreferenceEnglishClient();
		cec.setConnectionTimeout(connectionReadTimeout);
		logger.debug("Get English Coreference WLV Client Response:");
		
		long startTime = System.currentTimeMillis();
		String gateResponse =cec.getClientResponse(gateInputString, languageCode);
		long estimatedTime = System.currentTimeMillis() - startTime;
		logger.error("English Coreference time:"+estimatedTime);
		
		logger.debug("Finish English Coreference WLV ");
		return gateResponse;
	}
	
	
	
	public static void main(String[] args) throws Exception
	{
		String inputFile=inputDirectory+"inputEnglish-1.xml";	
		String gateDocumentString=FileUtils.readFileToString(new File(inputFile), "UTF-8");
		
		String correferenceString=getEnglishCoreferenceResults(gateDocumentString, parameters);

		String coreferenceFile = outputDirectory +"outputEnglishCoreference-1.xml";
		FileUtils.write(new File(coreferenceFile), correferenceString, "UTF-8");
	}

}
