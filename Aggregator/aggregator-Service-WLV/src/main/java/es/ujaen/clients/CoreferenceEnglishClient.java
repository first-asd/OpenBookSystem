package es.ujaen.clients;

import java.rmi.RemoteException;
import java.io.IOException;
import java.net.HttpURLConnection;
import java.net.URL;


import org.apache.log4j.Logger;

import ujaen.es.clients.CorefOBServiceImplServiceStub;
import ujaen.es.clients.FormatExceptionException;

public class CoreferenceEnglishClient {
	private int connectionTimeout;
	private String workingURL="";
	private String productionWSDL=" http://first-asd.wlv.ac.uk:8080/openbook-encoref-service-v1/services/CorefOBServiceImplPort?wsdl";
	private String developmentWSDL="http://first-asd.wlv.ac.uk:8080/openbook-encoref-dev/services/CorefOBServiceImplPort?wsdl"; 
	private static Logger logger = Logger.getLogger(CoreferenceEnglishClient.class);


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
	

	private String executeClient (CorefOBServiceImplServiceStub stub, String gateInputString,String parameters) throws RemoteException, FormatExceptionException {    


		CorefOBServiceImplServiceStub.ProcessCoreferenceE req= new  CorefOBServiceImplServiceStub.ProcessCoreferenceE ();
		CorefOBServiceImplServiceStub.ProcessCoreference aux= new  CorefOBServiceImplServiceStub.ProcessCoreference();
		aux.setGateDocument(gateInputString);
		aux.setParams(parameters);
		req.setProcessCoreference(aux);
		CorefOBServiceImplServiceStub.ProcessCoreferenceResponseE res=stub.processCoreference(req);
		return res.getProcessCoreferenceResponse().get_return();

	}

	public String getClientResponse (String gateInputString,String parameters) throws RemoteException, FormatExceptionException
	{
		String gateOutputString ="";
		CorefOBServiceImplServiceStub  stub = new  CorefOBServiceImplServiceStub ();
		stub._getServiceClient().getOptions().setTimeOutInMilliSeconds(connectionTimeout);

		gateOutputString =executeClient (stub,gateInputString,parameters);
		return  gateOutputString;
	}

}
