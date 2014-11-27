package es.ujaen.first.summarizer;

import gate.Annotation;
import gate.AnnotationSet;
import gate.Document;
import gate.Factory;
import gate.util.InvalidOffsetException;
import gate.util.OffsetComparator;

import java.io.BufferedReader;
import java.io.FileReader;
import java.text.DecimalFormat;
import java.util.ArrayList;
import java.util.Collections;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Iterator;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.Properties;
import java.util.Set;

import org.apache.log4j.Logger;
import org.jgrapht.graph.DefaultWeightedEdge;
import org.jgrapht.graph.SimpleWeightedGraph;

/**
 * An implementation of the pure graph based summarizer. 
 * Unlike the other implementation this does not computes a score for the position of sentences  
 * @author Eduard
 */
public class PureGraphSummarizer implements Summarizer {
	private Document gateDocument;

	private Properties properties;

	private Map<Integer,String> sentencesMap;
	private Map<Integer,String> sentenceRepMap;
	
	
	private Map <Integer,Double> positionScoreMap;
	private Map<Integer, Double> curVertexWeights ;
	private Map<Integer, Double> antVertexWeights;
	private Map<Integer,Double> finalScoreMap;



	private  SimpleWeightedGraph<Integer, DefaultWeightedEdge> sentenceGraph;


	private static Logger logger = Logger.getLogger(GraphSummarizer.class);

	
	public void setDocument (Document gateDocument)
	{
		this.gateDocument=gateDocument;
	}
	
	
	public PureGraphSummarizer (String configurationFile)
	{
		readConfigurationFile (configurationFile);
	}


	private void readConfigurationFile (String configurationFile) 
	{
		try {
			properties = new Properties();
			properties.load(new BufferedReader(new FileReader(configurationFile)));
			logger.debug("Loaded Summarizer Configuration File");
		} catch (Exception e) {
			logger.error("Error loading summarizer configuration file"+e);
		} 
	}

	private boolean isSelected (String pos, String lemma,String[] selectors)
	{
		if (lemma.length()>=3)
		{
			for (String selector:selectors)
			{
				if (pos.matches(selector))
				{
					return true;
				}
			}
		}
		return false;
	}


	private void computeSentenceRepresentation() 
	{
		sentenceRepMap=new LinkedHashMap <Integer,String> ();
		sentencesMap=new LinkedHashMap <Integer,String> ();

		String [] selectors=properties.getProperty("selectors").split("\\t");
		
		AnnotationSet defaultAS = gateDocument.getAnnotations();

		AnnotationSet sentenceAnnotation=defaultAS.get("Sentence",Factory.newFeatureMap());

		List <Annotation> sentenceSortList = new ArrayList<Annotation>(sentenceAnnotation);
		Collections.sort(sentenceSortList, new OffsetComparator());

		AnnotationSet tokenAnnotation=defaultAS .get("Token",Factory.newFeatureMap());

		//Get Sentences
		int sNumber=0;
		for (Annotation curSentenceAnnotation:sentenceSortList  ) {
			sNumber++;
			String curSentenceRep="";
			String curSentence="";
			Long startSentenceOffset=curSentenceAnnotation.getStartNode().getOffset();
			Long endSentenceOffset=curSentenceAnnotation.getEndNode().getOffset();

			//Get Tokens in Sentence
			AnnotationSet tokensInSentence=tokenAnnotation.getContained(startSentenceOffset,endSentenceOffset);
			int nTokensInSentence=tokensInSentence.size();
			List <Annotation> tokenSortList = new ArrayList<Annotation>(tokensInSentence);
			Collections.sort(tokenSortList, new OffsetComparator());

			for (Annotation curTokenAnnotation:tokenSortList   )
			{
				String pos = curTokenAnnotation.getFeatures().get("category").toString();

				String tokenLemma=curTokenAnnotation.getFeatures().get("root").toString();
				String tokenString;
				try {
					tokenString = gateDocument.getContent().getContent(curTokenAnnotation.getStartNode().getOffset(), curTokenAnnotation.getEndNode().getOffset()).toString();
					curSentence+=tokenString+" ";
					if (isSelected (pos,tokenLemma,selectors))
					{
						curSentenceRep+=tokenLemma+" ";
					}

				} catch (InvalidOffsetException e) {
					logger.error("Error:"+e);
				}

				
			}

			curSentenceRep=curSentenceRep.trim();
			curSentence=curSentence.trim();
			
			int minNWords=Integer.parseInt(properties.get("minDimensionOfSentence").toString());
			int maxNWords=Integer.parseInt(properties.get("maxDimensionOfSentence").toString());
			
			if ((nTokensInSentence>=minNWords) && (nTokensInSentence<=maxNWords))
			{
				sentencesMap.put(new Integer(sNumber), curSentence);
				if (!curSentenceRep.equalsIgnoreCase(""))
				{
					sentenceRepMap.put(new Integer(sNumber), curSentenceRep);
				}
			}
			
		
		}

	}


	private void computePositionScore()
	{
		positionScoreMap=new LinkedHashMap<Integer, Double>();
		
		//All should be double for correct Division.
		double maxScore = 1.0;
		double nOfSentences=sentencesMap.size();
		double index=-1;
		for (Integer i:sentencesMap.keySet())
		{
			++index;
			double currentSentenceScore = ((nOfSentences - index) / nOfSentences) * maxScore;
			positionScoreMap.put(i, currentSentenceScore);
		}
	}


	private void registerScores ()
	{
		DecimalFormat df = new DecimalFormat("#.##");
		
		String finalScoreString="";
		String positionScoreString="";
		String graphScoreString="";
		
		for (Integer i:finalScoreMap.keySet())
		{
			finalScoreString+=df.format(finalScoreMap.get(i))+"#";
			positionScoreString+=df.format(positionScoreMap.get(i))+"#";
			if (curVertexWeights.containsKey(i))
			{
				graphScoreString+=df.format(curVertexWeights.get(i))+"#";
			}
			else
			{
				graphScoreString+="ndef#";
			}
		}
		logger.debug("Graph Score:"+graphScoreString);
		logger.debug("Position Score:"+positionScoreString);
		logger.debug("Final Score:"+finalScoreString);
	}
	
	/**
	 * Computes the final score of sentences as a combination between graph scores and position scores.
	 */
	private void computeFinalSentenceScore()
	{
		finalScoreMap=new LinkedHashMap <Integer,Double> ();
		for (Integer i:positionScoreMap.keySet())
		{
			double finalScore=positionScoreMap.get(i);
			if (curVertexWeights.containsKey(i))
			{
				finalScore+=curVertexWeights.get(i);
			}
			finalScoreMap.put(i, new Double(finalScore));
		}
		registerScores ();
	}

	public void summarize () 
	{
		computeSentenceRepresentation();
		sentenceGraph =new SimpleWeightedGraph<Integer, DefaultWeightedEdge>(DefaultWeightedEdge.class); 
		buildGraph();
		graphRanking();
		computePositionScore();
		computeFinalSentenceScore();

	}
	
	private Map <Double,Integer> getMap (	List <Double> relevantScoreList)
	{
		Map <Double,Integer> relevantScoreMap = new HashMap <Double,Integer>  ();
		for (Double score:relevantScoreList)
		{
			relevantScoreMap.put(score, 0);
		}
		return relevantScoreMap;
	}
	
	private Map<Double,Integer> getOrderedScoresMap (int nSentences)
	{
		List<Double> orderedScoreList =new ArrayList<Double>();
		for (Integer i:curVertexWeights.keySet())
		{
			orderedScoreList.add(curVertexWeights.get(i));
		}
		Collections.sort(orderedScoreList,Collections.reverseOrder());
		List <Double> relevantScoreList=orderedScoreList.subList(0, nSentences);
		Map <Double,Integer> relevantScoreMap=getMap (relevantScoreList);
		return relevantScoreMap;
	}
	
	/**
	 * Get the summary for the document as a percent from the document
	 */
	public List <String> getSummary(double percent)
	{
		int totalSentences = curVertexWeights.size();
		long nSentences = Math.round(percent * totalSentences) + 1;
		return getSummary((int)nSentences);
	}
	
	/**
	 * Get summary as Fixed Number of Sentences.
	 */
	public List <String> getSummary(int nSentences)
	{
		ArrayList <String> extractList = new ArrayList <String>();
		
		Map <Double,Integer> relevantScoreMap = getOrderedScoresMap(nSentences);
		for (Integer i:curVertexWeights.keySet())
		{
			Double score=curVertexWeights.get(i);
			if (relevantScoreMap.containsKey(score))
			{
				extractList.add(sentencesMap.get(i));
			}
		}
		
		return extractList;
	}
	
	private void addVertexes ()
	{
		for (Integer i:sentenceRepMap.keySet() )
		{
			sentenceGraph.addVertex(i);
		}
	}
	
	private void addEdges ()
	{
		for (int i:sentenceRepMap.keySet())
		{
			String sentence1 = sentenceRepMap.get(i);
			for (int j:sentenceRepMap.keySet())
			{
				if (j>i)
				{
					String sentence2 = sentenceRepMap.get(j);
					double sim = Similarity.contentOverlap(sentence1, sentence2);
					if(sim > 0)
					{	
						DefaultWeightedEdge conEdge = sentenceGraph.addEdge(i, j);
						sentenceGraph.setEdgeWeight(conEdge, sim); 
					}
				}
				
			}
		}
		
	}

	/**
	 * Builds the similarity graph based on sentence representation
	 */
	private void buildGraph()
	{
		logger.debug("Graph Building ...");
		addVertexes ();
		addEdges ();
	}



	private void initGraphVertexWeights()
	{
		antVertexWeights  = new HashMap<Integer, Double>();
		for (Integer vertex:sentenceGraph.vertexSet())
		{
			antVertexWeights.put(vertex, new Double(1.01));
		}
		curVertexWeights  = new HashMap<Integer, Double>();
		registerCycle (antVertexWeights);
	}

	/**
	 * Computes the sum of the weights of edges that originate in a certain vertex
	 */

	private double computeWeightEdges(Integer vertex)
	{
		double sum=0;
		for (DefaultWeightedEdge curEdge :sentenceGraph.edgesOf(vertex))
		{
			double edgeWeight =sentenceGraph.getEdgeWeight(curEdge);
			sum+= edgeWeight;
		}
		return sum;
	}



	/**
	 * Checks if the converge condition for the graph is fulfilled
	 */

	private boolean evaluateConvergence( )
	{
		double diff;
		double currVertexWeight = 0;
		double prevVertexWeight = 0;
		Iterator<Integer> it = antVertexWeights.keySet().iterator();
		while(it.hasNext())
		{
			Integer key = it.next();
			currVertexWeight = curVertexWeights .get(key).doubleValue();
			prevVertexWeight = antVertexWeights.get(key).doubleValue();

			diff = Math.abs(currVertexWeight - prevVertexWeight);
			double threshold=Double.parseDouble(properties.get("threshold").toString());
			if(diff > threshold)
			{
				return false;
			}
		}
		return true;
	}
	
	
	private Set<Integer> getAllConnectedVertexes (Integer i)
	{
		Set <Integer> incomingVertexes = new HashSet <Integer> ();
		for ( DefaultWeightedEdge ji:sentenceGraph.edgesOf(i))
		{
			Integer startVertex =sentenceGraph.getEdgeSource(ji);
			Integer endVertex =sentenceGraph.getEdgeTarget(ji);
			if (startVertex.compareTo(i)==0)
			{
				incomingVertexes.add(endVertex);
			}
			else
			{
				incomingVertexes.add(startVertex);
			}
		}
		return incomingVertexes ;
	}
	
	
	private double getVertexWeight (Integer j)
	{
		if (curVertexWeights.containsKey(j))
		{
			return curVertexWeights.get(j);
		}
		return antVertexWeights.get(j);
	}
	

	private void computeVertexWeight (Integer i)
	{
		double d = 0.85;
		Set <Integer> incomingVertexes=getAllConnectedVertexes (i);
		
		double sum=0;
		for (Integer j:incomingVertexes)
		{
			double jVertexWeight=getVertexWeight(j);
			double jiWeight=sentenceGraph.getEdgeWeight(sentenceGraph.getEdge(i, j));
			double jEdgesWeight = computeWeightEdges(j);
			sum+=(jiWeight/jEdgesWeight)*jVertexWeight;
		}
		double iVertexWeight=(1-d)+d*sum;
		curVertexWeights.put(i, iVertexWeight);
	}
	
	private void registerCycle (Map<Integer, Double> vertexWeights)
	{
		String cycleString="";
		DecimalFormat df = new DecimalFormat("#.##");
		
		for (Integer i:vertexWeights.keySet())
		{
			cycleString+=df.format(vertexWeights.get(i))+"#";
		}
		
		logger.debug(cycleString);
	}
	
	
	private void updateWeights ()
	{
		Iterator<Integer> it = antVertexWeights.keySet().iterator();
		while(it.hasNext())
		{
			Integer key=it.next();
			Double currVertexWeight = curVertexWeights .get(key);
			antVertexWeights.put(key, currVertexWeight);
		}
	}

	private void graphRanking()
	{
		logger.debug("Graph Ranking ...");
		
		boolean isUnderTreshold = false;
		initGraphVertexWeights();

		while(isUnderTreshold == false)
		{
			for (Integer i: sentenceGraph.vertexSet())
			{
				computeVertexWeight (i);
			}
			
			registerCycle(curVertexWeights);
			isUnderTreshold = evaluateConvergence();
			updateWeights();
			
		}

	}
	
	
	

}
