package es.ujaen.first.summarizer;

import java.io.File;

import javax.servlet.ServletContext;

import org.apache.axis2.context.MessageContext;
import org.apache.axis2.transport.http.HTTPConstants;
import org.apache.log4j.Logger;

import gate.Corpus;
import gate.Document;
import gate.Factory;
import gate.FeatureMap;
import gate.Gate;
import gate.ProcessingResource;
import gate.creole.SerialAnalyserController;
import gate.util.GateException;

public class GateOperations {
	
	private static org.apache.log4j.Logger  log = Logger.getLogger(GateOperations.class);
	private static boolean gateInited = false; 
	
	private void initGateServiceWS ()  throws GateException
	{
		if (!gateInited)
		{
			MessageContext inContext = MessageContext.getCurrentMessageContext(); 
			ServletContext req = (ServletContext)inContext.getProperty(HTTPConstants.MC_HTTP_SERVLETCONTEXT);
			File gateHome = new File(req.getRealPath("/WEB-INF"));
			Gate.setGateHome(gateHome ); 
			Gate.setPluginsHome(new File (gateHome,"PLUGINS"));

			//set user config file
			Gate.setUserConfigFile(new File(gateHome, "user-gate.xml"));

			Gate.init();
			gateInited=true;	
		}

	}
	
	private void initGateStandAlone () throws GateException
	{
		if (!gateInited)
		{
			String gateHome=GateOperations.class.getResource("/WEB-INF/").getPath();
			Gate.setGateHome(new File(gateHome));
			Gate.init();
			gateInited=true;
		}
		
	}
		
	public void initGate () throws GateException
	{
		
		MessageContext inContext = MessageContext.getCurrentMessageContext(); 
		if (inContext==null)
		{
			initGateStandAlone ();
		}
		else
		{
			  initGateServiceWS ();
		}
	  
	}

	
}
