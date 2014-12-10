/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package es.ua.first.coreference.util;

import java.util.ArrayList;
import java.util.TreeSet;

/**
 * Represents a mention. 
 * @author imoreno
 */
public class Mention implements Comparable<Mention> {
    
    private double confidence;
    private ArrayList<Mention> antecedentsSet;
    
    private Mention antecedent;
    
    private Mention previousToken;
    
    private Mention nextToken;
    
    private String token;   //head of the nominal phrase
    
    private String lemma;   //lema's head of the nominal phrase
    
    private String genre;   //genre's head of the nominal phrase
    
    private String number;  //number's head of the nominal phrase
    
    private String postype; //type of the head of the nominal phrase
    
    private int sentence;   //the sentence where the nominal phrase appears
    
    private String typeNE;  //named entity type, _ if is not a named entity
    
    private boolean followedBySP;   //if the head of the nominal phrase is followed by a prepositonal phrase
    
    private boolean followedBySA;   //if the head of the nominal phrase is followed by a adjetival phrase

    private boolean preceedByAnArticle;     //if the head of the nominal phrase is preceed by an article
    
    private int idMention;  //id of the mention - indicates if two mentions are correferent.
    
    private int startOffset;    //the start offset of this mention in the original text
    
    private int endOffset;      //the end offset of this mention in the original text
    
    private int numToken;       //the position of this token (the core) in the sentence
    
    private ArrayList<String> words;

    public Mention() {
        words = new ArrayList<String>();
        token = null;
        lemma = null;
        genre = null;
        number = null;
        postype = null;
        sentence = -1;
        typeNE = null;
        followedBySP = false;
        followedBySA = false;
        preceedByAnArticle = false;
        idMention = -1;
        startOffset = -1;
        endOffset = -1;
        antecedent = null;
        confidence = 0.0;
        antecedentsSet = new ArrayList<Mention>();
    }

    public Mention(Mention m) {
        words = new ArrayList<String>(m.words);
        token = m.token;
        lemma = m.lemma;
        genre = m.genre;
        number = m.number;
        postype = m.postype;
        sentence = m.sentence;
        typeNE = m.typeNE;
        followedBySP = m.followedBySP;
        followedBySA = m.followedBySA;
        preceedByAnArticle = m.preceedByAnArticle;
        idMention = m.idMention;
        startOffset = m.startOffset;
        endOffset = m.endOffset;
        antecedent = m.antecedent;
        confidence = m.confidence;
        antecedentsSet = new ArrayList<Mention>(m.antecedentsSet);
    }
    
    public ArrayList<Mention> getAntecedentsSet() {
        return antecedentsSet;
    }

    public void setAntecedentsSet(ArrayList<Mention> antecedentsSet) {
        this.antecedentsSet = antecedentsSet;
    }

    public double getConfidence() {
        return confidence;
    }

    public void setConfidence(double confidence) {
        this.confidence = confidence;
    }

    
    
    public Mention getAntecedent() {
        return antecedent;
    }

    public void setAntecedent(Mention antecedent) {
        this.antecedent = antecedent;
    }
    
    
    
    public Mention getNextToken() {
        return nextToken;
    }

    public void setNextToken(Mention nextToken) {
        this.nextToken = nextToken;
    }

    public Mention getPreviousToken() {
        return previousToken;
    }

    public void setPreviousToken(Mention previousToken) {
        this.previousToken = previousToken;
    }
    
    public int getNumToken() {
        return numToken;
    }

    public void setNumToken(int numToken) {
        this.numToken = numToken;
    }
    
    public int getEndOffset(){
        return endOffset;
    }
    
    public void setEndOffset(int endOffset){
        this.endOffset = endOffset;
    }
    
    public int getStartOffset(){
        return startOffset;
    }

    public void setStartOffset(int startOffset) {
        this.startOffset = startOffset;
    }

    public int getIdMention() {
        return idMention;
    }

    public void setIdMention(int idMention) {
        this.idMention = idMention;
    }

    public boolean isPreceedByAnArticle() {
        return preceedByAnArticle;
    }

    public void setPreceedByAnArticle(boolean preceedByAnArticle) {
        this.preceedByAnArticle = preceedByAnArticle;
    }

    
    public String getPostype() {
        return postype;
    }

    public void setPostype(String postype) {
        this.postype = postype;
    }

    public ArrayList<String> getWords() {
        return words;
    }

    
    public void setWords(ArrayList<String> words) {
        this.words = words;
    }

    public void addWord(String w) {
        this.words.add(w);
    }

    public boolean isFollowedBySA() {
        return followedBySA;
    }

    public void setFollowedBySA(boolean followedBySA) {
        this.followedBySA = followedBySA;
    }

    public boolean isFollowedBySP() {
        return followedBySP;
    }

    public void setFollowedBySP(boolean followedBySP) {
        this.followedBySP = followedBySP;
    }

    public String getGenre() {
        return genre;
    }

    public void setGenre(String genre) {
        this.genre = genre;
    }
    
    public String getLemma(){
        return lemma;
    }
    
    public void setLemma(String lemma){
        this.lemma = lemma;
    }
    
    public String getNumber(){
        return number;
    }
    
    public void setNumber(String number){
        this.number = number;
    }
    
    public int getSentence(){
        return sentence;
    }
    
    public void setSentence(int sentence){
        this.sentence = sentence;
    }
    
    public String getToken(){
        return token;
    }
    
    public void setToken(String token){
        this.token = token;
    }

    public String getTypeNE() {
        return typeNE;
    }
    
    public void setTypeNE(String typeNE){
        this.typeNE = typeNE;
    }
    
    public Boolean sameHeadToken(Mention m){
        return this.token.equals(m.token);
    }
    
    public Boolean sameHeadLema(Mention m){
        return this.lemma.equals(m.lemma);
    }
    
    public Boolean isNE(){
        if(typeNE!=null)
            return (!typeNE.equals("00"));
        else return false;
    }
    
    public Boolean sameTypeNE(Mention m){
        if(typeNE!=null && m.typeNE!=null)
            return typeNE.equals(m.typeNE);
        else
            return false;
    }
    
    public Boolean sameGenre(Mention m){
        if(genre!=null && m.genre!=null)
        return genre.equals(m.genre);
        else return false;
    }
    
    public Boolean sameNumber(Mention m){
        if(number!=null && m.number!=null)
        return number.equals(m.number);
        else return false;
    }

    public Boolean samePostype(Mention m) {
        return postype.equals(m.postype);
    }
    
    public Boolean areCoreferents(Mention m){
        return (this.idMention == m.idMention);
    }

    public int compareTo(Mention o) {
        //return Double.compare(this.confidence, o.confidence);
        
        if(o.confidence > this.confidence )
            return 1;
        else if (o.confidence < this.confidence)
            return -1;
        else return 0;
    }

    
}
