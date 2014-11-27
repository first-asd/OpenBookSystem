package es.ujaen.sinai.first;

import es.ujaen.sinai.first.io.ManageProperties;
import gate.Document;
import gate.Factory;
import gate.Gate;
import gate.Utils;
import gate.creole.ResourceInstantiationException;
import gate.util.GateException;

import java.io.File;

import javax.servlet.ServletContext;

import org.apache.axis2.context.MessageContext;
import org.apache.axis2.transport.http.HTTPConstants;
import org.apache.log4j.Logger;

/**
 *This Class represents the Basic NLP processing used in all higher level processing in First Project.
 *@author Eduard
 */
public class BasicProcessing {
	
	private Logger 	logger = Logger.getLogger(BasicProcessing.class);
	
	/**
	 * Flag that indicates if gate is initiated or not.
	 */
	private static boolean gateInited=false;
	
	
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
			String gateHome=BasicProcessing.class.getResource("/WEB-INF/").getPath();
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
	
	
	private Document buildGateDocument(String gateInputString) throws ResourceInstantiationException {
		ManageProperties properties = ManageProperties.getInstance();
		Document doc = (Document) Factory.createResource("gate.corpora.DocumentImpl", Utils.featureMap("stringContent", gateInputString, "mimeType", "text/xml", "encoding", properties.getValue(PropertiesFields.ENCODING.toString())));
		return (doc);
	}
	
	
	public Document processNLP(String gateInputString, String languageCode) throws Exception {
		
		logger.debug("Start NLP Processing");
		ManageProperties properties = ManageProperties.getInstance();
		
		initGate();
		logger.debug("Gate is initiated");
		Document gateInputDocument = buildGateDocument(gateInputString);
		logger.debug("Build Gate document");
		
		String nameFactNLPToolsClass = properties.getValue(PropertiesFields.NLPTOOL_.toString()) + languageCode;
		Class<?> cf = Class.forName(nameFactNLPToolsClass);
		IFactoryNLPTools factNLPTools = (IFactoryNLPTools) cf.newInstance();
		INLPTOOL nlpTool = factNLPTools.createNLPTool();
		logger.debug("Create the nlp tool");
		
		nlpTool.init(factNLPTools.getParameters());
		nlpTool.setContent(gateInputDocument);
		nlpTool.nlpTokSplitMorphPos();
		gateInputDocument = (Document) nlpTool.getContent();
		
		logger.debug("Gate document is processed.");
		
		
		return gateInputDocument;
	}

}
