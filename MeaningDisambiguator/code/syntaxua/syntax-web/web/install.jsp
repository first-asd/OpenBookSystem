<%-- 
    Document   : install
    Created on : 16-may-2014, 12:15:48
    Author     : imoreno
--%>

<%@page import="es.ua.first.syntax.SyntaxServiceEvents"%>
<%@page import="javax.xml.ws.handler.MessageContext"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <link rel="StyleSheet" href="css/bootstrap.min.css" type="text/css" media="screen" />
        <link rel="StyleSheet" href="css/style.css" type="text/css" media="screen" />

        <script src="js/jquery-1.8.3.min.js" type="text/javascript"></script>
        <script src="js/bootstrap.min.js" type="text/javascript"></script>
        <script src="js/first.js" type="text/javascript"></script>
        <title>FIRST Page Setup</title>
    </head>
    <body>
        <div class="container">
            <legend>FIRST Page Setup</legend>
            <div class="well">
                <%
                    /*ServletContext servletContext = (ServletContext) context.getMessageContext().get(MessageContext.SERVLET_CONTEXT);*/
                    /*String error = (String) request.getSession().getServletContext().getAttribute("error");*/
                    String error = (String) request.getAttribute("error");
                    if (error != null) {
                        out.println("Failed to desploy web service: Incorrect path");
                        out.println(error);
                    }
                %>
                <form class="form-horizontal" id="params_conf" method='post' action='install'>
                    <fieldset>
                        <legend>Configuration Parameters</legend>
                        <%
                            boolean installGATE = (Boolean) request.getSession().getServletContext().getAttribute(SyntaxServiceEvents.INSTALL_GATE);
                            if (installGATE) {
                        %>
                        <div class="control-group">
                            <label class="control-label">GATE Path</label>
                            <div class="controls">
                                <input type="text" class="input-xlarge" id="path_GATE" name="path_GATE" rel="popover" data-content="gate.dir" data-original-title="gate.dir" />
                            </div>
                        </div>
                        <%       } 
                        %>
                        
                        <div class="control-group">
                            <label class="control-label"></label>
                            <div class="controls">
                                <button type="submit" class="btn btn-success" >Guardar</button>
                            </div>
                        </div>
                    </fieldset>
                </form>

            </div>
        </div>
    </body>
</html>

