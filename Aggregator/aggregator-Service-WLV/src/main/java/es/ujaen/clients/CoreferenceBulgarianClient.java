package es.ujaen.clients;

import java.io.IOException;
import java.net.HttpURLConnection;
import java.net.URL;
import java.rmi.RemoteException;

import org.apache.log4j.Logger;


import ujaen.es.clients.BgCorefOBServiceImplServiceStub;
import ujaen.es.clients.FormatExceptionException;

public class CoreferenceBulgarianClient {
	
	private int connectionTimeout;
	private String workingURL="";
	private String productionWSDL="http://first-asd.wlv.ac.uk/openbook-bgcoref-service-v1/services/BgCorefOBServiceImplPort?wsdl";
	private String developmentWSDL="http://first-asd.wlv.ac.uk:8080/openbook-encoref-dev/services/CorefOBServiceImplPort?wsdl"; 
	private static Logger logger = Logger.getLogger(CoreferenceBulgarianClient.class);


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
	
	
	
	private String executeClient (BgCorefOBServiceImplServiceStub stub, String gateInputString,String params) throws RemoteException, FormatExceptionException { 
		
		BgCorefOBServiceImplServiceStub.ProcessBGE req =  new BgCorefOBServiceImplServiceStub.ProcessBGE();
		BgCorefOBServiceImplServiceStub.ProcessBG aux = new BgCorefOBServiceImplServiceStub.ProcessBG();
		
		aux.setGateDocument(gateInputString);
		aux.setParams(params);
		req.setProcessBG(aux);
		
		BgCorefOBServiceImplServiceStub.ProcessBGResponseE res =stub.processBG(req);
		return res.getProcessBGResponse().get_return();
	}
	
	public String getClientResponse (String gateInputString,String params) throws RemoteException, FormatExceptionException
	{
		String gateOutputString ="";
		BgCorefOBServiceImplServiceStub stub = new  BgCorefOBServiceImplServiceStub ();
		stub._getServiceClient().getOptions().setTimeOutInMilliSeconds(connectionTimeout);

		gateOutputString =executeClient (stub,gateInputString,params);
		return  gateOutputString;
	}

}
