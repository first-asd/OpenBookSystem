package es.ujaen.test;

import es.ujaen.aggregator.Pipeline;
import es.ujaen.clients.CoreferenceSpanishClient;
import es.ujaen.clients.SyntaxSpanishClientUA;
import es.ujaen.clients.SyntaxSpanishClientUJ;
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

public class TestSyntacticSimplificationSpanishStandalone {
	
	private static String inputDirectory ="/opt/dist/008_first/Aggregator/inputFiles/";
	private static String outputDirectory ="/opt/dist/008_first/Aggregator/inputFiles/";

	private static String parameters = "{\"languageCode\":\"es\"}";
	private static Logger logger = Logger.getLogger(TestSyntacticSimplificationSpanishStandalone.class);
	private static  int connectionReadTimeout=5*60*1000 ; 
	
	private static Document readDocument (String gateDocumentString) throws ResourceInstantiationException
	{
		Document gateDocument= (Document) Factory.createResource("gate.corpora.DocumentImpl", Utils.featureMap("stringContent", gateDocumentString, "mimeType", "text/xml", "encoding", "UTF-8"));
		return gateDocument;
	}

	private static  String getSpanishSyntaxUJResponse (String gateInputString, String parameters) throws Exception 
	{
		SyntaxSpanishClientUJ sc = new SyntaxSpanishClientUJ();
		sc.setConnectionTimeout(connectionReadTimeout);
		logger.error("Get the Syntax Spanish UJ Client Response:");
		
		long startTime = System.currentTimeMillis();
		String gateResponse =sc.getClientResponse(gateInputString, parameters);
		long estimatedTime = System.currentTimeMillis() - startTime;
		logger.error("Syntax Spanish UJ Time:"+estimatedTime);
		logger.debug("Finish Syntax UJ");
		
		return gateResponse;
	}
	
	
	private static  String getSpanishSyntaxUAResponse (String gateInputString, String parameters) throws Exception 
	{
		SyntaxSpanishClientUA sc = new SyntaxSpanishClientUA();
		sc.setConnectionTimeout(connectionReadTimeout);
		logger.error("Get the Syntax Spanish UA Client Response:");
		
		long startTime = System.currentTimeMillis();
		String gateResponse =sc.getClientResponse(gateInputString, parameters);
		long estimatedTime = System.currentTimeMillis() - startTime;
		logger.error("Syntax Spanish UA Time:"+estimatedTime);
		logger.debug("Finish Syntax UA");
		
		return gateResponse;
	}
	    
	    

	public static void main(String[] args) throws Exception
	{
		String inputFile=inputDirectory+"inputSpanish-Syntax-I.xml";	
		
		Pipeline pl = new Pipeline ();
		pl.initGate();
		
		String gateInputString=FileUtils.readFileToString(new File(inputFile), "UTF-8");
		
		String syntaxUJString=getSpanishSyntaxUJResponse (gateInputString, parameters);
		String coreferenceJaenOutputFile = outputDirectory +"outputSpanish-Syntax-I-UJ.xml";
		FileUtils.write(new File(coreferenceJaenOutputFile), syntaxUJString, "UTF-8");
		
		
		String syntaxUAString=getSpanishSyntaxUAResponse (syntaxUJString, parameters);
		

		String coreferenceAlicanteOutputFile = outputDirectory +"outputSpanish-Syntax-I-UA.xml";
		FileUtils.write(new File(coreferenceAlicanteOutputFile), syntaxUAString, "UTF-8");
	}

}
