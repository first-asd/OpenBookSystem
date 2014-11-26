package es.ujaen.test;

import java.io.File;

import org.apache.commons.io.FileUtils;

import es.ujaen.aggregator.AggregatorWS;


public class TestAggregatorWSBulgarian {
	
	private static String inputDirectory ="/opt/dist/008_first/Aggregator/inputFiles/";
	private static String outputDirectory ="/opt/dist/008_first/Aggregator/inputFiles/";
	
	private static String parameters = "{\"languageCode\":\"bg\"}";
	
	
	public static void main(String[] args) throws Exception
	{
		String inputFile=inputDirectory+"inputBulgarian-1.xml";	
		String gateDocumentString=FileUtils.readFileToString(new File(inputFile), "UTF-8");
		
		AggregatorWS testAggregator = new AggregatorWS();
		
		String aggregatedDocumentString=testAggregator.aggregate(gateDocumentString, parameters);

		String aggregateFile = outputDirectory +"outputBulgarian-1.xml";
		FileUtils.write(new File(aggregateFile), aggregatedDocumentString, "UTF-8");
	}

}