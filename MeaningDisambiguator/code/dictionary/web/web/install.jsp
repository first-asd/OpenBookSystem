<%-- 
    Document   : install
    Created on : 14-ene-2014, 9:48:58
    Author     : lcanales
--%>

<%@page import="es.ua.dictionary.FirstServiceEvents"%>
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
                        out.println("Failed to desploy web service: Path incorrect");
                        out.println(error);
                    }
                %>
                <form class="form-horizontal" id="params_conf" method='post' action='installfirst'>
                    <fieldset>
                        <legend>Configuration Parameters</legend>
                        <%
                            boolean installBabelNet = (Boolean) request.getSession().getServletContext().getAttribute(FirstServiceEvents.INSTALL_BABELNET);
                            if (installBabelNet) {
                        %>
                        <div class="control-group">
                            <label class="control-label">BabelNet Path</label>
                            <div class="controls">
                                <input type="text" class="input-xlarge" id="path_bn" name="path_bn" rel="popover" data-content="babelnet_path" data-original-title="babelnet_path" />
                            </div>
                        </div>
                        <%       }%>
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
                        <%
                            //boolean installTreeTagger = (Boolean) request.getSession().getServletContext().getAttribute(FirstServiceEvents.INSTALL_TREETAGGER);
                            //if (installTreeTagger) {
                        %>
                        <!--div class="control-group">
                            <label class="control-label">Tree-tagger Path</label>
                            <div class="controls">
                                <input type="text" class="input-xlarge" id="path_tt" name="path_tt" rel="popover" data-content="treetagger_path" data-original-title="treetagger_path" />
                            </div>
                        </div-->
                        <%    //   }%>
                        <%
                            boolean installFreeling = (Boolean) request.getSession().getServletContext().getAttribute(FirstServiceEvents.INSTALL_FREELING);
                            if (installFreeling) {
                        %>
                        <div class="control-group">
                            <label class="control-label">Freeling Path</label>
                            <div class="controls">
                                <input type="text" class="input-xlarge" id="path_bn" name="path_freeling" rel="popover" data-content="freeling_path" data-original-title="freeling_path" />
                            </div>
                        </div>
                        <%       } else {
                            String pathFreeling = (String) request.getSession().getServletContext().getAttribute(FirstServiceEvents.PATH_FREELING);
                        %>
                        <div class="control-group" style="visibility: hidden">
                            <label class="control-label">Freeling Path</label>
                            <div class="controls">
                                <%

                                %>
                                <input type="text" class="input-xlarge" id="path_bn" value="<%= pathFreeling %>" name="path_freeling" rel="popover" data-content="freeling_path" data-original-title="freeling_path" />
                            </div>
                        </div>
                        <% }%>
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
