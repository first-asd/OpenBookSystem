/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package es.ua.first.multiwords;

import es.ua.db.DatabaseException;
import es.ua.first.multiwords.MultiWords;
import es.ua.first.multiwords.MultiWordsException;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.net.URISyntaxException;
import java.net.URL;
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

    static public String WEB_APP_PATH;
    static public String CONFIG_FILE="es/ua/first/config/multiwords.properties";

    
    static final public String INSTALL_MWEN = "installMultiWordsEN";
    static final public String INSTALL_MWES = "installMultiWordsES";
    static final public String INSTALL_MWBG = "installMultiWordsBG";
    static final public String PATH_MWEN = "pathMultiWordsEN";
    static final public String PATH_MWES = "pathMultiWordsES";
    static final public String PATH_MWBG = "pathMultiWordsBG";
    
    public void contextInitialized(ServletContextEvent sce) {
        try {
//            String fileSeparator = System.getProperty("file.separator");
            WEB_APP_PATH = sce.getServletContext().getRealPath("/");
//            CONFIG_FILE = WEB_APP_PATH + "config" + fileSeparator + "configuration.properties";

            // create and load default properties
            ClassLoader loader = MultiWordsService.class.getClassLoader();
            InputStream is = loader.getResourceAsStream(CONFIG_FILE);
            Properties defaultProps = new Properties();
            defaultProps.load(is);
            is.close();
            
             if (installMultiWordsEN(defaultProps) || installMultiWordsES(defaultProps) || installMultiWordsBG(defaultProps)) {
                sce.getServletContext().setAttribute(INSTALL_MWEN, installMultiWordsEN(defaultProps));
                sce.getServletContext().setAttribute(INSTALL_MWES, installMultiWordsES(defaultProps));
                sce.getServletContext().setAttribute(INSTALL_MWBG, installMultiWordsBG(defaultProps));
             } else {
                // desplegamos los web services
                String pathMWEN = defaultProps.getProperty(PATH_MWEN);
                String pathMWES = defaultProps.getProperty(PATH_MWES);
                String pathMWBG = defaultProps.getProperty(PATH_MWBG);
                desployWebServices(sce.getServletContext(), pathMWEN, pathMWES, pathMWBG);
            }
           
            
        } catch (JWNLException ex) {
            Logger.getLogger(FirstServiceEvents.class.getName()).log(Level.SEVERE, null, ex);
        } catch (DatabaseException ex) {
            Logger.getLogger(FirstServiceEvents.class.getName()).log(Level.SEVERE, null, ex);
        } catch (ParserConfigurationException ex) {
            Logger.getLogger(FirstServiceEvents.class.getName()).log(Level.SEVERE, null, ex);
        } catch (SAXException ex) {
            Logger.getLogger(FirstServiceEvents.class.getName()).log(Level.SEVERE, null, ex);
        } catch (MultiWordsException ex) {
            Logger.getLogger(FirstServiceEvents.class.getName()).log(Level.SEVERE, null, ex);
        } catch (IOException ex) {
            Logger.getLogger(FirstServiceEvents.class.getName()).log(Level.SEVERE, null, ex);
        } catch (URISyntaxException ex) {
            Logger.getLogger(FirstServiceEvents.class.getName()).log(Level.SEVERE, null, ex);
        }
    }

    
    
    public void contextDestroyed(ServletContextEvent sce) {
    }
    
    private static boolean installMultiWordsEN(Properties config) {
        if (config.getProperty(PATH_MWEN).equals("") || config.getProperty(PATH_MWEN) == null) {
            return true;
        } else {
            return false;
        }
    }
    
    private static boolean installMultiWordsES(Properties config) {
        if (config.getProperty(PATH_MWES).equals("") || config.getProperty(PATH_MWES) == null) {
            return true;
        } else {
            return false;
        }
    }
    
    private static boolean installMultiWordsBG(Properties config) {
        if (config.getProperty(PATH_MWBG).equals("") || config.getProperty(PATH_MWBG) == null) {
            return true;
        } else {
            return false;
        }
    }

   public static void desployWebServices(ServletContext sc, String pathMWEN, String pathMWES, String pathMWBG) throws IOException, FileNotFoundException, JWNLException, DatabaseException, ParserConfigurationException, SAXException, MultiWordsException, URISyntaxException {
                
        // create and load default properties
        ClassLoader loader = MultiWordsService.class.getClassLoader();
        InputStream is = loader.getResourceAsStream(CONFIG_FILE);
        Properties defaultProps = new Properties();
        defaultProps.load(is);
        is.close();
        
        //set the default properties to the ones in the parameters
        defaultProps.setProperty(PATH_MWBG, pathMWBG);
        defaultProps.setProperty(PATH_MWES, pathMWES);
        defaultProps.setProperty(PATH_MWEN, pathMWEN);
        
        sc.setAttribute(INSTALL_MWEN, installMultiWordsEN(defaultProps));
        sc.setAttribute(INSTALL_MWES, installMultiWordsES(defaultProps));
        sc.setAttribute(INSTALL_MWBG, installMultiWordsBG(defaultProps));
        
        
        // save this changes in the config file
        URL resourceUrl = loader.getResource(CONFIG_FILE);
        File file = new File(resourceUrl.toURI());
        OutputStream output = new FileOutputStream(file);
        defaultProps.store(output, "");
        try {
            output.close();
        } catch (IOException e) {
            e.printStackTrace();
        }
		
         // Create the multiwords object and set it as context attribute to share among web services
        MultiWords mw = new MultiWords(defaultProps, WEB_APP_PATH);
        sc.setAttribute(MultiWordsService.MW_ATT, mw);
        is.close();
    }
}
