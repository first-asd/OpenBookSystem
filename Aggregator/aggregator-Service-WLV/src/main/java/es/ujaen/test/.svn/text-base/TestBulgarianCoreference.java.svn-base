package es.ujaen.test;

import java.io.File;
import java.rmi.RemoteException;

import org.apache.commons.io.FileUtils;
import org.apache.log4j.Logger;

import ujaen.es.clients.FormatExceptionException;
import es.ujaen.aggregator.AggregatorWS;
import es.ujaen.aggregator.Pipeline;
import es.ujaen.clients.CoreferenceBulgarianClient;

public class TestBulgarianCoreference {
	
	private static String inputDirectory ="/opt/dist/008_first/Aggregator/inputFiles/";
	private static String outputDirectory ="/opt/dist/008_first/Aggregator/inputFiles/";
	
	private static String parameters = "{\"languageCode\":\"bg\"}";
	private static Logger logger = Logger.getLogger(TestBulgarianCoreference.class);
	private static  int connectionReadTimeout=5*60*1000 ; 
	
	
	private static String getBulgarianCoreferenceResults(String gateInputString, String languageCode) throws RemoteException, FormatExceptionException 
	{
		logger.debug("Start Bulgarian Coreference");
		CoreferenceBulgarianClient cbc = new CoreferenceBulgarianClient();
		cbc.setConnectionTimeout(connectionReadTimeout);
		logger.error("Get Bulgarian Coreference WLV Client Response:");
		
		long startTime = System.currentTimeMillis();
		String gateResponse =cbc.getClientResponse(gateInputString, languageCode);
		long estimatedTime = System.currentTimeMillis() - startTime;
		logger.error("Bulgarian Coreference time:"+estimatedTime);
		logger.error("Finish Bulgarian Coreference WLV ");
		return gateResponse;
	}
	
	
	
	
	public static void main(String[] args) throws Exception
	{
		String inputFile=inputDirectory+"inputBulgarian-1.xml";	
		String gateDocumentString=FileUtils.readFileToString(new File(inputFile), "UTF-8");
		
		String correferenceString=getBulgarianCoreferenceResults(gateDocumentString, parameters);

		String coreferenceFile = outputDirectory +"outputBulgarianCoreference-1.xml";
		FileUtils.write(new File(coreferenceFile), correferenceString, "UTF-8");
	}

}
