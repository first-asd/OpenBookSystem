package es.ujaen.ImageNet;

import java.io.File;
import java.io.IOException;
import java.util.ArrayList;

import org.apache.lucene.analysis.standard.StandardAnalyzer;
import org.apache.lucene.document.Document;
import org.apache.lucene.index.Term;
import org.apache.lucene.queryParser.ParseException;
import org.apache.lucene.queryParser.QueryParser;
import org.apache.lucene.search.IndexSearcher;
import org.apache.lucene.search.Query;
import org.apache.lucene.search.TermQuery;
import org.apache.lucene.search.TopDocs;
import org.apache.lucene.store.Directory;
import org.apache.lucene.store.FSDirectory;
import org.apache.lucene.util.Version;

/**
 * It searches images corresponding to particular words
 * @author Eduard
 */

public class SearchImages {
	
	
	private static StandardAnalyzer standardAnalyzer = new StandardAnalyzer(Version.LUCENE_34);
	private static String indexDir ="/opt/dist/008_first/onlineImageRetrieval/indexImageNetDatabase/";
	
	/**
	 * The maximum number of Synsets to retrieve
	 */
	private static int nDocumentsToRetrieve=10;
	
	
	/**
	 * Normalize the query to look like the terms in the Database (Multi-Terms separated by _  )
	 * @param initialQuery
	 * @return
	 */
	private static String normalizeQuery (String initialQuery)
	{
		String finalQuery=initialQuery.replaceAll("_+", "_");
		finalQuery=finalQuery.replaceAll(" +", "_");
		finalQuery=finalQuery.replaceAll("-+", "_");
		return finalQuery;
	}
	
	public static String[] search(String query)
	throws IOException, ParseException {

		
		query = normalizeQuery (query);
		
		Directory dir = FSDirectory.open(new File(indexDir));
		IndexSearcher is = new IndexSearcher(dir);   

		//Query myQuery = new TermQuery(new Term("id", query));
		
		Query myQuery = new QueryParser(Version.LUCENE_34, "id", standardAnalyzer).parse(query);
		TopDocs hits = is.search(myQuery, nDocumentsToRetrieve ); 	// for the moment I put a limit to the number of documents to retrieve.
		
		ArrayList<String> myResults = new ArrayList<String>();
		
		for (int i = 0; i < hits.totalHits; i++){  
			int docId = hits.scoreDocs[i].doc;
			Document doc=is.doc(docId);
			String curImageId=doc.get("url");
			myResults.add(curImageId);
			}  
		is.close();
		
		String [] allResults = myResults.toArray(new String[myResults.size()]);
		return allResults;
	}
	
}
