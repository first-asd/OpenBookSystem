package es.ujaen.test;

import es.ujaen.sinai.first.BasicProcessing;
import gate.AnnotationSet;
import gate.Document;
import gate.Factory;
import gate.FeatureMap;
import gate.Gate;
import gate.Utils;
import gate.creole.ResourceInstantiationException;
import gate.util.GateException;

import java.io.File;
import java.io.IOException;

import org.apache.commons.io.FileUtils;

public  class TestBug {
	
	private static boolean gateInited=false;
	private static String gateInputFilePath ="/opt/dist/008_first/Summarizer/intermediary/processedBulgarian.xml";
	
	private static void initGateStandAlone () throws GateException
	{
		if (!gateInited)
		{
			String gateHome=BasicProcessing.class.getResource("/WEB-INF/").getPath();
			Gate.setGateHome(new File(gateHome));
			Gate.init();
			gateInited=true;
		}
	}
	
	private static Document readDocument (String gateDocumentString) throws ResourceInstantiationException
	{
		Document gateDocument= (Document) Factory.createResource("gate.corpora.DocumentImpl", Utils.featureMap("stringContent", gateDocumentString, "mimeType", "text/xml", "encoding", "UTF-8"));
		return gateDocument;
	}

	public static void main(String[] args) throws GateException, IOException {
		String gateInputString=FileUtils.readFileToString(new File(gateInputFilePath ), "UTF-8");
		initGateStandAlone ();
		
		Document gateDocument=readDocument (gateInputString);
		
		AnnotationSet defaultAS = gateDocument.getAnnotations();
		
		AnnotationSet tokenAnnotation=defaultAS .get("Token",Factory.newFeatureMap());
		AnnotationSet sentenceAnnotation=defaultAS.get("Sentence",Factory.newFeatureMap());
		System.out.println("Finish");
	
	}

}
