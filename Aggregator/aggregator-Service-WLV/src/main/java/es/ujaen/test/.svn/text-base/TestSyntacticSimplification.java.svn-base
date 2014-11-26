package es.ujaen.test;

import es.ujaen.aggregator.GateOperations;
import es.ujaen.aggregator.Pipeline;
import es.ujaen.clients.CoreferenceSpanishClient;
import gate.Annotation;
import gate.AnnotationSet;
import gate.Document;
import gate.Factory;
import gate.FeatureMap;
import gate.Utils;
import gate.creole.ResourceInstantiationException;

import java.io.File;
import java.rmi.RemoteException;

import org.apache.commons.io.FileUtils;
import org.apache.log4j.Logger;

import ujaen.es.clients.AnaphoraResolutionExceptionException;

public class TestSyntacticSimplification {
	

	private static Logger logger = Logger.getLogger(TestSyntacticSimplification.class);
	private static String inputDirectory ="/opt/dist/008_first/Aggregator/inputFiles/";
	private static String outputDirectory ="/opt/dist/008_first/Aggregator/inputFiles/";
	
	
	private static Document readDocument (String gateDocumentString) throws ResourceInstantiationException
	{
		Document gateDocument= (Document) Factory.createResource("gate.corpora.DocumentImpl", Utils.featureMap("stringContent", gateDocumentString, "mimeType", "text/xml", "encoding", "UTF-8"));
		return gateDocument;
	}

	public static void main(String[] args) throws Exception
	{
		String inputFile=inputDirectory+"texto1-Simplified.xml";	
		
		//Initiate Gate
		Pipeline pl = new Pipeline ();
		pl.initGate();
		
		//Read the Document
		String gateInputString=FileUtils.readFileToString(new File(inputFile), "UTF-8");
		Document gateDocument= readDocument (gateInputString);
		
		//Add the Tokenization and SentenceDetection Annotation Sets.
		GateOperations go = new GateOperations();
		go.addExtraInfo(gateDocument);
		go.spanishSentenceDetection(gateDocument);
		
		
		String coreferenceOutputFile = outputDirectory +"texto1-Simplified-Sentence.xml";
		FileUtils.write(new File(coreferenceOutputFile), gateDocument.toXml(), "UTF-8");
	}


}
