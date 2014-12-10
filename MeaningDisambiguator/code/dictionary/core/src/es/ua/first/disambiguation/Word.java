/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package es.ua.first.disambiguation;

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
    private List<String> idSenses = null;
    private List<String> idSenses20 = null;
    private List<String> confSenses = null;
    private double complexity = 0.0;
    private boolean isLongWord = false;
    private boolean isRare = false;
    private boolean isSpecialized = false;
    private boolean isMentalVerb = false;
    private boolean isPolysemic = false;
    private String defintions;
    private String synonyms;
    private String synonymSimple;
    private String domains;

    public Word(String word, String lemma, String POS, List<Integer> start_offset, List<Integer> end_offset, List<String> senses, List<String> confSenses) {
        this.word = word;
        this.lemma = lemma;
        this.POS = POS;
        this.start_offset = start_offset;
        this.end_offset = end_offset;
        this.idSenses = senses;
        this.confSenses = confSenses;
    }

    public Word(String word, String lemma, String POS, List<Integer> start_offset, List<Integer> end_offset) {
        this.lemma = lemma;
        this.POS = POS;
        this.start_offset = start_offset;
        this.end_offset = end_offset;
        this.word = word;
    }

    public List<String> getIdSenses20() {
        return idSenses20;
    }

    public void setIdSenses20(List<String> idSenses20) {
        this.idSenses20 = idSenses20;
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

    public List<String> getIdSenses() {
        return idSenses;
    }

    public List<String> getConfSenses() {
        return confSenses;
    }

    public double getComplexity() {
        return complexity;
    }

    public boolean isIsLongWord() {
        return isLongWord;
    }

    public boolean isIsRare() {
        return isRare;
    }

    public boolean isIsSpecialized() {
        return isSpecialized;
    }

    public boolean isIsMentalVerb() {
        return isMentalVerb;
    }

    public boolean isIsPolysemic() {
        return isPolysemic;
    }

    public String getDefintions() {
        return defintions;
    }

    public String getSynonyms() {
        return synonyms;
    }

    public String getSynonymSimple() {
        return synonymSimple;
    }

    public String getDomains() {
        return domains;
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

    public void setIdSenses(List<String> idSenses) {
        this.idSenses = idSenses;
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

    public void setIsLongWord(boolean isLongWord) {
        this.isLongWord = isLongWord;
    }

    public void setIsRare(boolean isRare) {
        this.isRare = isRare;
    }

    public void setIsSpecialized(boolean isSpecialized) {
        this.isSpecialized = isSpecialized;
    }

    public void setIsMentalVerb(boolean isMentalVerb) {
        this.isMentalVerb = isMentalVerb;
    }

    public void setIsPolysemic(boolean isPolysemic) {
        this.isPolysemic = isPolysemic;
    }

    public void setDefintions(String defintions) {
        this.defintions = defintions;
    }

    public void setSynonyms(String synonyms) {
        this.synonyms = synonyms;
    }

    public void setSynonymSimple(String synonymSimple) {
        this.synonymSimple = synonymSimple;
    }

    public void setDomains(String domains) {
        this.domains = domains;
    }
}
