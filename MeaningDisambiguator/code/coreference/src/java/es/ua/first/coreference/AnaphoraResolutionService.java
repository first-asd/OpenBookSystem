/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package es.ua.first.coreference;

import javax.jws.WebMethod;
import javax.jws.WebParam;
import javax.jws.WebService;
import javax.servlet.ServletContext;
import net.sf.json.JSONException;
import net.sf.json.JSONObject;
import net.sf.json.JSONSerializer;

/**
 *
 * @author imoreno
 */
@WebService(serviceName = "AnaphoraResolution", 
        targetNamespace = "http://first-asd.eu/service/")
public class AnaphoraResolutionService {
    public static String webAppPath = null;
    private static AnaphoraResolutionUtils resolver = null;
    
    static void init(ServletContext servletContext) throws AnaphoraResolutionException {
        webAppPath = servletContext.getRealPath("/");
        try {
            resolver = new AnaphoraResolutionUtils();/*no sé si es necesario*/
            resolver.initialize(webAppPath);
        } catch (Exception ex) {
            AnaphoraResolutionException e = new AnaphoraResolutionException("Error 4: Problem with external machine learning tool, Weka: Models not loaded",ex);
            throw e;
        }
        
    }

    static void destroy(ServletContext servletContext) {
        
    }
    
    /**
     * This is a web service operation for pronoun anaphora resolution.  
     */
    @WebMethod(operationName = "pronominalAnaphoraResolution")
    private String pronominalAnaphoraResolution(@WebParam(name = "text") String text, @WebParam(name = "lang") String lang) throws AnaphoraResolutionException{ //throws Exception {
        AnaphoraResolutionInterface pronominalAnaphorResolver;
        if(lang.equals("es")){
            
            //pam = new SpanishPronominalAnaphoraStub();
            //System.out.println(webAppPath);
            try{
                pronominalAnaphorResolver = new SpanishPronominalAnaphora(webAppPath);
                
            } catch (Exception ex){
                AnaphoraResolutionException e = new AnaphoraResolutionException("Error 4: Problem with external machine learning tool, Weka: Model not loaded",ex);
                throw e;
            }
            return pronominalAnaphorResolver.resolveAnaphora(text);
            
            
        } else {
            AnaphoraResolutionException ex =  new AnaphoraResolutionException("Error 1: Language not supported.");
            throw ex;
        }
    }
    
    /**     
     * This is a web service operation for DefiniteDescription resolution.  
     */
    @WebMethod(operationName = "DefiniteDescriptionAnaphoraResolution")
    private String DefiniteDescriptionAnaphoraResolution(@WebParam(name = "text") String text, @WebParam(name = "lang") String lang) throws AnaphoraResolutionException{ //throws Exception {
    
        AnaphoraResolutionInterface definiteDescriptionResolver;
        if(lang.equals("es")){
            try {
                definiteDescriptionResolver = new SpanishDefiniteDescription(webAppPath);
            } catch (Exception ex) {
                AnaphoraResolutionException e = new AnaphoraResolutionException("Error 4: Problem with external machine learning tool, Weka: Model not loaded",ex);
                throw e;
            }
            return definiteDescriptionResolver.resolveAnaphora(text);
            
        } else {
            AnaphoraResolutionException ex =  new AnaphoraResolutionException("Error 1: Language not supported.");
            throw ex;
        }
    }
    
    /**     
     * This is a web service operation for elipsis resolution.  
     */
    @WebMethod(operationName = "EllipsisAnaphoraResolution")
    private String EllipsisAnaphoraResolution(@WebParam(name = "text") String text, @WebParam(name = "lang") String lang) throws AnaphoraResolutionException{ //throws Exception {
    
        AnaphoraResolutionInterface ellipsisResolver;
        if(lang.equals("es")){
            try {
                ellipsisResolver = new SpanishZeroPronoun(webAppPath);
            } catch (Exception ex) {
                AnaphoraResolutionException e = new AnaphoraResolutionException("Error 4: Problem with external machine learning tool, Weka: Model not loaded",ex);
                throw e;
            }
            return ellipsisResolver.resolveAnaphora(text);
            
        } else {
            AnaphoraResolutionException ex =  new AnaphoraResolutionException("Error 1: Language not supported.");
            throw ex;
        }
    }
    
    /*     
     * This is a web service operation for Anaphora resolution.  
     */
    @WebMethod(operationName = "AnaphoraResolution")
    public String AnaphoraResolution(@WebParam(name = "text") String text, @WebParam(name = "parameters") String parameters) throws AnaphoraResolutionException{ //throws Exception {
        
       JSONObject obj;
       System.out.println("Parameters =" + parameters);
       try{
            obj = (JSONObject) JSONSerializer.toJSON(parameters);
       } catch(JSONException e){
           if(parameters.equals("es")){
                 obj  = new JSONObject();
                 obj.put("languageCode", parameters);
             } else {
                AnaphoraResolutionException ex =  new AnaphoraResolutionException("Error 1: Language not supported.");
                throw ex;
            }
       }
        
        
       // obtenemos si debemos procesar o no, por defecto si
        String address = obj.optString("anaphoraResolution.address", "yes").toLowerCase();
        
        if(address.equals("yes")){
            // obtenemos el lenguaje
            String lang = obj.getString("languageCode").toLowerCase();
            if(lang.equals("es")){
                //se ha incluido en el resolveAnaphors la lógica de complexity, confidence, mode = {allAlternatives, oneAlternative}
                String complexity = obj.optString("anaphoraResolution.complexity", "low").toUpperCase();
                String confidence = obj.optString("anaphoraResolution.confidence", "zero").toUpperCase();
                String mode = obj.optString("anaphoraResolution.mode", "allAlternatives").toLowerCase();
                Boolean m = mode.equals("allalternatives");
                //este metodo (y los que utiliza) debe hacerse sincronized o deben dejar de ser estáticos, para permitir más de una llamada a la vez!!
                String nText = AnaphoraResolutionUtils.resolveAnaphors(text, webAppPath, AnaphoraResolutionUtils.Threshold.valueOf(complexity), AnaphoraResolutionUtils.Threshold.valueOf(confidence), m );
                return nText;
            } else {
                AnaphoraResolutionException ex =  new AnaphoraResolutionException("Error 1: Language not supported.");
                throw ex;
            }
        } else {
            return text;
        }
        
        /* //FORMA SENCILLA Y QUE TIENE QUE IR SEGURO
        AnaphoraResolutionInterface definiteDescriptionResolver;
        AnaphoraResolutionInterface pronominalAnaphorResolver;
        AnaphoraResolutionInterface ellipsisResolver;
        if(lang.equals("es")){
            try {
                definiteDescriptionResolver = new SpanishDefiniteDescription(webAppPath);
                pronominalAnaphorResolver = new SpanishPronominalAnaphora(webAppPath);
                ellipsisResolver = new SpanishZeroPronoun(webAppPath);
            } catch (Exception ex) {
                AnaphoraResolutionException e = new AnaphoraResolutionException("Error 4: Problem with external machine learning tool, Weka: Model not loaded",ex);
                throw e;
            }
            String textDD = definiteDescriptionResolver.resolveAnaphora(text);
            textDD = pronominalAnaphorResolver.resolveAnaphora(textDD);
            return ellipsisResolver.resolveAnaphora(textDD);
            
        } else {
            AnaphoraResolutionException ex =  new AnaphoraResolutionException("Error 1: Language not supported.");
            throw ex;
        }*/
    }
    
}
