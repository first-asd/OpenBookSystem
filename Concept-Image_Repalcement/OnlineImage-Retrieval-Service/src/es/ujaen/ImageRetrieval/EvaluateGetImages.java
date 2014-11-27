package es.ujaen.ImageRetrieval;

import java.io.File;
import java.io.IOException;
import java.util.HashSet;
import java.util.LinkedHashMap;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;

import org.apache.commons.io.FileUtils;
import org.apache.log4j.Logger;
import org.apache.lucene.queryParser.ParseException;

import es.ujaen.ReadLemmaAS.ConcepsForAnnotationSet;
import gate.util.GateException;

public class EvaluateGetImages {

	private static String directory="/Users/Eduard/Documents/MyPerlCode/FirstRelatedScripts/Evaluation/EvaluationGoogleAndBingImages/Spanish/adultsAlicanteTerms-Selected/";
	private static Map<String, String> termsMap;
	private static Logger logger = Logger.getLogger(TestGetImagesWS.class);
	
	private static String googleUserId="002103302136131223857:hwrl8d052ja";
	private static  String googlePassword="AIzaSyBJnDbJarykCu_c6fZtwvlzsgxNB33gpwg";
	
	private static String bingUserId="ceff1442-ee3c-4419-86f9-9840a763ca8e";
	private static String bingPassword="puiVzE+DbYMYtxytKmblkhVm6QcAtFbAHPE+/yjXjkY=";

	private static  void readQueries ()
	{
		termsMap = new LinkedHashMap<String, String>();
		termsMap.put("worker", "en");
		termsMap.put("obrero", "es");
	   
		//myTestMap.put("GGGGGGXXXXZZZZZZ", "en");
	}
	
	
	private static  void readFileTerms (String languageCode) throws IOException
	{
		termsMap = new LinkedHashMap<String, String>();
		String termFileDirectory="/Users/Eduard/Documents/MyPerlCode/FirstRelatedScripts/Evaluation/EvaluationGoogleAndBingImages/Spanish/adultsAlicanteTerms-Selected/";
		String termFilePath =termFileDirectory +"termstext6.txt" ;
		List <String> terms=FileUtils.readLines(new File(termFilePath), "UTF-8");
		for (String term:terms)
		{
			termsMap.put(term, languageCode);
		}
	}
	
	
	private static void  printResponse (Set <String> lines) throws IOException
	{
		String fileTerms=directory+"termsImages.txt";
		FileUtils.writeLines(new File(fileTerms), "UTF-8" ,lines,false);
	}

	public static void main(String[] args) throws IOException, ParseException, GateException {
		
       //readQueries();
	   readFileTerms ("es");
       GetImagesWS ws = new GetImagesWS ();
       Set <String> lines = new LinkedHashSet<String>();
       
       for (String term:termsMap.keySet())
       {
    	   lines.add("Concept:"+term);
    	   String languageCode=termsMap.get(term);
    	   logger.debug("Extract image URL's for the concept:"+term+" in language:"+languageCode);
    	   
    	   String [] serviceResponse=ws.getImageURL(term, languageCode,googleUserId,googlePassword,bingUserId,bingPassword);
    	   if (serviceResponse == null)
    	   {
    		   logger.debug ("The Service couldn't find any image for the concept:"+term);
    	   }
    	   //In the case of ImageNet I output a set of images (index in the array) for each sense of the word.
    	   else
    	   {
    		   for (int i=0;i<serviceResponse.length;i++)
    		   {
    			  lines.add(serviceResponse[i]);
    			}
    		  
    		 }
    	   }
       printResponse (lines); 
       }
	}
