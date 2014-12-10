/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package es.ua.dictionary.servlet;

import de.tudarmstadt.ukp.wikipedia.api.exception.WikiInitializationException;
import es.ua.db.DatabaseException;
import es.ua.dictionary.FirstServiceEvents;
import es.ua.first.disambiguation.DisambiguationException;
import gate.util.GateException;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.FileWriter;
import java.io.IOException;
import java.util.Properties;
import java.util.logging.Level;
import java.util.logging.Logger;
import javax.servlet.RequestDispatcher;
import javax.servlet.ServletContext;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.xml.parsers.ParserConfigurationException;
import net.didion.jwnl.JWNLException;
import org.xml.sax.SAXException;

/**
 *
 * @author lcanales
 */
public class installFirst extends HttpServlet {

    /**
     * Processes requests for both HTTP
     * <code>GET</code> and
     * <code>POST</code> methods.
     *
     * @param request servlet request
     * @param response servlet response
     * @throws ServletException if a servlet-specific error occurs
     * @throws IOException if an I/O error occurs
     */
    protected void processRequest(HttpServletRequest request, HttpServletResponse response)
            throws ServletException {
        String error = null;
        try {
            // Obtenemos el parametro del path de freeling
            String pathFreeling = request.getParameter("path_freeling"); // no sé si habrá problema
            // Obtenemos el parametro del path de babelnet
            String pathBabelNet = request.getParameter("path_bn");
            // Obtenemos el parametro del path de treetagger
            String pathGate = request.getParameter("path_gate");
            // Obtenemos el parametro del path de treetagger
//            String pathTreeTagger = request.getParameter("path_tt");
            String pathTreeTagger = null;
            // Obtenemos el contexto
            ServletContext sc = request.getSession().getServletContext();
            // Guardamos las rutas en el properties
            String fileSeparator = System.getProperty("file.separator");
            Properties config = new Properties();
            String configFile = sc.getRealPath("/") + "config" + fileSeparator + "configuration.properties";
            config.load(new FileInputStream(configFile));
            config.setProperty(FirstServiceEvents.BABELNET_DIR, pathBabelNet);
            config.setProperty(FirstServiceEvents.FREELING_DIR, pathFreeling);
            config.setProperty(FirstServiceEvents.GATE_DIR, pathGate);
            config.store(new FileWriter(configFile), "CONFIGURATION PROPERTIES");
            // Desplegamos los web services
            FirstServiceEvents.desployWebServices(sc, pathBabelNet, pathFreeling, pathTreeTagger, pathGate);
        } catch (FileNotFoundException ex) {
            error = ex.getMessage();
            Logger.getLogger(installFirst.class.getName()).log(Level.SEVERE, null, ex);
        } catch (GateException ex) {
            error = ex.getMessage();
            Logger.getLogger(installFirst.class.getName()).log(Level.SEVERE, null, ex);
        } catch (RuntimeException ex) {
            error = ex.getMessage();
            Logger.getLogger(installFirst.class.getName()).log(Level.SEVERE, null, ex);
        } catch (IOException ex) {
            error = ex.getMessage();
            Logger.getLogger(installFirst.class.getName()).log(Level.SEVERE, null, ex);
        } catch (WikiInitializationException ex) {
            error = ex.getMessage();
            Logger.getLogger(installFirst.class.getName()).log(Level.SEVERE, null, ex);
        } catch (JWNLException ex) {
            error = ex.getMessage();
            Logger.getLogger(installFirst.class.getName()).log(Level.SEVERE, null, ex);
        } catch (DatabaseException ex) {
            error = ex.getMessage();
            Logger.getLogger(installFirst.class.getName()).log(Level.SEVERE, null, ex);
        } catch (DisambiguationException ex) {
            error = ex.getMessage();
            Logger.getLogger(installFirst.class.getName()).log(Level.SEVERE, null, ex);
        } catch (ParserConfigurationException ex) {
            error = ex.getMessage();
            Logger.getLogger(installFirst.class.getName()).log(Level.SEVERE, null, ex);
        } catch (SAXException ex) {
            error = ex.getMessage();
            Logger.getLogger(installFirst.class.getName()).log(Level.SEVERE, null, ex);
        }

        // Si ha habido algún error redirigimos a /install.jsp con el error

        try {
            if (error != null && !error.isEmpty()) {
                request.setAttribute("error", error);
                RequestDispatcher requestDispatcher = request.getRequestDispatcher("/install.jsp");
                requestDispatcher.forward(request, response);
            } else {
                RequestDispatcher requestDispatcher = request.getRequestDispatcher("/index.jsp");
                requestDispatcher.forward(request, response);
            }
        } catch (IOException ex) {
            Logger.getLogger(installFirst.class.getName()).log(Level.SEVERE, null, ex);
        }
    }
// <editor-fold defaultstate="collapsed" desc="HttpServlet methods. Click on the + sign on the left to edit the code.">

    /**
     * Handles the HTTP
     * <code>GET</code> method.
     *
     * @param request servlet request
     * @param response servlet response
     * @throws ServletException if a servlet-specific error occurs
     * @throws IOException if an I/O error occurs
     */
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        processRequest(request, response);
    }

    /**
     * Handles the HTTP
     * <code>POST</code> method.
     *
     * @param request servlet request
     * @param response servlet response
     * @throws ServletException if a servlet-specific error occurs
     * @throws IOException if an I/O error occurs
     */
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        processRequest(request, response);
    }

    /**
     * Returns a short description of the servlet.
     *
     * @return a String containing servlet description
     */
    @Override
    public String getServletInfo() {
        return "Short description";
    }// </editor-fold>
}
