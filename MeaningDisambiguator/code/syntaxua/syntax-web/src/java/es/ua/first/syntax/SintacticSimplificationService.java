/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package es.ua.first.syntax;

import es.ua.first.sintactic.Sentence.NumberWords;
import javax.annotation.Resource;
import javax.jws.WebService;
import javax.jws.WebMethod;
import javax.jws.WebParam;
import javax.servlet.ServletContext;
import javax.xml.ws.WebServiceContext;
import javax.xml.ws.handler.MessageContext;

import es.ua.first.sintactic.SintacticSimplificator;
import es.ua.first.sintactic.SintacticSimplificationException;
import static es.ua.first.syntax.SintacticSimplificationService.SS_ATT;

import net.sf.json.JSONException;
import net.sf.json.JSONObject;
import net.sf.json.JSONSerializer;

/**
 *
 * @author imoreno
 */
@WebService(serviceName = "SintacticSimplificationService",
targetNamespace = "http://first-asd.eu/service/")
public class SintacticSimplificationService {

    public static final String SS_ATT = "SintacticSimplification";
    @Resource
    private WebServiceContext context;

    /**
     * Web service operation
     */
    @WebMethod(operationName = "performSintacticSimplification")
    public String performSintacticSimplification(@WebParam(name = "gDoc") String gDoc, @WebParam(name = "JSONparams") String JSONparams) throws SintacticSimplificationException {
        
        JSONObject obj;
        
        ServletContext servletContext = (ServletContext) context.getMessageContext().get(MessageContext.SERVLET_CONTEXT);
        SintacticSimplificator simp = (SintacticSimplificator) servletContext.getAttribute(SS_ATT);
         
        // obtain parameters
        try{
            obj = (JSONObject) JSONSerializer.toJSON(JSONparams);
       } catch(JSONException e){
           if(JSONparams.equals("es")){
                 obj  = new JSONObject();
                 obj.put("languageCode", JSONparams);
             } else {
                SintacticSimplificationException ex =  new SintacticSimplificationException("Error 1: Language not supported.");
                throw ex;
            }
       }
         

         // obtenemos si debemos procesar o no, por defecto si
        String address = obj.optString("syntacticSimplification", "y").toLowerCase();
        
        if(address.equals("yes") || address.equals("y") || address.equals("true") || address.equals("t")){
            // obtenemos el lenguaje
            String lang = obj.getString("languageCode").toLowerCase();
            if(lang.equals("es")){
                String adversatives = obj.optString("syntacticSimplification.adversatives", "true").toUpperCase();
                String longSentences = obj.optString("syntacticSimplification.longSentences", "true").toUpperCase();
                String sizeLongSentences = obj.optString("syntacticSimplification.sizeLongSentences", "long").toUpperCase();
                Boolean a = adversatives.equalsIgnoreCase("true") || adversatives.equalsIgnoreCase("yes") || adversatives.equalsIgnoreCase("t") || adversatives.equalsIgnoreCase("y");
                Boolean l = longSentences.equalsIgnoreCase("true") || longSentences.equalsIgnoreCase("yes") || longSentences.equalsIgnoreCase("t") || longSentences.equalsIgnoreCase("y");
                NumberWords nw = NumberWords.WORDS15;
                if (sizeLongSentences.equals("LONG") || sizeLongSentences.equals("long") || sizeLongSentences.equals("L") || sizeLongSentences.equals("l")) {
                    nw = NumberWords.WORDS20;
                }
                return simp.simplifyAdversativeConjunctionAndDetectLongSentences(gDoc, lang, a, l, nw);
               
            } else {
                SintacticSimplificationException ex =  new SintacticSimplificationException("Error 1: Language not supported.");
                throw ex;
            }
        }
        return gDoc;
    }
}
