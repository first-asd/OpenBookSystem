/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package es.ua.first.multiwords;

import java.util.List;

/**
 * Representa una palabra con todo su contenido sintáctico, información de
 * wordnet y offset.
 *
 * @author lcanales
 */
public class Word {

    private String word;
    private String lemma;
    private String POS;
    private List<Integer> start_offset;
    private List<Integer> end_offset;
    private List<String> confSenses = null;
    private double complexity = 0.0;
    private String defintions;
    private String synonyms;

    public Word(String word, String lemma, String POS, List<Integer> start_offset, List<Integer> end_offset) {
        this.word = word;
        this.lemma = lemma;
        this.POS = POS;
        this.start_offset = start_offset;
        this.end_offset = end_offset;
    }

    public Word(String word, List<Integer> start_offset, List<Integer> end_offset) {
        this.word = word;
        this.start_offset = start_offset;
        this.end_offset = end_offset;
    }

    public String getWord() {
        return word;
    }

    public String getLemma() {
        return lemma;
    }

    public String getPOS() {
        return POS;
    }

    public List<Integer> getStart_offset() {
        return start_offset;
    }

    public List<Integer> getEnd_offset() {
        return end_offset;
    }

    public List<String> getConfSenses() {
        return confSenses;
    }

    public double getComplexity() {
        return complexity;
    }

    public String getDefintions() {
        return defintions;
    }

    public String getSynonyms() {
        return synonyms;
    }

    public void setWord(String word) {
        this.word = word;
    }

    public void setLemma(String lemma) {
        this.lemma = lemma;
    }

    public void setPOS(String POS) {
        this.POS = POS;
    }

    public void setStart_offset(List<Integer> start_offset) {
        this.start_offset = start_offset;
    }

    public void setEnd_offset(List<Integer> end_offset) {
        this.end_offset = end_offset;
    }

    public void setConfSenses(List<String> confSenses) {
        this.confSenses = confSenses;
    }

    public void setComplexity(double complexity) {
        this.complexity = complexity;
    }

    public void setDefintions(String defintions) {
        this.defintions = defintions;
    }

    public void setSynonyms(String synonyms) {
        this.synonyms = synonyms;
    }
}
