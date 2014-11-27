package es.ujaen.ImageRetrieval;

import java.io.IOException;
import java.util.LinkedHashMap;
import java.util.Map;

import org.apache.log4j.Logger;
import org.apache.lucene.queryParser.ParseException;

public class TestGetImagesWS {

	private static Map<String, String> myTestMap;
	private static Logger logger = Logger.getLogger(TestGetImagesWS.class);
	
	private static String googleUserId="002103302136131223857:hwrl8d052ja";
	private static  String googlePassword="AIzaSyBJnDbJarykCu_c6fZtwvlzsgxNB33gpwg";
	
	private static String bingUserId="ceff1442-ee3c-4419-86f9-9840a763ca8e";
	private static String bingPassword="puiVzE+DbYMYtxytKmblkhVm6QcAtFbAHPE+/yjXjkY=";

	private static  void readQueries ()
	{
		myTestMap = new LinkedHashMap<String, String>();
		myTestMap.put("worker", "en");
		myTestMap.put("obrero", "es");
	   
		//myTestMap.put("GGGGGGXXXXZZZZZZ", "en");
	}
	

	public static void main(String[] args) throws IOException, ParseException {

       readQueries();
       GetImagesWS ws = new GetImagesWS ();
       
       for (String concept:myTestMap.keySet())
       {
    	   String languageCode=myTestMap.get(concept);
    	   logger.debug("Extract image URL's for the concept:"+concept+" in language:"+languageCode);
    	   
    	   String [] serviceResponse=ws.getImageURL(concept, languageCode,googleUserId,googlePassword,bingUserId,bingPassword);
    	   if (serviceResponse == null)
    	   {
    		   logger.debug ("The Service couldn't find any image for the concept:"+concept);
    	   }
    	   //In the case of ImageNet I output a set of images (index in the array) for each sense of the word.
    	   else
    	   {
    		   for (int i=0;i<serviceResponse.length;i++)
    		   {
    			   logger.debug (serviceResponse[i]); 
    			}
    			   
    		   }
    	   }
       }
	}
