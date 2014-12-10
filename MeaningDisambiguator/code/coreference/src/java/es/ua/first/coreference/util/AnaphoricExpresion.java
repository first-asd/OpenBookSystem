/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package es.ua.first.coreference.util;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.TreeSet;

/** 
 * This class represents an anaphoric expresion, that is a pronoun (including 
 * zero pronouns).
 * @author imoreno
 */
public class AnaphoricExpresion {
    /**
     * the token that represents the expresion
     */
    public String word;
    /**
     * syntactic funtion of the expression
     */
    public String syntactic_function;
    /**
     * start offset of the expression
     */
    public int position;
    /**
     * end offset of the expression
     */
    public int endPosition;
    
    /**
     * the antecedent with higher probability
     */
    public Antecedent antecedent;
    /**
     * A list of all posible antecedents (with a confidence greather than or 
     * equal 0.5)
     */
    public ArrayList<Antecedent> antecedentsSet;
    
    public AnaphoricExpresion (){
        word = null; syntactic_function = null; 
        position = -1; endPosition = -1;
        antecedentsSet = new ArrayList<Antecedent>();
    }
    
    /**
     * Constructor
     * @param w the token that represents the anaphoric expression
     * @param p the start offset of the token
     * @param end_offset    the end offset of the token
     * @param sf the syntactic funtion of the token
     */
    public AnaphoricExpresion (String w, int p, int end_offset, String sf){
        word = w;
        syntactic_function = sf;
        position = p;
        endPosition = end_offset;
        antecedentsSet = new ArrayList<Antecedent>();
    }
    
    /**
     * Constructor
     * @param w the token that represents the anaphoric expression
     * @param p the start offset of the token
     * @param end_offset    the end offset of the token
     * @param sf    the syntactic funtion of the token
     * @param ts    a set of antecedents    
     */
    public AnaphoricExpresion (String w, int p, int end_offset, String sf, 
            TreeSet<Antecedent> ts){
        word = w;
        syntactic_function = sf;
        position = p;
        endPosition = end_offset;
        antecedentsSet = new ArrayList<Antecedent>(ts);
    }
    
    /**
     * 
     * @return A list of all posible antecedents (with a confidence greather than or 
     * equal 0.5 and without duplicated words - when a duplicate is finded, the 
     * one with higher confidence is keeped) 
     */
    public ArrayList<Antecedent> getUniqueAntecedents(){
        ArrayList<Antecedent> unique = new ArrayList<Antecedent>();
        ArrayList<Antecedent> set = (ArrayList<Antecedent>) antecedentsSet.clone(); //para seguir teniendo todos los antecedentes, por si cambian de idea
        
        for(int i=0; i<set.size(); i++){
            Antecedent a1 = set.get(i);
            ArrayList<String> onlyWords1 = a1.getOnlyWords();
            Antecedent aHighestConfidence = a1;
            
            for(int j=i+1; j<set.size(); j++){
                Antecedent a2 = set.get(j);
                if(onlyWords1.equals(a2.getOnlyWords())){
                    if(a2.confidence > aHighestConfidence.confidence){
                        aHighestConfidence = a2;
                    } else if(a2.confidence==aHighestConfidence.confidence){
                        if(a2.startPosition > aHighestConfidence.startPosition){
                            aHighestConfidence = a2; //si su confidence es igual, nos quedamos con el más cercano (el de mayor startnode)
                        }
                    }
                
                    set.remove(j);//como ya sabemos que es igual, lo borramos para no tenerlo en cuenta
                    
                }
                
            }
            
            unique.add(aHighestConfidence);
        }
        
        return unique;
    }
    
}
