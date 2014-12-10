package it.uniroma1.lcl.babelnet;

import java.util.Comparator;

/**
 * {@link Comparator} for {@link BabelSynset}s that (a) puts WordNet synsets
 * first; (b) sorts WordNet synsets based on the sense number of a specific
 * input word (see the constructor); (c) sorts Wikipedia synsets
 * lexicographically based on their main sense
 * 
 * @author navigli
 *
 */
public class BabelSynsetComparator implements Comparator<BabelSynset>
{
	/*
	 * A word whose sense numbers are used to sort the WordNet-based synsets.
	 */
	private final String word;

	/**
	 * Creates a new instance of a {@link BabelSynsetComparator}
	 * 
	 * @param word
	 *            the word whose sense numbers are used to sort the
	 *            {@link BabelSynset}s corresponding to WordNet synsets
	 */
	public BabelSynsetComparator(String word)
	{
		this.word =  word;
	}
	
    @Override
    public int compare(BabelSynset b1, BabelSynset b2)
    {
    	BabelSynsetSource b1Source = b1.getSynsetSource();
    	BabelSynsetSource b2Source = b2.getSynsetSource();
    	
        boolean bWordNet1 =
        	b1Source == BabelSynsetSource.WN ||
        	b1Source == BabelSynsetSource.WIKIWN;
        boolean bWordNet2 =
        	b2Source == BabelSynsetSource.WN ||
        	b2Source == BabelSynsetSource.WIKIWN;
        
        if (bWordNet1 && bWordNet2)
        {
        	// both synsets are in the WordNet: sort based on the sense number
        	// of the senses of interest
        	int sNumber1 = 1000;
        	int sNumber2 = 1000;
            for (BabelSense s1 : b1.getSenses())
            {
                if (s1.getLemma().equalsIgnoreCase(word)
                	&& s1.getSource() == BabelSenseSource.WN)
                {
                	sNumber1 = s1.getSenseNumber();
                	break;
                }
            }
            for (BabelSense s2 : b2.getSenses())
            {
                if (s2.getLemma().equalsIgnoreCase(word)
                	&& s2.getSource() == BabelSenseSource.WN)
                {
                	sNumber2 = s2.getSenseNumber();
                	break;
                }
            }
            // do the magic ;)
            return sNumber1 - sNumber2;
        }
        // WordNet's senses come first that Wikipedia's
        else if (bWordNet1) return -1;
        // ditto
        else if (bWordNet2) return 1;
        // Wikipedia senses are sorted lexicographically instead
        else return b1.getMainSense().compareTo(b2.getMainSense());
    }
}
