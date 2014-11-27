package es.ujaen.first.summarizer;

import java.util.Arrays;
import java.util.HashSet;
import java.util.Set;
import java.util.TreeSet;

/**
 *Computes the similarity between sentences. 
 * @author Eduard
 */
public class Similarity {
	
	/**
	 *One of similarity measures that can be used:content Overlap.
	 */
 public static double contentOverlap(String sentence1, String sentence2)
 {
     double sim = 0;
     String[] words1 = sentence1.split(" ");
     String[] words2 = sentence2.split(" ");
     
     int length1 = words1.length;
     int length2 = words2.length;
     
     if((length1 == 1) && (length2 == 1))
     {
         length1++;
         length2++;
     }
     
     Set<String> set1 = new HashSet<String>(Arrays.asList(words1));
     Set<String> set2 = new HashSet<String>(Arrays.asList(words2));
     
     Set<String> intersect = new TreeSet<String>(set1);
     intersect.retainAll(set2);
     
     int nCommonElements = intersect.size();
     
     if(nCommonElements > 0)
     {
         sim = nCommonElements / (Math.log10(length1) + Math.log10(length2));
     }
     
     return sim;

 }

}
