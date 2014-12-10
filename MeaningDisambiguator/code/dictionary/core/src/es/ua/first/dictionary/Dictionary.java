/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package es.ua.first.dictionary;

import de.tudarmstadt.ukp.wikipedia.api.WikiConstants.Language;
import de.tudarmstadt.ukp.wikipedia.api.exception.WikiInitializationException;
import java.util.Properties;

/**
 *
 * @author lcanales
 */
public class Dictionary {
    private final WiktionaryParser esWiktionary;
    private final WiktionaryParser enWiktionary;
    private final WiktionaryParser bgWiktionary;

    
    public Dictionary(Properties defaultProps) throws WikiInitializationException {
        String host = defaultProps.getProperty("dataBaseServer");
        String user = defaultProps.getProperty("dataBaseUser");
        String pwd =  defaultProps.getProperty("dataBasePassword");
        Language langes = Language.valueOf(defaultProps.getProperty("langes"));
        String databasees = defaultProps.getProperty("dataBaseNamees");

        Language langen = Language.valueOf(defaultProps.getProperty("langen"));
        String databaseen = defaultProps.getProperty("dataBaseNameen");
        
        Language langbg = Language.valueOf(defaultProps.getProperty("langbg"));
        String databasebg = defaultProps.getProperty("dataBaseNamebg");
        
        esWiktionary =  new WiktionaryParser(host, databasees, user, pwd, langes);
        enWiktionary =  new WiktionaryParser(host, databaseen, user, pwd, langen);
        bgWiktionary =  new WiktionaryParser(host, databasebg, user, pwd, langbg);
        //wiktionary = new WiktionaryParser(); //al desplegar el servicio, generamos el eswiktionary
    }

    /**
     * @return the eswiktionary
     */
    public WiktionaryParser getEsWiktionary() {
        return esWiktionary;
    }

    /**
     * @return the enwiktionary
     */
    public WiktionaryParser getEnWiktionary() {
        return enWiktionary;
    }

    /**
     * @return the bgwiktionary
     */
    public WiktionaryParser getBgWiktionary() {
        return bgWiktionary;
    }
}
