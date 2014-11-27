package es.ujaen.images.bing;

import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.OutputStreamWriter;
import java.io.UnsupportedEncodingException;
import java.net.URL;
import java.net.URLConnection;
import java.net.URLEncoder;
import java.util.ArrayList;
import java.util.Iterator;
import java.util.LinkedHashMap;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;

import org.apache.commons.codec.binary.Base64;
import org.apache.http.client.ClientProtocolException;
import org.apache.log4j.Logger;
import org.json.simple.JSONObject;
import org.json.simple.JSONValue;
import org.json.simple.parser.ContainerFactory;
import org.json.simple.parser.JSONParser;
import org.json.simple.parser.ParseException;

import es.ujaen.ImageRetrieval.TestGetImagesWS;
import es.ujaen.images.common.ParseResponse;
import es.ujaen.images.common.QueryResponse;

public class BingClient {
	
	/**
	 * the user Id for Bing Client
	 */
	private String userId; 
	
	/**
	 * The Password for the Bing account.
	 */
	private String password;
	private String accountKeyEnc;
	private String bingURL;
	private static Logger logger = Logger.getLogger(BingClient.class);
	
	
	
	/**
	 * Here I might store the output as given by the searching engine
	 */
	private static String jsonFile="jsonQueryResults.txt";
	
	
	public void setGoogleEngineParameters (String userId, String password)
	{
		this.userId=userId;
		this.password=password;
	}
	
		
	private static void printResults (StringBuffer queryResult)
	{	  
		  BufferedWriter output=null ;
		  try{ 
			output = new BufferedWriter(new OutputStreamWriter(new FileOutputStream(jsonFile),"UTF8"));
		    output.write(queryResult.toString());
		  }
		 catch (IOException e) {
			e.printStackTrace();
		}
	}
	
	public void setAccountKey ()
	{
		String accountKey = userId+ ":" + password;
	    byte[] accountKeyBytes = Base64.encodeBase64(accountKey.getBytes());
	    accountKeyEnc = new String(accountKeyBytes);    
	}
	
	
	
	
	public String setBingURL (String queryText,String market) 
	{
		try {
			bingURL = "https://api.datamarket.azure.com/Bing/Search/Image?Query=%27"+URLEncoder.encode(queryText, "UTF-8")
			+"%27&Adult=%27Strict%27"+"&Market=%27"+market+"%27"+"&$format=json";
		} catch (UnsupportedEncodingException e) {
			e.printStackTrace();
		}
		return bingURL;
	}
	
	
	public String setBingURL (String queryText) 
	{
		try {
			bingURL = "https://api.datamarket.azure.com/Bing/Search/Image?Query=%27"+URLEncoder.encode(queryText, "UTF-8")+"%27&Adult=%27Strict%27&$format=json";
		} catch (UnsupportedEncodingException e) {
			e.printStackTrace();
		}
		return bingURL;
	}
	
	public ArrayList<QueryResponse> getImages (String query) throws IOException
	{
		ArrayList<QueryResponse> imageAnswers = new ArrayList<QueryResponse> ();
		String jsonResponse="";

		URL url = new URL(bingURL);
		URLConnection urlConnection = url.openConnection();
		urlConnection.setRequestProperty("Authorization", "Basic " + accountKeyEnc);
		logger.debug("Query:"+bingURL );

		//reads from the connection.
		BufferedReader in = new BufferedReader(new InputStreamReader( urlConnection.getInputStream()));
		String inputLine;
		while ((inputLine = in.readLine()) != null) 
		{
			jsonResponse+=inputLine;
		}
		in.close();

		ParseResponse pResp = new ParseResponse ();
		imageAnswers= pResp.parseBingQueryResults(jsonResponse,query);
	


		return imageAnswers;
	}

}
