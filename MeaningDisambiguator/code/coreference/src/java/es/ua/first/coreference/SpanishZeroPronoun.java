/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package es.ua.first.coreference;

import es.ua.first.coreference.util.AnaphoricExpresion;
import es.ua.first.coreference.util.Antecedent;
import es.ua.first.coreference.util.Clause;
import es.upv.xmlutils.XMLUtils;
import java.io.BufferedReader;
import java.io.File;
import java.io.FileReader;
import java.io.IOException;
import java.util.*;
import java.util.logging.Level;
import java.util.logging.Logger;
import org.w3c.dom.Document;
import org.w3c.dom.Element;
import org.w3c.dom.NodeList;
import weka.classifiers.Classifier;
import weka.core.Attribute;
import weka.core.Instance;
import weka.core.Instances;

/**
 *
 * @author imoreno
 */
public class SpanishZeroPronoun extends AnaphoraResolutionUtils implements AnaphoraResolutionInterface  {
    
    private static String appPath;                     //contexto de la aplicación web
    
    Classifier cResolution;                     //modelo para resolver los zero pronoun
    Instances dResolution;                      //info de las cabeceras
    
    Classifier cIdentification;                 //modelo para identificar los zero pronoun
    Instances dIdentification;                  //info de las cabeceras

    HashMap<Integer, ArrayList<Clause>> detectedParsedSubjects; //informacion del análisis de dependencias
    HashMap<Integer, Clause> zeroPronouns; //pronombres omitidos detectados
    
    protected static final String t = "config/Categoría:ES:Verbos_transitivos.txt";
    protected static final String in = "config/Categoría:ES:Verbos_intransitivos.txt";
    protected static final String p = "config/Categoría:ES:Verbos_pronominales.txt";
    protected static final String im = "config/Categoría:ES:Verbos_impersonales.txt";
    protected static final String c = "config/Categoría:ES:Verbos_copulativos.txt";
    
    private static HashSet<String> transitive_verbs;
    private static HashSet<String> intransitive_verbs;
    private static HashSet<String> impersonal_verbs;
    private static HashSet<String> pronominal_verbs;
    private static HashSet<String> copulative_verbs;
    
    private static final double complexity=0.60;
    
    public SpanishZeroPronoun(String path) throws Exception {
        this.appPath = path;
        
        //cargamos los modelos y las cabeceras
        Object obj_exp[] =  weka.core.SerializationHelper.readAll(path+"models/VFI_res_zp.model");
        cResolution = (Classifier)obj_exp[0];
        dResolution = (Instances) obj_exp[1];
        
        obj_exp =  weka.core.SerializationHelper.readAll(path+"models/NBTree_id_zp.model");
        cIdentification = (Classifier)obj_exp[0];
        dIdentification = (Instances) obj_exp[1];
        
        //cargar las listas de verbos
        readCopulativeVerbs();
        readImpersonalVerbs();
        readIntransitiveVerbs();
        readPronominalVerbs();
        readTransitiveVerbs();
    }
    
     private static void readTransitiveVerbs() throws IOException{
       
            File f = new File(appPath+t);
            FileReader fr = new FileReader (f);
            BufferedReader br = new BufferedReader(fr);
            transitive_verbs = new HashSet<String>();
            String linea;
            
            while((linea=br.readLine())!=null){
                transitive_verbs.add(linea);
            }
        
    }
    
    private static void readIntransitiveVerbs() throws IOException{
       
            File f = new File(appPath+in);
            FileReader fr = new FileReader (f);
            BufferedReader br = new BufferedReader(fr);
            intransitive_verbs = new HashSet<String>();
            String linea;
            
            while((linea=br.readLine())!=null){
                intransitive_verbs.add(linea);
            }
        
    }
    
    private static void readImpersonalVerbs() throws IOException{
       
            File f = new File(appPath+im);
            FileReader fr = new FileReader (f);
            BufferedReader br = new BufferedReader(fr);
            impersonal_verbs = new HashSet<String>();
            String linea;
            
            while((linea=br.readLine())!=null){
                impersonal_verbs.add(linea);
            }
        
    }
    
     private static void readPronominalVerbs() throws IOException{
       
            File f = new File(appPath+p);
            FileReader fr = new FileReader (f);
            BufferedReader br = new BufferedReader(fr);
            pronominal_verbs = new HashSet<String>();
            String linea;
            
            while((linea=br.readLine())!=null){
                pronominal_verbs.add(linea);
            }
        
    }
    
    private static void readCopulativeVerbs() throws IOException{
       
            File f = new File(appPath+c);
            FileReader fr = new FileReader (f);
            BufferedReader br = new BufferedReader(fr);
            copulative_verbs = new HashSet<String>();
            String linea;
            
            while((linea=br.readLine())!=null){
                copulative_verbs.add(linea);
            }
        
    }
    
    private HashMap<Integer,Clause> addPosTagsFollowingToken(HashMap<Integer,Clause> clauses, int num_token, String pos_tag){
        
        Clause c = clauses.get(num_token-1);
        if(c!=null){
            ArrayList<String> pospost = c.getPospost();
            if(pospost==null)
                pospost =  new ArrayList<String>();
            pospost.add(pos_tag);
            c.setPospost(pospost);
            //clauses.put(num_token -1, c);
        }
        
        c = clauses.get(num_token-2);
        if(c!=null){
            ArrayList<String> pospost = c.getPospost();
            if(pospost==null)
                pospost =  new ArrayList<String>();
            pospost.add(pos_tag);
            c.setPospost(pospost);
            //clauses.put(num_token -2, c);
        }
        
        c = clauses.get(num_token-3);
        if(c!=null){
            ArrayList<String> pospost = c.getPospost();
            if(pospost==null)
                pospost =  new ArrayList<String>();
            pospost.add(pos_tag);
            c.setPospost(pospost);
            //clauses.put(num_token -3, c);
        }
        
        c = clauses.get(num_token-4);
        if(c!=null){
            ArrayList<String> pospost = c.getPospost();
            if(pospost==null)
                pospost =  new ArrayList<String>();
            pospost.add(pos_tag);
            c.setPospost(pospost);
            //clauses.put(num_token -4, c);
        }
        
        return clauses;
    }
    
    private HashMap<Integer,ArrayList<Clause>> detectParsedSubjects(File outputFreeling) throws AnaphoraResolutionException {
        FileReader fr = null;
        BufferedReader br = null;
        int current_sentence = 0;
        String patronOracion2 = "S_\\[";
        String patronNucleoOracion = "/top/";
        int num_token = 0;
        
        Clause current_clause = null;
 
        
        HashMap<Integer,ArrayList<Clause>> clauses = new HashMap<Integer,ArrayList<Clause>>();
        
        ArrayList<Clause> cclauses = new ArrayList<Clause>();
        
        try {
            // Apertura del fichero y creacion de BufferedReader 
            fr = new FileReader (outputFreeling);
            br = new BufferedReader(fr);

            // Lectura del fichero
            String linea;
            
            while((linea=br.readLine())!=null){
                
                              
                if(linea.contains(patronNucleoOracion)){
                    current_sentence++;
                    cclauses = new ArrayList<Clause>();
                    clauses.put(current_sentence, cclauses);
                    
                } 
                
                //procesamos la oración actual
                if(linea.endsWith(") [")){
                    num_token++;
                    String llinea = linea.substring(linea.indexOf("(")+1, linea.lastIndexOf(")")).trim();
                    if(linea.contains("grup-verb")){
                        current_clause = new Clause();
                        current_clause.setLine(llinea);
                        //es verbo principial si no tiene espacios por delante, 
                        //es decir, comienza en la posicion 0
                        
                        current_clause.setIsmainVerb(linea.contains("grup-verb/top/") || linea.contains("grup-verb/co-v/")); 
                        current_clause.setNum_sentece(current_sentence);
                        cclauses.add(current_clause);
                        
                    }
                    
                    if(linea.contains("/subj/")){
                        current_clause.setParsedSubject(true);
                    }
                }
            }
            
            //la ultima oración
            //clauses.put(current_sentence, cclauses);
        } catch (IOException ex) {
            Logger.getLogger(SpanishZeroPronoun.class.getName()).log(Level.SEVERE, null, ex);
        } finally{
                // En el finally cerramos el fichero, para asegurarnos
                // que se cierra tanto si todo va bien como si salta 
                // una excepcion.
                try{                    
                    if( null != fr ){   
                    fr.close();     
                    }                  
                }catch (Exception e2){ 
                    e2.printStackTrace();
                }
        }   
        
        return clauses;
    }
    
    private HashMap<Integer,Clause> detectZeroPronuns(File outputFreeling, String original) throws AnaphoraResolutionException {
        FileReader fr = null;
        BufferedReader br = null;
        int current_sentence = 0;
        String patronOracion2 = "S_\\[";
        int num_token = 0;
        int start_offset=0, end_offset=0;
        
        Clause current_clause = null;
        Clause previous_clause = null;
        
        int num_sn_o = 0;
        int num_sn_c = 0;
        
        int num_a_c = 0;
        int num_inf_c = 0;
        
        HashMap<Integer,Clause> clauses = new HashMap<Integer,Clause>();
        
        String pos1 = null, pos2 = null, pos3 = null,pos4 = null, pos5 = null;
        
        boolean se = false;
        boolean vp = false;
        try {
            // Apertura del fichero y creacion de BufferedReader 
            fr = new FileReader (outputFreeling);
            br = new BufferedReader(fr);

            // Lectura del fichero
            String linea;
            
            while((linea=br.readLine())!=null){
                
                if(linea.matches(patronOracion2)){
                    current_sentence++;
                    //num_token=0;
                    num_sn_o = 0;
                    num_sn_c = 0;
                    current_clause = new Clause();
                    if(previous_clause!=null)
                        current_clause.setStartTrigger(previous_clause.getEndTrigger());
                    else
                        current_clause.setStartTrigger("");
                }
                
                if(linea.contains("verb_[")){
                    vp = true;
                }
                
                //procesamos la oración actual
                if(linea.contains("+(") || linea.contains("(")){
                    num_token++;
                    String llinea = linea.substring(linea.indexOf("+(")+2).trim();
                    if(!linea.contains("+("))
                        llinea = linea.substring(linea.indexOf("(")+1).trim();
                    String [] aux = llinea.split("\\s+");
                    if(aux[0].contains("_")){
                        start_offset = original.indexOf(aux[0].substring(0, aux[0].indexOf("_")), end_offset);
                        String [] tokens = aux[0].split("_");
                        int tam = 0;
                        for(int i=0; i<tokens.length; i++){
                            tam += tokens[i].length();
                            if(original.substring(start_offset + tam, start_offset + tam +1).equals(" "))
                                tam++;
                        }
                        end_offset = start_offset + tam;
                        //System.out.println(aux[0] + " ->" + start_offset + ", " + end_offset);
                    } else {
                        start_offset = original.indexOf(aux[0], end_offset);
                        int offset_espacio = original.indexOf(" ", start_offset+1);
                        if(offset_espacio>= original.length() || offset_espacio==-1)
                            offset_espacio = original.length()-1;
                        //System.out.println(aux[0] + " ->" + start_offset + ", " + offset_espacio);
                        String o = original.substring(start_offset, offset_espacio);
                        if(offset_espacio==start_offset)
                            o = original.substring(start_offset);
                            end_offset = start_offset + aux[0].length();
                    }
                                
                    if(start_offset == -1 || end_offset ==-1){
                        throw new AnaphoraResolutionException("Error 2: Incorrect offsets generation with "+ num_token +"st token " + aux[0] + " in sentence " + current_sentence);
                    }
                    
                    //nos guardamos el número de aes
                    if(aux[0].equals("a")){
                    num_a_c++; 
                    }
                    
                    //nos guardamos las etiquetas pos
                    pos1 = pos2;
                    pos2 = pos3;
                    pos3 = pos4;
                    pos4 = pos5;
                    pos5 = String.valueOf(aux[2].charAt(0)).toLowerCase();
                    
                    //intentamos añadir la etiqueta pos del token actual, donde nos falten las pos posteriores
                    addPosTagsFollowingToken(clauses, num_token, pos5);
                    
                    //miramos si tenemos un disparador
                    if(aux[2].startsWith("PR") || aux[2].startsWith("CS") || 
                            aux[2].startsWith("CC") || aux[2].startsWith("F")){
                        
                        //hemos encontrado el final de una cláusula y 
                        //el principio de otro. Nos guardamos la cláusula en el 
                        //listado. Pero antes nos guardamos todos los datos que 
                        //nos faltaban.
                        current_clause.setA(num_a_c);
                        current_clause.setEndTrigger(aux[2]);
                        current_clause.setInf(num_inf_c); 
                        current_clause.setNhprev(num_sn_c);
                        current_clause.setNhtotal(num_sn_o);
                        clauses.put(num_token, current_clause); 
                       
                        //dejo la siguiente claúsula preparada
                        previous_clause = new Clause(current_clause);
                        current_clause = new Clause();
                        current_clause.setStartTrigger(previous_clause.getEndTrigger());
                        current_clause.setNum_token(num_token);
                        current_clause.setNum_sentece(current_sentence);
                        num_sn_c = 0;
                        num_a_c =0;
                        num_inf_c =0;
                        se = false;
                        //clauses.put(num_token, current_clause); 
                    }
                    
                    if(aux[2].startsWith("V") && vp){ //verbo principal!
                        //¿es el verbo principal de la oración? ¿tiene sujeto?
                        //System.out.println(linea);
                        ArrayList<Clause> get = detectedParsedSubjects.get(current_sentence);
                        Clause caux = searchClause(get, llinea.substring(0, llinea.length()-1));
                        Clause cmain = caux;
                        if(caux!=null){ 
                            //throw new AnaphoraResolutionException("Error 10: Problem with external NLP tool - Freeling 3.0 with dependency analysis");
                        if(!caux.isIsmainVerb())
                            cmain = getMainClause(get);
//                        if(cmain==null)
//                            throw new AnaphoraResolutionException("Error 10: Problem with external NLP tool - Freeling 3.0 with dependency analysis");
                        vp = false;
                        //saco: lema, num, persona, tiempo, modo y se
                        current_clause.setSe(aux[1].endsWith("se") || se);
                        current_clause.setLemma(aux[1]);
                        current_clause.setNumber(aux[2].substring(5, 6)); 
                        current_clause.setPerson(aux[2].substring(4, 5));
                        current_clause.setTense(aux[2].substring(3, 4));
                        current_clause.setMode(aux[2].substring(2,3));
                        current_clause.setStartOffset(start_offset);
                        current_clause.setEndOffset(end_offset);
                        current_clause.setGenre(aux[2].substring(6, 7));
                        current_clause.setLine(linea);
                                                
                        //ver el tipo de verbo
                        current_clause.setIsCopulative(copulative_verbs.contains(current_clause.getLemma()));
                        current_clause.setIsIntransitive(intransitive_verbs.contains(current_clause.getLemma()));
                        current_clause.setIsTransivite(transitive_verbs.contains(current_clause.getLemma()));
                        current_clause.setIsImpersonal(impersonal_verbs.contains(current_clause.getLemma()));
                        current_clause.setIsPronominal(pronominal_verbs.contains(current_clause.getLemma()));
                        
                        //calcular agree con el anterior en tiempo, modo, persona y modo
                        StringBuilder sb = new StringBuilder();
                        
                            if(previous_clause==null){
                                
                                if(cmain==null || cmain!=null && caux.isIsmainVerb()){
                                    //no tiene ni verbo principal ni anterior ó él es el verbo principal
                                    sb.append("TTTT");
                                } else {
                                    if(!caux.isIsmainVerb()){
                                        //calculamos con el verbo principal
                                        Boolean sameTense = current_clause.getTense().equals(cmain.getTense());
                                        Boolean sameMode = current_clause.getMode().equals(cmain.getMode());
                                        Boolean samePerson = current_clause.getPerson().equals(cmain.getPerson());
                                        Boolean sameNumber = current_clause.getNumber().equals(cmain.getNumber());
                                        sb.append((sameTense)? "T" : "F");
                                        sb.append((sameMode)? "T" : "F");
                                        sb.append((samePerson)? "T" : "F");
                                        sb.append((sameNumber)? "T" : "F");
                                    }
                                }
                                
                                    
                                } else {
                                    
                                    if( cmain==null ||(cmain!=null && caux.isIsmainVerb())){ //calcular solo con el anterior 
                                        Boolean sameTense = current_clause.getTense().equals(previous_clause.getTense());
                                        Boolean sameMode = current_clause.getMode().equals(previous_clause.getMode());
                                        Boolean samePerson = current_clause.getPerson().equals(previous_clause.getPerson());
                                        Boolean sameNumber = current_clause.getNumber().equals(previous_clause.getNumber());
                                        sb.append((sameTense)? "T" : "F");
                                        sb.append((sameMode)? "T" : "F");
                                        sb.append((samePerson)? "T" : "F");
                                        sb.append((sameNumber)? "T" : "F");
                                    } else {
                                        //calcular con el anterior y el verbo principal
                                        Boolean sameTense = current_clause.getTense().equals(previous_clause.getTense()) 
                                                && current_clause.getTense().equals(cmain.getTense());
                                        Boolean sameMode = current_clause.getMode().equals(previous_clause.getMode()) 
                                                && current_clause.getMode().equals(cmain.getMode());
                                        Boolean samePerson = current_clause.getPerson().equals(previous_clause.getPerson()) 
                                                && current_clause.getPerson().equals(cmain.getPerson());
                                        Boolean sameNumber = current_clause.getNumber().equals(previous_clause.getNumber()) 
                                                && current_clause.getNumber().equals(cmain.getNumber());
                                        sb.append((sameTense)? "T" : "F");
                                        sb.append((sameMode)? "T" : "F");
                                        sb.append((samePerson)? "T" : "F");
                                        sb.append((sameNumber)? "T" : "F");
                                    }


                                }
                        
                        current_clause.setAgree(sb.toString());
                        current_clause.setIsmainVerb(caux.isIsmainVerb());
                        current_clause.setParsedSubject(caux.isParsedSubject());
                        
                        ArrayList<String> pre = new ArrayList<String>();
                        pre.add(pos1);
                        pre.add(pos2);
                        pre.add(pos3);
                        pre.add(pos4);
                        current_clause.setPospre(pre);
                        
                    } else {
                            vp = true; //si al buscarlo entre el análisis de dependencias, no lo he encontrado lo ignoro porque será auxiliar.
                        }
                    
                    }
                    
                }
                
                linea = linea.trim();
                if(linea.startsWith("morfema-verbal_[")){
                    se = true;
                }
                
                if(linea.startsWith("+infinitiu_[")){
                    se = true;
                }
                
                if(linea.startsWith("sn_[")){
                    num_sn_c++;
                    num_sn_o++;
                }      
                
            }
        } catch (IOException ex) {
            Logger.getLogger(SpanishZeroPronoun.class.getName()).log(Level.SEVERE, null, ex);
        } finally{
                // En el finally cerramos el fichero, para asegurarnos
                // que se cierra tanto si todo va bien como si salta 
                // una excepcion.
                try{                    
                    if( null != fr ){   
                    fr.close();     
                    }                  
                }catch (Exception e2){ 
                    e2.printStackTrace();
                }
        }
        
        return clauses;
    }

    /**
     * Busco la clausula cuya linea, se igual que llinea. (sin paréntesis)
     * @param get
     * @param llinea
     * @return 
     */
    private Clause searchClause(ArrayList<Clause> get, String llinea) {
        //TO-DO: AQUI DEBERÍA INCLUIR LO DE SI NO ES CONJUNCION, MIRAR LA CLAUSULA ENTRE SIGNOS DE PUNTUACIÓN
        boolean enc = false;
        Clause cl = null;
        for(int i=0; i<get.size() && !enc; i++){
            cl = get.get(i);
            if(cl.getLine().equals(llinea) && !cl.isUsed()){
                enc = true;
                cl.setUsed(true);
            }
        }
        
        return (enc)? cl : null;
    }
    
    private Clause getMainClause(ArrayList<Clause> get){
        boolean enc = false;
        Clause cl = null;
        for(int i=0; i<get.size() && !enc; i++ ){
            cl = get.get(i);
            if(cl.isIsmainVerb())
                enc = true;
        }
        return (enc)? cl : null;
    }

    private HashMap<Integer,Clause> obtainZeroPronouns(HashMap<Integer, Clause> clauses) throws AnaphoraResolutionException {
        HashMap<Integer,Clause> zero = new HashMap<Integer,Clause>();
        
        for(Integer i: clauses.keySet()){
            Clause cl = clauses.get(i);
            
            if(cl.getLemma()!=null){
            
                //llamamos a weka para ver si es un zero pronoun o no
                Instance ins = new Instance(25);                      
                ins.setDataset(dIdentification);
                ins.setMissing(24);
                ins.setValue(0, Boolean.toString(cl.isParsedSubject()));
                if(cl.getType()!=null)
                    ins.setValue(1, cl.getType());
                else 
                    ins.setMissing(1);
                if(cl.getLemma()!=null){
                    Attribute lema = dIdentification.attribute(2);
                    boolean existToken = lema.indexOfValue(cl.getLemma())!=-1; //conozco este token si su índice no es -1
                    if(!existToken)
                        ins.setMissing(2);
                    else
                        ins.setValue(2, cl.getLemma());
                    
                } else
                    ins.setMissing(2);
                if(cl.getNumber()!=null && !cl.getNumber().equals("0")) //el 0 es desconocido para freeling
                    ins.setValue(3, cl.getNumber().toLowerCase());
                else
                    ins.setMissing(3);
                if(cl.getPerson()!=null && !cl.getPerson().equals("0"))
                    ins.setValue(4, cl.getPerson());
                else
                    ins.setMissing(4);
                if(cl.getAgree()!=null )
                    ins.setValue(5, cl.getAgree());
                else
                    ins.setMissing(5);
                ins.setValue(6, cl.getNhprev());
                ins.setValue(7, cl.getNhtotal());
                ins.setValue(8, cl.getInf());
                ins.setValue(9, Boolean.toString(cl.isSe()));
                ins.setValue(10, cl.getA());

                ArrayList<String> pospre = cl.getPospre();
                for(int att=11; att<15 && (pospre.size()<(att-11)); att++){
                    ins.setValue(att, pospre.get(att-11));
                }

                ArrayList<String> pospos = cl.getPospost();
                for(int att=15; att<19 && (pospos.size()<(att-15)); att++){
                    ins.setValue(att, pospos.get(att-15));
                }

                ins.setValue(19, Boolean.toString(cl.isIsCopulative()));
                ins.setValue(20, Boolean.toString(cl.isIsImpersonal()));
                ins.setValue(21, Boolean.toString(cl.isIsPronominal()));
                ins.setValue(22, Boolean.toString(cl.isIsTransivite()));
                ins.setValue(23, Boolean.toString(cl.isIsIntransitive()));             
                try {
                    double[] res = cIdentification.distributionForInstance(ins);
                    if(res[0]< res[1]){
                        cl.setConfidence(res[1]);
                        cl.setIsZeroPronoun(true);
                        zero.put(i, cl); //lo incluimos en la lista para resolver
                    } else {
                        cl.setConfidence(res[0]);
                        cl.setIsZeroPronoun(false);
                    }
                } catch (Exception ex) {
                    throw new AnaphoraResolutionException("Error 5: Problem with external tool, weka: Incorrect value features", ex);
                }
            }
        }
        
        return zero;
    }

    private AnaphoricExpresion resolveZeroPronoun(Clause c, HashMap<Integer, ArrayList<Antecedent>> antecedents) throws AnaphoraResolutionException {
        
        AnaphoricExpresion a = new AnaphoricExpresion();
        a.position = c.getStartOffset();
        a.endPosition = c.getEndOffset();
        a.word = c.getLine();
        a.antecedent = null;
        
        //sacamos las características del prononbre omitido
        Instance ins = new Instance(15);                      
        ins.setDataset(dResolution);
        ins.setMissing(14);
        
        if(c.isParsedSubject())
            ins.setMissing(0); //función sintáctica del pronombre, por ahora desconocido, tb puede ser sujeto
        else
            ins.setValue(0, "suj");
        //if(c.getNumber()!=null)
        //    ins.setValue(1, c.getNumber().toLowerCase());//numero
        //else
            ins.setMissing(1);
        ins.setMissing(2);//genero
        //if(c.getPerson()!=null)
        //    ins.setValue(3, c.getPerson());//persona
        //else
            ins.setMissing(3);
        
        
        //para cada antecedente - empezamos por la oracion actual
        for(Integer oracion: antecedents.keySet()){
            ArrayList<Antecedent> ants = antecedents.get(oracion);
            Iterator<Antecedent> iterator = ants.iterator();
            
            while(iterator.hasNext()){
                Antecedent next = iterator.next();
                
                if(next.core!=null && next.endPosition<=c.getStartOffset()){
                    String []aux2 = next.core.split("\\s+");
                    
                    Attribute token = dResolution.attribute(4);
                    boolean existToken = token.indexOfValue(aux2[0])!=-1; //conozco este token si su índice no es -1
                    if(!existToken)
                        ins.setMissing(4); //palabra: es desconocido en entrenamiento
                    else
                        ins.setValue(token, aux2[0]);
                    
                    Attribute lemma = dResolution.attribute(5);
                    boolean existLemma = lemma.indexOfValue(aux2[2])!=-1;
                    if(!existLemma)
                        ins.setMissing(5); //lema: es desconocido en entrenamiento
                    else
                        ins.setValue(lemma, aux2[1]);
                    
                    String numero2 = Character.toString(aux2[2].charAt(3));
                    numero2 = (numero2.equals("N")|| numero2.equals("0"))? "c":numero2.toLowerCase();
                    ins.setValue(6, numero2); //numero
                    String genero2 = Character.toString(aux2[2].charAt(2)); 
                    genero2 = (genero2.equals("0"))? "c":genero2.toLowerCase();
                    ins.setValue(7, genero2); //genero
                    ins.setMissing(8); //los nombres no tienen persona

                    if(aux2[2].charAt(1)!='N'){
                        //tenemos en cuenta la en del nombre
                        String ne_nombre = aux2[2].substring(5, 6);
                        //other,org,loc,person,date,number
                        if(ne_nombre.equals("SP"))
                                ne_nombre = "person";
                        else if(ne_nombre.startsWith("G"))
                            ne_nombre = "loc";
                        else if(ne_nombre.startsWith("O"))
                            ne_nombre = "org";
                        else ne_nombre ="other";
                        ins.setValue(9, ne_nombre);
                    }

                    //2.2.2 Generar características ML que relacionan a ambos
                    int dist = next.startPosition - c.getStartOffset(); //distancia en la misma oración
                    if(c.getNum_sentece()>oracion)
                        dist = next.startPosition + c.getStartOffset(); //distancia en la oración anterior
                    ins.setValue(10, dist);
                    ins.setValue(11, 1);
                    if(c.getNumber()!=null && numero2!=null)
                        ins.setValue(12, (c.getNumber().equals(numero2))? 2: 0);
                    else
                        ins.setMissing(12);
                    if(c.getNumber()!=null && numero2!=null)
                        ins.setValue(13, (c.getGenre().equals(genero2))? 2: 0);
                    else
                        ins.setMissing(13);
                    ins.setValue(14, 0);
                    try {
                        //2.2.3 Obtener la clasificación con ML según el tipo de pronombre
                        double[] res = cResolution.distributionForInstance(ins);
                        //System.out.println(res[1] + " - " + res[0]);
                        if(res[0]<res[1]){
                            next.confidence = res[1];
                            a.antecedentsSet.add(next);
                        }
                        if(res[0]< res[1] && (a.antecedent==null || (a.antecedent!=null && res[1]>=a.antecedent.confidence))){
                            next.confidence = res[1];
                            a.antecedent = next;
                            //System.out.println("Entro!!");
                        }
                    } catch (Exception ex) {
                        Logger.getLogger(SpanishZeroPronoun.class.getName()).log(Level.SEVERE, null, ex);
                        throw new AnaphoraResolutionException("Error 5: Problem with external tool, weka: Incorrect value features", ex);
                    }

                }
            }
        }
        
        return a;
            
    }
    
    
    /**
     * Resolve only zero pronouns. This function is independet.
     * 
     * @param gDocument A gate document to resolve
     * @return a new gate document with a new annotation set that contains the resolution.
     * @throws AnaphoraResolutionException 
     */
    public String resolveAnaphora(String gDocument) throws AnaphoraResolutionException {
        String newDoc = gDocument;      
        Document doc = null;
        Element documentElement = null;
        Element textWithNodesElement = null;
        Element asde = null;
        int minNewId = -1;
        
        try {
            doc = XMLUtils.readXML(gDocument,"UTF8");
            documentElement = doc.getDocumentElement();
            textWithNodesElement = XMLUtils.getElementNamed(documentElement, "TextWithNodes");

            minNewId = getNextFreeID(doc);
            
            asde = insertNewAnnotationSet(doc, "Ellipsis Anaphora markups");
            
        } catch(Exception e){
            throw new AnaphoraResolutionException("Error 6: Problem processing input document due to parsing problems",e); //error parsing gate format
        }
        
        File outputFreeling = null;
        try {
            outputFreeling = runFreeling(textWithNodesElement.getTextContent(), appPath, "dep");
            detectedParsedSubjects = detectParsedSubjects(outputFreeling);
            outputFreeling.delete();
            
        } catch (IOException ex) {
            throw new AnaphoraResolutionException("Error 3: Problem with external NLP tool: freeling",ex);
        } catch (InterruptedException ex) {
            throw new AnaphoraResolutionException("Error 3: Problem with external NLP tool: freeling",ex);
        }
        
        /** CUANDO UNA LOS 3 TIPOS EN UNO, ESTO DESAPARECERÁ DE AQUÍ**/
        
        try {
            outputFreeling = runFreeling(textWithNodesElement.getTextContent(), appPath);
        } catch (IOException ex) {
            Logger.getLogger(SpanishDefiniteDescription.class.getName()).log(Level.SEVERE, null, ex);
            throw new AnaphoraResolutionException("Error 3: Problem with external NLP tool: freeling",ex);
        } catch (InterruptedException ex) {
            Logger.getLogger(SpanishDefiniteDescription.class.getName()).log(Level.SEVERE, null, ex);
            throw new AnaphoraResolutionException("Error 3: Problem with external NLP tool: freeling",ex);

        }
        
        //procesamos el texto a partir de la salida de freeling
        
        //2.1 detectar los verbos de todas las claúsulas de las frases, para distinguir si son zero pronouns o no
        
        try {
            textWithNodesElement = XMLUtils.getElementNamed(documentElement, "TextWithNodes");
            //detect verbs clauses + extract verb features;
            HashMap<Integer, Clause> clauses = detectZeroPronuns(outputFreeling, textWithNodesElement.getTextContent());
            //obtain if there are zero pronouns in each clause
            zeroPronouns = obtainZeroPronouns(clauses);
        } catch (Exception ex) {
            Logger.getLogger(SpanishDefiniteDescription.class.getName()).log(Level.SEVERE, null, ex);
            throw new AnaphoraResolutionException("Error 3: Problem with external NLP tool: freeling",ex);
        }
        
        //2.2 detectar los antecedentes de cada zero pronun
        ArrayList<AnaphoricExpresion> anaphors = new ArrayList<AnaphoricExpresion>();
        
        for(Integer i: zeroPronouns.keySet()) {
            Clause cl = zeroPronouns.get(i);
            if(cl.getType()!=null){ 
                //solo si es un verbo buscamos antecedentes y resolvemos.
                    HashMap<Integer,ArrayList<Antecedent>> antecedents = null;
                    try {
                        antecedents = detectAntecedentsInSentence(cl.getNum_sentece(), 
                                                                    outputFreeling, 
                                                                    textWithNodesElement.getTextContent());
                    } catch (AnaphoraResolutionException ex) {
                        throw ex;
                    }

                    //generar caracteristicas ML para el pronombre y el antecedente y resolver
                    
                    AnaphoricExpresion zp = resolveZeroPronoun(cl, antecedents);
                    anaphors.add(zp);
                }
                
        }
            
        
        
        TreeSet<Integer> node_offsets = new TreeSet<Integer>();
           
        //guardar el resultado en la salida
        for(AnaphoricExpresion a: anaphors){
        
             //1. rellanamos el nuevo annotationset
            if(a.antecedentsSet!=null && !a.antecedentsSet.isEmpty()){ //esta resuelto
//             if(a.antecedent!=null){ 
                Collections.sort(a.antecedentsSet);
                String idAntecedente = null;
                Iterator<Antecedent> iterator = a.antecedentsSet.iterator();
                StringBuilder idsAntecedents = new StringBuilder();
                StringBuilder startNodeAntecedents = new StringBuilder();
                StringBuilder endNodeAntecedents = new StringBuilder(); 
                StringBuilder confidenceAntecedents = new StringBuilder();
                
                while(iterator.hasNext()){
                    Antecedent next = iterator.next();
                    if(!node_offsets.contains(next.startPosition) 
                        && !node_offsets.contains(next.endPosition)){
                        Element antecedentElement = doc.createElement("Annotation");
                        idAntecedente = Integer.toString(minNewId);
                        antecedentElement.setAttribute("Id", minNewId+"");
                        if(next.startPosition==-1){
                            node_offsets.add(0);
                            antecedentElement.setAttribute("StartNode", "0"); 
                        } else {
                            node_offsets.add(next.startPosition);
                            antecedentElement.setAttribute("StartNode", next.startPosition+""); 
                        }
                        antecedentElement.setAttribute("EndNode", next.endPosition+""); 
                        node_offsets.add(next.endPosition);
                        antecedentElement.setAttribute("Type", "DiscourseEntity");
                        asde.appendChild(antecedentElement); //"Discourse Entity markups");
                        minNewId++;
                    } else {
                        //sino es que este antecedente ya esta marcado pero 
                        // tengo que saber su id para no liarla

                        NodeList annotations = XMLUtils.getElementsNamed(asde, "Annotation");

                        boolean enc = false;

                        for(int indice=0; indice< annotations.getLength() && !enc; indice++){
                            Element item = (Element) annotations.item(indice);
                            Integer startp = Integer.parseInt(item.getAttribute("StartNode"));
                            Integer endp = Integer.parseInt(item.getAttribute("EndNode"));
                            if(startp.equals(next.startPosition) 
                                    && endp.equals(next.endPosition)){
                                idAntecedente = item.getAttribute("Id");
                                enc = true;
                            }
                        }

                        if (!enc){
                            System.err.println("¡OJO! POSIBLE BUG: No se encuentra la anotación de "
                                    + textWithNodesElement.getTextContent().substring(
                                    next.startPosition, 
                                    next.endPosition) 
                                    + " en la posición " + 
                                    next.startPosition +"," 
                                    + next.endPosition);
                        }
                    }
                    
                    idsAntecedents.append(idAntecedente).append("|");
                    startNodeAntecedents.append(next.startPosition).append("|");
                    endNodeAntecedents.append(next.endPosition).append("|");
                    confidenceAntecedents.append(next.confidence).append("|");
                }
                
                Element pronounElement = doc.createElement("Annotation");
                pronounElement.setAttribute("Id", minNewId+"");
                pronounElement.setAttribute("StartNode", a.position+"");
                node_offsets.add(a.position);
                pronounElement.setAttribute("EndNode", a.position+""); 
                node_offsets.add(a.endPosition);
                pronounElement.setAttribute("Type", "Ellipsis");
                asde.appendChild(pronounElement);
                
                Element feature = doc.createElement("Feature");
                pronounElement.appendChild(feature);
                Element name = doc.createElement("Name");
                name.setAttribute("className", "java.lang.String");
                name.setTextContent("complexity");
                feature.appendChild(name);
                Element value = doc.createElement("Value");
                value.setAttribute("className", "java.lang.String");
//                value.setTextContent("0.85");
                value.setTextContent(Double.toString(complexity));
                feature.appendChild(value);
                
                /*** añadimos la información de todos los posibles antecedentes ***/

                feature = doc.createElement("Feature");
                pronounElement.appendChild(feature);
                name = doc.createElement("Name");
                name.setAttribute("className", "java.lang.String");
                name.setTextContent("StartNodeAntecedent");
                feature.appendChild(name);
                value = doc.createElement("Value");
                value.setAttribute("className", "java.lang.String");
//                value.setTextContent(a.antecedent.startPosition+"");
                value.setTextContent(startNodeAntecedents.substring(0, startNodeAntecedents.length()-1)); //quitamos el último |
                feature.appendChild(value);

                feature = doc.createElement("Feature");
                pronounElement.appendChild(feature);
                name = doc.createElement("Name");
                name.setAttribute("className", "java.lang.String");
                name.setTextContent("EndNodeAntecedent");
                feature.appendChild(name);
                value = doc.createElement("Value");
                value.setAttribute("className", "java.lang.String");
//                value.setTextContent(a.antecedent.endPosition+"");
                value.setTextContent(endNodeAntecedents.substring(0, endNodeAntecedents.length()-1)); //quitamos el último |
                feature.appendChild(value);

                feature = doc.createElement("Feature");
                pronounElement.appendChild(feature);
                name = doc.createElement("Name");
                name.setAttribute("className", "java.lang.String");
                name.setTextContent("confidence");
                feature.appendChild(name);
                value = doc.createElement("Value");
                value.setAttribute("className", "java.lang.String");
//                value.setTextContent(a.antecedent.confidence+"");
                 value.setTextContent(confidenceAntecedents.substring(0, confidenceAntecedents.length()-1)); //quitamos el último |
                feature.appendChild(value);

                feature = doc.createElement("Feature");
                pronounElement.appendChild(feature);
                name = doc.createElement("Name");
                name.setAttribute("className", "java.lang.String");
                name.setTextContent("AntecedentId");
                feature.appendChild(name);
                value = doc.createElement("Value");
                value.setAttribute("className", "java.lang.String");
//                value.setTextContent(idAntecedente);
                value.setTextContent(idsAntecedents.substring(0, idsAntecedents.length()-1)); //quitamos el último |
                feature.appendChild(value);


                minNewId++;
                
            } else {
                Element pronounElement = doc.createElement("Annotation");
                pronounElement.setAttribute("Id", minNewId+"");
                pronounElement.setAttribute("StartNode", a.position+"");
                node_offsets.add(a.position);
                pronounElement.setAttribute("EndNode", a.position+""); 
                //node_offsets.add(a.position);
                pronounElement.setAttribute("Type", "Ellipsis");
                asde.appendChild(pronounElement);
                
                Element feature = doc.createElement("Feature");
                pronounElement.appendChild(feature);
                Element name = doc.createElement("Name");
                name.setAttribute("className", "java.lang.String");
                name.setTextContent("complexity");
                feature.appendChild(name);
                Element value = doc.createElement("Value");
                value.setAttribute("className", "java.lang.String");
//                value.setTextContent("0.85");
                value.setTextContent(Double.toString(complexity));
                feature.appendChild(value);
                
                minNewId++;
            }
        }
        
        //modificar el gDocument para incluir las anotaciones:
        //los que ya tuvieramos y los de nuestras nuevas anotaciones,
        //teniendo en cuenta la salida de freeling para saber donde ponerlos
        try {
            addOffsetNodes(textWithNodesElement,node_offsets, doc);
        } catch(Exception ex){
            Logger.getLogger(SpanishDefiniteDescription.class.getName()).log(Level.SEVERE, null, ex);
            throw new AnaphoraResolutionException("Error 2: Incorrect offsets generation",ex);
        }

        try{
            outputFreeling.delete(); //ahora que ya no necesito la salida de freeling, borro el fichero

            newDoc = generateStringOutput(doc);
        } catch (Exception ex) {
            Logger.getLogger(SpanishDefiniteDescription.class.getName()).log(Level.SEVERE, null, ex);
            throw new AnaphoraResolutionException("Error 7: Problem generating output document",ex);

        } 
        
        
        return newDoc;
    }

    public String resolveAnaphora(String text, File outputFreeling, int nextID, Element as, Document doc) throws AnaphoraResolutionException {
        String newDoc = text;      
        Element documentElement = null;
        Element textWithNodesElement = null;
        Element asde = as;
        int minNewId = nextID;
        
        try {
            
            documentElement = doc.getDocumentElement();
            textWithNodesElement = XMLUtils.getElementNamed(documentElement, "TextWithNodes");
            
        } catch(Exception e){
            throw new AnaphoraResolutionException("Error 6: Problem processing input document due to parsing problems",e); //error parsing gate format
        }
        
        File outputFreeling2 = null;
        try {
            outputFreeling2 = runFreeling(textWithNodesElement.getTextContent(), appPath, "dep");
            detectedParsedSubjects = detectParsedSubjects(outputFreeling2);
            outputFreeling2.delete();
            
        } catch (IOException ex) {
            throw new AnaphoraResolutionException("Error 3: Problem with external NLP tool: freeling",ex);
        } catch (InterruptedException ex) {
            throw new AnaphoraResolutionException("Error 3: Problem with external NLP tool: freeling",ex);
        }
        
        //procesamos el texto a partir de la salida de freeling
        //2.1 detectar los verbos de todas las claúsulas de las frases, para distinguir si son zero pronouns o no
        try {
            textWithNodesElement = XMLUtils.getElementNamed(documentElement, "TextWithNodes");
            //detect verbs clauses + extract verb features;
            HashMap<Integer, Clause> clauses = detectZeroPronuns(outputFreeling, textWithNodesElement.getTextContent());
            //obtain if there are zero pronouns in each clause
            zeroPronouns = obtainZeroPronouns(clauses);
        } catch (Exception ex) {
            Logger.getLogger(SpanishDefiniteDescription.class.getName()).log(Level.SEVERE, null, ex);
            throw new AnaphoraResolutionException("Error 3: Problem with external NLP tool: freeling",ex);
        }
        
        //2.2 detectar los antecedentes de cada zero pronun
        ArrayList<AnaphoricExpresion> anaphors = new ArrayList<AnaphoricExpresion>();
        
        for(Integer i: zeroPronouns.keySet()) {
            Clause cl = zeroPronouns.get(i);
            if(cl.getType()!=null){ 
                //solo si es un verbo buscamos antecedentes y resolvemos.
                    HashMap<Integer,ArrayList<Antecedent>> antecedents = null;
                    try {
                        antecedents = detectAntecedentsInSentence(cl.getNum_sentece(), 
                                                                    outputFreeling, 
                                                                    textWithNodesElement.getTextContent());
                    } catch (AnaphoraResolutionException ex) {
                        throw ex;
                    }

                    //generar caracteristicas ML para el pronombre y el antecedente y resolver
                    
                    AnaphoricExpresion zp = resolveZeroPronoun(cl, antecedents);
                    anaphors.add(zp);
                }
                
        }
            
        
        
        TreeSet<Integer> node_offsets = new TreeSet<Integer>();
           
        //guardar el resultado en la salida
        for(AnaphoricExpresion a: anaphors){
        
             //1. rellanamos el nuevo annotationset
            if(a.antecedentsSet!=null && !a.antecedentsSet.isEmpty()){ //esta resuelto
//             if(a.antecedent!=null){ 
                String idAntecedente = null;
                Collections.sort(a.antecedentsSet);
                Iterator<Antecedent> iterator = a.antecedentsSet.iterator();
                StringBuilder idsAntecedents = new StringBuilder();
                StringBuilder startNodeAntecedents = new StringBuilder();
                StringBuilder endNodeAntecedents = new StringBuilder(); 
                StringBuilder confidenceAntecedents = new StringBuilder();
                
                while(iterator.hasNext()){
                    Antecedent next = iterator.next();
                    if(!node_offsets.contains(next.startPosition) 
                        && !node_offsets.contains(next.endPosition)){
                        Element antecedentElement = doc.createElement("Annotation");
                        idAntecedente = Integer.toString(minNewId);
                        antecedentElement.setAttribute("Id", minNewId+"");
                        if(next.startPosition==-1){
                            node_offsets.add(0);
                            antecedentElement.setAttribute("StartNode", "0"); 
                        } else {
                            node_offsets.add(next.startPosition);
                            antecedentElement.setAttribute("StartNode", next.startPosition+""); 
                        }
                        antecedentElement.setAttribute("EndNode", next.endPosition+""); 
                        node_offsets.add(next.endPosition);
                        antecedentElement.setAttribute("Type", "DiscourseEntity");
                        asde.appendChild(antecedentElement); //"Discourse Entity markups");
                        minNewId++;
                    } else {
                        //sino es que este antecedente ya esta marcado pero 
                        // tengo que saber su id para no liarla

                        NodeList annotations = XMLUtils.getElementsNamed(asde, "Annotation");

                        boolean enc = false;

                        for(int indice=0; indice< annotations.getLength() && !enc; indice++){
                            Element item = (Element) annotations.item(indice);
                            Integer startp = Integer.parseInt(item.getAttribute("StartNode"));
                            Integer endp = Integer.parseInt(item.getAttribute("EndNode"));
                            if(startp.equals(next.startPosition) 
                                    && endp.equals(next.endPosition)){
                                idAntecedente = item.getAttribute("Id");
                                enc = true;
                            }
                        }

                        if (!enc){
                            System.err.println("¡OJO! POSIBLE BUG: No se encuentra la anotación de "
                                    + textWithNodesElement.getTextContent().substring(
                                    next.startPosition, 
                                    next.endPosition) 
                                    + " en la posición " + 
                                    next.startPosition +"," 
                                    + next.endPosition);
                        }
                    }
                    
                    idsAntecedents.append(idAntecedente).append("|");
                    startNodeAntecedents.append(next.startPosition).append("|");
                    endNodeAntecedents.append(next.endPosition).append("|");
                    confidenceAntecedents.append(next.confidence).append("|");
                }
                
                Element pronounElement = doc.createElement("Annotation");
                pronounElement.setAttribute("Id", minNewId+"");
                pronounElement.setAttribute("StartNode", a.position+"");
                node_offsets.add(a.position);
                pronounElement.setAttribute("EndNode", a.position+""); 
                node_offsets.add(a.endPosition);
                pronounElement.setAttribute("Type", "Ellipsis");
                asde.appendChild(pronounElement);
                
                Element feature = doc.createElement("Feature");
                pronounElement.appendChild(feature);
                Element name = doc.createElement("Name");
                name.setAttribute("className", "java.lang.String");
                name.setTextContent("complexity");
                feature.appendChild(name);
                Element value = doc.createElement("Value");
                value.setAttribute("className", "java.lang.String");
//                value.setTextContent("0.85");
                value.setTextContent(Double.toString(complexity));
                feature.appendChild(value);
                
                /*** añadimos la información de todos los posibles antecedentes ***/

                feature = doc.createElement("Feature");
                pronounElement.appendChild(feature);
                name = doc.createElement("Name");
                name.setAttribute("className", "java.lang.String");
                name.setTextContent("StartNodeAntecedent");
                feature.appendChild(name);
                value = doc.createElement("Value");
                value.setAttribute("className", "java.lang.String");
//                value.setTextContent(a.antecedent.startPosition+"");
                
                value.setTextContent(startNodeAntecedents.substring(0, startNodeAntecedents.length()-1)); //quitamos el último |
                feature.appendChild(value);

                feature = doc.createElement("Feature");
                pronounElement.appendChild(feature);
                name = doc.createElement("Name");
                name.setAttribute("className", "java.lang.String");
                name.setTextContent("EndNodeAntecedent");
                feature.appendChild(name);
                value = doc.createElement("Value");
                value.setAttribute("className", "java.lang.String");
//                value.setTextContent(a.antecedent.endPosition+"");
                value.setTextContent(endNodeAntecedents.substring(0, endNodeAntecedents.length()-1)); //quitamos el último |
                feature.appendChild(value);

                feature = doc.createElement("Feature");
                pronounElement.appendChild(feature);
                name = doc.createElement("Name");
                name.setAttribute("className", "java.lang.String");
                name.setTextContent("confidence");
                feature.appendChild(name);
                value = doc.createElement("Value");
                value.setAttribute("className", "java.lang.String");
//                value.setTextContent(a.antecedent.confidence+"");
                 value.setTextContent(confidenceAntecedents.substring(0, confidenceAntecedents.length()-1)); //quitamos el último |
                feature.appendChild(value);

                feature = doc.createElement("Feature");
                pronounElement.appendChild(feature);
                name = doc.createElement("Name");
                name.setAttribute("className", "java.lang.String");
                name.setTextContent("AntecedentId");
                feature.appendChild(name);
                value = doc.createElement("Value");
                value.setAttribute("className", "java.lang.String");
//                value.setTextContent(idAntecedente);
                value.setTextContent(idsAntecedents.substring(0, idsAntecedents.length()-1)); //quitamos el último |
                feature.appendChild(value);


                minNewId++;
                
            } else {
                Element pronounElement = doc.createElement("Annotation");
                pronounElement.setAttribute("Id", minNewId+"");
                pronounElement.setAttribute("StartNode", a.position+"");
                node_offsets.add(a.position);
                pronounElement.setAttribute("EndNode", a.position+""); 
                //node_offsets.add(a.position);
                pronounElement.setAttribute("Type", "Ellipsis");
                asde.appendChild(pronounElement);
                
                Element feature = doc.createElement("Feature");
                pronounElement.appendChild(feature);
                Element name = doc.createElement("Name");
                name.setAttribute("className", "java.lang.String");
                name.setTextContent("complexity");
                feature.appendChild(name);
                Element value = doc.createElement("Value");
                value.setAttribute("className", "java.lang.String");
//                value.setTextContent("0.85");
                value.setTextContent(Double.toString(complexity));
                feature.appendChild(value);
                
                minNewId++;
            }
        }
        
        //modificar el gDocument para incluir las anotaciones:
        //los que ya tuvieramos y los de nuestras nuevas anotaciones,
        //teniendo en cuenta la salida de freeling para saber donde ponerlos
        try {
            addOffsetNodes(textWithNodesElement,node_offsets, doc);
        } catch(Exception ex){
            Logger.getLogger(SpanishDefiniteDescription.class.getName()).log(Level.SEVERE, null, ex);
            throw new AnaphoraResolutionException("Error 2: Incorrect offsets generation",ex);
        }

        try{
            //outputFreeling.delete(); //ahora que ya no necesito la salida de freeling, borro el fichero - se hará arriba

            newDoc = generateStringOutput(doc);
        } catch (Exception ex) {
            Logger.getLogger(SpanishDefiniteDescription.class.getName()).log(Level.SEVERE, null, ex);
            throw new AnaphoraResolutionException("Error 7: Problem generating output document",ex);

        } 
        
        
        return newDoc;
    }
    
    public String resolveAnaphora(String text, File outputFreeling, int nextID, Element as, Document doc, Boolean allAlternatives, Threshold minConfidence) throws AnaphoraResolutionException {
        String newDoc = text;      
        Element documentElement = null;
        Element textWithNodesElement = null;
        Element asde = as;
        int minNewId = nextID;
        
        try {
            
            documentElement = doc.getDocumentElement();
            textWithNodesElement = XMLUtils.getElementNamed(documentElement, "TextWithNodes");
            
        } catch(Exception e){
            throw new AnaphoraResolutionException("Error 6: Problem processing input document due to parsing problems",e); //error parsing gate format
        }
        
        File outputFreeling2 = null;
        try {
            outputFreeling2 = runFreeling(textWithNodesElement.getTextContent(), appPath, "dep");
            detectedParsedSubjects = detectParsedSubjects(outputFreeling2);
            outputFreeling2.delete();
            
        } catch (IOException ex) {
            throw new AnaphoraResolutionException("Error 3: Problem with external NLP tool: freeling",ex);
        } catch (InterruptedException ex) {
            throw new AnaphoraResolutionException("Error 3: Problem with external NLP tool: freeling",ex);
        }
        
        //procesamos el texto a partir de la salida de freeling
        //2.1 detectar los verbos de todas las claúsulas de las frases, para distinguir si son zero pronouns o no
        try {
            textWithNodesElement = XMLUtils.getElementNamed(documentElement, "TextWithNodes");
            //detect verbs clauses + extract verb features;
            HashMap<Integer, Clause> clauses = detectZeroPronuns(outputFreeling, textWithNodesElement.getTextContent());
            //obtain if there are zero pronouns in each clause
            zeroPronouns = obtainZeroPronouns(clauses);
        } catch (Exception ex) {
            Logger.getLogger(SpanishDefiniteDescription.class.getName()).log(Level.SEVERE, null, ex);
            throw new AnaphoraResolutionException("Error 3: Problem with external NLP tool: freeling",ex);
        }
        
        //2.2 detectar los antecedentes de cada zero pronun
        ArrayList<AnaphoricExpresion> anaphors = new ArrayList<AnaphoricExpresion>();
        
        for(Integer i: zeroPronouns.keySet()) {
            Clause cl = zeroPronouns.get(i);
            if(cl.getType()!=null){ 
                //solo si es un verbo buscamos antecedentes y resolvemos.
                    HashMap<Integer,ArrayList<Antecedent>> antecedents = null;
                    try {
                        antecedents = detectAntecedentsInSentence(cl.getNum_sentece(), 
                                                                    outputFreeling, 
                                                                    textWithNodesElement.getTextContent());
                    } catch (AnaphoraResolutionException ex) {
                        throw ex;
                    }

                    //generar caracteristicas ML para el pronombre y el antecedente y resolver
                    
                    AnaphoricExpresion zp = resolveZeroPronoun(cl, antecedents);
                    anaphors.add(zp);
                }
                
        }
            
        
        
        TreeSet<Integer> node_offsets = new TreeSet<Integer>();
           
        //guardar el resultado en la salida
        for(AnaphoricExpresion a: anaphors){
        
             //1. rellanamos el nuevo annotationset
            if(a.antecedentsSet!=null && !a.antecedentsSet.isEmpty()){ //esta resuelto
//             if(a.antecedent!=null){ 
                String idAntecedente = null;
                Collections.sort(a.antecedentsSet);
                Iterator<Antecedent> iterator = a.antecedentsSet.iterator();
                StringBuilder idsAntecedents = new StringBuilder();
                StringBuilder startNodeAntecedents = new StringBuilder();
                StringBuilder endNodeAntecedents = new StringBuilder(); 
                StringBuilder confidenceAntecedents = new StringBuilder();
                double currentConfidence = 0.0;
                do{
                    if(iterator.hasNext()){
                        Antecedent next = iterator.next();
                        currentConfidence = next.confidence;
                        if(currentConfidence>=minConfidence.getValue()){
                            if(!node_offsets.contains(next.startPosition) 
                                && !node_offsets.contains(next.endPosition)){
                                Element antecedentElement = doc.createElement("Annotation");
                                idAntecedente = Integer.toString(minNewId);
                                antecedentElement.setAttribute("Id", minNewId+"");
                                if(next.startPosition==-1){
                                    node_offsets.add(0);
                                    antecedentElement.setAttribute("StartNode", "0"); 
                                } else {
                                    node_offsets.add(next.startPosition);
                                    antecedentElement.setAttribute("StartNode", next.startPosition+""); 
                                }
                                antecedentElement.setAttribute("EndNode", next.endPosition+""); 
                                node_offsets.add(next.endPosition);
                                antecedentElement.setAttribute("Type", "DiscourseEntity");
                                asde.appendChild(antecedentElement); //"Discourse Entity markups");
                                minNewId++;
                            } else {
                                //sino es que este antecedente ya esta marcado pero 
                                // tengo que saber su id para no liarla

                                NodeList annotations = XMLUtils.getElementsNamed(asde, "Annotation");

                                boolean enc = false;

                                for(int indice=0; indice< annotations.getLength() && !enc; indice++){
                                    Element item = (Element) annotations.item(indice);
                                    Integer startp = Integer.parseInt(item.getAttribute("StartNode"));
                                    Integer endp = Integer.parseInt(item.getAttribute("EndNode"));
                                    if(startp.equals(next.startPosition) 
                                            && endp.equals(next.endPosition)){
                                        idAntecedente = item.getAttribute("Id");
                                        enc = true;
                                    }
                                }

                                if (!enc){
                                    System.err.println("¡OJO! POSIBLE BUG: No se encuentra la anotación de "
                                            + textWithNodesElement.getTextContent().substring(
                                            next.startPosition, 
                                            next.endPosition) 
                                            + " en la posición " + 
                                            next.startPosition +"," 
                                            + next.endPosition);
                                }
                            }

                            idsAntecedents.append(idAntecedente).append("|");
                            startNodeAntecedents.append(next.startPosition).append("|");
                            endNodeAntecedents.append(next.endPosition).append("|");
                            confidenceAntecedents.append(next.confidence).append("|");
                        }
                    }
                }while(iterator.hasNext() && //si hay siguiente elemento
                        currentConfidence>=minConfidence.getValue() && //si la confidence es mayor
                        allAlternatives); //si hay que mostrar más de una alternativa
                
                Element pronounElement = doc.createElement("Annotation");
                pronounElement.setAttribute("Id", minNewId+"");
                pronounElement.setAttribute("StartNode", a.position+"");
                node_offsets.add(a.position);
                pronounElement.setAttribute("EndNode", a.position+""); 
                node_offsets.add(a.endPosition);
                pronounElement.setAttribute("Type", "Ellipsis");
                asde.appendChild(pronounElement);
                
                Element feature = doc.createElement("Feature");
                pronounElement.appendChild(feature);
                Element name = doc.createElement("Name");
                name.setAttribute("className", "java.lang.String");
                name.setTextContent("complexity");
                feature.appendChild(name);
                Element value = doc.createElement("Value");
                value.setAttribute("className", "java.lang.String");
//                value.setTextContent("0.85");
                value.setTextContent(Double.toString(complexity));
                feature.appendChild(value);
                
                /*** añadimos la información de todos los posibles antecedentes ***/
                // solo si hay antecedentes que cumplan las condiciones!!
                if(startNodeAntecedents.length()>0){  
                    feature = doc.createElement("Feature");
                    pronounElement.appendChild(feature);
                    name = doc.createElement("Name");
                    name.setAttribute("className", "java.lang.String");
                    name.setTextContent("StartNodeAntecedent");
                    feature.appendChild(name);
                    value = doc.createElement("Value");
                    value.setAttribute("className", "java.lang.String");
    //                value.setTextContent(a.antecedent.startPosition+"");

                    value.setTextContent(startNodeAntecedents.substring(0, startNodeAntecedents.length()-1)); //quitamos el último |
                    feature.appendChild(value);

                    feature = doc.createElement("Feature");
                    pronounElement.appendChild(feature);
                    name = doc.createElement("Name");
                    name.setAttribute("className", "java.lang.String");
                    name.setTextContent("EndNodeAntecedent");
                    feature.appendChild(name);
                    value = doc.createElement("Value");
                    value.setAttribute("className", "java.lang.String");
    //                value.setTextContent(a.antecedent.endPosition+"");
                    value.setTextContent(endNodeAntecedents.substring(0, endNodeAntecedents.length()-1)); //quitamos el último |
                    feature.appendChild(value);

                    feature = doc.createElement("Feature");
                    pronounElement.appendChild(feature);
                    name = doc.createElement("Name");
                    name.setAttribute("className", "java.lang.String");
                    name.setTextContent("confidence");
                    feature.appendChild(name);
                    value = doc.createElement("Value");
                    value.setAttribute("className", "java.lang.String");
    //                value.setTextContent(a.antecedent.confidence+"");
                     value.setTextContent(confidenceAntecedents.substring(0, confidenceAntecedents.length()-1)); //quitamos el último |
                    feature.appendChild(value);

                    feature = doc.createElement("Feature");
                    pronounElement.appendChild(feature);
                    name = doc.createElement("Name");
                    name.setAttribute("className", "java.lang.String");
                    name.setTextContent("AntecedentId");
                    feature.appendChild(name);
                    value = doc.createElement("Value");
                    value.setAttribute("className", "java.lang.String");
    //                value.setTextContent(idAntecedente);
                    value.setTextContent(idsAntecedents.substring(0, idsAntecedents.length()-1)); //quitamos el último |
                    feature.appendChild(value);
                }

                minNewId++;
                
            } else {
                Element pronounElement = doc.createElement("Annotation");
                pronounElement.setAttribute("Id", minNewId+"");
                pronounElement.setAttribute("StartNode", a.position+"");
                node_offsets.add(a.position);
                pronounElement.setAttribute("EndNode", a.position+""); 
                //node_offsets.add(a.position);
                pronounElement.setAttribute("Type", "Ellipsis");
                asde.appendChild(pronounElement);
                
                Element feature = doc.createElement("Feature");
                pronounElement.appendChild(feature);
                Element name = doc.createElement("Name");
                name.setAttribute("className", "java.lang.String");
                name.setTextContent("complexity");
                feature.appendChild(name);
                Element value = doc.createElement("Value");
                value.setAttribute("className", "java.lang.String");
//                value.setTextContent("0.85");
                value.setTextContent(Double.toString(complexity));
                feature.appendChild(value);
                
                minNewId++;
            }
        }
        
        //modificar el gDocument para incluir las anotaciones:
        //los que ya tuvieramos y los de nuestras nuevas anotaciones,
        //teniendo en cuenta la salida de freeling para saber donde ponerlos
        try {
            addOffsetNodes(textWithNodesElement,node_offsets, doc);
        } catch(Exception ex){
            Logger.getLogger(SpanishDefiniteDescription.class.getName()).log(Level.SEVERE, null, ex);
            throw new AnaphoraResolutionException("Error 2: Incorrect offsets generation",ex);
        }

        try{
            //outputFreeling.delete(); //ahora que ya no necesito la salida de freeling, borro el fichero - se hará arriba

            newDoc = generateStringOutput(doc);
        } catch (Exception ex) {
            Logger.getLogger(SpanishDefiniteDescription.class.getName()).log(Level.SEVERE, null, ex);
            throw new AnaphoraResolutionException("Error 7: Problem generating output document",ex);

        } 
        
        
        return newDoc;
    }
    
}
