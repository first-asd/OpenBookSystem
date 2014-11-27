package es.ujaen.sinai.first;

import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.util.List;
import java.util.Properties;

import org.apache.axis2.context.MessageContext;
import org.apache.commons.io.FileUtils;
import org.apache.log4j.Logger;

import es.ujaen.sinai.first.io.ListConfigurationUnit;
import es.ujaen.sinai.first.io.ManageProperties;
import es.ujaen.sinai.first.io.MultiWordListConfigurationLoader;
import es.ujaen.sinai.first.io.XmlListLoader;
import gate.Document;
import gate.Factory;
import gate.Utils;
import gate.creole.ResourceInstantiationException;

public class MultiWordDetection {
	
	private Logger 	logger = Logger.getLogger(MultiWordDetection.class);
	
	//By Default I match the lemma part of the multiWord list against the root part of the Gate Document 
	private String  inputAnnotationName="Token";
	private String fieldToMatch="string";
	private String inputFeatureName="string";
	
	private void setMatchParameters (JsonParameters jp )
	{
		String value=jp.getValue("matchLemma");
		if (value.compareTo("n")==0)
		{
			fieldToMatch="string";
			inputFeatureName="string";
		}
	}
	
	
	private String getConfigFilePath ()
	{
		String appConfFile="";
		MessageContext inContext = MessageContext.getCurrentMessageContext(); 
		if (inContext==null)
		{
			String confFile=MultiWordDetection .class.getResource("/conf/conf.txt").getPath();
			Properties appProperties = new Properties();
			try {
				appProperties.load (new FileInputStream(confFile));
				appConfFile=appProperties.getProperty("AppConfigFile");
			} catch (Exception e) {
				logger.debug("I cannot load the Application Configuration File",e);
			} 
		}
		else
		{
			//Read it from services.xml
			appConfFile=MessageContext.getCurrentMessageContext().getAxisService().getParameter("AppConfFile").getParameterElement().getText();
		}
		
		return appConfFile;
	}
	
	private List<ListConfigurationUnit> getMwXmlLists () throws FileNotFoundException, IOException
	{
		
		String appConfigFile=getConfigFilePath ();
		ManageProperties properties =ManageProperties.getInstance();
		properties.loadProperties(appConfigFile);
		String fileConfigListPath=properties.getValue("LISTCONFIGURATIONFILE");
		
		MultiWordListConfigurationLoader mwl= new MultiWordListConfigurationLoader();  
		List<ListConfigurationUnit> lcus =mwl.load(fileConfigListPath);
		return lcus;
	}
	
	private List<MultiWordUnit> getMultiWordList (ListConfigurationUnit lcu)
	{
		String fileMwListPath=lcu.getLocation();
		XmlListLoader xll = new XmlListLoader ();
		List<MultiWordUnit> mwus =xll.load(fileMwListPath);
		return mwus;
	}
	
	
	
	private Document buildGateDocument(String gateInputString) throws ResourceInstantiationException {
		ManageProperties properties = ManageProperties.getInstance();
		Document doc = (Document) Factory.createResource("gate.corpora.DocumentImpl", Utils.featureMap("stringContent", gateInputString, "mimeType", "text/xml", "encoding", properties.getValue(PropertiesFields.ENCODING.toString())));
		return (doc);
	}
	
	
	private void writeForTest (Document processedDocument) throws IOException
	{
		String processedFile="/opt/dist/008_first/MultiWordDetection/outputFiles/processed.xml";
		FileUtils.write(new File(processedFile), processedDocument.toXml(), "UTF-8");
	}
	
	/**
	 * Check if we should search or not with the respective list.
	 * @return
	 */
	private boolean isSearch (String parameters,ListConfigurationUnit lcu)
	{
		JsonParameters jp = new JsonParameters(parameters);
		String languageCode=jp.getValue("languageCode");
		
		String multiWordDetection=jp.getValue("multiWordDetection");
		String idiomDetection=jp.getValue("idiomDetection");
		
		String listLanguageCode=lcu.getLanguageCode();
		String listType=lcu.getType();
		
		if (listLanguageCode.compareToIgnoreCase(languageCode)!=0)
		{
			return false;
		}
		
		if ((listType.compareToIgnoreCase("idiom")==0) && (idiomDetection.compareToIgnoreCase("y")==0) )
		{
			return true;
		}
		
		
		if ((listType.compareToIgnoreCase("multiWordExpression")==0) && (multiWordDetection.compareToIgnoreCase("y")==0) )
		{
			return true;
		}
		
		
		
		return false;
	}
	
	private String getMultiWordsNow (String gateInputString, String parameters) throws Exception
	{	
		
		JsonParameters jp = new JsonParameters(parameters);
		String languageCode=jp.getValue("languageCode");
		
		logger.error("Get The Multi Word List Configurations :");
		List<ListConfigurationUnit> lcus =getMwXmlLists ();
		
		logger.error ("NLP Process the Document:");
		BasicProcessing bp = new BasicProcessing ();
		Document processedDocument=bp.processNLP(gateInputString, languageCode);
		//writeForTest (processedDocument);
		
		Document toAddAnnotationDocument=buildGateDocument(gateInputString);
		
		logger.error ("Match the multi-words using Aho-Corasick algorihm");
		MatchMultipleWords mmw = new MatchMultipleWords ();
		
		mmw.setDocument(processedDocument);
		mmw.setAnDocument(toAddAnnotationDocument);
		for (ListConfigurationUnit lcu:lcus)
		{
			if (isSearch (parameters,lcu))
			{
				List<MultiWordUnit> mwus = getMultiWordList (lcu);
				
				logger.error ("Search with the List :"+lcu.getName());
				mmw.setMultipleWordList(mwus );
				mmw.setFieldToMatch(fieldToMatch);
				mmw.matchMWords(inputAnnotationName, inputFeatureName, lcu.getOutputAnnotationSetName(),lcu.getOutputAnnotationName(),lcu.getType());
			}
		}
		
		return toAddAnnotationDocument.toXml();
	}
	
	public String getMultiWords (String gateInputString, String parameters) throws Exception
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
			throw new  Exception ("The second argument is not a JSON parameter");
		}
		
		BasicProcessing bp = new BasicProcessing ();
		bp.initGate();
		CheckArguments.checkArguments(gateInputString, languageCode);
		
		if (isJson)
		{
			gateInputString=getMultiWordsNow(gateInputString, parameters);
		}
		
		
		return gateInputString;
		
	}
	

}
