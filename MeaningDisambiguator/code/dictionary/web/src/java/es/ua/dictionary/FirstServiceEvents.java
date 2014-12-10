/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package es.ua.dictionary;

import de.tudarmstadt.ukp.wikipedia.api.exception.WikiInitializationException;
import es.ua.db.DatabaseException;
import es.ua.first.First;
import es.ua.first.dictionary.Dictionary;
import es.ua.first.disambiguation.DisambiguationException;
import es.ua.first.disambiguation.Disambiguator2;
import gate.util.GateException;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.io.InputStream;
import java.util.Properties;
import java.util.logging.Level;
import java.util.logging.Logger;
import javax.servlet.ServletContext;
import javax.servlet.ServletContextEvent;
import javax.servlet.ServletContextListener;
import javax.xml.parsers.ParserConfigurationException;
import net.didion.jwnl.JWNLException;
import org.xml.sax.SAXException;

/**
 *
 * @author lcanales
 */
public class FirstServiceEvents implements ServletContextListener {

    static final public String BABELNET_DIR = "babelnet.dir";
    static final public String GATE_DIR = "gate.dir";
    static final public String FREELING_DIR = "freeling.dir";
    static final public String TREETAGGER_DIR = "treetagger.dir";
    static final public String INSTALL_BABELNET = "installbabelNet";
    static final public String INSTALL_GATE = "installgate";
    static final public String INSTALL_FREELING = "installfreeling";
    static final public String INSTALL_TREETAGGER = "installtreetagger";
    static final public String PATH_FREELING = "pathfreeling";
    static final public String PATH_TREETAGGER = "pathtreetagger";
    static public String WEB_APP_PATH;
    static public String CONFIG_FILE;

    public void contextInitialized(ServletContextEvent sce) {
        try {
            String fileSeparator = System.getProperty("file.separator");
            WEB_APP_PATH = sce.getServletContext().getRealPath("/");
            CONFIG_FILE = WEB_APP_PATH + "config" + fileSeparator + "configuration.properties";
            // Comprobar si existe la propiedad babelnet.dir
            Properties config = new Properties();
            config.load(new FileInputStream(CONFIG_FILE));
            // determinamos que debemos instalar
            if (installFreeling(sce, config, fileSeparator) || installBabelNet(config) || installGate(config)) {
                sce.getServletContext().setAttribute(INSTALL_BABELNET, installBabelNet(config));
                sce.getServletContext().setAttribute(INSTALL_GATE, installGate(config));
                sce.getServletContext().setAttribute(INSTALL_FREELING, installFreeling(sce, config, fileSeparator));
                sce.getServletContext().setAttribute(PATH_FREELING, config.getProperty(FREELING_DIR));
//                sce.getServletContext().setAttribute(INSTALL_TREETAGGER, installTreeTagger(config));
//                sce.getServletContext().setAttribute(PATH_TREETAGGER, config.getProperty(TREETAGGER_DIR));
            } else {
                // desplegamos los web services
                String pathBabelNet = config.getProperty(BABELNET_DIR);
                String pathFreeling = config.getProperty(FREELING_DIR);
                String pathTreeTagger = config.getProperty(TREETAGGER_DIR);
                String pathGate = config.getProperty(GATE_DIR);
                desployWebServices(sce.getServletContext(), pathBabelNet, pathFreeling, pathTreeTagger, pathGate);
            }
        } catch (GateException ex) {
            Logger.getLogger(FirstServiceEvents.class.getName()).log(Level.SEVERE, null, ex);
        } catch (ParserConfigurationException ex) {
            Logger.getLogger(FirstServiceEvents.class.getName()).log(Level.SEVERE, null, ex);
        } catch (SAXException ex) {
            Logger.getLogger(FirstServiceEvents.class.getName()).log(Level.SEVERE, null, ex);
        } catch (DatabaseException ex) {
            Logger.getLogger(FirstServiceEvents.class.getName()).log(Level.SEVERE, null, ex);
        } catch (FileNotFoundException ex) {
            Logger.getLogger(FirstServiceEvents.class.getName()).log(Level.SEVERE, null, ex);
        } catch (DisambiguationException ex) {
            Logger.getLogger(FirstServiceEvents.class.getName()).log(Level.SEVERE, null, ex);
        } catch (IOException ex) {
            Logger.getLogger(FirstServiceEvents.class.getName()).log(Level.SEVERE, null, ex);
        } catch (WikiInitializationException ex) {
            Logger.getLogger(FirstServiceEvents.class.getName()).log(Level.SEVERE, null, ex);
        } catch (JWNLException ex) {
            Logger.getLogger(FirstServiceEvents.class.getName()).log(Level.SEVERE, null, ex);
        }
    }

    public void contextDestroyed(ServletContextEvent sce) {
        Disambiguator2 disam = (Disambiguator2) sce.getServletContext().getAttribute(DisambiguationService.DIS_ATT);
        try {
            disam.close();
        } catch (IOException ex) {
            Logger.getLogger(FirstServiceEvents.class.getName()).log(Level.SEVERE, null, ex);
        }
    }

    public static void desployWebServices(ServletContext sc, String pathBabelNet, String pathFreeling, String pathTreeTagger, String pathGate) throws IOException, WikiInitializationException, JWNLException, FileNotFoundException, DatabaseException, DisambiguationException, ParserConfigurationException, SAXException, GateException {
        sc.setAttribute(INSTALL_BABELNET, false);
        sc.setAttribute(INSTALL_FREELING, false);
        sc.setAttribute(INSTALL_GATE, false);
        // create and load default properties
        ClassLoader loader = First.class.getClassLoader();
        InputStream is = loader.getResourceAsStream("es/ua/first/config/dictionary.properties");
        Properties defaultProps = new Properties();
        defaultProps.load(is);
        // Create the dictionary and set it as context attribute to share among web services
        Dictionary dict = new Dictionary(defaultProps);
        sc.setAttribute(DictionaryService.DIC_ATT, dict);
        // Obtenemos el path de babelNet y creamos Disambiguation
        Disambiguator2 disambiguator = new Disambiguator2(defaultProps, sc.getRealPath("/"), pathBabelNet, pathFreeling, pathTreeTagger, pathGate);
        sc.setAttribute(DisambiguationService.DIS_ATT, disambiguator);
        is.close();
    }

    private boolean installFreeling(ServletContextEvent sce, Properties config, String fileSeparator) {
        if (config.getProperty(FREELING_DIR) != null) {
            try {
                Runtime.getRuntime().exec(config.getProperty(FREELING_DIR) + fileSeparator + "/bin/analyzer");
                return false;
            } catch (Exception e) {
                return true;
            }
        } else {
            return true;
        }
    }

    private boolean installBabelNet(Properties config) {
        if (config.getProperty(BABELNET_DIR).equals("") || config.getProperty(BABELNET_DIR) == null) {
            return true;
        } else {
            return false;
        }
    }

    private boolean installTreeTagger(Properties config) {
        if (config.getProperty(TREETAGGER_DIR).equals("") || config.getProperty(TREETAGGER_DIR) == null) {
            return true;
        } else {
            return false;
        }
    }

    private boolean installGate(Properties config) {
        if (config.getProperty(GATE_DIR).equals("") || config.getProperty(GATE_DIR) == null) {
            return true;
        } else {
            return false;
        }
    }
}
