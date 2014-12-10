/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package es.ua.first.coreference.util;

import java.util.ArrayList;

/**
 *
 * @author imoreno
 */
public class Antecedent implements Comparable<Antecedent>{
    
    public String core;
    public ArrayList<String> words;
    public ArrayList<String> onlywords;
    public int startPosition;
    public double confidence;
    public int endPosition;
    
    public Antecedent(){
        super();
        core = null;
        words = new ArrayList<String>();
        onlywords = new ArrayList<String>();
        startPosition=-1;
        endPosition = -1;
        confidence = 0;
    }
    
    public Antecedent(Antecedent a){
        super();
        core = a.core;
        words = new ArrayList<String>(a.words);
        onlywords = new ArrayList<String>(a.onlywords);
        startPosition = a.startPosition;
        confidence = a.confidence;
    }

    public int compareTo(Antecedent o) {
        if(o.confidence > this.confidence )
            return 1;
        else if (o.confidence < this.confidence)
            return -1;
        else return 0;
        //return (o.confidence - this.confidence); //ordenado de mayor a menor
    }
    
    public ArrayList<String> getOnlyWords(){
        if(onlywords.size()!=words.size()){
            onlywords = new ArrayList<String>();

            for(int i=0; i<words.size(); i++){
                String w = words.get(i).substring(1);
                w = w.substring(0,w.indexOf(" "));

                onlywords.add(w);
            }
        }
        
        return onlywords;
    }
    
}
