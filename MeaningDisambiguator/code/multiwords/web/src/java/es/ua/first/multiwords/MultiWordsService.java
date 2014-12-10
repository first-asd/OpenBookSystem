/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package es.ua.first.multiwords;

import es.ua.db.DatabaseException;
import java.io.IOException;
import java.util.concurrent.locks.ReentrantLock;
import java.util.logging.Level;
import java.util.logging.Logger;
import javax.annotation.Resource;
import javax.jws.WebService;
import javax.jws.WebMethod;
import javax.jws.WebParam;
import javax.servlet.ServletContext;
import javax.xml.parsers.ParserConfigurationException;
import javax.xml.ws.WebServiceContext;
import javax.xml.ws.handler.MessageContext;
import net.didion.jwnl.JWNLException;
import net.sf.json.JSONException;
import net.sf.json.JSONObject;
import net.sf.json.JSONSerializer;
import org.xml.sax.SAXException;

/**
 *
 * @author lcanales
 */
@WebService(serviceName = "MultiWordsService", targetNamespace = "http://first-asd.eu/service/")
public class MultiWordsService {

    @Resource
    private WebServiceContext context;
    public static final String MW_ATT = "multiwords";

    /**
     * This is a web service operation that detects multiwords
     */
    @WebMethod(operationName = "detectMultiWords")
    public String detectMultiWords(@WebParam(name = "text") String text, @WebParam(name = "parameters") String parameters) throws MultiWordsException {
        // Cargamos el fichero de entrada
        JSONObject obj;
        String output = text;
        String langCode = null;
        
        // procesamos los parametros
        try{
             obj = (JSONObject) JSONSerializer.toJSON(parameters);
             langCode = obj.getString("languageCode").toLowerCase();
        } catch(JSONException e){
            if(parameters.equals("es") || parameters.equals("en") || parameters.equals("bg")){
                  obj  = new JSONObject();
                  obj.put("languageCode", parameters);
                  langCode = obj.getString("languageCode").toLowerCase();
              } else {
                 MultiWordsException ex =  new MultiWordsException(es.ua.first.multiwords.MultiWordsException.ERROR2);
                 throw ex;
             }
        }
        
         // obtenemos si debemos procesar o no, por defecto si
        String address = obj.optString("multiWordDetection", "y").toLowerCase();
        
        
        if(address.equals("y") || address.equals("yes") || address.equals("true") || address.equals("t")){
            // preparamos la llamada
            try {

                // obtain context        
                ServletContext servletContext = (ServletContext) context.getMessageContext().get(MessageContext.SERVLET_CONTEXT);
                // obtain object detectMultiWords
                MultiWords mw = (MultiWords) servletContext.getAttribute(MW_ATT);
                // call to detectMultiWords method
                output = mw.multiwords(text, langCode, "GATE", "GATE", servletContext.getRealPath("/"));
            } catch (IOException ex) {
                Logger.getLogger(MultiWordsService.class.getName()).log(Level.SEVERE, null, ex);
            } catch (ParserConfigurationException ex) {
                Logger.getLogger(MultiWordsService.class.getName()).log(Level.SEVERE, null, ex);
            } catch (SAXException ex) {
                Logger.getLogger(MultiWordsService.class.getName()).log(Level.SEVERE, null, ex);
            } catch (DatabaseException ex) {
                Logger.getLogger(MultiWordsService.class.getName()).log(Level.SEVERE, null, ex);
            } catch (JWNLException ex) {
                Logger.getLogger(MultiWordsService.class.getName()).log(Level.SEVERE, null, ex);
            } 
        }
        return output;
    }
}
