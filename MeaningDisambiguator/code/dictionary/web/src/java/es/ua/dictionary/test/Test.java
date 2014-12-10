package es.ua.dictionary.test;


import de.tudarmstadt.ukp.wikipedia.api.exception.WikiApiException;
import de.tudarmstadt.ukp.wikipedia.api.exception.WikiInitializationException;
import es.ua.first.dictionary.DictionaryException;
import es.ua.first.dictionary.WiktionaryParser;
import es.upv.xmlutils.XMLUtils;
import java.io.IOException;
import javax.xml.parsers.ParserConfigurationException;

/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */

/**
 *
 * @author imoreno
 */
public class Test {
    
    public static void main(String args[]) throws WikiInitializationException, DictionaryException, IOException, WikiApiException, ParserConfigurationException {
    
        WiktionaryParser eswiktionary = new WiktionaryParser();
        String definitions = XMLUtils.toString(eswiktionary.getDefinitions("ola"));
        System.out.println(definitions);
    }
}
