/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package es.ua.first.sintactic;

import gate.Annotation;
import gate.AnnotationSet;
import gate.Document;
import gate.Factory;
import gate.FeatureMap;
import gate.Gate;
import gate.creole.ResourceInstantiationException;
import gate.util.GateException;
import gate.util.InvalidOffsetException;
import gate.util.SimpleFeatureMapImpl;
import java.io.BufferedReader;
import java.io.File;
import java.io.IOException;
import java.util.ArrayList;
import java.util.Iterator;
import java.util.regex.Matcher;
import es.ua.first.sintactic.Sentence.NumberWords;

/**
 *
 * @author imoreno
 */
public class SintacticSimplificator {
    
    public SintacticSimplificator(String gatePath) throws GateException {
        if(!Gate.isInitialised()){
            Gate.setGateHome(new File(gatePath));
            Gate.setSiteConfigFile(new File(Gate.getGateHome().getAbsolutePath() + "/gate.xml"));
            Gate.init();
        }
    }
    
    public String simplifyAdversativeConjunctionAndDetectLongSentences(BufferedReader br, String lang, boolean adversatives, boolean longSentences, NumberWords numwords) throws SintacticSimplificationException{
        StringBuilder original = new StringBuilder();
        try {
            while(br.ready()) {
                String line = br.readLine();
                if(line != null) {
                    
                    original.append(line);
                    original.append('\n');
                }
            }
        } catch (IOException ex) {
            throw new SintacticSimplificationException("Error 4: Problem loading the text.",ex);
        }
        
        return simplifyAdversativeConjunctionAndDetectLongSentences(original.toString(), lang, adversatives, longSentences, numwords);
    }
    
    
    public String simplifyAdversativeConjunctionAndDetectLongSentences(String original, String lang, boolean adversatives, boolean longSentences, NumberWords numWords) throws SintacticSimplificationException{
        gate.Document gDoc;
        try {
            gDoc = Factory.newDocument(original);
        } catch (ResourceInstantiationException ex) {
            throw new SintacticSimplificationException("Error 4: Problem loading the text.",ex);
        }

        ArrayList<Sentence> sentences = readSentencesFromGATEDocument(gDoc, numWords);

//        System.out.println("adversatives:" + adversatives + "  long:" + longSentences);
        if(adversatives)
            detectAndResolveAdversativeConjunctions(sentences); 
        if(longSentences)
            detectLongSentences(sentences);
        return generateGateOutput(sentences, gDoc, adversatives, longSentences);
        
      
    }

    private String generateGateOutput(ArrayList<Sentence> sentences, Document gDoc, boolean adversatives, boolean longSentences) throws SintacticSimplificationException {
        AnnotationSet syntaxAS = gDoc.getAnnotations("syntax");
        
        for(Sentence s: sentences){
            if(adversatives){
                /** if adversatives have been found in this sentence **/
                if(!s.getAdversatives().isEmpty()){ //hemos encontrado adversativas
                    AnnotationSet altSentencesAS = syntaxAS.getCovering("AltSentences", s.getStartNode(), s.getEndNode());
                    /** if this sentence had conjunctions already detected, modify the current annotation **/
                    if(altSentencesAS!=null && !altSentencesAS.isEmpty()){
                        if(altSentencesAS.size()>1)
                            System.err.println("There is more than one AltSentences for one sentence!!");
                        Iterator<Annotation> iterator = altSentencesAS.iterator();
                        if(iterator.hasNext()){
                             Annotation altAnn = iterator.next();
                             syntaxAS.remove(altAnn);

                             FeatureMap features = altAnn.getFeatures();
                             features.put("alternative", s.getAlt());
                             features.put("type", s.getTypes() + "," + Sentence.TYPE);

                             String previousSubstitution = (String)s.getSubstitutions();
                             if(previousSubstitution==null)
                                 previousSubstitution = "";

                             StringBuilder sb = new StringBuilder();
                             if(!previousSubstitution.isEmpty())
                                 sb.append(previousSubstitution).append(",");

                             for(Sentence.Adversative adv : s.getAdversatives()){
                                 sb.append(adv.token());
                                 sb.append("###");
                                 sb.append(Sentence.PERO);
                                 sb.append(",");
                             }

                             String conjSubsValue = sb.toString(); 
                             conjSubsValue = conjSubsValue.substring(0, conjSubsValue.length()-1);
                             features.put("substitution", conjSubsValue);
                             altAnn.setFeatures(features);

                             syntaxAS.add(altAnn);
                        } 
                    } else {
                        /** if this sentence had no conjunctions already detected, create a new annotation **/
                        FeatureMap features = new SimpleFeatureMapImpl();

                        features.put("origtext", s.getOrig());
                        features.put("alternative", s.getAlt());
                        features.put("type",  Sentence.TYPE);

                         StringBuilder sb = new StringBuilder();
                         for(Sentence.Adversative adv : s.getAdversatives()){
                             sb.append(adv.token());
                             sb.append("->");
                             sb.append(Sentence.PERO);
                             sb.append(",");
                         }

                         String conjSubsValue = sb.toString(); 
                         conjSubsValue = conjSubsValue.substring(0, conjSubsValue.length()-1);

                        features.put("substitution", conjSubsValue);
                        try {
                            syntaxAS.add(s.getStartNode(), s.getEndNode(), "AltSentences", features);
                        } catch (InvalidOffsetException ex) {
                            throw new SintacticSimplificationException("Error 3: Problem with offsets generation.",ex);
                        }
                    }
                }
            }
            
            if(longSentences){
            
                /** if this sentence is long **/
                if(s.isOriginalLongSentence()){
                    FeatureMap features = new SimpleFeatureMapImpl();

                    features.put("origtext", s.getOrig());
                    try {
                        syntaxAS.add(s.getStartNode(), s.getEndNode(), "LongSentences", features);
                    } catch (InvalidOffsetException ex) {
                         throw new SintacticSimplificationException("Error 3: Problem with offsets generation.",ex);
                    }
                }
            }
        }
        
//        File outputFile = new File("/home/imoreno/Dropbox/myFIRST/mia/WP3_ANALISISSINTACTICO/ejemplos/allAdversatives.out.xml");
//        gate.corpora.DocumentStaxUtils.writeDocument(gDoc, outputFile);
        
        String xml = gDoc.toXml();
        
        Factory.deleteResource(gDoc);
        
        return xml;
    }
    
    public void detectAndResolveAdversativeConjunctions(ArrayList<Sentence> sentences){
        
        for(int i=0;i< sentences.size(); i++){
            Sentence s = sentences.get(i);

            /** if there is already an alternative, use it **/
            String phrase = (s.getAlt()!=null)? s.getAlt(): s.getOrig();
            
            for(Sentence.Adversative a : Sentence.Adversative.values()){
                /** detection **/
                Matcher matcher = a.pattern().matcher(phrase);
                
                /** replacement **/
                if(matcher.find()){
                    
                    phrase = matcher.replaceAll(Sentence.PERO);
                    
                    int index = phrase.indexOf(Sentence.PERO);
                    if(index==0){
                        
                        Matcher matcherPeroInicio = Sentence.PEROPATTERN.matcher(phrase);
                        phrase = matcherPeroInicio.replaceFirst(Sentence.PERO2);
                    }
                    
                    /** save conjunction **/
                    s.addAdversative(a);
//                    System.out.println(a + " in sentence " + i);
                }
                
            }
            /** save the alternative **/
            s.setAlt(phrase);
            sentences.set(i, s);
        }
        
        
    }
    
    public void detectLongSentences(ArrayList<Sentence> sentences){
        for(int i=0; i<sentences.size(); i++){
            Sentence s = sentences.get(i);
            
            s.isOriginalLongSentence();
            
            sentences.set(i, s);
        }
        
        
    }
    
    public ArrayList<Sentence> readSentencesFromGATEDocument(gate.Document gDoc, NumberWords numWords) throws SintacticSimplificationException {
        ArrayList<Sentence> sentencesList = new ArrayList<Sentence>();
        
        /** obtain the sentences of the current document **/
        AnnotationSet defaultAS = gDoc.getAnnotations();
        AnnotationSet sentencesAS = defaultAS.get("Sentence");
        
        AnnotationSet syntaxAS = gDoc.getAnnotations("syntax");
        
        for(Annotation sentenceAnn: sentencesAS){
            String sentenceOrig;
            try {
                sentenceOrig = gDoc.getContent().getContent(
                                     sentenceAnn.getStartNode().getOffset(),
                                     sentenceAnn.getEndNode().getOffset())
                                     .toString();
            } catch (InvalidOffsetException ex) {
                throw new SintacticSimplificationException("Error 3:  Problem with offsets generation.",ex);
            }
            
            Sentence sentenceObj = new Sentence(sentenceOrig, 
                    sentenceAnn.getStartNode().getOffset(), 
                    sentenceAnn.getEndNode().getOffset(), numWords);
            /** look for altSenteces with the same offsets **/
            AnnotationSet altSentencesAS = syntaxAS.getCovering("AltSentences", sentenceAnn.getStartNode().getOffset(),sentenceAnn.getEndNode().getOffset());
            if(altSentencesAS!=null && !altSentencesAS.isEmpty()){
                if(altSentencesAS.size()>1)
                    System.err.println("There is more than one AltSentences for one sentence!!");
                
                Iterator<Annotation> iterator = altSentencesAS.iterator();
                if(iterator.hasNext()){
                    Annotation altAnn = iterator.next();
                    sentenceObj.setAlt(altAnn.getFeatures().get("alternative").toString());
                    sentenceObj.setTypes(altAnn.getFeatures().get("type").toString());
                    sentenceObj.setSubstitutions(altAnn.getFeatures().get("substitution").toString());
                }
            } 
            
            sentencesList.add(sentenceObj);
        }
        return sentencesList;
    }
    
}
