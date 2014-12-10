<%-- 
    Document   : install
    Created on : 14-ene-2014, 9:48:58
    Author     : lcanales
--%>

<%@page import="es.ua.acronyms.FirstServiceEvents"%>
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
                    String error = (String) request.getAttribute("error");
                    if (error != null) {
                        out.println("Failed to desploy web service: Path incorrect");
                        out.println(error);
                    }
                %>
                <form class="form-horizontal" id="params_conf" method='post' action='installation'>
                    <fieldset>
                        <legend>Configuration Parameters</legend>
                        <%
                            boolean installGate = (Boolean) request.getSession().getServletContext().getAttribute(FirstServiceEvents.INSTALL_GATE);
                            if (installGate) {
                        %>
                        <div class="control-group">
                            <label class="control-label">GATE Path</label>
                            <div class="controls">
                                <input type="text" class="input-xlarge" id="path_gate" name="path_gate" rel="popover" data-content="gate_path" data-original-title="gate_path" />
                            </div>
                        </div>
                        <%       }%>
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
