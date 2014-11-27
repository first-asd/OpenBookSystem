package es.ujaen.wikipediaImages;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.net.HttpURLConnection;
import java.net.MalformedURLException;
import java.net.URL;
import java.net.URLConnection;
import java.net.URLEncoder;
import java.util.ArrayList;
import java.util.Map;

import org.apache.log4j.Logger;
import org.json.simple.JSONArray;
import org.json.simple.parser.JSONParser;
import org.json.simple.parser.ParseException;


/**
 * In this class I retrieve the corresponding Images 
 * for the disambiguated Wikipedia Concepts.
 * @author Eduard
 */

public class WikipediaImages {


	private static String spanishAPI ="http://es.wikipedia.org/w/api.php?";
	private static String englishAPI ="http://en.wikipedia.org/w/api.php?";
	private static String bulgarianAPI ="http://bg.wikipedia.org/w/api.php?";

	private static Logger logger = Logger.getLogger(WikipediaImages.class);

	private ArrayList <String> getPageImages (String disambiguatedConcept, String currentWikipediaAPI) throws IOException, ParseException
	{
		String wikipediaURL= currentWikipediaAPI+"action=query&prop=images&titles="+disambiguatedConcept+"&format=json";
		logger.debug(wikipediaURL);
		URL url = new URL(wikipediaURL);
		URLConnection urlConnection = url.openConnection();
		String jsonResponse="";
		BufferedReader in = new BufferedReader(new InputStreamReader( urlConnection.getInputStream()));
		String inputLine;
		while ((inputLine = in.readLine()) != null) 
		{
			jsonResponse+=inputLine;
		}
		in.close();

		ArrayList <String> imageAnswers = _getPageImages (jsonResponse);
		return imageAnswers ;
	}

	@SuppressWarnings("rawtypes")
	private ArrayList <String> _getPageImages (String jsonResponse) 
	{
		ArrayList<String> imageAnswers = new ArrayList<String> ();
		JSONParser parser = new JSONParser();
		Map jsonResponseParsedMap;
		JSONArray arrayResults=new JSONArray();

		try {
			jsonResponseParsedMap = (Map)parser.parse(jsonResponse);
			Map queryResultsMap=(Map) jsonResponseParsedMap.get("query");
			Map pagesMap=(Map) queryResultsMap.get("pages");

			String pageId="";
			for (Object id:pagesMap.keySet())
			{
				pageId=id.toString();
			}

			arrayResults=(JSONArray)((Map) pagesMap.get(pageId)).get("images");
		}
		catch (Exception e) {
			logger.debug("Error parsing the images on the Page",e);
		}
		if (arrayResults!=null)
		{
			for (int i=0;i<arrayResults.size();i++)
			{
				Map queryAnswer  = (Map) arrayResults.get(i);  	
				Object imageFile=queryAnswer.get("title");
				imageAnswers.add(imageFile.toString());
			}
		}
		else
		{
			return null;
		}



		return imageAnswers;
	}


	private String getCorrectImage (ArrayList <String> imageAnswers , String disambiguatedConcept)
	{
		//Immanuel_Kant -> Immanuel Kant
		disambiguatedConcept=disambiguatedConcept.replaceAll("_", " ");
		for (String imageFile:imageAnswers)
		{
			if (imageFile.toLowerCase().contains(disambiguatedConcept.toLowerCase() ))
			{
				return imageFile;
			}
		}

		//Here is a problem with lemmatization in rich languages like Spanish or Bulgarian. 
		//Normally you should first lemmatize the titles of the images and then match at the level of strings.
		//Here is a temporal workaround this problem.

		if (imageAnswers.size() >1)
		{
			return imageAnswers.get(imageAnswers.size()-2);
		}
		return imageAnswers.get(0);
	}

	private String _getPageImageURL (String jsonResponse)
	{
		String imageURL="";
		try{
			JSONParser parser = new JSONParser();
			Map jsonResponseParsedMap = (Map)parser.parse(jsonResponse);

			//sometimes Wikipedia returns a bad structure where some keys do not exist.
			boolean isFirstMap=jsonResponseParsedMap.containsKey("query");

			if (isFirstMap)
			{
				boolean isSecondMap=((Map) jsonResponseParsedMap.get("query")).containsKey("pages");
				if (isSecondMap)
				{
					boolean isThirdMap=((Map) ((Map) jsonResponseParsedMap.get("query")).get("pages")).containsKey("-1");
					if (isThirdMap)
					{
						Map queryPagesMap=(Map)((Map) ((Map)jsonResponseParsedMap .get("query")).get("pages")).get("-1");
						if (queryPagesMap.containsKey("imageinfo"))
						{
							JSONArray arrayResults=(JSONArray) queryPagesMap.get("imageinfo");
							Map queryAnswer  = (Map) arrayResults.get(0);  	
							imageURL=queryAnswer.get("url").toString();
						}
					}
				}
			}	

		}
		catch(ParseException pe){
			logger.error("Parsing the image from Wikipedia error",pe);
		}

		return imageURL;
	}


	private String getPageImageURL (String imageFile,String currentWikipediaAPI) throws IOException
	{
		imageFile=imageFile.replaceAll(" ", "_");
		String wikipediaURL= currentWikipediaAPI+"action=query&titles="+imageFile+"&prop=imageinfo&iiprop=url&format=json";
		logger.debug(wikipediaURL);
		URL url = new URL(wikipediaURL);
		HttpURLConnection urlConnection= (HttpURLConnection) url.openConnection();
		urlConnection.setRequestProperty("Accept-Charset", "UTF-8");
		urlConnection.setRequestProperty("content-type", "application/x-www-form-urlencoded;charset=utf-8");
		String jsonResponse="";
		BufferedReader in = new BufferedReader(new InputStreamReader( urlConnection.getInputStream(),"UTF-8"));
		String inputLine;
		while ((inputLine = in.readLine()) != null) 
		{
			jsonResponse+=inputLine;
		}
		in.close();	

		String imageURL=_getPageImageURL (jsonResponse);
		return imageURL;
	}


	/**
	 * Tries to eliminate images that are Wikipedia icons. Usually they have certain extensions.
	 * @param imageName
	 * @return
	 */
	private boolean isGoodImage (String imageName)
	{

		if (imageName.matches("(?i:.*\\.SVG)")||(imageName.compareTo("")==0))
		{
			return false;
		}
		return true;
	}

	public String getImageURL (String disambiguatedConcept, String languageCode) throws IOException, ParseException
	{

		//all the image URL's will be separated by separator: @@@

		String separator="@@@";
		String imageURLS ="";
		String currentWikipediaAPI="";

		if (languageCode.equalsIgnoreCase("es"))
		{
			currentWikipediaAPI=spanishAPI;
		}
		else if (languageCode.equalsIgnoreCase("en"))
		{
			currentWikipediaAPI=englishAPI;
		}
		else if (languageCode.equalsIgnoreCase("bg"))
		{
			currentWikipediaAPI=bulgarianAPI;
		}

		logger.debug("Get Images on the disambiguated Page:");
		ArrayList <String> pageImages = getPageImages (disambiguatedConcept,currentWikipediaAPI);

		if (pageImages!=null)
		{
			for (String pageImage:pageImages)
			{
				String curImageURL=getPageImageURL (pageImage,currentWikipediaAPI);
				if (isGoodImage (curImageURL))
				{
					imageURLS+=curImageURL+separator;
				}
				else
				{
					logger.debug("Bad Image");
				}
			}
		}
		else
		{
			logger.debug("No image on the Page!");
		}

		imageURLS=imageURLS.replaceFirst("@@@$", "");
		return imageURLS;
	}

}
