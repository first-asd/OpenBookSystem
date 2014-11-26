package es.ujaen.test;

import java.io.File;
import java.rmi.RemoteException;

import org.apache.commons.io.FileUtils;
import org.apache.log4j.Logger;

import ujaen.es.clients.DisambiguationExceptionException;
import es.ujaen.clients.DisambiguatorClient;

public class TestDisambiguatorAlicante {
	
	private static String inputDirectory ="/opt/dist/008_first/Aggregator/inputFiles/";
	private static String outputDirectory ="/opt/dist/008_first/Aggregator/inputFiles/";
	
	private static String parameters = "{\"languageCode\":\"en\"}";
	private static Logger logger = Logger.getLogger(TestDisambiguatorAlicante.class);
	private static  int connectionReadTimeout=5*60*1000 ; 
	
	
	private static String getDisambiguatorResponse (String gateInputString, String parameters) throws RemoteException, DisambiguationExceptionException 
	{
		DisambiguatorClient dc = new DisambiguatorClient ();
		dc.setConnectionTimeout(connectionReadTimeout);
		logger.debug("Get the Disambiguator Client Response:");
		
		long startTime = System.currentTimeMillis();
		String gateResponse =dc.getClientResponse(gateInputString, parameters);
		long estimatedTime = System.currentTimeMillis() - startTime;
		logger.error("Disambiguator Time:"+estimatedTime);
		logger.debug("Finish Disambiguation Alicante");
		
		return gateResponse;
	}
	
	public static void main(String[] args) throws Exception
	{
		String inputFile=inputDirectory+"inputEnglish-1.xml";	
		String gateDocumentString=FileUtils.readFileToString(new File(inputFile), "UTF-8");
		
		String disambiguationString=getDisambiguatorResponse(gateDocumentString, parameters);

		String disambiguationFile = outputDirectory +"outputEnglishDisambiguation-1.xml";
		FileUtils.write(new File(disambiguationFile), disambiguationString, "UTF-8");
	}
	

}
