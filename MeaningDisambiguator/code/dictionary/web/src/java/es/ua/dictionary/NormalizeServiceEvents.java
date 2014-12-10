///*
// * To change this template, choose Tools | Templates
// * and open the template in the editor.
// */
//package es.ua.dictionary;
//
//import java.util.logging.Level;
//import java.util.logging.Logger;
//import javax.servlet.ServletContextEvent;
//import javax.servlet.ServletContextListener;
//
///**
// *
// * @author lcanales
// */
//public class NormalizeServiceEvents implements ServletContextListener {
//
//    public void contextInitialized(ServletContextEvent sce) {
//        try {
//            NormalizeService.init(sce.getServletContext());
//        } catch (NormalizeException ex) {
//            Logger.getLogger(NormalizeServiceEvents.class.getName()).log(Level.SEVERE, null, ex);
//        }
//    }
//
//    public void contextDestroyed(ServletContextEvent sce) {
//        NormalizeService.destroy(sce.getServletContext());
//    }
//    
//}
