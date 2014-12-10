/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package es.ua.dictionary;

import java.util.ArrayList;

/**
 *
 * @author lcanales
 */
class ParamsJSON {

//    public enum Information {
//
//        DEFINITIONS, SYNONYMS, DEFSYN;
//    }
//
//    public enum MethodDisambiguation {
//
//        MFS, UKB;
//    }
//
//    public enum Language {
//
//        ES, EN, BG;
//    }
//
//    public enum TypeWords {
//
//        RARE, SPECIALIZED, POLYSEMIC, LONGWORDS, ACRONYMS, OOV;
//    }
//    
    private String lang;
    private String methodDisam;
    private String retunInfo;
    private ArrayList<String> typeWords;
    private Integer numMaxSenses;
    private String address;

    public ParamsJSON(String lang, String methodDisam, String retunInfo, ArrayList<String> typeWords, Integer numMaxDefinitions, String address) {
        this.lang = lang;
        this.methodDisam = methodDisam;
        this.retunInfo = retunInfo;
        this.typeWords = typeWords;
        this.numMaxSenses = numMaxDefinitions;
        this.address = address;
    }

    public ParamsJSON(String lang, ArrayList<String> typeWords, String address) {
        this.lang = lang;
        this.typeWords = typeWords;
        this.address = address;
    }

    public String getAddress() {
        return address;
    }

    public String getLang() {
        return lang;
    }

    public String getMethodDisam() {
        return methodDisam;
    }

    public String getRetunInfo() {
        return retunInfo;
    }

    public ArrayList<String> getTypeWords() {
        return typeWords;
    }

    public Integer getNumMaxSenses() {
        return numMaxSenses;
    }

    public void setLang(String lang) {
        this.lang = lang;
    }

    public void setMethodDisam(String methodDisam) {
        this.methodDisam = methodDisam;
    }

    public void setRetunInfo(String retunInfo) {
        this.retunInfo = retunInfo;
    }

    public void setTypeWords(ArrayList<String> typeWords) {
        this.typeWords = typeWords;
    }

    public void setNumMaxDefinitions(Integer numMaxDefinitions) {
        this.numMaxSenses = numMaxDefinitions;
    }
}
