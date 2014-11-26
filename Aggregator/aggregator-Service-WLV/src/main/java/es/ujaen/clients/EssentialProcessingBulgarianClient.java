package es.ujaen.clients;

import java.io.IOException;
import java.net.HttpURLConnection;
import java.net.URL;
import java.rmi.RemoteException;

import org.apache.log4j.Logger;

import ujaen.es.clients.BgPrepOBServiceImplServiceStub;
import ujaen.es.clients.FormatExceptionException;

public class EssentialProcessingBulgarianClient {
	
	private int connectionTimeout;
	private String workingURL="";
	private String productionWSDL="http://first-asd.wlv.ac.uk/openbook-bgprep-service-v1/services/BgPrepOBServiceImplPort?wsdl";
	private String developmentWSDL="http://first-asd.wlv.ac.uk/openbook-bgprep-dev/services/BgPrepOBServiceImplPort?wsdl"; 
	private static Logger logger = Logger.getLogger(EssentialProcessingBulgarianClient.class);


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
	
	
	private String executeClient (BgPrepOBServiceImplServiceStub stub, String gateInputString,String bpJson) throws RemoteException, FormatExceptionException  {   
		
		BgPrepOBServiceImplServiceStub.ProcessBGE req = new BgPrepOBServiceImplServiceStub.ProcessBGE();
		
		BgPrepOBServiceImplServiceStub.ProcessBG aux = new BgPrepOBServiceImplServiceStub.ProcessBG();
		aux.setGateDocument(gateInputString);
		aux.setParams(bpJson);
		
		req.setProcessBG(aux);
		BgPrepOBServiceImplServiceStub.ProcessBGResponseE res = stub.processBG(req);
		
		return res.getProcessBGResponse().get_return();
	}
	
	
	public String getClientResponse (String gateInputString,String bpJson) throws RemoteException, FormatExceptionException
	{
		String gateOutputString ="";
		BgPrepOBServiceImplServiceStub  stub = new  BgPrepOBServiceImplServiceStub ();
		stub._getServiceClient().getOptions().setTimeOutInMilliSeconds(connectionTimeout);

		gateOutputString =executeClient (stub,gateInputString,bpJson);
		return  gateOutputString;
	}


}
