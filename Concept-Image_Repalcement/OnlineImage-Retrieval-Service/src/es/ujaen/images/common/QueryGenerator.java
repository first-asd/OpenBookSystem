package es.ujaen.images.common;

import java.util.ArrayList;

/**
 * This class generates queries for a certain keyword. 
 * It will implement several methods for making relevant queries from keywords.
 * @author Eduard
 */
public class QueryGenerator {
	
	/**
	 * For generate gender specific queries: e.g. happy woman, happy man, happy child
	 * @return 
	 */
	public ArrayList<String> generateGenderQueries (String keyWord)
	{
		ArrayList<String> queriesForKeyword = new ArrayList<String> ();
		queriesForKeyword.add(keyWord+" "+"woman");
		queriesForKeyword.add(keyWord+" "+"man");
		queriesForKeyword.add(keyWord+" "+"child");
		
		return queriesForKeyword;
	}

}
