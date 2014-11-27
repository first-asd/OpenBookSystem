package es.ujaen.sinai.first;

import java.util.ArrayList;
import java.util.Collection;
import java.util.Collections;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Iterator;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.Set;

import org.ahocorasick.trie.Emit;
import org.ahocorasick.trie.Trie;
import org.apache.log4j.Logger;

import gate.Annotation;
import gate.AnnotationSet;
import gate.Document;
import gate.FeatureMap;
import gate.Factory;
import gate.util.InvalidOffsetException;
import gate.util.OffsetComparator;

public class MatchMultipleWords {

	private Logger 	logger = Logger.getLogger(MatchMultipleWords.class);
	
	private Document processedGateDocument;
	private Document toAddAnnotationDocument;
	
	private Map <Long,GateOffset> offsetMap = new LinkedHashMap <Long,GateOffset> ();
	private String textToSearch ;
	private List<MultiWordUnit> multiWordList ;
	private Map<String,Integer> multiWordMap;
	
	
	private String fieldToMatch; //lemma or string

	
	public void setAnDocument (Document toAddAnnotationDocument)
	{
		this.toAddAnnotationDocument=toAddAnnotationDocument;
	}
	
	public void setFieldToMatch (String fieldToMatch)
	{
		this.fieldToMatch=fieldToMatch;
	}
	
	public void setMultipleWordList(List<MultiWordUnit> multiWordList) {
		this.multiWordList = multiWordList;
		textToSearch="";
	}

	
	public void setDocument (Document processedGateDocument)
	{
		this.processedGateDocument=processedGateDocument;
	}

	

	/**
	 * It Constructs the offset Mapping between the offsets of tokens and lemmas in the String to be matched using Aho-Corasick and the Offsets
	 * of the tokens in the GATE processed text.
	 * @param annotationName (string or root)
	 */
	private void offsetMapping (String annotationName,String featureName)
	{
		AnnotationSet defaultAs = processedGateDocument.getAnnotations();

		Set <String> toProcess= new HashSet<String> ();
		toProcess.add(annotationName);

		AnnotationSet tokensToProcess = defaultAs.get(toProcess);

		//Of course you should sort the tokens by Offset...
		List <Annotation> tokenSortList = new ArrayList<Annotation>(tokensToProcess);
		Collections.sort(tokenSortList, new OffsetComparator());

		long startAhoOffset=0;
		long endAhoOffset=0;

		for (Iterator<Annotation> it = tokenSortList.iterator(); it.hasNext(); )
		{
			Annotation tokenAnnotation=it.next();

			Long startGateOffset=tokenAnnotation.getStartNode().getOffset();
			Long endGateOffset=tokenAnnotation.getEndNode().getOffset();

			FeatureMap annotationFeaturesMap =tokenAnnotation.getFeatures();
			if (annotationFeaturesMap.containsKey(featureName))
			{
				startAhoOffset =textToSearch.length();
				
				String fText=annotationFeaturesMap.get(featureName).toString();
				
				
				textToSearch+=fText;
				endAhoOffset=textToSearch.length()-1;
				textToSearch+=" ";
				
				if (startAhoOffset!=endAhoOffset)
				{
					GateOffset goStart = new GateOffset();
					GateOffset goEnd = new GateOffset();
					
					goStart.setBegGateOffset(startGateOffset);
					goEnd .setEndGateOffset(endGateOffset);
					
					offsetMap.put(startAhoOffset, goStart);
					offsetMap.put(endAhoOffset, goEnd);
				}
				else //when you have only one character, for example "y" end and start Aho Offset coincide.
				{
					GateOffset goOne = new GateOffset();
					goOne.setBegGateOffset(startGateOffset);
					goOne .setEndGateOffset(endGateOffset);
					offsetMap.put(startAhoOffset, goOne);
				}
				
				
			}

		}

	}

	private Trie buildTrie ()
	{
		Trie trie = new Trie();    
		trie.onlyWholeWords();
		trie.caseInsensitive();
		trie.removeOverlaps();

		for (String mw:multiWordMap.keySet())
		{
			trie.addKeyword(mw);
		}

		return trie;
	}
	
	private String getFormToMatch (MultiWordUnit mwu)
	{
		String formToMatch="";
		if (fieldToMatch.compareTo("lemma")==0)
		{
			formToMatch =mwu.getLemma();
		}
		else
		{
			formToMatch =mwu.getString();
		}
		return formToMatch;	
	}
	
	/**
	 * Make a map matching the multiple words (which should be unique) with the index in the initial multiple word list.
	 */
	private void getMultipleWordsMap ()
	{
		multiWordMap = new LinkedHashMap <String,Integer> ();
		int index=-1;
		for (MultiWordUnit mwu:multiWordList)
		{
			index++;
			String formToMatch =getFormToMatch (mwu);
			multiWordMap.put(formToMatch, index);
			
		}
	}
	
	/*
	private int singleWordPosition (String keyword)
	{
		int sWp=0;
		
		String [] components =keyword.split(" ");
		int lastIndex=components.length-1;
		if ( (components[0].length()==1) && ((components[lastIndex].length()==1) ))
		{
			sWp=1;
		}
		else if ((components[0].length()==1))
		{
			sWp=2;
		}
		else if ((components[lastIndex].length()==1))
		{
			sWp=3;
		}
			
		return sWp;
	}
	*/
	
	private GateOffset getGateOffsets(long startAhoOffset, long endAhoOffset, String keyword)
	{
		GateOffset goAnswer = new GateOffset ();
		long startGateOffset =offsetMap.get(startAhoOffset).getBegGateOffset();
		long endGateOffset=offsetMap.get(endAhoOffset).getEndGateOffset();
		
		goAnswer.setBegGateOffset( startGateOffset);
		goAnswer.setEndGateOffset(endGateOffset);

		return goAnswer;
	}
	

/**
 * @param inputAnnotationName = Normally you look for annotation of type token
 * @param inputFeatureName       = The feature name to match {either "string" or "root" corresponding to (word) or (word lemma) }
 */
	public void matchMWords ( String inputAnnotationName , String inputFeatureName, String outputAnnotationSetName,String outputAnnotationName,String type) {
		
		
		//logger.debug("Register the occurences of the keywords in the text.");
		
		Map <String, Integer> occurencesMap = new HashMap <String, Integer>();
		
		//logger.debug ("Match the Multiple Words (selected word or lemma) with their Index in the multiword list.");
		getMultipleWordsMap();
		
		//logger.debug ("Buld the trie using the keywords in the Map");
		Trie trie=buildTrie ();
		
		//logger.debug(" It builds a mapping between the offset in the text made up for matching to the offsets in the initial text processed by GATE");
		offsetMapping(inputAnnotationName,inputFeatureName);

		AnnotationSet outputAnSet = toAddAnnotationDocument.getAnnotations(outputAnnotationSetName);

		Collection<Emit> emits = trie.parseText(textToSearch);
		int id=0;
		for (Emit emit:emits)
		{
			long startAhoOffset=emit.getStart();
			long endAhoOffset=emit.getEnd();
			String keyword=emit.getKeyword();
		
			if ((offsetMap.containsKey(startAhoOffset)) && (offsetMap.containsKey(endAhoOffset)))
			{
				id++;
				GateOffset go =getGateOffsets(startAhoOffset, endAhoOffset, keyword);
				long startGateOffset=go.getBegGateOffset();
				long endGateOffset=go.getEndGateOffset();

				int index=multiWordMap.get(keyword);
				
				String definition=multiWordList.get(index).getDefinition();
				String wikipediaURL=multiWordList.get(index).getWikipediaURL();
				FeatureMap mwFeaturesMap = Factory.newFeatureMap();
				
				if (occurencesMap.containsKey(keyword))
				{
					int backId=occurencesMap.get(keyword);
					mwFeaturesMap.put("wordIndexId", backId);
					
				}
				else
				{
					occurencesMap.put(keyword, id);
					mwFeaturesMap.put("definition", definition);
					mwFeaturesMap.put("token",keyword );
					mwFeaturesMap.put("Type",type );
					
					if (wikipediaURL.compareToIgnoreCase("")!=0)
					{
						mwFeaturesMap.put("wikipediaURL",wikipediaURL);
					}
								
				}
				try {
					
					//this can happen when Aho Corasick matches in the middle of a word and then a -1 offset is added (eg 31 abril) is matched as 1 abril
					outputAnSet.add(id,startGateOffset,endGateOffset, outputAnnotationName,mwFeaturesMap);
					
				} catch (InvalidOffsetException e) {
					logger.error("Gate Invalid Offset Exception for:"+keyword);
					logger.error ("----Start Gate Offset:"+startGateOffset);
					logger.error ("----End Gate Offset:"+endGateOffset);
					
				}
				
			}
			else
			{
				logger.error("The start Offset found by the Aho-Corasick Algorithm it is not the same as the offset computed in OffsetMap\n"+"keyword:"+keyword+"\n"+"startAhoOffset:"+startAhoOffset+"\nendAhoOffset:"+endAhoOffset);
			}
			
			
		}

	}

}
