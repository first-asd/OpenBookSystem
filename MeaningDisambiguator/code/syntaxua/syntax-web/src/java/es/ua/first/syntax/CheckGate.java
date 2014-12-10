package es.ua.first.syntax;

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

/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */

/**
 *
 * @author imoreno
 */
public class CheckGate implements Filter {

    @Override
    public void init(FilterConfig filterConfig) throws ServletException {
        
    }

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain) throws IOException, ServletException {
        Boolean att_gate = (Boolean) ((HttpServletRequest) request).getSession().getServletContext().getAttribute(SyntaxServiceEvents.INSTALL_GATE);
        
        if(att_gate){
            Logger.getLogger(CheckGate.class.getName()).info("No se ha indicado el path de GATE");
            RequestDispatcher requestDispatcher = request.getRequestDispatcher("/install.jsp");
            requestDispatcher.forward(request, response);
        } else {
            Logger.getLogger(CheckGate.class.getName()).info("Ya se ha indicado el path de GATE, continua");
            chain.doFilter(request, response);
        }
    }

    @Override
    public void destroy() {
        
    }
    
}
