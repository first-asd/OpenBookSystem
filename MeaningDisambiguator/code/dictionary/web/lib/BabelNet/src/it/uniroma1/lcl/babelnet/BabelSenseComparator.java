package it.uniroma1.lcl.babelnet;

import java.util.Comparator;

/**
 * {@link Comparator} for {@link BabelSense}s that (a) puts WordNet senses
 * first; (b) sorts WordNet senses based on their sense number; (c) sorts
 * Wikipedia senses lexicographically.
 * 
 * @author ponzetto
 *
 */
public class BabelSenseComparator implements Comparator<BabelSense>
{
   @Override
    public int compare(BabelSense b1, BabelSense b2)
    {
        boolean bWordNet1 =
        	b1.getSource() == BabelSenseSource.WN;
        boolean bWordNet2 =
        	b2.getSource() == BabelSenseSource.WN;
        
        if (bWordNet1 && bWordNet2)
        {
        	// both senses are in the WordNet: sort based on the sense number
        	// of the senses of interest
            // do the magic ;)
            return b1.getSenseNumber() - b2.getSenseNumber();
        }
        // WordNet's senses come first that Wikipedia's
        else if (bWordNet1) return -1;
        // ditto
        else if (bWordNet2) return 1;
        // Wikipedia senses are sorted lexicographically instead
        else return b1.getSenseString().compareTo(b2.getSenseString());
    }
}
