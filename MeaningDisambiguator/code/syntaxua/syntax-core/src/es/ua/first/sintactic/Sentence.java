/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package es.ua.first.sintactic;

import static es.ua.first.sintactic.Sentence.PERO;
import java.util.EnumSet;
import java.util.regex.Pattern;

/**
 *
 * @author imoreno
 */
public class Sentence {
    
    public static final String PERO = "pero";
    public static final Pattern PEROPATTERN = Pattern.compile("^" + PERO);
    public static final String PERO2 = "Pero";
    public static final String SEP = ",";
    public static final String SEPSUBS = "->";
    public static final String TYPE = "adversative";
    private static final String delimiters = "[,\\.\\s\\(\\)_\\{\\}\n\"'\\:<>!¿¡?\\[\\]\\/«»;%-\\+=]+";
    
    
    
    public enum Adversative {
        //AUNQUE("aunque",false,"(?=\\b)aunque(?=\\b)"),
        SINO("sino",false,"(?=\\b)sino(?!\\s+que)"), 
        MAS("mas",false,"(?=\\b)mas(?=\\b)"),
        EMPERO("empero",false,"(?=\\b)empero(?=\\b)"),
        SIN_EMBARGO("sin embargo",false,"(?=\\b)sin\\s+embargo(?=\\b)"),
        NO_OBSTANTE("no obstante",false,"(?=\\b)no\\s+obstante(?=\\b)"),
        SINO_QUE("sino que",false,"(?=\\b)sino\\s+que(?=\\b)"),
        A_PESAR_DE("a pesar de",false,"(?=\\b)a\\s+pesar\\s+de(?=\\b)"),
        EN_CAMBIO("en cambio",false,"(?=\\b)en\\s+cambio(?=\\b)"),
        ESO_SI("eso si", false,"(?=\\b)eso\\s+si(?=\\b)"),
        AHORA_BIEN("ahora bien",false,"(?=\\b)ahora\\s+bien(?=\\b)"),
        ANTES_BIEN("antes bien",false,"(?=\\b)antes\\s+bien(?=\\b)"),
        ANTES_AL_CONTRARIO("antes al contrario",false,"(?=\\b)antes\\s+al\\s+contrario(?=\\b)"),
        POR_EL_CONTRARIO("por el contrario",false,"(?=\\b)por\\s+el\\s+contrario(?=\\b)");
        
        private final String token;
        private final String regex;
        private final boolean mayus;
        private final Pattern pattern;
        Adversative(String v, boolean m, String r){
            this.token = v;
            this.mayus = m;
            this.regex = r;
            pattern = Pattern.compile(this.regex(), Pattern.CASE_INSENSITIVE);
            
        }
        
        public Pattern pattern() { return pattern;}
        public String token(){ return token;}
        public boolean isUppercassed(){ return mayus;}

        String regex() {
            return regex;
        }
    }
    
    public enum NumberWords {
        WORDS15(15), WORDS20(20);
        private final int size;
        NumberWords(int s){this.size = s;}
        public int getValue (){ return size;}
    }
    
    private String orig;
    private String alt;
    private String types;
    private String substitutions;
    private long startNode, endNode;
    private EnumSet<Sentence.Adversative> adversatives;
    private NumberWords numberwords; 
    
    private String[] origsplitted;
    private boolean isLong;

    public Sentence(String orig, long startNode, long endNode, NumberWords numWords) {
        this.orig = orig;
        this.startNode = startNode;
        this.endNode = endNode;
        alt = null;
        types = null;
        substitutions = null;
        adversatives = EnumSet.noneOf(Sentence.Adversative.class);
        origsplitted = null;
        isLong=false;
        numberwords = numWords;
    }
    
    
    public boolean isOriginalLongSentence(){
        origsplitted = (origsplitted==null)? orig.split(delimiters) : origsplitted;
        isLong= (origsplitted.length>=numberwords.getValue());
        return isLong;
    }
    
    public boolean isAlternativeLongSentence(){
        //esta se calcula cada vez porque puede cambiar de la primera vez que se crea, a cuando yo sustituyo.
        return (alt==null)? false: (alt.split(delimiters).length >=numberwords.getValue());
    }

    public String getOrig() {
        return orig;
    }

    public void setOrig(String orig) {
        this.orig = orig;
    }

    public String getAlt() {
        return alt;
    }

    public void setAlt(String alt) {
        this.alt = alt;
    }

    public String getTypes() {
        return types;
    }

    public void setTypes(String types) {
        this.types = types;
    }

    public long getStartNode() {
        return startNode;
    }

    public void setStartNode(long startNode) {
        this.startNode = startNode;
    }

    public long getEndNode() {
        return endNode;
    }

    public void setEndNode(long endNode) {
        this.endNode = endNode;
    }

    public EnumSet<Sentence.Adversative> getAdversatives() {
        return adversatives;
    }

    public void setAdversatives(EnumSet<Sentence.Adversative> adversatives) {
        this.adversatives = adversatives;
    }
    
    public boolean addAdversative(Sentence.Adversative a){
       return this.adversatives.add(a);
    }

    public String getSubstitutions() {
        return substitutions;
    }

    public void setSubstitutions(String substitutions) {
        this.substitutions = substitutions;
    }
    
    
}
