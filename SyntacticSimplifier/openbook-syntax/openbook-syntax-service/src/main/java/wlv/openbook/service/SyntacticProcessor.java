package wlv.openbook.service;

import gate.Corpus;
import gate.CorpusController;
import gate.Document;
import gate.Factory;
import gate.FeatureMap;
import gate.Gate;
import gate.ProcessingResource;
import gate.creole.ExecutionException;
import gate.creole.ResourceInstantiationException;
import gate.creole.SerialAnalyserController;
import gate.util.GateException;

import java.io.IOException;
import java.net.MalformedURLException;
import java.net.URL;
import java.util.HashMap;
import java.util.Map;
import java.util.concurrent.BlockingQueue;
import java.util.concurrent.LinkedBlockingQueue;


/**
 * A wrapper for a Gate embedded application
 * This Class uses object pooling
 * 
 * @author idornescu
 *
 */
public class SyntacticProcessor extends ObstacleProcessor {

	String language="en";

	//TODO: make final
	String workingAS="ENtokens";

	/**
	 * A pool of workers
	 */
	private BlockingQueue<SerialAnalyserController> pool=null;

	/**
	 * This allows up to 2 working threads
	 */
	private int POOL_SIZE=2;
	//TODO: make this smarter (configuration app/page/context param/etc)

	public SyntacticProcessor(){
		this("en");
	}
	public SyntacticProcessor(String language) {
		init();
	}

	/**
	 * Creates the Gate application workers
	 * Assumes Gate.init()! 
	 */
	public void init() {
		if (pool!=null)return;
		pool = new LinkedBlockingQueue<SerialAnalyserController>();
		try {
			for(int i = 0; i < POOL_SIZE; i++) {
				pool.add(loadController());
			}
		} catch (GateException e) {
			e.printStackTrace();
		} catch (IOException e) {
			e.printStackTrace();
		}
	}

	public void destroy() {
		for(CorpusController c : pool) 
			Factory.deleteResource(c);
	}

	@Override
	public Document process(Document doc,Map<String, String> params) {

		Document d=null;
		try {
			d=processGate(doc, params);
		} catch (ResourceInstantiationException e) {
			e.printStackTrace();
		} catch (ExecutionException e) {
			e.printStackTrace();
		} catch (GateException e) {
			e.printStackTrace();
		} catch (IOException e) {
			e.printStackTrace();
		}
		return d;

	}

	/**
	 * Creates a GATE application
	 * TODO: design pattern - allow other application loaders
	 * @return
	 * @throws GateException
	 * @throws IOException
	 */
	protected SerialAnalyserController loadController() throws GateException, IOException{
		SerialAnalyserController application=null;
		//Alternative load from gapp file
		//
		// load application
		application=(SerialAnalyserController) Factory.createResource(
				"gate.creole.SerialAnalyserController", Factory.newFeatureMap(),
				Factory.newFeatureMap(), "SYNC_" + Gate.genSym() );

		return application;
	}

	void loadANNIE(SerialAnalyserController application) throws ResourceInstantiationException{
		// load each standard PR 

		//"gate.creole.tokeniser.DefaultTokeniser"
		FeatureMap params = null;
		ProcessingResource pr = null;
		String prname=null;
		params=Factory.newFeatureMap(); 
		params.put("annotationSetName", workingAS);
		prname="gate.creole.tokeniser.DefaultTokeniser";
		//Force \n to split sentences: main-single-nl.jape instead of main.jape 
		pr = (ProcessingResource) Factory.createResource(prname, params);
		// add the PR to the pipeline controller
		application.add(pr);

		//"gate.creole.splitter.SentenceSplitter"
		params = Factory.newFeatureMap(); 
		params.put("inputASName", workingAS);
		params.put("outputASName", workingAS);
		prname="gate.creole.splitter.SentenceSplitter";
		pr = (ProcessingResource) Factory.createResource(prname, params);
		// add the PR to the pipeline controller
		application.add(pr);

		///old:"gate.creole.POSTagger"
		loadPOSTagger(application,language);
	}

	protected void loadPOSTagger(SerialAnalyserController application, String language2) throws ResourceInstantiationException {

		if ("en".equalsIgnoreCase(language2)) {
			FeatureMap params = Factory.newFeatureMap(); 
			params.put("inputASName", workingAS); 
			params.put("outputASName", workingAS); 
			ProcessingResource pr = (ProcessingResource)
					Factory.createResource("gate.creole.POSTagger", params);

			application.add(pr);
		} else if ("bg".equalsIgnoreCase(language2)) {
			FeatureMap params = Factory.newFeatureMap(); // use default parameters
			try {
				//FIXME: fix path setup
				params.put("taggerBinary", new URL("file:/home/idornescu/apps/treetagger3.2/cmd/tree-tagger-bulgarian"));
			} catch (MalformedURLException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
			params.put("inputASName", workingAS); 
			params.put("outputASName", workingAS); 
			params.put("inputAnnotationtype", "Sentence");
			params.put("outputAnnotationtype", "Token");
			params.put("encoding", "UTF8");

			ProcessingResource pr = (ProcessingResource)
					Factory.createResource("gate.taggerframework.GenericTagger", params);

			application.add(pr);
		} 
	}

	ProcessingResource loadAppositionDetector() throws ResourceInstantiationException{
		FeatureMap params = Factory.newFeatureMap(); 
		FeatureMap scriptParams = Factory.newFeatureMap(); 

		params.put("scriptURL","../../resources/detectAppositions.v0.3.groovy");//exportCRFpr.groovy");
		params.put("inputASName","syntax");
		params.put("outputASName","syntax");

		//scriptParams.put("runMode","detect");//ignored
		scriptParams.put("inputAnnieAS",workingAS);
		scriptParams.put("cleanAnnie","false");
		scriptParams.put("workerId",""+(int)(100+Math.random()*900));
		scriptParams.put("fileprefix",Gate.getGateHome().getAbsolutePath()+"/");//"target/gate/");
		//
		params.put("scriptParams",scriptParams);
		ProcessingResource pr= (ProcessingResource) Factory.createResource("gate.groovy.ScriptPR", params);

		return pr;
	}

	ProcessingResource loadRuleEngine(String syntaxModel) throws ResourceInstantiationException{
		FeatureMap params = Factory.newFeatureMap(); 
		FeatureMap scriptParams = Factory.newFeatureMap(); 

		//params.put("scriptURL","../../resources/applySyntacticRulesPlv0.2.groovy");//exportCRFpr.groovy");
		params.put("scriptURL","../../resources/applySyntacticRulesPl.v0.3.groovy");//exportCRFpr.groovy");
		params.put("inputASName","syntax");
		params.put("outputASName","syntax");

		//which model to use for the structure processor
		scriptParams.put("processorDir", syntaxModel);
		scriptParams.put("inputAnnieASName",workingAS);
		scriptParams.put("cleanAnnie","false");
		scriptParams.put("workerId",""+(int)(100+Math.random()*900));
		scriptParams.put("prefix",Gate.getGateHome().getAbsolutePath()+"/");
		scriptParams.put("fileprefix",Gate.getGateHome().getAbsolutePath()+"/");//"target/gate/");
		scriptParams.put("relativePath","../../");
		
		
		scriptParams.put("runDiagnosis","true");
		scriptParams.put("diagnosisDir","SyntacticDiagnosis-v1"); 
		scriptParams.put("diagnosisAS","SentenceDetection"); 
		//
		params.put("scriptParams",scriptParams);
		ProcessingResource pr= (ProcessingResource) Factory.createResource("gate.groovy.ScriptPR", params);

		return pr;
	}

	ProcessingResource loadSignProcessor(String signModel) throws ResourceInstantiationException{

		FeatureMap params = Factory.newFeatureMap();
		FeatureMap scriptParams = Factory.newFeatureMap();

		params.put("inputASName",workingAS);
		params.put("outputASName","syntax"); 
		//this path is relative to the $gateHome/$plugins/Groovy directory (!classloader of creole resources)
		params.put("scriptURL","../../resources/exportCRFpr.v0.7.groovy"); 

		//which model to use "model-${modelfile}.model"
		scriptParams.put("modelfile",signModel);
		//if useSyntax=true, then Stanford annotations are assumed to be present 
		scriptParams.put("useSyntax","false");
		//files/paths
		scriptParams.put("outFileBuffer","out-crf-"+(int)(100+Math.random()*900)+"-tmp.txt");
		scriptParams.put("prefix",Gate.getGateHome().getAbsolutePath()+"/");
		scriptParams.put("crfprefix","/apps/CRF++-0.57/");
		//other params
		scriptParams.put("trainMode","false");//use Gold annotations ("Original markups")
		scriptParams.put("buildMode","false");//train a new Model on the generated file
		scriptParams.put("predictMode","true");//use model to make predictions

		params.put("scriptParams",scriptParams);
		ProcessingResource pr= (ProcessingResource) Factory.createResource("gate.groovy.ScriptPR", params);
		return pr;
	}

	/**
	 * Destructive processing of document doc
	 * @param doc input/output document
	 * @return
	 * @throws GateException
	 * @throws IOException
	 */
	public Document processGate(Document doc, Map<String, String> params) throws GateException, IOException{

		//Wait until a controller from the pool becomes available
		SerialAnalyserController app1 = null;
		try {
			app1=pool.take();
		} catch (InterruptedException e) {
			e.printStackTrace();
		}

		try {

			params=checkParameters(params);
			// get optional processors
			SerialAnalyserController app=(SerialAnalyserController) Factory.duplicate(app1);
			loadANNIE(app);
			app.add(loadSignProcessor(params.get("sign.modelfile")));
			if (!"ignore".equals(params.get("syntax.appositions"))) 
				app.add(loadAppositionDetector());
			if (!"ignore".equals(params.get("syntax.structure")))
				app.add(loadRuleEngine(params.get("syntax.syntaxModel")));
			else if ("y".equals(params.get("syntax.diagnosis")))
				app.add(loadRuleEngine(params.get("syntax.syntaxModel")));
			// create a new corpus to use.
			Corpus corpus = Factory.newCorpus("BatchProcessApp Corpus");
			app.setCorpus(corpus);
			corpus.add(doc);
			// run the application
			app.execute();

			// remove the document from the corpus again
			corpus.clear();

			int prs=app.getPRs().size();
			while (prs>0){
				app.remove(0);
				prs=prs-1;
			}
			Factory.deleteResource(app);
		
			return doc;
		}finally{
			//return worker to the pool
			pool.add(app1);
		}
	}

	protected Map<String, String> checkParameters(Map<String, String> params) {
		Map<String, String> initParams=new HashMap<String, String>();
		//initParams.put("syntax.processAppositions","true");
		//initParams.put("syntax.processSyntax","true");
		//initParams.put("syntax.diagnose", "y");
		initParams.put("syntax.keepTokenisation","false");

		initParams.put("sign.model.meter","meter-bio-tpl-alpha-02");
		initParams.put("sign.model.patient","patient-tpl-alpha-02");
		initParams.put("sign.model.literature","literature-bio-tpl-alpha-02");
		initParams.put("sign.modelfile",initParams.get("sign.model.meter"));
		initParams.put("syntax.syntaxModel","SyntacticProcessor-v2");//"SyntacticSimplification");//

		if (null!=params){
			//passthrough
			for (String key:params.keySet()){
				initParams.put(key, params.get(key));
			}
			String m=params.get("syntax.model");
			if (initParams.containsKey("sign.model."+m))
				initParams.put("sign.modelfile", initParams.get("sign.model."+m));		

			if ("taggedsigns".equals(params.get("syntax.outFormat"))){
				//initParams.put("syntax.processAppositions","false");
				//initParams.put("syntax.processSyntax","false");
				initParams.put("syntax.appositions", "ignore");
				initParams.put("syntax.structure", "ignore");
			}
		}
		return initParams;
	}

}
