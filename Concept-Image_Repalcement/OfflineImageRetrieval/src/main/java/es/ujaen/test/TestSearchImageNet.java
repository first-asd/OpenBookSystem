package es.ujaen.test;

import java.io.IOException;

import org.apache.log4j.Logger;
import org.apache.lucene.queryParser.ParseException;

import es.ujaen.ImageNet.SearchImages;

public class TestSearchImageNet {
	
	private static Logger logger = Logger.getLogger(TestSearchImageNet .class);
	
	public static void main(String[] args) throws IOException, ParseException
	{
		String indexDir="/opt/dist/008_first/onlineImageRetrieval/indexImageNetDatabase/";
		String query="n03986857";
		
		SearchImages si = new SearchImages ();
		si.setIndexImageNetDir(indexDir);
		String [] allResults =si.search(query);
		
		for (String result:allResults)
		{
			logger.debug(result);
		}
		
		
}

}
