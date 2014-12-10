/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package es.ua.dictionary;

import java.util.List;

/**
 * Representa una palabra con todo su contenido sintáctico, información de
 * wordnet y offset.
 *
 * @author lcanales
 */
public class Word implements Comparable<Word> {

    private String word;
    private String lemma;
    private String POS;
//    private String idWordNet;
    private int start_offset;
    private int end_offset;
    private String typeWord;
    private String domains;
    private List<String> senses = null;
    private double complexity = 0.0;

    public Word(String lemma, String POS, List<String> senses, int start_offset, int end_offset, String word) {
        this.lemma = lemma;
        this.POS = POS;
//        this.idWordNet = idWordNet;
        this.start_offset = start_offset;
        this.end_offset = end_offset;
        this.word = word;
        this.senses = senses;

    }

    public Word(String lemma, String POS, int start_offset, int end_offset, String word) {
        this.lemma = lemma;
        this.POS = POS;
        this.start_offset = start_offset;
        this.end_offset = end_offset;
        this.word = word;
    }

//    public void setIdWordNet(String idWordNet) {
//        this.idWordNet = idWordNet;
//    }
    public Word(String word) {
        this.word = word;
    }

    public String getLemma() {
        return lemma;
    }

    public String getWord() {
        return word;
    }

    public String getPOS() {
        return POS;
    }

    public List<String> getSenses() {
        return senses;
    }

    public double getComplexity() {
        return complexity;
    }

//    public String getIdWordNet() {
//        return idWordNet;
//    }
    public int getStart_offset() {
        return start_offset;
    }

    public int getEnd_offset() {
        return end_offset;
    }

    public String getTypeWord() {
        return typeWord;
    }

    public String getDomains() {
        return domains;
    }

    public void setTypeWord(String typeWord) {
        this.typeWord = typeWord;
    }

    public void setPOS(String POS) {
        this.POS = POS;
    }

    public void setDomains(String domains) {
        this.domains = domains;
    }

    public void setComplexity(double complexity) {
        this.complexity = complexity;
    }

    public int compareTo(Word o) {
        if (this.word.equals(o.getWord())) {
            return 0;
        } else {
            return -1;
        }
    }
}
