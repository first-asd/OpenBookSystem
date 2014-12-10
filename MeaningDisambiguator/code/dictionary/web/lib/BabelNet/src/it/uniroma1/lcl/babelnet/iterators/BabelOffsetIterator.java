package it.uniroma1.lcl.babelnet.iterators;

import it.uniroma1.lcl.babelnet.BabelNet;
import it.uniroma1.lcl.babelnet.BabelNetIndexField;

import java.io.IOException;

import org.apache.lucene.document.Document;
import org.apache.lucene.search.IndexSearcher;

/**
 * Abstract iterator over {@link BabelNet}'s synset offset
 */
public class BabelOffsetIterator extends BabelIterator<String>
{
	public BabelOffsetIterator(IndexSearcher dictionary) { super(dictionary); }
	
	@Override
	public String next()
	{
		try
		{
			Document doc = searcher.doc(docs[currentIndex].doc);
			currentIndex++;
			return doc.get(BabelNetIndexField.ID.toString());
		}
		catch (IOException e)
		{ throw new RuntimeException("Cannot return next: " + currentIndex); }
	}
}
