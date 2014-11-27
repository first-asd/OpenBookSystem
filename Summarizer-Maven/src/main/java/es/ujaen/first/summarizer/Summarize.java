package es.ujaen.first.summarizer;

import java.io.File;
import java.io.FileInputStream;
import java.util.List;
import java.util.Properties;

import org.apache.log4j.Logger;

import es.ujaen.sinai.first.BasicProcessing;
import es.ujaen.sinai.first.PropertiesFields;
import es.ujaen.sinai.first.io.ManageProperties;
import es.ujaen.test.TestSummarize;
import gate.Document;
import gate.Factory;
import gate.FeatureMap;
import gate.Utils;
import gate.creole.ResourceInstantiationException;

import org.apache.axis2.context.MessageContext;
import org.apache.commons.io.FileUtils;
import org.apache.commons.lang3.StringUtils;


/**
 * This is the class that implements the summarization for the FIRST project.
 * @author Eduard
 */
public class Summarize {
	
	private Logger logger= Logger.getLogger(Summarize.class);
	
	/**
	 * The default number of Sentences
	 */
	private int nSentences=5;
	
	private Document buildGateDocument(String gateInputString) throws ResourceInstantiationException {
		ManageProperties properties = ManageProperties.getInstance();
		Document doc = (Document) Factory.createResource("gate.corpora.DocumentImpl", Utils.featureMap("stringContent", gateInputString, "mimeType", "text/xml", "encoding", properties.getValue(PropertiesFields.ENCODING.toString())));
		return (doc);
	}
	
	private void addSummary (Document inputDocument,String summary)
	{
		FeatureMap metaFeatures = inputDocument.getFeatures();
		metaFeatures.put("summary", summary);
		inputDocument.setFeatures(metaFeatures);
	}
	
	private String getConfigFilePath ()
	{
		String appConfFile="";
		MessageContext inContext = MessageContext.getCurrentMessageContext(); 
		if (inContext==null)
		{
			String confFile=BasicProcessing.class.getResource("/conf/conf.txt").getPath();
			Properties appProperties = new Properties();
			try {
				appProperties.load (new FileInputStream(confFile));
				appConfFile=appProperties.getProperty("AppConfigFile");
			} catch (Exception e) {
				logger.debug("I cannot load the property file",e);
			} 
		}
		else
		{
			//read it from services.xml
			appConfFile=MessageContext.getCurrentMessageContext().getAxisService().getParameter("AppConfFile").getParameterElement().getText();
		}
		
		return appConfFile;
	}
	
	private String summarizeNow (String gateInputString, String languageCode) throws Exception
	{

		String appConfigFile=getConfigFilePath ();
		ManageProperties.getInstance().loadProperties(appConfigFile);
		
		logger.debug("Basic NLP Operations");
		BasicProcessing bp = new BasicProcessing ();
		Document gateProcessedDocument=bp.processNLP(gateInputString, languageCode);
		
		if (languageCode.compareToIgnoreCase("bg")==0)
		{
			String gateProcessedDocumentString =gateProcessedDocument.toXml();
			gateProcessedDocument= buildGateDocument(gateProcessedDocumentString);
		}
		
		//logger.debug("Write the Processed File:");
		//FileUtils.write(new File("/opt/dist/008_first/Summarizer/intermediary/processedBulgarian.xml"), gateProcessedDocument.toXml(), "UTF-8");	
		
		logger.debug("Build the input Document");
		Document gateInputDocument = buildGateDocument(gateInputString);
		
		logger.debug("Perform Summarization");
		SummarizerFactory sf = new SummarizerFactory();
		//Summarizer gs=sf.getSummarizer("PUREGRAPH", languageCode);
		Summarizer gs=sf.getSummarizer("GRAPH", languageCode);
		gs.setDocument(gateProcessedDocument);
		gs.summarize();
		
		List<String> extractList=gs.getSummary(nSentences);
		String summary = StringUtils.join(extractList, "#@@\n");
		addSummary (gateInputDocument,summary);
		
		return gateInputDocument.toXml();
	}
	
	public String summarize (String gateInputString, String parameters) throws Exception
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
		
	   BasicProcessing bp = new BasicProcessing ();
	   bp.initGate();
	   CheckArguments.checkArguments(gateInputString, languageCode);
		if (isJson)
		{
			String isSummarization=jp.getValue("summarization");
			String nSentencesString=jp.getValue("summarization.nSentences");
			if (nSentencesString.compareTo("y")!=0)
			{
				nSentences=Integer.parseInt(nSentencesString);
			}
			
			if (isSummarization.compareToIgnoreCase("n")!=0)
			{
				gateInputString= summarizeNow (gateInputString, languageCode);
			}
		}
		else
		{
			gateInputString= summarizeNow (gateInputString, languageCode);
		}
		
		
		return gateInputString;
	}
}
