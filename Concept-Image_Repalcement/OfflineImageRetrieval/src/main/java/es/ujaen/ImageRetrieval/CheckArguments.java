package es.ujaen.ImageRetrieval;

import org.apache.log4j.Logger;

import gate.Document;
import gate.Factory;
import gate.FeatureMap;
import gate.Utils;

/**
 * Check the validity of arguments : languageCode should be allowed and the inputGateDocument should be parsed.  
 * @author Eduard
 */


public class CheckArguments {
	
	private static Logger logger = Logger.getLogger(CheckArguments.class);
	
	
	public static void checkArguments (String gateDocumentString, String languageCode) throws Exception
	{
		boolean isGoodLanguageCode= checkLanguageCode (languageCode);
		boolean isValidDocument=checkDocumentValidity (gateDocumentString);
		
		if (!isGoodLanguageCode)
		{
			logger.error("Language Code not supported:"+languageCode);
			throw new Exception ("Language Code not supported:"+languageCode);
		}
		
		if (!isValidDocument)
		{
			throw new Exception ("The input Document is not a valid Gate Document");
		}
		
	}
	
	private static boolean checkLanguageCode (String languageCode)
	{
		boolean isCorrectLanguage =false;
		
		if ((languageCode.compareTo("bg")==0)||(languageCode.compareTo("en")==0)||(languageCode.compareTo("es")==0))
		{
			isCorrectLanguage=true; 
		}
		
		return isCorrectLanguage;
		
	}
	
	private static boolean checkDocumentValidity (String gateDocumentString) 
	{
		boolean isValidDocument=true;
		Document gateDocument=null;
	
		try {
		gateDocument = (Document) Factory.createResource("gate.corpora.DocumentImpl", Utils.featureMap("stringContent", gateDocumentString, "mimeType", "text/xml", "encoding", "UTF-8"));
		} catch (Exception e) {
			isValidDocument=false;
			logger.error("Exception instatiating the Gate Document:",e);
			logger.error("The following Document is not a Valid Gate Document:\n");
			logger.error("===================================");
			logger.error(gateDocumentString);
			logger.error("===================================");
		}
		
		//The Document can have a parsing Exception. You should check the gate document features: (parsingError=true)
		if (gateDocument!=null)
		{
			FeatureMap fm= gateDocument.getFeatures();
			if (fm.containsKey("parsingError"))
			{
				isValidDocument=false;
				String parsingError= fm.get("parsingError").toString();
				if (parsingError.compareTo("true")==0)
				{
					logger.error("Gate Parsing Error the following Document is not a Valid Gate Document:\n");
					logger.error("===================================");
					logger.error(gateDocumentString);
					logger.error("===================================");
				}
			}
			
		}
		return isValidDocument;
	}

}
