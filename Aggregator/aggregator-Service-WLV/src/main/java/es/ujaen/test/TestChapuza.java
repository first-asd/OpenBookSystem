package es.ujaen.test;

import es.ujaen.aggregator.GateOperations;
import gate.Document;
import gate.Factory;
import gate.Gate;
import gate.Utils;
import gate.creole.ResourceInstantiationException;
import gate.util.GateException;

import java.io.File;

import org.apache.commons.io.FileUtils;

public class TestChapuza {
	
	private static String inputDirectory ="/opt/dist/008_first/Aggregator/outputFiles/chapuzaFiles/";
	private static String outputDirectory ="/opt/dist/008_first/Aggregator/outputFiles/chapuzaFiles/";
	private static boolean gateInited =false;
	
	private static void initGateStandAlone () throws GateException
	{
		if (!gateInited)
		{
			Gate.setGateHome(new File("/Applications/GATE_Developer_7.0/"));
			Gate.init();
			gateInited=true;
		}

	}
	
	private static Document readDocument (String gateDocumentString) throws ResourceInstantiationException
	{
		Document gateDocument= (Document) Factory.createResource("gate.corpora.DocumentImpl", Utils.featureMap("stringContent", gateDocumentString, "mimeType", "text/xml", "encoding", "UTF-8"));
		return gateDocument;
	}
	
	public static void main(String[] args) throws Exception 
	{
		String inputFile=inputDirectory+"inputEnglish-1.xml";	
		initGateStandAlone (); 
		
		String gateDocumentString=FileUtils.readFileToString(new File(inputFile), "UTF-8");
		Document gateDocument = readDocument (gateDocumentString);
		
		GateOperations go = new GateOperations ();
		go.chapuza(gateDocument);
		
		String chapuzaFile = outputDirectory +"outputEnglishIdiom-1.xml";
		FileUtils.write(new File(chapuzaFile), gateDocument.toXml(), "UTF-8");
	
}
}
