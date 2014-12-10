/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package es.ua.first.multiwords;

import es.ua.db.DatabaseException;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.net.URISyntaxException;
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
 * @author imoreno
 */
public class Install extends HttpServlet {
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
            // Obtenemos el parametro del path de ES
            String pathMWES = request.getParameter("path_mwES"); 
            // Obtenemos el parametro del path de EN
            String pathMWEN = request.getParameter("path_mwEN");
            // Obtenemos el parametro del path de BG
            String pathMWBG = request.getParameter("path_mwBG"); 
          
            // Obtenemos el contexto
            ServletContext sc = request.getSession().getServletContext();
            // Desplegamos los web services
            FirstServiceEvents.desployWebServices(sc, pathMWEN, pathMWES, pathMWBG);
            
        } catch (FileNotFoundException ex) {
            error = ex.getMessage();
            Logger.getLogger(Install.class.getName()).log(Level.SEVERE, null, ex);
        } catch (RuntimeException ex) {
            error = ex.getMessage();
            Logger.getLogger(Install.class.getName()).log(Level.SEVERE, null, ex);
        } catch (IOException ex) {
            error = ex.getMessage();
            Logger.getLogger(Install.class.getName()).log(Level.SEVERE, null, ex);
        }  catch (JWNLException ex) {
            error = ex.getMessage();
            Logger.getLogger(Install.class.getName()).log(Level.SEVERE, null, ex);
        } catch (DatabaseException ex) {
            error = ex.getMessage();
            Logger.getLogger(Install.class.getName()).log(Level.SEVERE, null, ex);
        } catch (ParserConfigurationException ex) {
            error = ex.getMessage();
            Logger.getLogger(Install.class.getName()).log(Level.SEVERE, null, ex);
        } catch (SAXException ex) {
            error = ex.getMessage();
            Logger.getLogger(Install.class.getName()).log(Level.SEVERE, null, ex);
        } catch (MultiWordsException ex) {
            error = ex.getMessage();
            Logger.getLogger(Install.class.getName()).log(Level.SEVERE, null, ex);
        } catch (URISyntaxException ex) {
            error = ex.getMessage();
            Logger.getLogger(Install.class.getName()).log(Level.SEVERE, null, ex);
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
            Logger.getLogger(Install.class.getName()).log(Level.SEVERE, null, ex);
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

