<%-- 
    Document   : install
    Created on : 04-abr-2014, 9:15:08
    Author     : imoreno
--%>

<%@page import="es.ua.first.multiwords.FirstServiceEvents"%>
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
                <form class="form-horizontal" id="params_conf" method='post' action='installfirst'>
                    <fieldset>
                        <legend>Configuration Parameters</legend>
                        <%
                            boolean installMultiWordsES = (Boolean) request.getSession().getServletContext().getAttribute(FirstServiceEvents.INSTALL_MWES);
                            if (installMultiWordsES) {
                        %>
                        <div class="control-group">
                            <label class="control-label">MultiWordsES Path</label>
                            <div class="controls">
                                <input type="text" class="input-xlarge" id="path_mwES" name="path_mwES" rel="popover" data-content="pathMultiWordsES" data-original-title="pathMultiWordsES" />
                            </div>
                        </div>
                        <%       } else {
                            String path_mwES = (String) request.getSession().getServletContext().getAttribute(FirstServiceEvents.PATH_MWES);
                        %>
                        <div class="control-group" style="visibility: hidden">
                            <label class="control-label">MultiWordsES Path</label>
                            <div class="controls">
                                <%

                                %>
                                <input type="text" class="input-xlarge" id="path_mwES" value="<%= path_mwES %>" name="path_mwES" rel="popover" data-content="pathMultiWordsES" data-original-title="pathMultiWordsES" />
                            </div>
                        </div>
                        <% }%>
                        
                        <%
                            boolean installMultiWordsEN = (Boolean) request.getSession().getServletContext().getAttribute(FirstServiceEvents.INSTALL_MWEN);
                            if (installMultiWordsEN) {
                        %>
                        <div class="control-group">
                            <label class="control-label">MultiWordsEN Path</label>
                            <div class="controls">
                                <input type="text" class="input-xlarge" id="path_mwEN" name="path_mwEN" rel="popover" data-content="pathMultiWordsEN" data-original-title="pathMultiWordsEN" />
                            </div>
                        </div>
                         <%       } else {
                            String path_mwEN = (String) request.getSession().getServletContext().getAttribute(FirstServiceEvents.PATH_MWEN);
                        %>
                        <div class="control-group" style="visibility: hidden">
                            <label class="control-label">MultiWordsEN Path</label>
                            <div class="controls">
                                <%

                                %>
                                <input type="text" class="input-xlarge" id="path_mwBG" value="<%= path_mwEN %>" name="path_mwEN" rel="popover" data-content="pathMultiWordsEN" data-original-title="pathMultiWordsEN" />
                            </div>
                        </div>
                        <% }%>
                        
                        <%
                            boolean installMultiWordsBG = (Boolean) request.getSession().getServletContext().getAttribute(FirstServiceEvents.INSTALL_MWBG);
                            if (installMultiWordsBG) {
                        %>
                        <div class="control-group">
                            <label class="control-label">MultiWordsBG Path</label>
                            <div class="controls">
                                <input type="text" class="input-xlarge" id="path_mwBG" name="path_mwBG" rel="popover" data-content="pathMultiWordsBG" data-original-title="pathMultiWordsBG" />
                            </div>
                        </div>
                        <%       } else {
                            String path_mwBG = (String) request.getSession().getServletContext().getAttribute(FirstServiceEvents.PATH_MWBG);
                        %>
                        <div class="control-group" style="visibility: hidden">
                            <label class="control-label">MultiWordsBG Path</label>
                            <div class="controls">
                                <%

                                %>
                                <input type="text" class="input-xlarge" id="path_mwBG" value="<%= path_mwBG %>" name="path_mwBG" rel="popover" data-content="pathMultiWordsBG" data-original-title="pathMultiWordsBG" />
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

