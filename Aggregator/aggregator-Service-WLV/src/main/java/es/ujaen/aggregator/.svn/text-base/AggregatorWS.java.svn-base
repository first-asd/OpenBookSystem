package es.ujaen.aggregator;


import org.apache.log4j.Logger;

/**
 * It aggregates the input from all partner web services: used in Production or in Development.
 * @author Eduard
 */

public class AggregatorWS {
	
	private static Logger logger = Logger.getLogger(AggregatorWS.class);
	
	private String getLanguageCode (String parameters)
	{
		JsonParameters jp = new JsonParameters(parameters);
		boolean isJson=jp.isJsonParameter();
		
		String languageCode="";
		if (isJson)
		{
			languageCode =jp.getValue("languageCode");
		}
		else
		{
			languageCode=parameters;
		}
		return languageCode;
	}
	
	
	public String aggregate(String inputGateDocument, String parameters) throws Exception 
	{	
		String aggregatedDocumentString =inputGateDocument;
		Pipeline pl = new Pipeline();
		pl.initGate();
		
		String languageCode=getLanguageCode(parameters);
		CheckArguments.checkArguments(inputGateDocument, languageCode);
		
		logger.debug("The Arguments of the Aggregator are valid: start the Aggregation Process!");
		aggregatedDocumentString=pl.aggregate(inputGateDocument, parameters);
		
		return aggregatedDocumentString;
	}
		
}



