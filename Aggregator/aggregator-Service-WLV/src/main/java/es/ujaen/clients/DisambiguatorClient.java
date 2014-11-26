package es.ujaen.clients;

import java.io.IOException;
import java.net.HttpURLConnection;
import java.net.URL;
import java.rmi.RemoteException;

import org.apache.log4j.Logger;


import ujaen.es.clients.DisambiguationExceptionException;
import ujaen.es.clients.DisambiguationStub;


public class DisambiguatorClient {
	
	
	private int connectionTimeout;
	private String workingURL="";
	private String productionWSDL="http://intime.dlsi.ua.es:8080/dictionaryua/DisambiguationService?wsdl";
	private String developmentWSDL="http://intime.dlsi.ua.es:8080/dictionaryua/DisambiguationService?wsdl"; 
	private static Logger logger = Logger.getLogger(DisambiguatorClient .class);


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
	
	
	private String executeClient (DisambiguationStub stub, String gateInputString,String parameters) throws RemoteException, DisambiguationExceptionException{    
		
		DisambiguationStub.DisambiguateE req = new DisambiguationStub.DisambiguateE ();
		DisambiguationStub.Disambiguate aux = new DisambiguationStub.Disambiguate ();
		
		aux.setText(gateInputString);
		aux.setJsonParameters(parameters);
		req.setDisambiguate(aux);
		
		DisambiguationStub.DisambiguateResponseE res =stub.disambiguate(req);
		return res.getDisambiguateResponse().get_return();
	}
	
	
	public String getClientResponse (String gateInputString,String parameters) throws RemoteException, DisambiguationExceptionException
	{
		String gateOutputString ="";
		DisambiguationStub stub = new  DisambiguationStub();
        stub._getServiceClient().getOptions().setTimeOutInMilliSeconds(connectionTimeout);
        
        gateOutputString =executeClient (stub,gateInputString,parameters);
        return  gateOutputString;
	}
	
}

