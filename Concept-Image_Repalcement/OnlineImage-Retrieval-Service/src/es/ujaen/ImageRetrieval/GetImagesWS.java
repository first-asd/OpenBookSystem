package es.ujaen.ImageRetrieval;

import java.io.IOException;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.Map;

import org.apache.lucene.queryParser.ParseException;

import es.ujaen.ImageNet.SearchImages;
import es.ujaen.images.bing.BingClient;
import es.ujaen.images.common.QueryResponse;
import es.ujaen.images.google.GoogleClient;

/**
 * Extracts the relevant Images using Bing Searching Engine, Google Searching Engine and ImageNet database.
 * @author Eduard
 */

public class GetImagesWS {
	
	private static String googleConfigurationFilePath ="/opt/dist/008_first/onlineImageRetrieval/conf/confGoogle.cfg";
	private static String bingConfigurationFilePath ="/opt/dist/008_first/onlineImageRetrieval/conf/confBing.cfg";
	private static String terminator="#@#";
	private static int maxNbImg=3;
	 
    private Credential getCurrentCredential (ArrayList <Credential> credentials)
	{
		for (Credential curCredential:credentials)
		{
		   if (curCredential.isValidKey())
		   {
			   return curCredential;
		   }
		}
		return null;
	}
	
	
	private String getMarketValue (String language)
	{
		String market="en-US";
		if (language.equals("es"))
		{
			market="es-ES";
		}
		if (language.equals("bg"))
		{
			market="bg-BG";
		} 
		
		return market;
	}
	
	
	private  ArrayList<QueryResponse> getBingImages (Credential curBingCredential, String queryText, String language)
	{
		ArrayList<QueryResponse> queryResponses=new ArrayList<QueryResponse> ();
		try
		{
			//if (i%2==0) throw new IOException("Induced Bing Exception"); 
			BingClient bc = new BingClient();
			bc.setGoogleEngineParameters(curBingCredential.getUserId(), curBingCredential.getPassword());
			bc.setAccountKey();
			String market=getMarketValue(language);
			bc.setBingURL(queryText,market);
			
			queryResponses=bc.getImages(queryText);
		}
		
		catch (IOException e) {
			curBingCredential.setValidKey(false);
			String message =e.getMessage();
			System.out.println (message);
			e.printStackTrace();
		}       

		return queryResponses;
	}
	
	
	private   ArrayList<QueryResponse> getGoogleImages (Credential curGoogleCredential, String query,String language)
	{
		ArrayList<QueryResponse> queryResponses=new ArrayList<QueryResponse> ();
		String googleLanguage ="lang_"+language;
		try
		{
			//if (i%2==0) throw new IOException("Induced Google Exception"); 
			GoogleClient gc = new GoogleClient();
			gc.setGoogleEngineParameters(curGoogleCredential.getPassword(),curGoogleCredential.getUserId(),googleLanguage );
			gc.setGoogleURL(query, "1");
			queryResponses=gc.getImageAnswers(query);
		}
		catch (IOException e) {
			curGoogleCredential.setValidKey(false);
			String message =e.getMessage();
			System.out.println (message);
			e.printStackTrace();
		}       
		return queryResponses;
	}
	
	
	private String[] agregateImages (ArrayList<QueryResponse> bingQueryResponseList,ArrayList<QueryResponse> googleQueryResponseList,String[] imageNetResults,int maxNbImg)
	{
		String [] allSourcesImageResults =null;
		ArrayList <String> finalResults = new ArrayList <String> ();
		
		//Add first GOOGLE images
		if (googleQueryResponseList.size()>0)
		{
			int index=-1;
			String imageString="GoogleImages";
			for (QueryResponse response:googleQueryResponseList)
			{
				index++;
				if (index<maxNbImg-1)
				{
					String urlImageLink=response.getImageURL();
					imageString+=terminator+urlImageLink;
				}	
				else
				{
					break;
				}
			}
			finalResults.add(imageString);
		}
		
		//Then Add BING images		
		if (bingQueryResponseList.size()>0)
		{
			int index=-1;
			String imageString="BingImages";
			for (QueryResponse response:bingQueryResponseList)
			{
				index++;
				if (index<maxNbImg-1)
				{
					String urlImageLink=response.getImageURL();
					imageString+=terminator+urlImageLink;
				}
				else
				{
					break;
				}
			}
			finalResults.add(imageString);
		}
		
		//Then Add ImageNet Images
		if (imageNetResults!=null)
		{
			int index=0;
			for (String urlImage:imageNetResults)
			{
				index++;
				finalResults.add("ImageNetSense:"+index+terminator+urlImage);
			}
		}
		
		if (finalResults.size()>0)
		{
			return (finalResults.toArray(new String[finalResults.size()]));
		}
		return allSourcesImageResults;
	}
	
	
	public String[] getImageURL(String concept,String languageCode,String googleUserId,String googlePassword,String bingUserId, String bingPassword) throws IOException, ParseException
	{
		
		
		//-------------------------GOOGLE STUFF-----------------------		
		ArrayList<QueryResponse> googleQueryResponseList = null;
		Credential googleCredential = new Credential ();
		googleCredential.setUserId(googleUserId);
		googleCredential.setPassword(googlePassword);
		googleQueryResponseList=getGoogleImages(googleCredential, concept, languageCode); 
		

		//-----------------------------BING STUFF------------------------------
		ArrayList<QueryResponse> bingQueryResponseList = null; 
		Credential bingCredential = new Credential ();
		bingCredential.setUserId(bingUserId);
		bingCredential.setPassword(bingPassword);
		bingQueryResponseList=getBingImages(bingCredential, concept, languageCode); 
	

		//----------------------------------ImageNet stuff---------------------------
		String [] imageNetResults=null;
		if (languageCode.equalsIgnoreCase("en"))
		{
			imageNetResults=SearchImages.search(concept);
		}

		String[] allSourcesImageResults=agregateImages (bingQueryResponseList,googleQueryResponseList, imageNetResults,maxNbImg);
		return allSourcesImageResults;
		
	}
	
	

}
