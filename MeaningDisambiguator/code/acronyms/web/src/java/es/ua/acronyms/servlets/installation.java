/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package es.ua.acronyms.servlets;

import es.ua.acronyms.FirstServiceEvents;
import gate.util.GateException;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.FileWriter;
import java.io.IOException;
import java.io.PrintWriter;
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
import org.xml.sax.SAXException;

/**
 *
 * @author lcanales
 */
public class installation extends HttpServlet {

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
            throws ServletException, IOException {
        String error = null;
        try {
            // Obtenemos el path de GATE
            String pathGate = request.getParameter("path_gate");
            String pathTreeTagger = null;
            // Obtenemos el contexto
            ServletContext sc = request.getSession().getServletContext();
            // Guardamos las rutas en el properties
            String fileSeparator = System.getProperty("file.separator");
            Properties config = new Properties();
            String configFile = sc.getRealPath("/") + "config" + fileSeparator + "configuration.properties";
            config.load(new FileInputStream(configFile));
            config.setProperty(FirstServiceEvents.GATE_DIR, pathGate);
            config.store(new FileWriter(configFile), "CONFIGURATION PROPERTIES");
            // Desplegamos los web services
            FirstServiceEvents.desployWebServices(sc, pathGate);
        } catch (FileNotFoundException ex) {
            Logger.getLogger(installation.class.getName()).log(Level.SEVERE, null, ex);
        } catch (ParserConfigurationException ex) {
            Logger.getLogger(installation.class.getName()).log(Level.SEVERE, null, ex);
        } catch (SAXException ex) {
            Logger.getLogger(installation.class.getName()).log(Level.SEVERE, null, ex);
        } catch (GateException ex) {
            Logger.getLogger(installation.class.getName()).log(Level.SEVERE, null, ex);
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
            Logger.getLogger(installation.class.getName()).log(Level.SEVERE, null, ex);
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
