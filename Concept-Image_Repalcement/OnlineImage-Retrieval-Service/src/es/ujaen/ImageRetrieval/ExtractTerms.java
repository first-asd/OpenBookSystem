package es.ujaen.ImageRetrieval;

import java.io.File;
import java.io.IOException;
import java.net.MalformedURLException;
import java.util.LinkedHashMap;

import org.apache.commons.io.FileUtils;

import es.ujaen.ReadLemmaAS.ConcepsForAnnotationSet;
import gate.util.GateException;

public class ExtractTerms {
	
	private static String directory="/Users/Eduard/Documents/MyPerlCode/FirstRelatedScripts/Evaluation/EvaluationGoogleAndBingImages/Spanish/adultsProcessed/";
	private static String fileTestPath =directory+"texto6.xml";

	private static void  printWordsForDocument (LinkedHashMap<String,String> termsMap) throws IOException
	{
		String fileTerms=directory+"terms.txt";
		FileUtils.writeLines(new File(fileTerms), "UTF-8" ,termsMap.keySet(),false);
	}
	
	public static void main(String[] args) throws GateException, IOException {
		ConcepsForAnnotationSet cas = new ConcepsForAnnotationSet ();
		cas.setFilePath (fileTestPath);
		cas.setEncoding("UTF-8");
		cas.constructDocument();
		
		LinkedHashMap<String,String> termsMap =cas.getTerms("es");
		printWordsForDocument (termsMap) ;

	}

}
