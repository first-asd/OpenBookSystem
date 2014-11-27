/**
 * 
 */
package es.ujaen.sinai.first;

import gate.Corpus;
import gate.Document;
import gate.Factory;
import gate.Gate;
import gate.ProcessingResource;
import gate.creole.SerialAnalyserController;
import gate.util.GateException;

import java.io.File;
import java.net.MalformedURLException;
import java.util.Map;

/**
 * es.ujaen.sinai.first
 * @author Eugenio Martínez Cámara
 * @since  02/12/2013
 *
 */
public class NLPGate implements INLPTOOL {
	
	private String encoding;
	
	private Document gateDoc;
	

	/**
	 * Default constructor
	 */
	public NLPGate(){}
	
	/**
	 * Initiate Gate Tool.
	 * @see es.ujaen.sinai.first.INLPTOOL#init(java.util.Map)
	 */
	public void init(Map<String, Object> params) {
		encoding = (String) params.get("ENCODING");

	}

	/* (non-Javadoc)
	 * @see es.ujaen.sinai.first.INLPTOOL#setContent(java.lang.Object)
	 */
	@Override
	public void setContent(Document doc) {
		gateDoc = (Document) doc;

	}

	/* (non-Javadoc)
	 * @see es.ujaen.sinai.first.INLPTOOL#getContent()
	 */
	@Override
	public Object getContent() {
		// TODO Auto-generated method stub
		return (gateDoc);
	}

	/* (non-Javadoc)
	 * @see es.ujaen.sinai.first.INLPTOOL#tokenize()
	 */
	@Override
	public void tokenize() {
		
		File annieDirectory = new File ( Gate.getPluginsHome (), "ANNIE");
		try {
			Gate.getCreoleRegister().registerDirectories(annieDirectory.toURI().toURL());
			ProcessingResource simpleTokenizer = (ProcessingResource) Factory.createResource("gate.creole.tokeniser.SimpleTokeniser");
			SerialAnalyserController annieController =
					( SerialAnalyserController ) Factory.createResource ("gate.creole.SerialAnalyserController", Factory.newFeatureMap(),Factory.newFeatureMap (), " ANNIE ");
			annieController . add(simpleTokenizer);
			Corpus corpus = Factory.newCorpus("UnicodeTokenizer-Corpus");
			annieController.setCorpus (corpus);
			corpus.add(gateDoc);
			annieController.execute();
			corpus.clear();
		} catch (MalformedURLException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		} catch (GateException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}

	}

	/* (non-Javadoc)
	 * @see es.ujaen.sinai.first.INLPTOOL#splitter()
	 */
	@Override
	public void splitter() {
		File splitterDirectory = new File(Gate.getPluginsHome(), "ANNIE");
		
		try {
			Gate.getCreoleRegister().registerDirectories(splitterDirectory.toURI().toURL());
			ProcessingResource splitter = (ProcessingResource) Factory.createResource("gate.creole.splitter.SentenceSplitter");
			SerialAnalyserController analyzerController = (SerialAnalyserController) Factory.createResource("gate.creole.SerialAnalyserController", Factory.newFeatureMap(),Factory.newFeatureMap (), " ANNIE ");
			analyzerController.add(splitter);
			Corpus corpus = Factory.newCorpus("Splitter-corpus");
			analyzerController.setCorpus(corpus);
			corpus.add(gateDoc);
			analyzerController.execute();
			corpus.clear();
		} catch (MalformedURLException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		} catch (GateException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
	}

	/**
	 * Lemmatize a gate document.
	 * @see es.ujaen.sinai.first.INLPTOOL#lemmatize()
	 */
	public void lemmatize() {
		File morphoDirectory = new File(Gate.getPluginsHome(), "Tools");
		
		try {
			Gate.getCreoleRegister().registerDirectories(morphoDirectory.toURI().toURL());
			ProcessingResource postagger = (ProcessingResource) Factory.createResource("gate.creole.POSTagger");
			ProcessingResource lemmatizer = (ProcessingResource) Factory.createResource("gate.creole.morph.Morph");
			SerialAnalyserController analyzerController = (SerialAnalyserController) Factory.createResource("gate.creole.SerialAnalyserController", Factory.newFeatureMap(),Factory.newFeatureMap (), " Tools ");
			analyzerController.add(postagger);
			analyzerController.add(lemmatizer);
			Corpus corpus = Factory.newCorpus("Lemma-corpus");
			analyzerController.setCorpus(corpus);
			corpus.add(gateDoc);
			analyzerController.execute();
			corpus.clear();
		} catch (MalformedURLException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		} catch (GateException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}

	}

	/**
	 * This method runs a typical nlp process which covers: tokenization
	 * splitting, lematization and pos-tagging.
	 */
	public void nlpTokSplitMorphPos() {
		File annieDirectory = new File ( Gate.getPluginsHome (), "ANNIE");
		File morphoDirectory = new File(Gate.getPluginsHome(), "Tools");
		
		try {
			Gate.getCreoleRegister().registerDirectories(annieDirectory.toURI().toURL());
			Gate.getCreoleRegister().registerDirectories(morphoDirectory.toURI().toURL());
			ProcessingResource simpleTokenizer = (ProcessingResource) Factory.createResource("gate.creole.tokeniser.SimpleTokeniser");
			ProcessingResource splitter = (ProcessingResource) Factory.createResource("gate.creole.splitter.SentenceSplitter");
			ProcessingResource postagger = (ProcessingResource) Factory.createResource("gate.creole.POSTagger");
			ProcessingResource lemmatizer = (ProcessingResource) Factory.createResource("gate.creole.morph.Morph");
			SerialAnalyserController analyzerController = (SerialAnalyserController) Factory.createResource("gate.creole.SerialAnalyserController", Factory.newFeatureMap(),Factory.newFeatureMap (), " NLPPIPELINE ");
			analyzerController.add(simpleTokenizer);
			analyzerController.add(splitter);
			analyzerController.add(postagger);
			analyzerController.add(lemmatizer);
			Corpus corpus = Factory.newCorpus("NLP-corpus");
			analyzerController.setCorpus(corpus);
			corpus.add(gateDoc);
			analyzerController.execute();
			corpus.clear();
		} catch (MalformedURLException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		} catch (GateException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
	}

}
