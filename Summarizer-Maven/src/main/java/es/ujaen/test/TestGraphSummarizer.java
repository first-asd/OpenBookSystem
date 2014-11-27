package es.ujaen.test;


import es.ujaen.first.summarizer.GateOperations;
import es.ujaen.first.summarizer.Summarizer;
import es.ujaen.first.summarizer.SummarizerFactory;
import gate.Document;
import gate.Factory;
import gate.Utils;
import gate.creole.ResourceInstantiationException;

import java.io.File;
import java.util.List;

import org.apache.commons.io.FileUtils;
import org.apache.log4j.Logger;

public class TestGraphSummarizer {

	private static String gateInputFilePath =TestGraphSummarizer.class.getResource("/input/en/inputEnglish-1-Linguistic.xml").getPath();
	private static Logger logger = Logger.getLogger(TestGraphSummarizer.class);

	private static Document buildGateDocument(String gateInputString) throws ResourceInstantiationException {
		Document gateDocument= (Document) Factory.createResource("gate.corpora.DocumentImpl", Utils.featureMap("stringContent", gateInputString, "mimeType", "text/xml", "encoding", "UTF-8"));
		return gateDocument;
	}
	
	public static void main(String[] args) throws Exception {
		
		GateOperations go = new GateOperations ();
		go.initGate();
		String gateInputString=FileUtils.readFileToString(new File(gateInputFilePath ), "UTF-8");
		Document gateInputDocument=buildGateDocument(gateInputString);
		
		SummarizerFactory sf = new SummarizerFactory();
		Summarizer gs=sf.getSummarizer("GRAPH", "en");
		gs.setDocument(gateInputDocument);
		gs.summarize();
		
		List<String> extractList=gs.getSummary(10);
		
		logger.debug("Summary:");
		for (String sentence:extractList)
		{
			logger.debug(sentence);
		}
		
	}

}
