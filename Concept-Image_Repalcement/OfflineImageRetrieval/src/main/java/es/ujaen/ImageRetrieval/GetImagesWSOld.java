package es.ujaen.ImageRetrieval;

import es.ujaen.ImageNet.SearchImages;
import es.ujaen.wikipediaImages.WikipediaImages;
import gate.util.GateException;

import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.net.MalformedURLException;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashSet;
import java.util.List;
import java.util.Properties;

import org.apache.axis2.context.MessageContext;
import org.apache.commons.io.FileUtils;
import org.apache.log4j.Logger;
import org.apache.lucene.queryParser.ParseException;

public class GetImagesWSOld {


	private static Logger logger = Logger.getLogger(GetImagesWSOld.class);
	UpdateAnnotationSet uas = null;
	
	private List<String> annotationSetNames= new ArrayList<String> ();
	private String imageNetIndexDir;
	
	
	private String getConfigFilePath ()
	{
		String appConfFile="";
		MessageContext inContext = MessageContext.getCurrentMessageContext(); 
		if (inContext==null)
		{
			String confFile=UpdateAnnotationSet.class.getResource("/conf/conf.txt").getPath();
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
	
	private void setAppParameters ()
	{
		String appConfFile = getConfigFilePath ();
		try {
			List <String> lines=FileUtils.readLines(new File(appConfFile));
			annotationSetNames=Arrays.asList(lines.get(0).split("#"));
			imageNetIndexDir=lines.get(1);
		} catch (IOException e) {
			logger.error("Cannot read appConfig File",e);
		}
	}
	
	
	private void initGateFramework (String gateInputString)
	{
		uas = new UpdateAnnotationSet ();
		uas.setAnnotationSetNames(annotationSetNames);
		try {
			uas.initGate();
			uas.constructDocument(gateInputString);
		} catch (GateException e) {
			logger.error ("GateException:",e);
		}
	}
	
	
	private String getConceptNameFromWikipediaURL (String wikipediaURL) throws MalformedURLException
	{
		String[] components = wikipediaURL.split("/");
		return components[components.length-1];
	}
	
	
	private HashSet <ConceptImage>  getImagesForConfigurableSets ( ) throws IOException, ParseException, GateException 
	{
		HashSet <ConceptImage>  conceptsToRetrieveImagesFor=uas. getAnnotationOffsetsForConfigurableSets();
		SearchImages sImNet= new SearchImages();
		sImNet.setIndexImageNetDir(imageNetIndexDir);
		
		for (ConceptImage concept:conceptsToRetrieveImagesFor)
		{
			String wordnetId=concept.getWordnetId();
			//logger.debug("Extract image URL's for the wordnet Id:"+wordnetId);
			String[] imNetResults=sImNet.search(wordnetId);
			if (imNetResults.length>0)
			{
				logger.debug("Found image in ImageNet for wordnet concept:"+wordnetId);
				concept.setImagesURL(imNetResults);
			}
			
		}
		
		return conceptsToRetrieveImagesFor;
	}
	
	

	
	private HashSet <ConceptImage>  getImagesForWikipediaSet(String languageCode) throws GateException, IOException, org.json.simple.parser.ParseException
	{
		HashSet <ConceptImage>  conceptsToRetrieveImagesFor=uas.getAnnotationOffsetsForSet("WikipediaDisambiguationAnnotationSet");
		WikipediaImages wi = new WikipediaImages ();

		for (ConceptImage concept:conceptsToRetrieveImagesFor)
		{
			String disambiguatedConcept=getConceptNameFromWikipediaURL (concept.getWikipediaURL());
			logger.debug("Extract image URL's for the concept:"+disambiguatedConcept);
			String wikipediaImageURLS=wi.getImageURL(disambiguatedConcept,languageCode);
			if (wikipediaImageURLS.compareToIgnoreCase("")!=0)
			{
				concept.setWikipediaImageURL(wikipediaImageURLS);
			}
			
		}

		return conceptsToRetrieveImagesFor;
	}
	
	
	private void addImageNetImages() throws Exception
	{
		HashSet<ConceptImage> configurableSetConcepts = getImagesForConfigurableSets ();
		uas.addImageNetSet(configurableSetConcepts);
	}
	
	
	private String addImagesNow(String gateInputString,String languageCode) throws Exception
	{
		setAppParameters();
		
		logger.debug ("Init GATE framework:");
		initGateFramework (gateInputString);
		
		/* These were added for the concepts identified by UA web service. It were first disambiguated on Wikipedia and then I added images to them.
		 * logger.debug ("Add ImageNet Images:");
		if (languageCode.compareToIgnoreCase("en")==0)
		{
			addImageNetImages();
		}
		
		logger.debug ("Add images for Wikipedia Disambiguated Concepts:");
		HashSet<ConceptImage> conceptsWithWikipediaImages;
		conceptsWithWikipediaImages = getImagesForWikipediaSet(languageCode);
		uas. addWikipediaImageSet(conceptsWithWikipediaImages);
		*/
		
		
		return uas.getAnnotatedDocument();
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
