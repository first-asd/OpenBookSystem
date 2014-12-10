/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package es.ua.acronyms;

import es.ua.first.acronyms.Acronyms;
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
import org.xml.sax.SAXException;

/**
 *
 * @author lcanales
 */
public class FirstServiceEvents implements ServletContextListener {

    static final public String GATE_DIR = "gate.dir";
    static final public String INSTALL_GATE = "installgate";
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
            if (installGate(config)) {
                sce.getServletContext().setAttribute(INSTALL_GATE, installGate(config));
            } else {
                // desplegamos los web services
                String pathGate = config.getProperty(GATE_DIR);
                desployWebServices(sce.getServletContext(), pathGate);
            }
        } catch (GateException ex) {
            Logger.getLogger(FirstServiceEvents.class.getName()).log(Level.SEVERE, null, ex);
        } catch (FileNotFoundException ex) {
            Logger.getLogger(FirstServiceEvents.class.getName()).log(Level.SEVERE, null, ex);
        } catch (ParserConfigurationException ex) {
            Logger.getLogger(FirstServiceEvents.class.getName()).log(Level.SEVERE, null, ex);
        } catch (SAXException ex) {
            Logger.getLogger(FirstServiceEvents.class.getName()).log(Level.SEVERE, null, ex);
        } catch (IOException ex) {
            Logger.getLogger(FirstServiceEvents.class.getName()).log(Level.SEVERE, null, ex);
        }
    }

    public void contextDestroyed(ServletContextEvent sce) {
    }

     public static void desployWebServices(ServletContext sc, String pathGate) throws IOException, FileNotFoundException, ParserConfigurationException, SAXException, GateException {
        sc.setAttribute(INSTALL_GATE, false);
        // create and load default properties
        ClassLoader loader = Acronyms.class.getClassLoader();
        InputStream is = loader.getResourceAsStream("es/ua/first/config/acronyms.properties");
        Properties defaultProps = new Properties();
        defaultProps.load(is);
        // Desplegamos el servicio web de acronimos
        Acronyms acronyms = new Acronyms(defaultProps, sc.getRealPath("/"), pathGate);
        sc.setAttribute(AcronymsService.ACR_ATT, acronyms);
        is.close();
    }
     
    private boolean installGate(Properties config) {
        if (config.getProperty(GATE_DIR).equals("") || config.getProperty(GATE_DIR) == null) {
            return true;
        } else {
            return false;
        }
    }
}
