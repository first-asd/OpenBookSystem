package es.ujaen.images.google;

import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.OutputStreamWriter;
import java.net.URL;
import java.net.URLConnection;
import java.util.ArrayList;

import org.apache.log4j.Logger;

import es.ujaen.ImageRetrieval.TestGetImagesWS;
import es.ujaen.images.common.ParseResponse;
import es.ujaen.images.common.QueryResponse;

public class GoogleClient {
	
	/**
	 * The two parameters you need to access Google Custom Search ...
	 */
	private String key;
	private String cx;
	
	/**
	 * The Language of the retrieved page
	 */
	private String language ;
	
	private String googleURL;
	private static Logger logger = Logger.getLogger(TestGetImagesWS.class);

	
	
	public void setGoogleEngineParameters (String key, String cx,String language)
	{
		this.key=key;
		this.cx=cx;
		this.language=language;
	}
	
	public void setGoogleURL (String query, String pageNumber) 
	{
		googleURL = "https://www.googleapis.com/customsearch/v1?key="+key+"&cx="+cx+"&q="+query+"&searchType=image"+"&lr="+language+"&safe=high"+"&start="+pageNumber+"&alt=json";
	}
	
	
	public ArrayList<QueryResponse> getImageAnswers (String query) throws IOException
	{
		ArrayList<QueryResponse> imageAnswersResponse = new ArrayList<QueryResponse> ();
		String jsonResponse="";

		URL url = new URL(googleURL);
		URLConnection urlConnection = url.openConnection();
		logger.debug("Query:"+googleURL );

		//reads from the connection.
		BufferedReader in = new BufferedReader(new InputStreamReader( urlConnection.getInputStream()));
		String inputLine;
		while ((inputLine = in.readLine()) != null) 
		{
			jsonResponse+=inputLine;
		}
		in.close();

		ParseResponse pResp = new ParseResponse ();
		
		imageAnswersResponse= pResp.parseGoogleQueryResults(jsonResponse,query);

		return imageAnswersResponse;       

	}
	
	
	
	
}
