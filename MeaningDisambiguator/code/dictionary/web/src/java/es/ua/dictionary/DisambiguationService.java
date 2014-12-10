/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package es.ua.dictionary;

import es.ua.db.DatabaseException;
import es.ua.first.disambiguation.DisambiguationException;
import es.ua.first.disambiguation.Disambiguator2;
import gate.creole.ResourceInstantiationException;
import java.io.IOException;
import java.sql.SQLException;
import java.util.ArrayList;
import javax.annotation.Resource;
import javax.jws.WebMethod;
import javax.jws.WebParam;
import javax.jws.WebService;
import javax.servlet.ServletContext;
import javax.xml.parsers.ParserConfigurationException;
import javax.xml.ws.WebServiceContext;
import javax.xml.ws.handler.MessageContext;
import net.didion.jwnl.JWNLException;
import net.sf.json.JSONArray;
import net.sf.json.JSONObject;
import net.sf.json.JSONSerializer;
import org.xml.sax.SAXException;

/**
 *
 * @author lcanales
 */
@WebService(serviceName = "Disambiguation", targetNamespace = "http://first-asd.eu/service/")
public class DisambiguationService {

    @Resource
    private WebServiceContext context;
    public static final String DIS_ATT = "disambiguator";

    @WebMethod(operationName = "disambiguate")
    public String disambiguate(@WebParam(name = "text") String text, @WebParam(name = "jsonParameters") String jsonParameters) throws DisambiguationException {
        String output = "";
        try {
            // obtain parameters
            ParamsJSON params = parseJSON(jsonParameters);
            if (params.getAddress().equals("y")) {
                // obtain context        
                ServletContext servletContext = (ServletContext) context.getMessageContext().get(MessageContext.SERVLET_CONTEXT);
                // obtain object disambiguator
                Disambiguator2 dis = (Disambiguator2) servletContext.getAttribute(DIS_ATT);
                // call to disambiguation method
                if (params.getLang().equals("en") || params.getLang().equals("bg")) {
                    output = dis.disambiguate(text, params.getTypeWords(), params.getLang(), params.getNumMaxSenses(), params.getMethodDisam(), params.getRetunInfo(), "GATE", "GATE", "WORDNET", servletContext.getRealPath("/"));
                } else {
                    output = dis.disambiguate(text, params.getTypeWords(), params.getLang(), params.getNumMaxSenses(), params.getMethodDisam(), params.getRetunInfo(), "GATE", "GATE", "FREELING", servletContext.getRealPath("/"));
                }
            } else {
                output = text;
            }
        } catch (ResourceInstantiationException ex) {
            throw new DisambiguationException(ex);
        } catch (IOException ex) {
            throw new DisambiguationException(ex);
        } catch (ParserConfigurationException ex) {
            throw new DisambiguationException(ex);
        } catch (SAXException ex) {
            throw new DisambiguationException(ex);
        } catch (JWNLException ex) {
            throw new DisambiguationException(ex);
        } catch (SQLException ex) {
            throw new DisambiguationException(ex);
        } catch (InterruptedException ex) {
            throw new DisambiguationException(ex);
        } catch (DatabaseException ex) {
            throw new DisambiguationException(ex);
        }
        return output;
    }

    private ParamsJSON parseJSON(String parameters) throws DisambiguationException {
        String lang;
        String methodDisam = "MFS";
        String returnInfo;
        String address;
        ArrayList<String> typeWords = new ArrayList<String>();
        Integer numMaxSenses;
        JSONObject obj = new JSONObject();
        if (parameters.startsWith("{")) {
            obj = (JSONObject) JSONSerializer.toJSON(parameters);
        } else {
            if (parameters.equals("es") || parameters.equals("en") || parameters.equals("bg")) {
                obj.put("languageCode", parameters);
            } else { 
                throw new DisambiguationException(DisambiguationException.ERROR4);
            }
        }
        // obtenemos el lenguaje
        lang = obj.getString("languageCode").toLowerCase();
        // Obtenemos los tipos de palabras
        JSONArray typeWordsJson = obj.optJSONArray("disambiguate.types");
        if (typeWordsJson != null) {
            for (Object typeWord : typeWordsJson) {
                if (typeWord.equals("rare")) {
                    typeWords.add(Disambiguator2.RARE);
                } else if (typeWord.equals("specialized")) {
                    typeWords.add(Disambiguator2.SPECIALIZED);
                } else if (typeWord.equals("longwords")) {
                    typeWords.add(Disambiguator2.LONGWORDS);
                } else if (typeWord.equals("polysemics")) {
                    typeWords.add(Disambiguator2.POLYSEMIC);
                } else if (typeWord.equals("mentalverbs")) {
                    typeWords.add(Disambiguator2.MENTALVERBS);
                } else {
                    throw new DisambiguationException(DisambiguationException.ERROR3, typeWord.toString());
                }
            }
        } else {
            typeWords.add(Disambiguator2.RARE);
            typeWords.add(Disambiguator2.SPECIALIZED);
            typeWords.add(Disambiguator2.LONGWORDS);
            typeWords.add(Disambiguator2.MENTALVERBS);
        }
        // Obtenemos el valor del enumerado Information
        returnInfo = obj.optString("disambiguate.information", "definitionsSynonyms");
        if (returnInfo.equals("onlyDefinitions")) {
            returnInfo = Disambiguator2.DEFINITIONS;
        } else if (returnInfo.equals("onlySynonyms")) {
            returnInfo = Disambiguator2.SYNONYMS;
        } else if (returnInfo.equals("definitionsSynonyms")) {
            returnInfo = Disambiguator2.DEFSYN;
        } else {
            throw new DisambiguationException(DisambiguationException.ERROR15);
        }
        // Obtenemos el adress
        address = obj.optString("disambiguate.address", "y");

        // obtenemos el valor
        numMaxSenses = Integer.parseInt(obj.optString("disambiguate.numMaxSenses", "3"));
        return new ParamsJSON(lang, methodDisam, returnInfo, typeWords, numMaxSenses, address);
    }
}
