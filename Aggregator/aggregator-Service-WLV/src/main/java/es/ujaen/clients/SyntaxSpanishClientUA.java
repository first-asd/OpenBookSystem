package es.ujaen.clients;

import java.io.IOException;
import java.net.HttpURLConnection;
import java.net.URL;
import java.rmi.RemoteException;

import org.apache.log4j.Logger;

import ujaen.es.clients.SintacticSimplificationServiceStub;

public class SyntaxSpanishClientUA {
	
	private int connectionTimeout;
	private String workingURL="";
	private String productionWSDL="http://intime.dlsi.ua.es:8080/syntaxua/SintacticSimplificationService?wsdl";
	private String developmentWSDL="http://intime.dlsi.ua.es:8080/syntaxua_development/SintacticSimplificationService?wsdll"; 
	private static Logger logger = Logger.getLogger(SyntaxSpanishClientUA.class);


	public void setConnectionTimeout (int connectionTimeout)
	{
		this.connectionTimeout=connectionTimeout;	
	}
	
	public void setDevelopment (boolean isDevelopment)
	{
		if (isDevelopment)
		{
			workingURL=developmentWSDL;
		}
		else
		{
			workingURL=productionWSDL;
		}
	}
	
	public boolean isAvailable () 
	{
		try {
		URL url = new URL(workingURL);
	    HttpURLConnection connection = (HttpURLConnection) url.openConnection();
	    connection.setConnectTimeout(2000); // Timeout 2 seconds
	    connection.connect();
	    if (connection.getResponseCode() == 200) {
	        return true;
	    }
			connection = (HttpURLConnection) url.openConnection();
		} catch (IOException e) {
			logger.error("An error occured while trying to open the connection to WSDL",e);
		}
	   
	    return false;

	}
	
	
private String executeClient (SintacticSimplificationServiceStub stub, String gateInputString,String parameters) throws Exception { 
	
	SintacticSimplificationServiceStub.PerformSintacticSimplificationE req = new SintacticSimplificationServiceStub.PerformSintacticSimplificationE ();
	SintacticSimplificationServiceStub.PerformSintacticSimplification aux = new SintacticSimplificationServiceStub.PerformSintacticSimplification();
	
	aux.setGDoc(gateInputString);
	aux.setJSONparams(parameters);
	
	req.setPerformSintacticSimplification(aux);
	
	SintacticSimplificationServiceStub.PerformSintacticSimplificationResponseE res =stub.performSintacticSimplification(req);
	return res.getPerformSintacticSimplificationResponse().get_return();
}

public String getClientResponse (String gateInputString,String parameters) throws Exception 
{
	String gateOutputString ="";
	SintacticSimplificationServiceStub stub = new  SintacticSimplificationServiceStub ();
    stub._getServiceClient().getOptions().setTimeOutInMilliSeconds(connectionTimeout);
    
    gateOutputString =executeClient (stub,gateInputString,parameters);
    return  gateOutputString;
}

}
