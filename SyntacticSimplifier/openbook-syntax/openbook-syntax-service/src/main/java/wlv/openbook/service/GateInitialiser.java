package wlv.openbook.service;

import gate.Gate;
import gate.util.GateException;

import java.io.File;
import java.io.IOException;

import javax.servlet.ServletContext;
import javax.xml.ws.WebServiceContext;
import javax.xml.ws.handler.MessageContext;

public class GateInitialiser {

	/**
	 * Flags the status of GATE library initialisation
	 */
	static private Boolean gateInited = false;

	static public boolean isGateInitialised(){
		return gateInited;
	}

	/**
	 * Initialise Gate to be used in embedded mode
	 * @param wsc the WebServiceContext provided by the Servlet container 
	 * @throws GateException Gate could not be initialised
	 * @throws IOException Gate configuration files not accessible
	 */
	static void gateInit(WebServiceContext wsc) throws GateException, IOException{
		synchronized(gateInited){
			if(!gateInited) { 
				MessageContext ctxt = wsc.getMessageContext();
				ServletContext req = (ServletContext) ctxt.get(MessageContext.SERVLET_CONTEXT);
				File gateHome = new File(req.getRealPath("/WEB-INF"));
				//File gateHome =new File("target/gate");
				Gate.setGateHome(gateHome);
				// plugins dir is $gateHome/plugins
				File pluginsHome = new File(gateHome, "plugins");
				Gate.setPluginsHome(pluginsHome);

				File userConfig = new File(gateHome,"user-gate.xml");
				Gate.setUserConfigFile(userConfig);

				//// initialise GATE - this must be done before calling any GATE APIs
				Gate.init();

				// Load ANNIE plugin
				Gate.getCreoleRegister().registerDirectories(new File(pluginsHome, "ANNIE").toURI().toURL());
				// Load ANNIE plugin
				Gate.getCreoleRegister().registerDirectories(new File(pluginsHome, "Groovy").toURI().toURL());

				gateInited = true;
			}
		}
	}

	/**
	 * Initialise Gate to be used in embedded mode 
	 * @throws GateException Gate could not be initialised
	 * @throws IOException Gate configuration files not accessible
	 */
	static void gateInit(String gatePath) throws GateException, IOException{
		synchronized(gateInited){
			if(!gateInited) { 
				String gateHomePath=gatePath;  //"src/main/resources/gate";
				if (System.getProperty("gate.home")!=null){
					gateHomePath=System.getProperty("gate.home");
				}
				File gateHome =new File(gateHomePath);
				Gate.setGateHome(gateHome);
				File pluginsHome = new File(gateHome, "plugins");
				Gate.setPluginsHome(pluginsHome);
				File userConfig = new File(gateHome,"user-gate.xml");
				Gate.setUserConfigFile(userConfig);
				//// site config is gateHome/gate.xml
				////Gate.setSiteConfigFile(gappFile);
				//// initialise GATE - this must be done before calling any GATE APIs
				Gate.init();

				// Load ANNIE plugin
				Gate.getCreoleRegister().registerDirectories(new File(pluginsHome, "ANNIE").toURI().toURL());
				// Load ANNIE plugin
				Gate.getCreoleRegister().registerDirectories(new File(pluginsHome, "Groovy").toURI().toURL());

				gateInited = true;
			}
		}
	}
}
