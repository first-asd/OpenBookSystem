package es.ujaen.ImageRetrieval;

import es.ujaen.wikipediaImages.WikipediaImages;
import gate.Annotation;
import gate.AnnotationSet;
import gate.Document;
import gate.Factory;
import gate.FeatureMap;
import gate.Gate;
import gate.Utils;
import gate.creole.ResourceInstantiationException;
import gate.util.GateException;

import java.io.File;
import java.io.IOException;
import java.net.MalformedURLException;

import javax.servlet.ServletContext;

import org.apache.axis2.context.MessageContext;
import org.apache.axis2.transport.http.HTTPConstants;
import org.apache.log4j.Logger;
import org.json.simple.parser.ParseException;

public class AddMultiWordImages {
	
	private Document inputDocument;
	private static Logger logger = Logger.getLogger(AddMultiWordImages.class);
	private static boolean gateInited = false; 
	
	

	private static void initGateServiceWS ()  throws GateException
	{
		if (!gateInited)
		{
			MessageContext inContext = MessageContext.getCurrentMessageContext(); 
			ServletContext req = (ServletContext)inContext.getProperty(HTTPConstants.MC_HTTP_SERVLETCONTEXT);
			File gateHome = new File(req.getRealPath("/WEB-INF"));
			Gate.setGateHome(gateHome ); 
			Gate.setPluginsHome(new File (gateHome,"PLUGINS"));

			//set user config file
			Gate.setUserConfigFile(new File(gateHome, "user-gate.xml"));

			Gate.init();
			gateInited=true;	
		}

	}
	
	private static void initGateStandAlone () throws GateException
	{
		if (!gateInited)
		{
			String gateHome=UpdateAnnotationSet.class.getResource("/WEB-INF/").getPath();
			Gate.setGateHome(new File(gateHome));
			Gate.init();
			gateInited=true;
		}
		
	}
		
	public static  void initGate () throws GateException
	{
		
		MessageContext inContext = MessageContext.getCurrentMessageContext(); 
		if (inContext==null)
		{
			initGateStandAlone ();
		}
		else
		{
			  initGateServiceWS ();
		}
	  
	}

	public void constructDocument (String gateInputString) throws ResourceInstantiationException 
	{
		inputDocument = (Document) Factory.createResource("gate.corpora.DocumentImpl", Utils.featureMap("stringContent", gateInputString, "mimeType", "text/xml", "encoding", "UTF-8"));
	}
	
	
	private String getWikipediaURL (Annotation currAnnot)
	{
		FeatureMap termFeatures = currAnnot.getFeatures();
		String wikipediaURL=termFeatures.get("wikipediaURL").toString();
		return wikipediaURL;
	}
	
	private String getConceptNameFromWikipediaURL (String wikipediaURL) throws MalformedURLException
	{
		String[] components = wikipediaURL.split("/");
		return components[components.length-1];
	}
	
	public  String addImages (String gateInputString,String languageCode) throws GateException, IOException, ParseException
	{
		String multiWordsASetName ="Disambiguate markups MULTIWORDS";
		
		constructDocument (gateInputString);
		AnnotationSet aSet=inputDocument.getAnnotations(multiWordsASetName);
		
		WikipediaImages wi =new WikipediaImages ();
		
		for (Annotation an:aSet)
		{
			FeatureMap fm=an.getFeatures();
			if (fm.containsKey("wikipediaURL"))
			{
				String wikipediaConcept=getConceptNameFromWikipediaURL(fm.get("wikipediaURL").toString());
				String wikipediaImageURLS=wi.getImageURL(wikipediaConcept,languageCode);
				if (wikipediaImageURLS.compareToIgnoreCase("")!=0)
				{
					fm.put("image",wikipediaImageURLS);
				}
			}
		}
		
		return inputDocument.toXml();
	}
	
	
	

}
