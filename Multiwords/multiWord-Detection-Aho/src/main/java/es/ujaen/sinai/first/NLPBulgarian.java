package es.ujaen.sinai.first;

import gate.AnnotationSet;
import gate.Factory;
import gate.Annotation;
import gate.Document;
import gate.FeatureMap;

import java.util.Iterator;
import java.util.Map;

/**
 * This class implements a transformation on the Bulgarian document received by the Aggregator
 * The document contains all the information but does not contain the annotations in the default set. 
 * @author Eduard
 */
public class NLPBulgarian implements INLPTOOL {
	
	private Document gateDocument;
	
	public void init(Map<String, Object> params)
	{
		
	}
	
	public void setContent(Document doc)
	{
		gateDocument=doc;
	}
	
	public Object getContent()
	{
		return gateDocument;
	}
	
	public void tokenize()
	{
		AnnotationSet tokenizationAs =gateDocument.getAnnotations("Tokenization");
		AnnotationSet defaultAs =gateDocument.getAnnotations("");
		
		for (Iterator<Annotation> it = tokenizationAs .iterator(); it.hasNext(); ) {
			
			Annotation currentTokenAnnotation=it.next();
			FeatureMap tokenFeaturesMap=currentTokenAnnotation.getFeatures();
			FeatureMap curFeaturesMap = Factory.newFeatureMap();
			
			if ("Token".compareToIgnoreCase(currentTokenAnnotation.getType())==0)
			{
				curFeaturesMap.put("string",tokenFeaturesMap.get("string"));
				curFeaturesMap.put("root",tokenFeaturesMap.get("lemma"));
				curFeaturesMap.put("category",tokenFeaturesMap.get("POS"));
				
				//Add the new Token to the Annotation Set
			
				defaultAs.add(currentTokenAnnotation.getStartNode(), currentTokenAnnotation.getEndNode(), 	currentTokenAnnotation.getType(), curFeaturesMap);
			}
			
			
		}
		gateDocument.removeAnnotationSet("Tokenization");
		
	}
	
	public void splitter()
	{
		AnnotationSet sDetectionAS =gateDocument.getAnnotations("SentenceDetection");
		AnnotationSet defaultAs =gateDocument.getAnnotations("");
		
		for (Iterator<Annotation> it = sDetectionAS .iterator(); it.hasNext(); ) {
			
			Annotation currentSentenceAnnotation=it.next();
			
			//Add the Sentence to the Annotation Set
			defaultAs.add(currentSentenceAnnotation.getStartNode(), currentSentenceAnnotation.getEndNode(), "Sentence", null);
			
		}
		gateDocument.removeAnnotationSet("SentenceDetection");
	}
	
	public void lemmatize()
	{
		
	}
	
	
	
	public void nlpTokSplitMorphPos()
	{
		tokenize();
		splitter();
	}

}
