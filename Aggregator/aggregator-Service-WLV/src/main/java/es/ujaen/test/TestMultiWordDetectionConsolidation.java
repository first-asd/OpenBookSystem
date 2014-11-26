package es.ujaen.test;

import java.io.File;

import org.apache.commons.io.FileUtils;
import org.apache.log4j.Logger;

import es.ujaen.aggregator.GateOperations;
import es.ujaen.aggregator.Pipeline;
import gate.Document;
import gate.Factory;
import gate.Utils;
import gate.creole.ResourceInstantiationException;

/**
 * The Program tests the Consolidation of the Multi-Word detection and Idiom detection sets. 
 * @author Eduard
 */
public class TestMultiWordDetectionConsolidation {
	
	private static Logger logger = Logger.getLogger(TestMultiWordDetectionConsolidation.class);
	
	private static String inputDirectory ="/opt/dist/008_first/MultiWordDetection/outputFiles/";
	private static String outputDirectory ="/opt/dist/008_first/MultiWordDetection/outputFiles/";
	
	
	private static Document readDocument (String gateDocumentString) throws ResourceInstantiationException
	{
		Document gateDocument= (Document) Factory.createResource("gate.corpora.DocumentImpl", Utils.featureMap("stringContent", gateDocumentString, "mimeType", "text/xml", "encoding", "UTF-8"));
		return gateDocument;
	}

	public static void main(String[] args) throws Exception
	{
		String inputFile=inputDirectory+"texto-Overlap-Output-1.xml";	
		
		//Initiate Gate
		Pipeline pl = new Pipeline ();
		pl.initGate();
		
		//Read the Document
		String gateInputString=FileUtils.readFileToString(new File(inputFile), "UTF-8");
		Document gateDocument= readDocument (gateInputString);
		
		//Add the Tokenization and SentenceDetection Annotation Sets.
		GateOperations go = new GateOperations();
		go.consolidateSets(gateDocument);
		
		logger.error("Consolidate the Idiom Detection Annotation Sets ");
		String consolidatedSetFile = outputDirectory +"consolidatedSet.xml";
		FileUtils.write(new File(consolidatedSetFile), gateDocument.toXml(), "UTF-8");
	}


}
	


