package es.ujaen.first.summarizer;

import es.ujaen.sinai.first.io.ManageProperties;

/**
 * The factory for creating the summarizer to perform the summarization.
 * @author Eduard
 */
public class SummarizerFactory {
	
	
	private String getConfigFileForLanguage (String languageCode)
	{
		String configFile="";
		ManageProperties properties = ManageProperties.getInstance();
		if (languageCode.equalsIgnoreCase("en"))
		{
			configFile=properties.getValue("EN-SUMMARIZER-CONFFILE");
		}
		else if (languageCode.equalsIgnoreCase("es"))
		{
			configFile=properties.getValue("ES-SUMMARIZER-CONFFILE");
		}
		else if (languageCode.equalsIgnoreCase("bg"))
		{
			configFile=properties.getValue("BG-SUMMARIZER-CONFFILE");
		}
		return configFile;
	}
	
	public Summarizer getSummarizer (String summarizerName,String languageCode)
	{
		
		if (summarizerName.equalsIgnoreCase("GRAPH"))
		{
			String configFile=getConfigFileForLanguage (languageCode);
			return new GraphSummarizer (configFile);
		}
		
		if (summarizerName.equalsIgnoreCase("PUREGRAPH"))
		{
			String configFile=getConfigFileForLanguage (languageCode);
			return new PureGraphSummarizer (configFile);
		}
			
		return null;	
	}

}
