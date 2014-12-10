/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package es.ua.first.syntax;

import es.ua.first.sintactic.SintacticSimplificator;
import static es.ua.first.syntax.SyntaxServiceEvents.CONFIG_FILE;
import static es.ua.first.syntax.SyntaxServiceEvents.CONFIG_FILENAME;
import static es.ua.first.syntax.SyntaxServiceEvents.GATE_DIR;
import static es.ua.first.syntax.SyntaxServiceEvents.INSTALL_GATE;
import static es.ua.first.syntax.SyntaxServiceEvents.WEB_APP_PATH;
import static es.ua.first.syntax.SyntaxServiceEvents.deployWebServices;
import gate.util.GateException;
import java.io.File;
import java.io.FileInputStream;
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


/**
 *
 * @author imoreno
 */
public class SyntaxServiceEvents implements ServletContextListener {
    
    static public String WEB_APP_PATH;
   
    static public String CONFIG_FILENAME="syntax.properties";
    static public String CONFIG_FILE;
    
    static final public String GATE_DIR = "gate.dir";
    static final public String INSTALL_GATE = "installgate";
    
    
    public static void deployWebServices(ServletContext sc, String pathGate) throws IOException, URISyntaxException, gate.util.GateException {
        
         // create and load default properties
//        ClassLoader loader = SintacticSimplificationService.class.getClassLoader();
//        InputStream is = loader.getResourceAsStream(CONFIG_FILE);
//        Properties defaultProps = new Properties();
//        defaultProps.load(is);
//        is.close();
        
        
        Properties defaultProps = new Properties();
        defaultProps.load(new FileInputStream(CONFIG_FILE));
        
         //set the default properties to the ones in the parameters
        defaultProps.setProperty(GATE_DIR, pathGate);
        sc.setAttribute(INSTALL_GATE, isGATEInstalled(defaultProps));
        

        // save this changes in the config file
//        URL resourceUrl = loader.getResource(CONFIG_FILE);
        File file = new File(CONFIG_FILE);
        OutputStream output = new FileOutputStream(file);
        defaultProps.store(output, "");
        try {
            output.close();
        } catch (IOException e) {
            e.printStackTrace();
        }
        
        
        // Create the simplificator and set it as context attribute to share among web services
        SintacticSimplificator ss;
        ss = new SintacticSimplificator(pathGate);
        sc.setAttribute(SintacticSimplificationService.SS_ATT, ss);
        
    }
    
    @Override
     public void contextInitialized(ServletContextEvent sce) {
        try {        
            String fileSeparator = System.getProperty("file.separator");
            WEB_APP_PATH = sce.getServletContext().getRealPath("/");
            CONFIG_FILE = WEB_APP_PATH + "config" + fileSeparator + CONFIG_FILENAME;
            
            
             // create and load default properties
//            ClassLoader loader = SintacticSimplificationService.class.getClassLoader();
//            InputStream is = loader.getResourceAsStream(CONFIG_FILE);
//            Properties defaultProps = new Properties();
//            defaultProps.load(is);
//            is.close();
            
            Properties defaultProps = new Properties();
            defaultProps.load(new FileInputStream(CONFIG_FILE));
            
            
            // determinamos que debemos instalar
            if (!isGATEInstalled(defaultProps) ) {
                String pathGate = defaultProps.getProperty(GATE_DIR);
                
                deployWebServices(sce.getServletContext(), pathGate);
            } else {
                sce.getServletContext().setAttribute(INSTALL_GATE, isGATEInstalled(defaultProps));
            }
        } catch (IOException ex) {
            Logger.getLogger(SyntaxServiceEvents.class.getName()).log(Level.SEVERE, null, ex);
        } catch (URISyntaxException ex) {
            Logger.getLogger(SyntaxServiceEvents.class.getName()).log(Level.SEVERE, null, ex);
        } catch (GateException ex) {
            Logger.getLogger(SyntaxServiceEvents.class.getName()).log(Level.SEVERE, null, ex);
        }
        
    }

    @Override
    public void contextDestroyed(ServletContextEvent sce) {
    }
    
    private static boolean isGATEInstalled(Properties config) {
        if (config.getProperty(GATE_DIR).equals("") || config.getProperty(GATE_DIR) == null) {
            return true;
        } else {
            return false;
        }
    }
    
    
    
    
}
