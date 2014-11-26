package es.ujaen.clients;

import java.io.IOException;
import java.net.HttpURLConnection;
import java.net.URL;
import java.rmi.RemoteException;

import org.apache.log4j.Logger;

import ujaen.es.clients.MultiWordsServiceStub;

public class MultiWordDetectionClientUA {
	
	private int connectionTimeout;
	private String workingURL="";
	private String productionWSDL=" http://intime.dlsi.ua.es:8080/multiwordsua/MultiWordsService?wsdl";
	private String developmentWSDL=" http://intime.dlsi.ua.es:8080/multiwords_development/MultiWordsService?wsdl"; 
	private static Logger logger = Logger.getLogger(MultiWordDetectionClientUA.class);


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
	
	
	private String executeClient (MultiWordsServiceStub stub, String gateInputString,String parameters) throws RemoteException, Exception{    
		
		MultiWordsServiceStub.DetectMultiWordsE req = new MultiWordsServiceStub.DetectMultiWordsE  ();
		MultiWordsServiceStub.DetectMultiWords aux = new MultiWordsServiceStub.DetectMultiWords ();
		
		aux.setText(gateInputString);
		aux.setParameters(parameters);
		req.setDetectMultiWords(aux);
		
		MultiWordsServiceStub.DetectMultiWordsResponseE res = stub.detectMultiWords(req);
		return res.getDetectMultiWordsResponse().get_return();
	}
	

	
	public String getClientResponse (String gateInputString,String parameters) throws RemoteException, Exception 
	{
		String gateOutputString ="";
		MultiWordsServiceStub stub = new  MultiWordsServiceStub();
        stub._getServiceClient().getOptions().setTimeOutInMilliSeconds(connectionTimeout);
        
        gateOutputString =executeClient (stub,gateInputString,parameters);
        return  gateOutputString;
	}
	
}

