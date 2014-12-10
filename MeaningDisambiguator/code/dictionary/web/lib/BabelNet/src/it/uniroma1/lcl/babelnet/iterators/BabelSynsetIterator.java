package it.uniroma1.lcl.babelnet.iterators;

import it.uniroma1.lcl.babelnet.BabelNet;
import it.uniroma1.lcl.babelnet.BabelSynset;

import java.io.IOException;

import org.apache.lucene.document.Document;
import org.apache.lucene.search.IndexSearcher;

/**
 * Iterator over {@link BabelNet}'s synsets
 */
public class BabelSynsetIterator extends BabelIterator<BabelSynset>
{
	public BabelSynsetIterator(IndexSearcher dictionary) { super(dictionary); }
	
	@Override
	public BabelSynset next()
	{
		try
		{
			Document doc = searcher.doc(docs[currentIndex].doc);
			currentIndex++;
			return BabelNet.getBabelSynsetFromDocument(doc);
		}
		catch (IOException e)
		{ throw new RuntimeException("Cannot return next: " + currentIndex); }
	}
}
