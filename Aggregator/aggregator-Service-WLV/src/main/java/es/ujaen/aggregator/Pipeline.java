package es.ujaen.aggregator;

import es.ujaen.clients.*;
import gate.Annotation;
import gate.AnnotationSet;
import gate.Document;
import gate.Factory;
import gate.FeatureMap;
import gate.Gate;
import gate.Utils;
import gate.corpora.DocumentContentImpl;
import gate.creole.ResourceInstantiationException;
import gate.util.GateException;

import java.io.File;
import java.io.IOException;
import java.rmi.RemoteException;
import java.util.ArrayList;
import java.util.List;
import java.util.concurrent.Callable;
import java.util.concurrent.ExecutorCompletionService;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.concurrent.Future;
import java.util.concurrent.TimeUnit;

import javax.servlet.ServletContext;

import org.apache.axis2.context.MessageContext;
import org.apache.axis2.transport.http.HTTPConstants;
import org.apache.commons.io.FileUtils;
import org.apache.log4j.Logger;

import ujaen.es.clients.AnaphoraResolutionExceptionException;
import ujaen.es.clients.DisambiguationExceptionException;
import ujaen.es.clients.FormatExceptionException;


public class Pipeline {


	private static int pollTime=20;
	private static Logger logger = Logger.getLogger(Pipeline.class);
	private static boolean gateInited = false; 
	private boolean isBulgarianProcess=true;


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
			String gateHome=Pipeline.class.getResource("/WEB-INF/").getPath();
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



	private Document readDocument (String gateDocumentString) throws ResourceInstantiationException
	{
		Document gateDocument= (Document) Factory.createResource("gate.corpora.DocumentImpl", Utils.featureMap("stringContent", gateDocumentString, "mimeType", "text/xml", "encoding", "UTF-8"));
		return gateDocument;
	}


	private String getEssentialProcessingResponse (String gateInputString, String bpJson) throws RemoteException, Exception
	{
		int connectionReadTimeout=70000;
		EssentialProcessingBulgarianClient bc = new EssentialProcessingBulgarianClient ();
		bc.setConnectionTimeout(connectionReadTimeout);

		logger.debug("Get the Essential Bulgarian Processing Client Response:");

		long startTime = System.currentTimeMillis();
		bc.setDevelopment(true);
		String gateResponse=gateInputString;

		if (bc.isAvailable())
		{
			gateResponse =bc.getClientResponse(gateInputString, bpJson);	
		}
		else
		{
			logger.error("Bulgarian Essential Processing Web Service Unavailable!");
		}

		long estimatedTime = System.currentTimeMillis() - startTime;

		logger.error("Essential Bulgarian Processing Time:"+estimatedTime);

		logger.debug("Finish Essential Bulgarian Processing Wolverhampton");
		return gateResponse;
	}

	private String getSummarizerResponse (String gateInputString, String parameters) throws RemoteException, Exception
	{
		int connectionReadTimeout=40000;
		SummarizerClient sc = new SummarizerClient ();
		sc.setConnectionTimeout(connectionReadTimeout);

		logger.debug("Get Summarizer Client Response:");
		long startTime = System.currentTimeMillis();
		sc.setDevelopment(false);
		String gateResponse=gateInputString;

		if (sc.isAvailable())
		{
			gateResponse =sc.getClientResponse(gateInputString, parameters);	
		}
		else
		{
			logger.error("The Summarizer Web Service Unavailable!");
		}

		long estimatedTime = System.currentTimeMillis() - startTime;
		logger.error("Summarizer Time:"+estimatedTime);

		logger.debug("Finish Summarizer Jaen");
		return gateResponse;
	}




	private String getMultiWordAlicanteResponse (String gateInputString, String parameters) throws RemoteException, Exception
	{
		int connectionReadTimeout=40000;
		MultiWordDetectionClientUA ua = new MultiWordDetectionClientUA ();
		ua.setConnectionTimeout(connectionReadTimeout);

		logger.debug("Get the Multi Word Detection Alicante Response:");
		long startTime = System.currentTimeMillis();
		ua.setDevelopment(true);
		String gateResponse=gateInputString;

		if (ua.isAvailable())
		{
			gateResponse =ua.getClientResponse(gateInputString,parameters);	
		}
		else
		{
			logger.error("Multi Word Alicante Web Service Unavailable!");
		}

		long estimatedTime = System.currentTimeMillis() - startTime;
		logger.error("Multi Word Detection Alicante:"+estimatedTime);

		logger.debug("Finish Multi Word Detection Alicante");
		return gateResponse;
	}


	private String getMultiWordJaenResponse (String gateInputString, String parameters) throws RemoteException, Exception
	{
		int connectionReadTimeout=50000;
		MultiWordDetectionClientUJ ic = new MultiWordDetectionClientUJ ();
		ic.setConnectionTimeout(connectionReadTimeout);

		logger.debug("Get the Multi Word Detection Jaen Response:");
		long startTime = System.currentTimeMillis();
		ic.setDevelopment(true);
		String gateResponse=gateInputString;

		if (ic.isAvailable())
		{
			gateResponse =ic.getClientResponse(gateInputString,parameters);	
		}
		else
		{
			logger.error("Multi Word Jaen Web Service Unavailable!");
		}

		long estimatedTime = System.currentTimeMillis() - startTime;
		logger.error("Multi Word Detection Jaen:"+estimatedTime);

		logger.debug("Finish Multi Word Detection Jaen");


		return gateResponse;
	}



	private String getDisambiguatorResponse (String gateInputString, String parameters) throws RemoteException, DisambiguationExceptionException 
	{
		int connectionReadTimeout=400000; //--------400 seconds. this one is very slow.
		DisambiguatorClient dc = new DisambiguatorClient ();
		dc.setConnectionTimeout(connectionReadTimeout);
		logger.debug("Get the Disambiguator Client Response:");

		long startTime = System.currentTimeMillis();
		dc.setDevelopment(false);
		String gateResponse=gateInputString;

		if (dc.isAvailable())
		{
			gateResponse =dc.getClientResponse(gateInputString, parameters);	
		}
		else
		{
			logger.error("Disambiguator Web Service Unavailable!");
		}

		long estimatedTime = System.currentTimeMillis() - startTime;
		logger.error("Disambiguator Time:"+estimatedTime);
		logger.debug("Finish Disambiguation Alicante");

		return gateResponse;
	}


	private String getWDResponse (String gateInputString, String parameters) throws RemoteException, Exception 
	{
		int connectionReadTimeout=40000;
		WikipediaDisambiguationClient wdc = new WikipediaDisambiguationClient ();
		wdc.setConnectionTimeout(connectionReadTimeout);
		wdc.setDevelopment(false);
		long startTime = System.currentTimeMillis();
		String gateResponse=gateInputString;

		if (wdc.isAvailable())
		{
			gateResponse =wdc.getClientResponse(gateInputString, parameters);	
		}
		else
		{
			logger.error("Wikipedia Disambiguation Web Service Unavailable!");
		}
		logger.debug("Get the Wikipedia Disambiguation Client Response:");

		long estimatedTime = System.currentTimeMillis() - startTime;
		logger.error("WD Time:"+estimatedTime);
		logger.debug("Finish WD Jaen");

		return gateResponse;
	}

	private String getOfflineImage (String gateInputString, String parameters) throws RemoteException, Exception 
	{
		int connectionReadTimeout=60000;
		//String fileNamePath="inputEnglish-Test-OfflineImage.xml";
		//writeFile (gateInputString,fileNamePath) ;
		OfflineImageClient oic = new OfflineImageClient ();
		oic.setConnectionTimeout(connectionReadTimeout);
		logger.debug("Get the Offline Image Client Response:");

		long startTime = System.currentTimeMillis();
		oic.setDevelopment(true);
		String gateResponse=gateInputString;

		if (oic.isAvailable())
		{
			gateResponse =oic.getClientResponse(gateInputString, parameters);	
		}
		else
		{
			logger.error("Offline Image Retrieval Web Service Unavailable!");
		}

		long estimatedTime = System.currentTimeMillis() - startTime;
		logger.error("OI time:"+estimatedTime);
		logger.debug("Finish OfflineImage Jaen");


		return gateResponse;
	}


	private  String normaliseEsCoreferenceAnnotations(String document){
		Document doc=null;
		try {
			doc=readDocument(document);
			String providerAsName="Pronominal Anaphora markups";
			String providerAnn="PronounAnaphora";
			String targetAsName="Coreference";
			String targetAnn="CorefEntity";
			AnnotationSet asToCopy=doc.getAnnotations(providerAsName).get(providerAnn);
			AnnotationSet targetAS=doc.getAnnotations(targetAsName);

			for(Object obj:asToCopy) {
				Annotation oneAnn = (Annotation)obj;

				String text=Utils.stringFor(doc, oneAnn); 
				String chain=(String)oneAnn.getFeatures().get("chain");
				if (chain!=null){
					FeatureMap fm=Factory.newFeatureMap();
					fm.put("text", text);                
					fm.put("chain", chain);
					targetAS.add(oneAnn.getStartNode(), oneAnn.getEndNode(),targetAnn, fm);
				}
				//else: some pronouns are not resolved automatically: 
				//UI should show the obstacle was detected 
			}

			document= doc.toXml();
		} catch (ResourceInstantiationException e) {
			logger.error("Failed to normalise Spanish Coreference Annotations "+e.getLocalizedMessage());
		}finally{
			if (doc!=null)
				Factory.deleteResource(doc);
		}
		return document;
	}


	private  String getSpanishCoreferenceResults(String gateInputString, String parameters) throws RemoteException, AnaphoraResolutionExceptionException
	{
		int connectionReadTimeout=40000;
		CoreferenceSpanishClient cac =new CoreferenceSpanishClient ();
		cac.setConnectionTimeout(connectionReadTimeout);
		logger.debug("Get Spanish Coreference Alicante Client Response:");

		long startTime = System.currentTimeMillis();
		cac.setDevelopment(false);
		String gateResponse=gateInputString;

		if (cac.isAvailable())
		{
			gateResponse =cac.getClientResponse(gateInputString, parameters);	
		}
		else
		{
			logger.error("Spanish Coreference Web Service Unavailable!");
		}

		long estimatedTime = System.currentTimeMillis() - startTime;
		logger.error("Spanish Coreference time:"+estimatedTime);

		logger.debug("Finish Spanish Coreference Alicante ");

		return gateResponse;
	}


	private String getEnglishCoreferenceResults(String gateInputString, String parameters) throws RemoteException, FormatExceptionException 
	{
		int connectionReadTimeout=45000;
		CoreferenceEnglishClient cec = new CoreferenceEnglishClient();
		cec.setConnectionTimeout(connectionReadTimeout);
		logger.debug("Get English Coreference WLV Client Response:");

		long startTime = System.currentTimeMillis();
		cec.setDevelopment(true);
		String gateResponse=gateInputString;

		if (cec.isAvailable())
		{
			gateResponse =cec.getClientResponse(gateInputString, parameters);	
		}
		else
		{
			logger.error("English Coreference Web Service Unavailable!");
		}

		long estimatedTime = System.currentTimeMillis() - startTime;
		logger.error("English Coreference time:"+estimatedTime);

		logger.debug("Finish English Coreference WLV ");
		return gateResponse;
	}


	private String getBulgarianCoreferenceResults(String gateInputString, String parameters) throws RemoteException, FormatExceptionException 
	{
		int connectionReadTimeout=30000;
		CoreferenceBulgarianClient cbc = new CoreferenceBulgarianClient();
		cbc.setConnectionTimeout(connectionReadTimeout);
		logger.debug("Get Bulgarian Coreference WLV Client Response:");

		long startTime = System.currentTimeMillis();
		cbc.setDevelopment(true);

		String gateResponse=gateInputString;
		if (cbc.isAvailable())
		{
			gateResponse =cbc.getClientResponse(gateInputString, parameters);	
		}
		else
		{
			logger.error("Bulgarian Coreference Web Service Unavailable!");
		}
		long estimatedTime = System.currentTimeMillis() - startTime;
		logger.error("Bulgarian Coreference time:"+estimatedTime);
		logger.debug("Finish Bulgarian Coreference WLV ");
		return gateResponse;
	}


	private String getCorefResponse(String gateInputString, String parameters) throws RemoteException, FormatExceptionException, AnaphoraResolutionExceptionException
	{
		final String languageCode =getLanguageCode(parameters);
		if (languageCode.equalsIgnoreCase("en"))
		{
			return getEnglishCoreferenceResults(gateInputString, parameters);
		}
		else if (languageCode.equalsIgnoreCase("es"))
		{
			return getSpanishCoreferenceResults(gateInputString, parameters);
		}
		else if (languageCode.equalsIgnoreCase("bg"))
		{
			return getBulgarianCoreferenceResults(gateInputString, parameters);
		}

		return null;
	}



	private  String getEnglishSyntaxResponse (String gateInputString, String parameters) throws RemoteException, FormatExceptionException 
	{
		int connectionReadTimeout=40000;
		SyntaxEnglishClient sc = new SyntaxEnglishClient ();

		sc.setConnectionTimeout(connectionReadTimeout);
		logger.debug("Get the Syntax English Client Response:");

		long startTime = System.currentTimeMillis();
		String gateResponse=gateInputString;
		sc.setDevelopment(true);
		if (sc.isAvailable())
		{
			gateResponse =sc.getClientResponse(gateInputString, parameters);	
		}
		else
		{
			logger.error("English Syntax Web Service Unavailable!");
		}

		long estimatedTime = System.currentTimeMillis() - startTime;
		logger.error("WLV Syntax Time:"+estimatedTime);
		logger.debug("Finish Syntax WLV");

		return gateResponse;
	}


	private static  String getSpanishSyntaxUJResponse (String gateInputString, String parameters) throws Exception 
	{
		int connectionReadTimeout=40000;
		SyntaxSpanishClientUJ sc = new SyntaxSpanishClientUJ();
		sc.setConnectionTimeout(connectionReadTimeout);
		logger.debug("Get the Syntax Spanish UJ Client Response:");

		long startTime = System.currentTimeMillis();
		String gateResponse=gateInputString;
		sc.setDevelopment(false);
		if (sc.isAvailable())
		{
			gateResponse =sc.getClientResponse(gateInputString, parameters);	
		}
		else
		{
			logger.error("Spanish Syntax Web Service UJ Unavailable!");
		}
		long estimatedTime = System.currentTimeMillis() - startTime;
		logger.error("Syntax Spanish UJ Time:"+estimatedTime);
		logger.debug("Finish Syntax UJ");

		return gateResponse;
	}


	private static  String getSpanishSyntaxUAResponse (String gateInputString, String parameters) throws Exception 
	{
		int connectionReadTimeout=40000;
		SyntaxSpanishClientUA sc = new SyntaxSpanishClientUA();
		sc.setConnectionTimeout(connectionReadTimeout);
		logger.debug("Get the Syntax Spanish UA Client Response:");

		long startTime = System.currentTimeMillis();
		String gateResponse=gateInputString;
		sc.setDevelopment(false);
		if (sc.isAvailable())
		{
			gateResponse =sc.getClientResponse(gateInputString, parameters);	
		}
		else
		{
			logger.error("Spanish Syntax Web Service UA Unavailable!");
		}

		long estimatedTime = System.currentTimeMillis() - startTime;
		logger.error("Syntax Spanish UA Time:"+estimatedTime);
		logger.debug("Finish Syntax UA");

		return gateResponse;
	}

	private  String getSpanishSyntaxResponse (String gateInputString, String parameters) throws Exception 
	{
		String syntaxUJString=getSpanishSyntaxUJResponse (gateInputString, parameters);
		String syntaxUAString=getSpanishSyntaxUAResponse (syntaxUJString, parameters);

		return syntaxUAString;
	}

	private String getAcronymsResponse (String gateInputString, String parameters) throws Exception 
	{
		int connectionReadTimeout=30000;
		AcronymsClientUA ac = new AcronymsClientUA ();
		ac.setConnectionTimeout(connectionReadTimeout);
		logger.debug("Get Acronyms UA Client Response:");

		long startTime = System.currentTimeMillis();
		String gateResponse=gateInputString;
		ac.setDevelopment(false);
		if (ac.isAvailable())
		{
			gateResponse =ac.getClientResponse(gateInputString, parameters);	
		}
		else
		{
			logger.error("Acronyms Web Service UA Unavailable!");
		}

		long estimatedTime = System.currentTimeMillis() - startTime;
		logger.error("Acronyms UA Time:"+estimatedTime);
		logger.debug("Finish Acronyms UA");

		return gateResponse;
	}



	private String getSyntaxResponse(String gateInputString, String parameters) throws Exception
	{
		final String languageCode =getLanguageCode(parameters);
		if (languageCode.equalsIgnoreCase("en"))
		{
			return getEnglishSyntaxResponse(gateInputString, parameters);
		}
		else if (languageCode.equalsIgnoreCase("es"))
		{
			return getSpanishSyntaxResponse(gateInputString, parameters);
		}

		return gateInputString;
	}
	
	
	private String getExtractorResponse(String gateInputString, String parameters) throws Exception
	{
		int connectionReadTimeout=30000;
		KeywordsClient kc = new KeywordsClient ();
		kc.setConnectionTimeout(connectionReadTimeout);
		logger.debug("Get Keywords UA Client Response:");

		long startTime = System.currentTimeMillis();
		String gateResponse=gateInputString;
		kc.setDevelopment(false);
		if (kc.isAvailable())
		{
			gateResponse =kc.getClientResponse(gateInputString, parameters);	
		}
		else
		{
			logger.error("Keywords Web Service UA Unavailable!");
		}

		long estimatedTime = System.currentTimeMillis() - startTime;
		logger.error("Keywords UA Time:"+estimatedTime);

		return gateResponse;
	}


	private String getInputString (String gateInputString,String languageCode) 
	{
		if (languageCode.compareToIgnoreCase("bg")==0)
		{
			String bpJson="{\"bgprep.simplify\":\"y\"}";
			try {
				String gateResponse=getEssentialProcessingResponse(gateInputString, bpJson);
				if (gateResponse.compareToIgnoreCase(gateInputString)==0)
				{
					isBulgarianProcess=false;
				}
				gateInputString=gateResponse;
			} catch (RemoteException e) {
				logger.error("Aggregator Error: Exception Occured in Bulgarian Basic Processing at Remote site",e.getCause());
				isBulgarianProcess=false;
			} catch (Exception e) {
				logger.error("Aggregator Error: Exception Occured in Bulgarian Basic Processing",e.getCause());
				isBulgarianProcess=false;
			}

		}
		return gateInputString;
	}




	private void writeFile (String docString,String fileName) throws IOException
	{
		String outputDirectory="/opt/dist/008_first/Aggregator/inputFiles/";
		String disambiguationFile = outputDirectory +fileName;
		FileUtils.write(new File(disambiguationFile), docString, "UTF-8");
	}

	private String getLanguageCode (String parameters)
	{
		JsonParameters jp = new JsonParameters(parameters);
		boolean isJson=jp.isJsonParameter();

		String languageCode="";
		if (isJson)
		{
			languageCode =jp.getValue("languageCode");
		}
		else
		{
			languageCode=parameters;
		}
		return languageCode;
	}

	private String getSentenceLevel (String parameters)
	{
		JsonParameters jp = new JsonParameters(parameters);
		boolean isJson=jp.isJsonParameter();

		String sentenceLevel="";
		if (isJson)
		{
			sentenceLevel =jp.getValueSentenceLevel("sentenceLevel");
		}
		else
		{
			sentenceLevel=parameters;
		}
		
		return sentenceLevel;
	}

	private String aggregateNormal (String gateInputString,final String parameters) throws Exception 
	{
		long startTime = System.currentTimeMillis();

		final String languageCode =getLanguageCode(parameters);

		//The Bulgarian Pipe modifies the input String: It basic processes it.
		final String gateString=getInputString (gateInputString,languageCode);
		if (isBulgarianProcess)
		{
			ExecutorService es = Executors.newCachedThreadPool();
			ExecutorCompletionService<String> ecs = new ExecutorCompletionService<String>(es);
			List<Callable<String>> tasks = new ArrayList<Callable<String>>();


			tasks.add(new Callable<String>() {
				public String call() throws Exception {
					return getSyntaxResponse (gateString, parameters);
				}		});
			
			
		

			tasks.add(new Callable<String>() {
				public String call() throws Exception {
					return getCorefResponse(gateString, parameters);
				}		});


			//This should run in any case  because there is idiom detection

			tasks.add(new Callable<String>() {
				public String call() throws Exception {
					String docString =getMultiWordJaenResponse (gateString, parameters);

					//Only then identify multiWords
					if (!languageCode.equalsIgnoreCase("en"))
					{
						docString = getOfflineImage (docString,  parameters);
					}
					return docString;
				}		});



			if (languageCode.equalsIgnoreCase("en"))
			{
				tasks.add(new Callable<String>() {
					public String call() throws Exception {
						String docString = getMultiWordAlicanteResponse (gateString, parameters);
						docString = getOfflineImage (docString,  parameters);
						return docString;
					}		});
			}



			tasks.add(new Callable<String>() {
				public String call() throws Exception {
					return getSummarizerResponse (gateString, parameters);
				}		});


			tasks.add(new Callable<String>() {
				public String call() throws Exception {
					return getAcronymsResponse (gateString, parameters);
				}		});


			//The Disambiguator for Spanish takes too long. It will be called only for sentences. 
			if (languageCode.equalsIgnoreCase("en") || languageCode.equalsIgnoreCase("bg"))
			{
				tasks.add(new Callable<String>() {
					public String call() throws Exception {
						String docString=gateString;
						docString = getDisambiguatorResponse(docString, parameters);
						docString = getWDResponse (docString,  parameters);
						return docString;
					}		});	
			}


			//submit tasks. The Future object can be used to check the status of a Callable and to retrieve the result from the Callable.
			List<Future<String>> futures = new ArrayList<Future<String>>();
			for (Callable<String> t : tasks) {
				futures.add(ecs.submit(t));
			}

			//Now we collect responses
			ArrayList<Document> docs=new ArrayList<Document>();
			while (!futures.isEmpty()) {
				try {
					Future<String> f = ecs.poll(pollTime, TimeUnit.SECONDS);
					futures.remove(f);  
					if (f == null) {  // poll returns null on timeout
					} else if (f.isCancelled()){
					} else if (f.isDone()){
						String content=f.get();
						try {
							Document doc=readDocument(content);
							docs.add(doc);
						} catch (Exception e) {
							logger.error("Bad response: Invalid Gate xml file "+content);
						}
					} else {	}
				} catch (Exception e) {
					logger.error("Aggregator Error: Exception Occured in one of the threads",e.getCause());
				} 

			}

			logger.error("ShutDown the Executor");
			es.shutdown();

			Document result=readDocument(gateInputString);

			//Chapuza for Spanish: for Sentence Detector to Work I need to add an "extra \n."
			/*
			 if (languageCode.compareTo("es")==0)
			{
				String documentContent=result.getContent().toString();
				documentContent+="\n.";
				result.setContent(new DocumentContentImpl(documentContent));
			}
			
			*/


			GateOperations go = new GateOperations ();
			for(Document d:docs){
				if (d!=null)
				{
					go.aggregate(d, result);
				}

			}


			if (languageCode.compareTo("bg")!=0)
			{
				go.addExtraInfo(result);
			}

			if (languageCode.compareTo("es")==0)
			{
				go.spanishSentenceDetection(result);
			}

			//go.chapuza(result);

			logger.error ("Consolidate the MultiWord Expression Annotation Set by copying the Idiom Annotation Set.");
			go.consolidateSets(result);
			
			logger.error ("Compute the layout information.");
			Layout lay = new Layout ();
			lay.addLayout(result);
			
			long endTime = System.currentTimeMillis();
			long totalTime=(endTime-startTime)/1000;
			
			logger.error("Aggregator Total Time:"+totalTime +" seconds");

			return result.toXml();
		}

		return gateInputString;
	}
	
	
	private String englishSentenceOperations (final String gateInputString,final String parameters) throws Exception
	{
		ExecutorService es = Executors.newCachedThreadPool();
		ExecutorCompletionService<String> ecs = new ExecutorCompletionService<String>(es);
		List<Callable<String>> tasks = new ArrayList<Callable<String>>();
		
		tasks.add(new Callable<String>() {
			public String call() throws Exception {
				return getSyntaxResponse (gateInputString, parameters);
			}		});
		
		tasks.add(new Callable<String>() {
			public String call() throws Exception {
				return getDisambiguatorResponse (gateInputString, parameters);
			}		});
		
		List<Future<String>> futures = new ArrayList<Future<String>>();
		for (Callable<String> t : tasks) {
			futures.add(ecs.submit(t));
		}
		
		ArrayList<Document> docs=new ArrayList<Document>();
		while (!futures.isEmpty()) {
			try {
				Future<String> f = ecs.poll(pollTime, TimeUnit.SECONDS);
				futures.remove(f);  
				if (f == null) {  
				} else if (f.isCancelled()){
				} else if (f.isDone()){
					String content=f.get();
					try {
						Document doc=readDocument(content);
						docs.add(doc);
					} catch (Exception e) {
						logger.error("Bad response in Aggregator Sentence: Invalid Gate xml file "+content);
					}
				} else {	}
			} catch (Exception e) {
				logger.error("Aggregator Sentence Error: Exception Occured in one of the threads",e.getCause());
			} 

		}

		logger.error("ShutDown the Executor in Aggregator Sentence");
		es.shutdown();
		
		Document result=readDocument(gateInputString);
		GateOperations go = new GateOperations ();
		for(Document d:docs){
			if (d!=null)
			{
				go.aggregate(d, result);
			}

		}
		
		go.addExtraInfo(result);
		
		Layout lay = new Layout ();
		lay.addLayout(result);
		
		return result.toXml();
	}
	
	
	private String spanishSentenceOperations (final String gateInputString,final String parameters) throws Exception
	{
		
		Document d=readDocument(getDisambiguatorResponse (gateInputString, parameters));
		
		Document result=readDocument(gateInputString);
		GateOperations go = new GateOperations ();
		
		go.aggregate(d, result);
		go.addExtraInfo(result);
		go.spanishSentenceDetection(result);
		
		Layout lay = new Layout ();
		lay.addLayout(result);

		return result.toXml();
	}
	
	private String aggregateSentence (String gateInputString,final String parameters) throws Exception  
	{
		String languageCode =getLanguageCode(parameters);
		
		if (languageCode.compareTo("es")==0)
		{
			return spanishSentenceOperations(gateInputString, parameters);
		}
		
		if (languageCode.compareTo("en")==0)
		{
			return englishSentenceOperations(gateInputString, parameters);
		}
		
		return null;
	}

	public String aggregate (String gateInputString,final String parameters) throws Exception  
	{
		final String sentenceLevel=getSentenceLevel(parameters);
		
		if (sentenceLevel.compareToIgnoreCase("y")==0)
		{
			logger.error("Aggregation for Sentence Level");
			return  aggregateSentence (gateInputString, parameters);
		}
		else
		{
			logger.error("Normal Aggregation");
			return aggregateNormal (gateInputString, parameters);
		}
		

	}



}

