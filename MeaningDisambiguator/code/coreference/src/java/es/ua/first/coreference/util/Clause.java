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
public class Clause {

    public Clause(Clause c) {
        this.a = c.a;
        this.agree = c.agree;
        this.confidence = c.confidence;
        this.endTrigger = c.endTrigger;
        this.inf = c.inf;
        this.isCopulative = c.isCopulative;
        this.isImpersonal = c.isImpersonal;
        this.isIntransitive = c.isImpersonal;
        this.isPronominal = c.isPronominal;
        this.isTransivite = c.isTransivite;
        this.isZeroPronoun = c.isZeroPronoun;
        this.lemma = c.lemma;
        this.nhprev = c.nhprev;
        this.nhtotal = c.nhtotal;
        this.num_sentece = c.num_sentece;
        this.number = c.number;
        this.person = c.person;
        this.pospost = c.pospost;
        this.pospre = c.pospre;
        this.se = c.se;
        this.startTrigger  = c.startTrigger;
        this.type = c.type;
        
    }

    public Clause() {
        this.pospost = new ArrayList<String>();
        this.pospre = new ArrayList<String>();
    }

    public int getA() {
        return a;
    }

    public void setA(int a) {
        this.a = a;
    }

    public String getAgree() {
        return agree;
    }

    public void setAgree(String agree) {
        this.agree = agree;
    }

    public double getConfidence() {
        return confidence;
    }

    public void setConfidence(double confidence) {
        this.confidence = confidence;
    }

    public int getInf() {
        return inf;
    }

    public void setInf(int inf) {
        this.inf = inf;
    }

    public boolean isIsCopulative() {
        return isCopulative;
    }

    public void setIsCopulative(boolean isCopulative) {
        this.isCopulative = isCopulative;
    }

    public boolean isIsImpersonal() {
        return isImpersonal;
    }

    public void setIsImpersonal(boolean isImpersonal) {
        this.isImpersonal = isImpersonal;
    }

    public boolean isIsIntransitive() {
        return isIntransitive;
    }

    public void setIsIntransitive(boolean isIntransitive) {
        this.isIntransitive = isIntransitive;
    }

    public boolean isIsPronominal() {
        return isPronominal;
    }

    public void setIsPronominal(boolean isPronominal) {
        this.isPronominal = isPronominal;
    }

    public boolean isIsTransivite() {
        return isTransivite;
    }

    public void setIsTransivite(boolean isTransivite) {
        this.isTransivite = isTransivite;
    }

    public boolean isIsZeroPronoun() {
        return isZeroPronoun;
    }

    public void setIsZeroPronoun(boolean isZeroPronoun) {
        this.isZeroPronoun = isZeroPronoun;
    }

    public String getLemma() {
        return lemma;
    }

    public void setLemma(String lemma) {
        this.lemma = lemma;
    }

    public int getNhprev() {
        return nhprev;
    }

    public void setNhprev(int nhprev) {
        this.nhprev = nhprev;
    }

    public int getNhtotal() {
        return nhtotal;
    }

    public void setNhtotal(int nhtotal) {
        this.nhtotal = nhtotal;
    }

    public String getNumber() {
        return number;
    }

    public void setNumber(String number) {
        this.number = number;
    }

    public String getPerson() {
        return person;
    }

    public void setPerson(String person) {
        this.person = person;
    }

    public ArrayList<String> getPospost() {
        return pospost;
    }

    public void setPospost(ArrayList<String> pospost) {
        this.pospost = pospost;
    }

    public ArrayList<String> getPospre() {
        return pospre;
    }

    public void setPospre(ArrayList<String> pospre) {
        this.pospre = pospre;
    }

    public boolean isSe() {
        return se;
    }

    public void setSe(boolean se) {
        this.se = se;
    }

    public String getType() {
        if(type==null){
            if(startTrigger.startsWith("PR")){
                type="Rel";
            } else {
                if(startTrigger.startsWith("CS")){
                    type="Imp";
                }
                else {
                    if(startTrigger.startsWith("CC")){
                        type="Prop";
                    } else {
                        type="Punct";
                    }
                }
            }
        }
        return type;
    }

    /*public void setType(String type) {
        this.type = type;
    }*/
 
    private String type;
    private String lemma;
    private String number;
    private String person;
    private String tense;
    private String agree;
    private int nhprev;
    private int nhtotal;
    private int inf;
    private boolean se;
    private int a;
    ArrayList<String> pospre;
    ArrayList<String> pospost;
    private boolean isCopulative;
    private boolean isImpersonal;
    private boolean isPronominal;
    private boolean isTransivite;
    private boolean isIntransitive;
    private boolean isZeroPronoun;
    private double confidence;
    private String startTrigger;
    private String endTrigger;
    private String mode;
    private int num_token;
    private boolean parsedSubject;
    private boolean ismainVerb;
    private String line;
    private int startOffset;
    private int endOffset;
    private String genre;

    public String getGenre() {
        return genre;
    }

    public void setGenre(String genre) {
        this.genre = genre;
    }
    
    public int getEndOffset() {
        return endOffset;
    }

    public void setEndOffset(int endOffset) {
        this.endOffset = endOffset;
    }

    public int getStartOffset() {
        return startOffset;
    }

    public void setStartOffset(int startOffset) {
        this.startOffset = startOffset;
    }
    
    public int getNum_token() {
        return num_token;
    }

    public void setNum_token(int num_token) {
        this.num_token = num_token;
    }
    
    public String getEndTrigger() {
        return endTrigger;
    }

    public void setEndTrigger(String endTrigger) {
        this.endTrigger = endTrigger;
    }

    public String getStartTrigger() {
        return startTrigger;
    }

    public void setStartTrigger(String startTrigger) {
        this.startTrigger = startTrigger;
    }
    
    private int num_sentece;

    public int getNum_sentece() {
        return num_sentece;
    }

    public void setNum_sentece(int num_sentece) {
        this.num_sentece = num_sentece;
    }

    public String getTense() {
        return tense;
    }

    public void setTense(String tense) {
        this.tense = tense;
    }

    public String getMode() {
        return mode;
    }

    public void setMode(String mode) {
        this.mode = mode;
    }
    
    public boolean isIsmainVerb() {
        return ismainVerb;
    }

    public void setIsmainVerb(boolean ismainVerb) {
        this.ismainVerb = ismainVerb;
    }

    public String getLine() {
        return line;
    }

    public void setLine(String line) {
        this.line = line;
    }

    public boolean isParsedSubject() {
        return parsedSubject;
    }

    public void setParsedSubject(boolean parsedSubject) {
        this.parsedSubject = parsedSubject;
    }

    private boolean used;
    
    public boolean isUsed() {
        return used;
    }
    
    public void setUsed(boolean u){
        used = u;
    }
}
