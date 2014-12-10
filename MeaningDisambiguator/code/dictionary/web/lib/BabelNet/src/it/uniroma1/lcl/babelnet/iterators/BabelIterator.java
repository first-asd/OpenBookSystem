package it.uniroma1.lcl.babelnet.iterators;

import it.uniroma1.lcl.babelnet.BabelNet;

import java.io.IOException;
import java.util.Iterator;

import org.apache.lucene.search.IndexSearcher;
import org.apache.lucene.search.MatchAllDocsQuery;
import org.apache.lucene.search.ScoreDoc;
import org.apache.lucene.search.TopDocs;

/**
 * 
 * Abstract iterator over {@link BabelNet}'s content
 *
 * @param <T>
 */
public abstract class BabelIterator<T> implements Iterator<T>
{
	protected int currentIndex;
	protected final ScoreDoc[] docs;
	protected final IndexSearcher searcher;
	
	private static final int MAX_HITS = 25000000; // enough to catch all synsets, etc.
	
	protected BabelIterator(IndexSearcher searcher)
	{
		try
		{
			this.currentIndex = 0;
			this.searcher = searcher;
			TopDocs tDocs = searcher.search(new MatchAllDocsQuery(), MAX_HITS);
			this.docs = tDocs.scoreDocs;
		}
		catch (IOException ioe)
		{
			throw new RuntimeException("Cannot init: " + ioe);
		}
	}

	@Override
	public boolean hasNext()
	{
		return currentIndex < docs.length;
	}

	@Override
	public void remove()
	{
		throw new RuntimeException("Unsupported operation 'remove'");
	}
}
