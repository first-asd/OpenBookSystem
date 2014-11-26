package es.ujaen.clients;

import java.io.IOException;
import java.net.HttpURLConnection;
import java.net.URL;
import java.rmi.RemoteException;

import org.apache.log4j.Logger;

import ujaen.es.clients.FormatExceptionException;
import ujaen.es.clients.SyntaxOBServiceImplServiceStub;

public class SyntaxEnglishClient {
	
	
	private int connectionTimeout;
	private String workingURL="";
	private String productionWSDL=" http://first-asd.wlv.ac.uk:8080/openbook-syntax-service-v1/services/SyntaxOBServiceImplPort?wsdl";
	private String developmentWSDL="http://first-asd.wlv.ac.uk:8080/openbook-syntax-dev/services/SyntaxOBServiceImplPort?wsdl"; 
	private static Logger logger = Logger.getLogger(SyntaxEnglishClient.class);


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
	
private String executeClient (SyntaxOBServiceImplServiceStub stub, String gateInputString,String languageCode) throws FormatExceptionException, RemoteException{    
		
	SyntaxOBServiceImplServiceStub.SimplifySyntaxE req= new  SyntaxOBServiceImplServiceStub.SimplifySyntaxE();
	SyntaxOBServiceImplServiceStub.SimplifySyntax aux= new  SyntaxOBServiceImplServiceStub.SimplifySyntax();
	aux.setGateDocument(gateInputString);
	aux.setParams(languageCode);
	req.setSimplifySyntax(aux);
	SyntaxOBServiceImplServiceStub.SimplifySyntaxResponseE res=stub.simplifySyntax(req);
	return res.getSimplifySyntaxResponse().get_return();
	}

public String getClientResponse (String gateInputString,String languageCode) throws RemoteException, FormatExceptionException
{
	String gateOutputString ="";
	SyntaxOBServiceImplServiceStub  stub = new  SyntaxOBServiceImplServiceStub ();
    stub._getServiceClient().getOptions().setTimeOutInMilliSeconds(connectionTimeout);
    
    gateOutputString =executeClient (stub,gateInputString,languageCode);
    return  gateOutputString;
}
	
	

}
