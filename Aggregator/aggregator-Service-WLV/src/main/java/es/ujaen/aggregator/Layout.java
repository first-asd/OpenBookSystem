package es.ujaen.aggregator;

import gate.Document;
import gate.Annotation;
import gate.AnnotationSet;
import gate.Corpus;
import gate.Document;
import gate.Factory;
import gate.FeatureMap;
import gate.Gate;
import gate.ProcessingResource;
import gate.Utils;
import gate.creole.ResourceInstantiationException;
import gate.creole.SerialAnalyserController;
import gate.util.InvalidOffsetException;
import gate.util.OffsetComparator;

import java.io.File;
import java.util.ArrayList;
import java.util.Collections;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import java.util.Set;

import org.apache.log4j.Logger;



/**
 * Generate the layout information for the Gate Document.
 * @author Eduard
 */

public class Layout {

	private static org.apache.log4j.Logger  log = Logger.getLogger(Layout.class);


	private boolean isEOL (String content)
	{
		String [] arTest=content.split("");
		for (String letter:arTest)
		{
			if (letter.compareTo("\n")==0)
			{
				return true;
			}
		}
		return false;
	}




	private Eol register (long startOffset, long endOffset, boolean isParagraph)
	{
		Eol eol = new Eol ();
		eol.setStartOffset(startOffset);
		eol.setEndOffset(endOffset);
		eol.setParagraph(isParagraph);
		return eol;
	}


	private boolean checkEOLBetween (Document doc, AnnotationSet tokenAnnotations , long startOffset , long endOffset)
	{
		AnnotationSet tokensBetweenSentences = tokenAnnotations.get(startOffset, endOffset);

		for (Annotation token:tokensBetweenSentences)
		{
			String content=Utils.stringFor(doc, token);
			if (isEOL(content))
			{
				return true;
			}

		}

		return false;

	}
	
	
	private void printEOL (ArrayList <Eol> eolList)
	{
		for (Eol curEol:eolList)
		{
			if (curEol.isParagraph()==false)
			{
				log.error(curEol.startOffset+":"+curEol.endOffset);
			}
		}
	}
	
	private void printParagraph (ArrayList <Eol> eolList)
	{
		for (Eol curEol:eolList)
		{
			if (curEol.isParagraph())
			{
				log.error(curEol.startOffset+":"+curEol.endOffset);
			}
		}
	}
	
	/**
	 * The Layout Annotation Set will be used for debugging purposes.
	 */
	private void addLayoutAnnotationSet (Document doc , ArrayList <Eol> eolList) throws InvalidOffsetException
	{
		AnnotationSet layoutAS =doc.getAnnotations("Layout");
		for (Eol curEol:eolList)
		{
			long startOffset=curEol.getStartOffset();
			long endOffset=curEol.getEndOffset();
			FeatureMap curFeatures = Factory.newFeatureMap();
			
			if (curEol.isParagraph())
			{
				layoutAS.add(startOffset, endOffset, "p", curFeatures);
			}
			else
			{
				layoutAS.add(startOffset, endOffset, "br", curFeatures);
			}
		}
	}
	
	
	private FeatureMap changeFeatureMap (Annotation eolAnnotation)
	{
		FeatureMap fm =eolAnnotation.getFeatures();
		fm.clear();
		
		fm.put("kind","newline");
		fm.put("string","br");
		
		return fm;
	}
	
	/**
	 * The Layout will be used by IE to generate the HTML.
	 */
	private void addOpenBookLayout(Document doc , ArrayList <Eol> eolList) throws InvalidOffsetException
	{
		log.debug("Add paragraph information");
		AnnotationSet paragraphAS =doc.getAnnotations("ParagraphDetection");
		for (Eol curEol:eolList)
		{
			long startOffset=curEol.getStartOffset();
			long endOffset=curEol.getEndOffset();
			FeatureMap curFeatures = Factory.newFeatureMap();
			
			if (curEol.isParagraph())
			{
				paragraphAS.add(startOffset, endOffset, "p", curFeatures);
			}
		}
		
		log.debug("Add br information in the tokenization set");
		AnnotationSet tokenizationAS =doc.getAnnotations("Tokenization");
		for (Eol curEol:eolList)
		{
			long startOffset=curEol.getStartOffset();
			long endOffset=curEol.getEndOffset();
			
			if (curEol.isParagraph()==false)
			{
				AnnotationSet eolAS=tokenizationAS.get("SpaceToken", startOffset, endOffset);
				for (Annotation eolAnnotation:eolAS)
				{
					changeFeatureMap (eolAnnotation);
					break;
				}
					
			}
		}
	}
	

	public void addLayout (Document doc) throws Exception
	{

		log.error("Start Layout Computation");
		

		ArrayList <Eol> eolList = new ArrayList <Eol> ();
		ArrayList<SentenceBoundary> alSentenceBoundary = new ArrayList<SentenceBoundary> ();

		AnnotationSet tokenAnnotations =doc.getAnnotations("Tokenization");
		List<Annotation> sentenceAnnotations=Utils.inDocumentOrder(doc.getAnnotations("SentenceDetection"));

		log.error("Compute EOL inside the sentence boundaries");
		for (Annotation sentence:sentenceAnnotations)
		{
			SentenceBoundary sb = new SentenceBoundary ();

			sb.setStartSentence(Utils.start(sentence));
			sb.setEndSentence(Utils.end(sentence));
			alSentenceBoundary.add(sb);

			AnnotationSet tokensInSentence = Utils.getContainedAnnotations(tokenAnnotations, sentence);
			for (Annotation token:tokensInSentence)
			{
				String content=Utils.stringFor(doc, token);

				if (isEOL(content))
				{
					Eol eol = register(Utils.start(token),Utils.end(token),false);	
					eolList.add(eol);
				}

			}

		}

		log.error("Add paragraph boundaries:");
		long paraStart=alSentenceBoundary.get(0).getStartSentence();
		long paraEnd=alSentenceBoundary.get(0).getEndSentence();
		for (int i=1;i<alSentenceBoundary.size();i++ )
		{
			long difOffset =alSentenceBoundary.get(i).getStartSentence()-alSentenceBoundary.get(i-1).getEndSentence();
			if (difOffset>0)
			{
				if (checkEOLBetween (doc,tokenAnnotations , alSentenceBoundary.get(i-1).getEndSentence(), alSentenceBoundary.get(i).getStartSentence() ))
				{
					paraEnd=alSentenceBoundary.get(i-1).getEndSentence();

					Eol eol = register(paraStart,paraEnd,true);	
					eolList.add(eol);

					paraStart=alSentenceBoundary.get(i).getStartSentence();
					paraEnd=alSentenceBoundary.get(i).getEndSentence();
				}
				else
				{
					paraEnd=alSentenceBoundary.get(i).getEndSentence();
				}
			}
			else
			{
				paraEnd=alSentenceBoundary.get(i).getEndSentence();
			}
		}

		Eol eol = register(paraStart,paraEnd,true);	
		eolList.add(eol);
		
	
		log.error("======EOL=======");
		printEOL (eolList);
		
		log.error("======Paragraph=======");
		printParagraph (eolList);
		
		
		log.error ("Add the Layout and Paragraph Annotations Sets");
		addLayoutAnnotationSet(doc, eolList);
		addOpenBookLayout(doc , eolList);
		log.error ("Finish");
		
	}


}
