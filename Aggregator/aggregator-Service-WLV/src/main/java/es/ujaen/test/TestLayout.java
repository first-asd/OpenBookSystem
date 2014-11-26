package es.ujaen.test;

import java.io.File;
import java.io.IOException;

import org.apache.commons.io.FileUtils;
import org.apache.log4j.Logger;

import es.ujaen.aggregator.GateOperations;
import es.ujaen.aggregator.Layout;
import es.ujaen.aggregator.Pipeline;
import gate.Document;
import gate.Factory;
import gate.Utils;
import gate.creole.ResourceInstantiationException;
import gate.util.GateException;

public class TestLayout {
	
	private static String inputDirectory ="/opt/dist/008_first/Aggregator/inputFiles/Layout/";
	private static String outputDirectory ="/opt/dist/008_first/Aggregator/inputFiles/Layout/";
	private static org.apache.log4j.Logger  log = Logger.getLogger(TestLayout.class);
	
	
	private static void writeFile (String docString,String fileName) throws IOException
	{
		String outputDirectory="/opt/dist/008_first/Aggregator/inputFiles/Layout/";
		String disambiguationFile = outputDirectory +fileName;
		FileUtils.write(new File(disambiguationFile), docString, "UTF-8");
	}

	private static Document readDocument (String gateDocumentString) throws ResourceInstantiationException
	{
		Document gateDocument= (Document) Factory.createResource("gate.corpora.DocumentImpl", Utils.featureMap("stringContent", gateDocumentString, "mimeType", "text/xml", "encoding", "UTF-8"));
		return gateDocument;
	}
	
	
	public static void main(String[] args) throws Exception {
		
		String inputFile=inputDirectory+"inputBulgarianSpecial-1.xml";	
		String gateString=FileUtils.readFileToString(new File(inputFile), "UTF-8");
		
		
		log.error("Start Pipeline");
		Pipeline pl = new Pipeline ();
		pl.initGate();
		Document doc=readDocument(gateString);
		
		/*
		log.error("Add Sentence Detection and Tokenization");
		GateOperations go = new GateOperations ();
		go.addExtraInfo(doc);
		writeFile(doc.toXml(),"inputEnglish-Proc-1.xml");
		*/
		
		log.error("Add the Layout Annotation Sets");
		Layout layout = new Layout ();
		layout.addLayout(doc);
		writeFile(doc.toXml(),"inputBulgarianSpecial-Final-1.xml");
		
	}

}
