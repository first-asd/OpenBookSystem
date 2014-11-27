package es.ujaen.images.common;

import java.util.ArrayList;
import java.util.Map;

import org.json.simple.JSONArray;
import org.json.simple.parser.JSONParser;
import org.json.simple.parser.ParseException;




public class ParseResponse {

	
    public ArrayList<QueryResponse> parseBingQueryResults (String jsonContent,String query)
    {
    	ArrayList<QueryResponse> imageAnswers = new ArrayList<QueryResponse> ();
    	try{
    		JSONParser parser = new JSONParser();
    	    Map jsonContentParsed = (Map)parser.parse(jsonContent);
    	    Map queyResults=(Map) jsonContentParsed.get("d");
    	    JSONArray arrayResults=(JSONArray)queyResults.get("results");
    	    int index=0;
    	    for (int i=0;i<arrayResults.size();i++)
    	    {
    	    	index++;
    	    	Map queryAnswer  = (Map) arrayResults.get(i);
    	    	
    	    	Object imageURL=queryAnswer.get("MediaUrl");
    	    	Object imageTitle=queryAnswer.get("Title");
    	    	
    	    	//set the Query Response
    	    	QueryResponse queryResponse = new QueryResponse ();
    	    	queryResponse.setTitle(imageTitle.toString());
    	    	queryResponse.setImageUrl(imageURL.toString());
    	    	queryResponse.setQuery(query);
    	    	
    	    	imageAnswers.add(queryResponse);
    	    }
    	    
    	  }
    	  catch(ParseException pe){
    	    System.out.println(pe);
    	  }
    	  
    	  return imageAnswers;
    	  
    }
    
    
    public ArrayList<QueryResponse> parseGoogleQueryResults (String jsonContent,String query)
    {
    	ArrayList<QueryResponse> imageAnswers = new ArrayList<QueryResponse> ();
    	try{
    		JSONParser parser = new JSONParser();
    	    Map jsonContentParsed = (Map)parser.parse(jsonContent);
    	    JSONArray arrayResults=(JSONArray)jsonContentParsed.get("items");
    	    if (arrayResults!=null)
    	    {
    	    	int index=0;
        	    for (int i=0;i<arrayResults.size();i++)
        	    {
        	    	index++;
        	    	Map queryAnswer  = (Map) arrayResults.get(i);
        	    	
        	    	Object imageURL=queryAnswer.get("link");
        	    	Object imageTitle=queryAnswer.get("title");
        	    	
        	    	//set the Query Response
        	    	QueryResponse queryResponse = new QueryResponse ();
        	    	queryResponse.setTitle(imageTitle.toString());
        	    	queryResponse.setImageUrl(imageURL.toString());
        	    	queryResponse.setQuery(query);
        	    	
        	    	imageAnswers.add(queryResponse);
        	    }
    	    }
    	  }
    	  catch(ParseException pe){
    	    System.out.println(pe);
    	  }
    	  
    	  return imageAnswers;
    	  
    }
    
		

}
