package es.ujaen.test;

import java.io.File;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

import org.apache.commons.io.FileUtils;
import org.apache.log4j.Logger;
import org.json.simple.parser.ParseException;

import es.ujaen.wikipediaImages.WikipediaImages;


/**
 * A Test Set:
 * Jaguar----> a correctly disambiguated Word for which the Wikipedia Page exists. (passed)
 * Immanuel_Kant------>a composed word (the Wikipedia Page Exists) (passed)
 * curgh ------------------->a word that do not exists in Wikipedia.
 */

public class TestWikipediaImages {


	private static Logger logger = Logger.getLogger(TestWikipediaImages.class);
	
	private static void getImageURL (String fileWords, String fileImageURL,String languageCode) throws IOException, ParseException
	{
		ArrayList <String> outputFileLines = new ArrayList <String> ();
		
		List<String> lines=	FileUtils.readLines(new File(fileWords), "UTF-8");
		WikipediaImages wi = new WikipediaImages ();
		
		for (String line:lines)
		{
			String [] components = line.split(":");
			logger.debug(components[1]);
			String imageURL=wi.getImageURL(components[1] ,languageCode);
			outputFileLines.add(components[0]+":"+imageURL);
		}
		
		FileUtils.writeLines(new File(fileImageURL),outputFileLines);
	}
	
	
	public static void main(String[] args) throws IOException, ParseException {
		
		String directory="/Users/Eduard/Documents/MyPerlCode/FirstRelatedScripts/Evaluation/EvaluationWikipedia/EnglishAndSpanish/";
		String fileWords=directory+"spanishWords-Test.txt";
		String fileImageURL=directory+"spanishImages.txt";
		
		getImageURL (fileWords, fileImageURL,"es");

		/*String disambiguatedConcept ="Panthera_onca";
		String languageCode="es";
		WikipediaImages wi = new WikipediaImages ();
		wi.getImageURL(disambiguatedConcept,languageCode);*/
	}

}
