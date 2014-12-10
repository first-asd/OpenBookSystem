/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package es.ua.dictionary;

import de.tudarmstadt.ukp.wikipedia.api.exception.WikiApiException;
import es.ua.first.dictionary.Dictionary;
import es.ua.first.dictionary.DictionaryException;
import es.ua.first.dictionary.WiktionaryParser;
import es.upv.xmlutils.XMLUtils;
import java.io.IOException;
import javax.annotation.Resource;
import javax.jws.WebMethod;
import javax.jws.WebParam;
import javax.jws.WebService;
import javax.servlet.ServletContext;
import javax.xml.parsers.ParserConfigurationException;
import javax.xml.ws.WebServiceContext;
import javax.xml.ws.handler.MessageContext;

/**
 *
 * @author imoreno
 */
@WebService(serviceName = "DictionaryService",
targetNamespace = "http://first-asd.eu/service/")
public class DictionaryService {
    public static final String DIC_ATT = "dictionary";
    @Resource
    private WebServiceContext context;

    /**
     * This operation retrieves the definition for the given word in the
     * specified language
     */
    @WebMethod(operationName = "getDefinitions")
    public String getDefinitions(@WebParam(name = "word") String word,
            @WebParam(name = "lang") String lang) throws DictionaryException {
        ServletContext servletContext = (ServletContext) context.getMessageContext().get(MessageContext.SERVLET_CONTEXT);
        Dictionary dict = (Dictionary) servletContext.getAttribute(DIC_ATT);
        WiktionaryParser eswiktionary = dict.getEsWiktionary();
        WiktionaryParser enwiktionary = dict.getEnWiktionary();
        WiktionaryParser bgwiktionary = dict.getBgWiktionary();
        try {
            if (lang.equals("es")) {
                return XMLUtils.toString(eswiktionary.getDefinitions(word));
            } else if (lang.equals("en")) {
                return XMLUtils.toString(enwiktionary.getDefinitions(word));
            } else if (lang.equals("bg")) {
                return XMLUtils.toString(bgwiktionary.getDefinitions(word));
            } else {
                throw new DictionaryException("Error 1: Language not supported.");
            }
        } catch (IOException ex) {
            throw new DictionaryException(ex);
        } catch (WikiApiException ex) {
            throw new DictionaryException(ex);
        } catch (ParserConfigurationException ex) {
            throw new DictionaryException(ex);
        }
    }
}
