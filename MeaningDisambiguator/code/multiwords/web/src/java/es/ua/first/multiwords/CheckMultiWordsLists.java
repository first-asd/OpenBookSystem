/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package es.ua.first.multiwords;

import java.io.IOException;
import java.util.logging.Logger;
import javax.servlet.Filter;
import javax.servlet.FilterChain;
import javax.servlet.FilterConfig;
import javax.servlet.RequestDispatcher;
import javax.servlet.ServletException;
import javax.servlet.ServletRequest;
import javax.servlet.ServletResponse;
import javax.servlet.http.HttpServletRequest;

/**
 *
 * @author imoreno
 */
public class CheckMultiWordsLists implements Filter {
    public void init(FilterConfig fc) throws ServletException {
    }

    public void doFilter(ServletRequest request, ServletResponse response, FilterChain filter) throws IOException, ServletException {
        Boolean att_mwES = (Boolean) ((HttpServletRequest) request).getSession().getServletContext().getAttribute(FirstServiceEvents.INSTALL_MWES);
        Boolean att_mwEN = (Boolean) ((HttpServletRequest) request).getSession().getServletContext().getAttribute(FirstServiceEvents.INSTALL_MWEN);
        Boolean att_mwBG = (Boolean) ((HttpServletRequest) request).getSession().getServletContext().getAttribute(FirstServiceEvents.INSTALL_MWBG);

        if (att_mwES || att_mwEN || att_mwBG) {
            Logger.getLogger(CheckMultiWordsLists.class.getName()).info("No se ha indicado el path de alguna las listas de multi words");
            RequestDispatcher requestDispatcher = request.getRequestDispatcher("/install.jsp");
            requestDispatcher.forward(request, response);
        } else {
            Logger.getLogger(CheckMultiWordsLists.class.getName()).info("Ya se ha indicado el path de todas las listas de multi words, continua");
            filter.doFilter(request, response);
        }
    }

    public void destroy() {
    }
}
