package es.ujaen.ImageRetrieval;

import org.apache.log4j.Logger;

public class GetImagesWS {


	private static Logger logger = Logger.getLogger(GetImagesWS.class);

	
	

	private String addImagesNow(String gateInputString,String languageCode) throws Exception
	{
		logger.error("Add Images to multiwords terms");
		AddMultiWordImages ai = new AddMultiWordImages();
		String gateOutputString=ai.addImages(gateInputString, languageCode);
		logger.error("Finished adding images to multiwords terms");
		return gateOutputString;
	}
	
	

	public String addImages(String gateInputString,String parameters) throws Exception  {
	
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
		
		AddMultiWordImages.initGate();
		CheckArguments.checkArguments(gateInputString, languageCode);
		
		if (isJson)
		{
			String isWikipediaDisambiguation=jp.getValue("imageRetrieval");
			
			if (isWikipediaDisambiguation.compareToIgnoreCase("n")!=0)
			{
				gateInputString=addImagesNow(gateInputString, languageCode);
			}
		}
		else
		{
			gateInputString=addImagesNow(gateInputString, languageCode);
		}
		
		
		return gateInputString;
	}

}
