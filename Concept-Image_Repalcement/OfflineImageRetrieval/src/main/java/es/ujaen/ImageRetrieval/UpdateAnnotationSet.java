package es.ujaen.ImageRetrieval;

import java.util.List;

import gate.Annotation;
import gate.AnnotationSet;
import gate.Document;
import gate.Factory;
import gate.FeatureMap;
import gate.Gate;
import gate.Utils;
import gate.creole.ResourceInstantiationException;
import gate.util.GateException;
import gate.util.InvalidOffsetException;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStreamReader;
import java.util.ArrayList;
import java.util.HashSet;
import java.util.Iterator;
import java.util.Map;
import java.util.Properties;

import javax.servlet.ServletContext;

import org.apache.axis2.context.MessageContext;
import org.apache.axis2.transport.http.HTTPConstants;
import org.apache.commons.io.FileUtils;
import org.apache.log4j.Logger;

public class UpdateAnnotationSet {

	private Document inputDocument;
	private List<String> annotationSetNames;

	
	
	private static Logger logger = Logger.getLogger(UpdateAnnotationSet.class);
	private static boolean gateInited = false; 
	
	public void setAnnotationSetNames ( List<String> annotationSetNames)
	{
		this.annotationSetNames=	annotationSetNames;
	}


	private void initGateServiceWS ()  throws GateException
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
	
	private void initGateStandAlone () throws GateException
	{
		if (!gateInited)
		{
			String gateHome=UpdateAnnotationSet.class.getResource("/WEB-INF/").getPath();
			Gate.setGateHome(new File(gateHome));
			Gate.init();
			gateInited=true;
		}
		
	}
		
	public void initGate () throws GateException
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
	
	/**
	 * Verifies that a term annotation is the right term to consider for adding an image to.
	 * @param currAnnot
	 * @return
	 */
	private boolean isGoodTerm (Annotation currAnnot )
	{
		FeatureMap termFeatures = currAnnot.getFeatures();
		
		if (termFeatures.containsKey("POS"))
		{
			String termPOS=termFeatures.get("POS").toString();
			if ((termPOS.equalsIgnoreCase("N")) && (termFeatures.containsKey("idWN"))  )
			{
				return true;
			}
		}
		
		return false;
	}
	
	private String getWordnetId (Annotation currAnnot)
	{
		FeatureMap termFeatures = currAnnot.getFeatures();
		String[] allIds=termFeatures.get("idWN").toString().split("\\|");
		String isabelId=allIds[0]; //05933246n
		String imageNetId="n"+(String) isabelId.subSequence(0, isabelId.length()-1);
		return imageNetId;
	}
	
	
	private String getLemma (Annotation currAnnot)
	{
		FeatureMap termFeatures = currAnnot.getFeatures();
		String termLemma=termFeatures.get("lemma").toString();
		return termLemma;
	}
	
	
	private String getWikipediaURL (Annotation currAnnot)
	{
		FeatureMap termFeatures = currAnnot.getFeatures();
		String wikipediaURL=termFeatures.get("wikipediaURL").toString();
		return wikipediaURL;
	}
	
	public HashSet<ConceptImage>  getAnnotationOffsetsForSet(String setToRetriveConceptsName) throws GateException
	{

		HashSet<ConceptImage> conceptsToAddImage = new HashSet<ConceptImage> ();
		
		//String documentXml = inputDocument.toXml();
		//logger.debug("The content of the document is :"+documentXml);

		Map<String,AnnotationSet> mAllNamedAnSets=inputDocument.getNamedAnnotationSets();
   		
		logger.debug("The number of named annotation sets in the document is :"+mAllNamedAnSets.keySet().size());
		
		for (String curAnnotationName: mAllNamedAnSets.keySet())
		{
			logger.debug("Cur Annotation Set:"+curAnnotationName);
			if (setToRetriveConceptsName.equalsIgnoreCase(curAnnotationName))
			{
				AnnotationSet curAnnotationSet = inputDocument .getAnnotations(setToRetriveConceptsName);
				Iterator<Annotation> it = curAnnotationSet.iterator();

				while(it.hasNext()) {
					Annotation currAnnot = (Annotation) it.next();		
					long startOffset=currAnnot.getStartNode().getOffset().longValue();
					long endOffset=currAnnot.getEndNode().getOffset().longValue();
					
					String conceptLemma = getLemma(currAnnot);
					ConceptImage curConcept = new ConceptImage();
					curConcept.setStartOffset(startOffset);
					curConcept.setEndOffset(endOffset);
					curConcept.setConceptName(conceptLemma);
					curConcept.setWikipediaURL(getWikipediaURL(currAnnot));
					conceptsToAddImage.add(curConcept);	

				}
			}
		}
		return conceptsToAddImage;
	}

	

	public HashSet<ConceptImage>  getAnnotationOffsetsForConfigurableSets() throws GateException
	{
		HashSet <String> verifySet = new HashSet <String> (); 	
		
		HashSet<ConceptImage> conceptsToAddImage = new HashSet<ConceptImage> ();
		Map<String,AnnotationSet> mAllNamedAnSets=inputDocument.getNamedAnnotationSets();
		
		logger.debug("The number of named annotation sets in the document is :"+mAllNamedAnSets.keySet().size());
		
		for (String curAnnotationName: mAllNamedAnSets.keySet())
		{
			for (String annotationName:annotationSetNames)
			{
				if (annotationName.equalsIgnoreCase(curAnnotationName))
				{
					AnnotationSet curAnnotationSet = inputDocument .getAnnotations(annotationName);
					Iterator<Annotation> it = curAnnotationSet.iterator();
					
					while(it.hasNext()) {
						Annotation currAnnot = (Annotation) it.next();		
						if (isGoodTerm (currAnnot))
						{
							long startOffset=currAnnot.getStartNode().getOffset().longValue();
							long endOffset=currAnnot.getEndNode().getOffset().longValue();
							String wordnetId=getWordnetId(currAnnot);

							String annotationSpan =startOffset+"-"+endOffset;

							if (!verifySet.contains(annotationSpan))
							{
								verifySet.add(annotationSpan);
								String conceptLemma = getLemma(currAnnot);
								ConceptImage curConcept = new ConceptImage();
								curConcept.setStartOffset(startOffset);
								curConcept.setEndOffset(endOffset);
								curConcept.setConceptName(conceptLemma);
								curConcept.setWordnetId(wordnetId);
								conceptsToAddImage.add(curConcept);
							}
							
						}

					}

				}
			}
		}
		return conceptsToAddImage;
	}
	
	
	public String addImageNetSet (HashSet <ConceptImage>  concepts) 
	{
		AnnotationSet image=inputDocument.getAnnotations("ImageNetAnnotationSet");	
		int id=-1;
		for (ConceptImage concept:concepts)
		{
			if (concept.getImagesURL()!=null)
			{
				id++;
				FeatureMap imageFeatures = Factory.newFeatureMap();
				for (String imageURL:concept.getImagesURL())
				{
					String featureURLName="url";
					String confidenceName="imageConfidence";
					
					imageFeatures.put(featureURLName, imageURL);
					imageFeatures.put(confidenceName, "high");
				}
				
				try {
					image.add(id, concept.getStartOffset(), concept.getEndOffset(), "image", imageFeatures);
				} catch (InvalidOffsetException e) {
					logger.error ("Invalid Offset Exception:",e);
				}
		}	
	}
       return inputDocument.toXml();
	}
	
	
	public void addWikipediaImageSet (HashSet <ConceptImage>  concepts) throws InvalidOffsetException
	{
		AnnotationSet image=inputDocument.getAnnotations("WikipediaImageAnnotationSet");	
		int id=-1;
		for (ConceptImage concept:concepts)
		{
			if (concept.getWikipediaImageURL()!=null)
			{
				id++;
				FeatureMap imageFeatures = Factory.newFeatureMap();
				String urlName="url";
				String confidenceName="imageConfidence";
				String lemmaName="lemma";
				
				imageFeatures.put(lemmaName, concept.getConceptName());
				imageFeatures.put(urlName, concept.getWikipediaImageURL());
				imageFeatures.put(confidenceName, "high");
				
				
				image.add(id, concept.getStartOffset(), concept.getEndOffset(), "image", imageFeatures);
			}	
		}
		
	}
	
	public String getAnnotatedDocument ()
	{
		 return inputDocument.toXml();
	}

}
