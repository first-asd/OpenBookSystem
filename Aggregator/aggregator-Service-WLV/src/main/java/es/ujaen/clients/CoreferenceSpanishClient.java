package es.ujaen.clients;


import java.io.IOException;
import java.net.HttpURLConnection;
import java.net.URL;
import java.rmi.RemoteException;

import org.apache.log4j.Logger;

import ujaen.es.clients.AnaphoraResolutionExceptionException;
import ujaen.es.clients.AnaphoraResolutionStub;

public class CoreferenceSpanishClient {
	
	private int connectionTimeout;
	private String workingURL="";
	private String productionWSDL=" http://intime.dlsi.ua.es:8080/coreferenceua/AnaphoraResolutionService?wsdl";
	private String developmentWSDL=" http://intime.dlsi.ua.es:8080/coreferenceua/AnaphoraResolutionService?wsdl"; 
	
	private static Logger logger = Logger.getLogger(CoreferenceSpanishClient.class);


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
	
	
	
private String executeClient (AnaphoraResolutionStub stub, String gateInputString,String parameters) throws RemoteException, AnaphoraResolutionExceptionException { 
	
	AnaphoraResolutionStub.AnaphoraResolutionE req =  new AnaphoraResolutionStub.AnaphoraResolutionE ();
	AnaphoraResolutionStub.AnaphoraResolution aux= new AnaphoraResolutionStub.AnaphoraResolution();
	
	aux.setText(gateInputString);
	aux.setParameters(parameters);

	req.setAnaphoraResolution(aux); 
	AnaphoraResolutionStub.AnaphoraResolutionResponseE res= stub.anaphoraResolution(req);
	return res.getAnaphoraResolutionResponse().get_return();
	}

public String getClientResponse (String gateInputString,String parameters) throws RemoteException, AnaphoraResolutionExceptionException 
{
	String gateOutputString ="";
	AnaphoraResolutionStub  stub = new  AnaphoraResolutionStub ();
    stub._getServiceClient().getOptions().setTimeOutInMilliSeconds(connectionTimeout);
    
    gateOutputString =executeClient (stub,gateInputString,parameters);
    return  gateOutputString;
}

}
