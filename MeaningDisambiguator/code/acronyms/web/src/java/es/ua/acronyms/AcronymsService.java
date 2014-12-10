/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package es.ua.acronyms;

import es.ua.first.acronyms.Acronyms;
import es.ua.first.acronyms.AcronymsException;
import gate.creole.ResourceInstantiationException;
import java.io.IOException;
import javax.annotation.Resource;
import javax.jws.WebService;
import javax.jws.WebMethod;
import javax.jws.WebParam;
import javax.servlet.ServletContext;
import javax.xml.parsers.ParserConfigurationException;
import javax.xml.ws.WebServiceContext;
import javax.xml.ws.handler.MessageContext;
import net.sf.json.JSONObject;
import net.sf.json.JSONSerializer;
import org.xml.sax.SAXException;

/**
 *
 * @author lcanales
 */
@WebService(serviceName = "AcronymsService", targetNamespace = "http://first-asd.eu/service/")
public class AcronymsService {

    @Resource
    private WebServiceContext context;
    public static final String ACR_ATT = "acronyms";

    @WebMethod(operationName = "detectAcronyms")
    public String detectAcronyms(@WebParam(name = "text") String text, @WebParam(name = "jsonParameters") String jsonParameters) throws AcronymsException, IOException, ParserConfigurationException, SAXException, ResourceInstantiationException {
        String output;
        // obtain parameters
        ParamsJSON params = parseJSON(jsonParameters);
        if (params.getAddress().equals("y")) {
            // obtain context        
            ServletContext servletContext = (ServletContext) context.getMessageContext().get(MessageContext.SERVLET_CONTEXT);
            // obtain object acronyms
            Acronyms acr = (Acronyms) servletContext.getAttribute(ACR_ATT);
            // call to method of acronyms detection
            output = acr.detectionAcronyms(text, params.getLang(), "GATE", "GATE", servletContext.getRealPath("/"));
        } else {
            output = text;
        }
        return output;
    }

    private ParamsJSON parseJSON(String parameters) throws AcronymsException {
        String lang;
        String address;
        JSONObject obj = new JSONObject();
        if (parameters.startsWith("{")) {
            obj = (JSONObject) JSONSerializer.toJSON(parameters);
        } else {
            if (parameters.equals("es") || parameters.equals("en") || parameters.equals("bg")) {
                obj.put("languageCode", parameters);
            } else {
                throw new AcronymsException(AcronymsException.ERROR2);
            }
        }
        // obtenemos el lenguaje
        lang = obj.getString("languageCode").toLowerCase();

        // Obtenemos el adress
        address = obj.optString("acronyms.address", "y");
        return new ParamsJSON(lang, address);
    }
}
