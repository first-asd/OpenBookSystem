/**
 * Indexes the Newer Version of the Image Database.
 * All Multi-Words in Synsets have been normalized to use "_" as separator;
 */

package es.ujaen.ImageNet;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStreamReader;

import org.apache.lucene.analysis.standard.StandardAnalyzer;
import org.apache.lucene.document.Document;
import org.apache.lucene.document.Field;
import org.apache.lucene.index.CorruptIndexException;
import org.apache.lucene.index.IndexWriter;
import org.apache.lucene.index.IndexWriterConfig;
import org.apache.lucene.store.Directory;
import org.apache.lucene.store.FSDirectory;
import org.apache.lucene.util.Version;

public class IndexImageDatabase {
	
	 private IndexWriter writer;
	 private long numIndexed=0;
	
public void  setIndexer(String indexDir) throws IOException {
	    
		Directory dir = FSDirectory.open(new File(indexDir));
		
		// Builds a configuration object with the standard analyzer 
		 IndexWriterConfig config = new IndexWriterConfig(Version.LUCENE_34, new StandardAnalyzer(Version.LUCENE_34));
		 
		 //creates the Index Writer. This is the class that writes the documents in the index.
	     writer =new IndexWriter(dir,config);
	  }

public void indexImageDatabase (File fileDatabase) throws CorruptIndexException, IOException
{
	BufferedReader reader = new BufferedReader(new InputStreamReader(new FileInputStream(fileDatabase),"UTF-8"));
	 String dbLine;
	while ((dbLine = reader.readLine()) != null)   {
		  numIndexed++;
		  String[] dbLineContents = dbLine.split("\\t");
		  String synsetID=dbLineContents[0];
		  String synset = dbLineContents[1];
		  String imageURL=dbLineContents[2];
		  Document d = new Document();	 
		  
		  //Field.Index.NOT_ANALYZED =Index the field's value without using an Analyzer, so it can be searched.
		  d.add(new Field("id", synsetID, Field.Store.YES, Field.Index.NOT_ANALYZED));  
		  
		  //Field.Index.ANALYZED=Index the tokens produced by running the field's value through an Analyzer.
		  d.add(new Field("id", synset, Field.Store.YES, Field.Index.ANALYZED));  
		  
		  //Field.Index.NO= Do not index the field value.
		  d.add(new Field("url", imageURL, Field.Store.YES, Field.Index.NO));
		  
		  
		  writer.addDocument(d);
		  }
	
	writer.close();
	reader.close();
}

public static void main(String[] args) throws Exception
{
	
	 String indexDir = "indexImageNetDatabase";         //the directory you keep the index
	 String fileDatabase="/Users/Eduard/Documents/EclipseWorkspaces/TestPrograms/OnlineImage-Retrieval/ImageNetDatabase/imageNetDatabase-Normalized.txt";
	 
	 IndexImageDatabase index = new  IndexImageDatabase(); 
	
    long start = System.currentTimeMillis();
    
    //.............Index the data and store the Index in a Directory........
    index.setIndexer(indexDir);
    index.indexImageDatabase(new File(fileDatabase));
    
    long end = System.currentTimeMillis();

	    System.out.println("Indexing " + index.numIndexed + " db records took "
	      + (end - start) + " miliseconds");
}

}
