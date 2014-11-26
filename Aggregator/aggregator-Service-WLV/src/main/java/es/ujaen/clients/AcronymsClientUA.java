package es.ujaen.clients;

import java.io.IOException;
import java.net.HttpURLConnection;
import java.net.URL;
import java.rmi.RemoteException;

import org.apache.log4j.Logger;

import ujaen.es.clients.AcronymsServiceStub;


public class AcronymsClientUA {
	
	private int connectionTimeout;
	private String workingURL="";
	private String productionWSDL="http://intime.dlsi.ua.es:8080/acronymsua_development/AcronymsService?WSDL";
	private String developmentWSDL="http://intime.dlsi.ua.es:8080/acronymsua_development/AcronymsService?WSDL"; 
	private static Logger logger = Logger.getLogger(AcronymsClientUA.class);


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
	
	
	private String executeClient (AcronymsServiceStub stub, String gateInputString,String parameters) throws RemoteException, Exception{    
		
		AcronymsServiceStub.DetectAcronymsE req = new AcronymsServiceStub.DetectAcronymsE ();
		
		
		AcronymsServiceStub.DetectAcronyms aux = new AcronymsServiceStub.DetectAcronyms ();
		aux.setText(gateInputString);
		aux.setJsonParameters(parameters);
		req.setDetectAcronyms(aux);
		
		AcronymsServiceStub.DetectAcronymsResponseE res= stub.detectAcronyms(req);
		return res.getDetectAcronymsResponse().get_return();	
	}
	

	
	public String getClientResponse (String gateInputString,String parameters) throws RemoteException, Exception 
	{
		String gateOutputString ="";
		AcronymsServiceStub stub = new  AcronymsServiceStub();
        stub._getServiceClient().getOptions().setTimeOutInMilliSeconds(connectionTimeout);
        
        gateOutputString =executeClient (stub,gateInputString,parameters);
        return  gateOutputString;
	}

}
