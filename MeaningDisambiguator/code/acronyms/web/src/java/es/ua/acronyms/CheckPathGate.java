/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package es.ua.acronyms;

import java.io.IOException;
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
 * @author lcanales
 */
public class CheckPathGate implements Filter {

    public void init(FilterConfig fc) throws ServletException {
    }

    public void doFilter(ServletRequest request, ServletResponse response, FilterChain filter) throws IOException, ServletException {
        Boolean att_gate = (Boolean) ((HttpServletRequest) request).getSession().getServletContext().getAttribute(FirstServiceEvents.INSTALL_GATE);
        if (att_gate) {
            org.apache.log4j.Logger.getLogger("Log4j").info("No se ha indicado el path de BabelNet o Freeling no está instalado");
            RequestDispatcher requestDispatcher = request.getRequestDispatcher("/install.jsp");
            requestDispatcher.forward(request, response);
        } else {
            org.apache.log4j.Logger.getLogger("Log4j").info("Ya se ha indicado el path de BabelNet, continua");
            filter.doFilter(request, response);
        }
    }

    public void destroy() {
    }
}
