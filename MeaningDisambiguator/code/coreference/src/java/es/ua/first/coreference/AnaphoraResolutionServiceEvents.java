/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package es.ua.first.coreference;

import java.util.logging.Level;
import java.util.logging.Logger;
import javax.servlet.ServletContextEvent;
import javax.servlet.ServletContextListener;

/**
 *
 * @author imoreno
 */
public class AnaphoraResolutionServiceEvents implements ServletContextListener {

    public void contextInitialized(ServletContextEvent sce) {
        try {
            AnaphoraResolutionService.init(sce.getServletContext());
        } catch (AnaphoraResolutionException ex) {
            Logger.getLogger(AnaphoraResolutionServiceEvents.class.getName()).log(Level.SEVERE, null, ex);
        }
    }

    public void contextDestroyed(ServletContextEvent sce) {
        AnaphoraResolutionService.destroy(sce.getServletContext());
    }
    
}
