package es.ujaen.ReadLemmaAS;

import gate.Annotation;
import gate.AnnotationSet;
import gate.Document;
import gate.Factory;
import gate.FeatureMap;
import gate.Gate;
import gate.util.GateException;
import gate.util.InvalidOffsetException;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileInputStream;
import java.io.InputStreamReader;
import java.net.MalformedURLException;
import java.net.URL;
import java.util.ArrayList;
import java.util.HashSet;
import java.util.Iterator;
import java.util.LinkedHashMap;
import java.util.Map;

import org.apache.log4j.Logger;

public class ConcepsForAnnotationSet {

	/**
	 * The annotation sets I want to Retrieve Concepts to Retrieve Images For ... 
	 */
	private String fileAnnotationSets="/Users/Eduard/Documents/MyPerlCode/FirstRelatedScripts/Evaluation/EvaluationGoogleAndBingImages/annotationSetNames.txt";
	private Document inputDocument;
	private URL fileURL;
	private String encoding;

	
	ArrayList<String> annotationSetNames= new ArrayList<String> ();
	
	private static Logger logger = Logger.getLogger(ConcepsForAnnotationSet.class);
	
	/**
	 * It is static become Gate should be initialized only once.
	 */
	private static boolean gateInited = false; 
	

	public void  setEncoding (String encoding)
	{
		this.encoding=encoding;
	}

	public void setFilePath (String filePath) throws MalformedURLException
	{
		this.fileURL=new File(filePath).toURI().toURL(); 
	}

	public void readAnnotationSetNames ()
	{
		try{
			BufferedReader input = new BufferedReader(new InputStreamReader(new FileInputStream(fileAnnotationSets),"UTF8"));
			String  annotationSetName;
			while ((annotationSetName= input.readLine()) != null)
			{
				annotationSetNames.add(annotationSetName);
			}
		}
		catch(Exception e){	
		}
	}


	private void initGateStandAlone () throws GateException
	{
		if (!gateInited)
		{
			Gate.setGateHome(new File("/Applications/GATE_Developer_7.0/"));
			Gate.init();
			gateInited=true;
		}
		
	}
	
	
	public void initGate () throws GateException
	{
		initGateStandAlone ();
	}

	public void constructDocument () throws GateException
	{
		initGate();
		FeatureMap params = Factory.newFeatureMap();
		params.put("sourceUrl", fileURL);
		params.put("encoding", encoding);

		inputDocument =  (Document) Factory.createResource("gate.corpora.DocumentImpl", params);
		logger.debug ("Constructed Document with url:"+fileURL);

	}
	
	/**
	 * Verifies that a term annotation is the right term to consider for adding an image to
	 * @param currAnnot
	 * @return
	 */
	private boolean isGoodTerm (Annotation currAnnot )
	{
		FeatureMap termFeatures = currAnnot.getFeatures();
		String termPOS=termFeatures.get("POS").toString();
		if (termPOS.equalsIgnoreCase("N")  )
		{
			return true;
		}
		return false;
	}
	
	
	private String getLemma (Annotation currAnnot)
	{
		FeatureMap termFeatures = currAnnot.getFeatures();
		String termLemma=termFeatures.get("lemma").toString();
		return termLemma;
	}
	
	
	
	public LinkedHashMap<String,String> getTerms(String languageCode) throws GateException
	{
		readAnnotationSetNames();
		LinkedHashMap<String,String> conceptsToAddImage = new LinkedHashMap<String,String> ();
		Map<String,AnnotationSet> mAllNamedAnSets=inputDocument.getNamedAnnotationSets();
   		
		logger.debug("The number of named annotation sets in the document is :"+mAllNamedAnSets.keySet().size());
		
		for (String curAnnotationName: mAllNamedAnSets.keySet())
		{
			logger.debug("Cur Annotation Set:"+curAnnotationName);
			for (String setToRetrieveImagesFor:annotationSetNames )
			{
				if (curAnnotationName.equalsIgnoreCase(setToRetrieveImagesFor))
				{
					logger.debug("Extract Terms for the set:"+curAnnotationName);
					AnnotationSet curAnnotationSet = inputDocument .getAnnotations(curAnnotationName);
					Iterator<Annotation> it = curAnnotationSet.iterator();

					while(it.hasNext()) {
						Annotation currAnnot = (Annotation) it.next();	
						if (isGoodTerm (currAnnot ))
						{
							String conceptLemma = getLemma(currAnnot);
							conceptsToAddImage.put(conceptLemma, languageCode);	
						}
					}
				}
			}
			
		}
		return conceptsToAddImage;
	}

}
