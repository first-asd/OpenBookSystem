package es.ujaen.clients;

import java.io.IOException;
import java.net.HttpURLConnection;
import java.net.URL;
import java.rmi.RemoteException;

import org.apache.log4j.Logger;

import ujaen.es.clients.MultiWordDetectionUJStub;

public class MultiWordDetectionClientUJ {
	
	private int connectionTimeout;
	
	private String workingURL="";
	private String productionWSDL="http://sinai.ujaen.es/firstmultiworddetection_uj/services/MultiWordDetection-UJ?wsdl";
	private String developmentWSDL="http://sinai.ujaen.es/firstmultiworddetection_uj_dev/services/MultiWordDetection-UJ-Dev?wsdl"; 
	private static Logger logger = Logger.getLogger(MultiWordDetectionClientUJ.class);


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
	
	private String executeClient (MultiWordDetectionUJStub stub, String gateInputString,String parameters) throws RemoteException,  Exception{
		
		MultiWordDetectionUJStub.GetMultiWords req = new MultiWordDetectionUJStub.GetMultiWords();
		req.setGateInputString(gateInputString);
		req.setParameters(parameters);
		MultiWordDetectionUJStub.GetMultiWordsResponse res=stub.getMultiWords(req);
        return res.get_return();
	}
	
	
	public String getClientResponse (String gateInputString,String parameters) throws RemoteException, Exception 
	{
		String gateOutputString ="";
		MultiWordDetectionUJStub stub = new  MultiWordDetectionUJStub();
        stub._getServiceClient().getOptions().setTimeOutInMilliSeconds(connectionTimeout);
        
        gateOutputString =executeClient (stub,gateInputString,parameters);
        return  gateOutputString;
	}
	
}

