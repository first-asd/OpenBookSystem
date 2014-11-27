/**
 * 
 */
package es.ujaen.sinai.freelingnlp.model;

import java.io.File;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.math.BigInteger;

import javax.xml.bind.JAXBException;

import org.xml.sax.SAXException;

import edu.upc.freeling.HmmTagger;
import edu.upc.freeling.ListSentence;
import edu.upc.freeling.ListWord;
import edu.upc.freeling.Maco;
import edu.upc.freeling.MacoOptions;
import edu.upc.freeling.Sentence;
import edu.upc.freeling.Splitter;
import edu.upc.freeling.Tokenizer;
import edu.upc.freeling.Util;
import edu.upc.freeling.Word;
import es.ujaen.sinai.freelingnlp.model.io.IFactoryIOShare;
import es.ujaen.sinai.freelingnlp.model.io.IIOShare;
import es.ujaen.sinai.freelingnlp.model.utils.PropertiesFields;
import es.ujaen.sinai.freelingnlp.model.utils.PropertiesManagement;

/**
 * @author Eugenio Martínez Cámara
 * @date 02/01/2014
 * Implementation of the application model or backend.
 *
 */
public class FreelingNLPprocess implements IModel {
	
	/**
	 * Text to process
	 */
	private String text;
	
	/**
	 * Indication flag of the modification of the original text
	 */
	private boolean textModified;
	
	/**
	 * Texto procesado
	 */
	private ListSentence processedText;
	
	/**
	 * IO handler
	 */
	private IIOShare iohandler;
	
	/**
	 * Name of the ouput file.
	 */
	private String outputfile;
	
	
	/**
	 * Sole constructor
	 */
	public FreelingNLPprocess() {
		text = "";
		processedText = null;
		iohandler = null;
		outputfile = null;
		textModified = false;
	}

	/**
	 * Init the model
	 * @throws IOException 
	 * @throws FileNotFoundException 
	 * @throws ClassNotFoundException 
	 * @throws IllegalAccessException 
	 * @throws InstantiationException 
	 */
	public void init(String confPath, String aOutputfile) throws FileNotFoundException, IOException, ClassNotFoundException, InstantiationException, IllegalAccessException {
		PropertiesManagement.loadProperties(confPath);
		String nameFactoryIOShare = PropertiesManagement.getPropertyValue(PropertiesFields.IOSHAREFACTORY.toString());
		Class<?> cf = Class.forName(nameFactoryIOShare);
		IFactoryIOShare factIOShare = (IFactoryIOShare) cf.newInstance();
		iohandler = factIOShare.getIOShare();
		outputfile = aOutputfile;
	}

	/**
	 * Method to load the input text.
	 * @throws SAXException 
	 * @throws JAXBException 
	 * @throws FileNotFoundException 
	 */
	public void loadText(String inputPath) throws FileNotFoundException, JAXBException, SAXException {
		text = iohandler.loadText(inputPath);
		String auxText = text.trim();
		if(!auxText.endsWith(".")) {
			textModified = true;
			text += ".";
		}
	}

	/**
	 * Processed the input text.
	 */
	public void processText() {
		System.loadLibrary(PropertiesManagement.getPropertyValue(PropertiesFields.FREELINGJAVAAPI.toString()));
		Util.initLocale("default");
		String fpathdata = PropertiesManagement.getPropertyValue(PropertiesFields.FREELINGDATA.toString());
		String sharePath = fpathdata + File.separator + PropertiesManagement.getPropertyValue(PropertiesFields.LANG.toString()) + File.separator;
		String fpathtokenizer = sharePath + PropertiesManagement.getPropertyValue(PropertiesFields.FREELINGTOKENIZER.toString());
		String fpathsplitter = sharePath + PropertiesManagement.getPropertyValue(PropertiesFields.FREELINGSPLITTER.toString());
		String fpathlocutions = sharePath + PropertiesManagement.getPropertyValue(PropertiesFields.FREELINGLOCUTIONS.toString());
		String fpathquantities = sharePath + PropertiesManagement.getPropertyValue(PropertiesFields.FREELINGQUANTITIES.toString());
		String fpathafixos = sharePath + PropertiesManagement.getPropertyValue(PropertiesFields.FREELINGAFIXOS.toString());
		String fpathprobabilities = sharePath + PropertiesManagement.getPropertyValue(PropertiesFields.FREELINGPROBABILITIES.toString());
		String fpathdicc = sharePath + PropertiesManagement.getPropertyValue(PropertiesFields.FREELINGDICC.toString());
		String fpathnp = sharePath + PropertiesManagement.getPropertyValue(PropertiesFields.FREELINGNP.toString());
		String fpathpunct = fpathdata + File.separator + PropertiesManagement.getPropertyValue(PropertiesFields.FREELINGPUNCT.toString());
		String fpathcorrector = sharePath + PropertiesManagement.getPropertyValue(PropertiesFields.FREELINGCORRECTOR.toString());
		String fpathtagger = sharePath + PropertiesManagement.getPropertyValue(PropertiesFields.FREELINGTAGGER.toString());
		Tokenizer tokenizer = new Tokenizer(fpathtokenizer);
		Splitter splitter = new Splitter(fpathsplitter);
		MacoOptions morphoOptions = new MacoOptions(PropertiesManagement.getPropertyValue(PropertiesFields.LANG.toString()));
		morphoOptions.setActiveModules(false, true, false, true, true, false, false, true, true, true, false);
		morphoOptions.setRetokContractions(false);
		morphoOptions.setDataFiles("", fpathlocutions, fpathquantities, fpathafixos, fpathprobabilities, fpathdicc, fpathnp, fpathpunct, fpathcorrector);
		Maco morpho = new Maco(morphoOptions);
		HmmTagger posTagger = new HmmTagger(PropertiesFields.LANG.toString(),fpathtagger,false,1);
//		HmmTagger posTagger = new HmmTagger(fpathtagger,true,2);
		ListWord words = tokenizer.tokenize(text);
		processedText = splitter.split(words, false);
		words.clear();
		words.delete();
		morpho.analyze(processedText);
		posTagger.analyze(processedText);
	}

	/**
	 * Method to Write the processed text.
	 */
	public void writeOutput() throws JAXBException {
		BigInteger beginSentence = null, endSentence = null;
		
		iohandler.initWriter();
		if(textModified)
			iohandler.setText(text.substring(0, (text.length() - 1)));
		else
			iohandler.setText(text);
//		ListSentenceIterator iterSentences = new ListSentenceIterator(processedText);
//		while(iterSentences.hasNext()) {
//			Sentence sent = iterSentences.next();
//			VectorWord words = sent.getWords();
//			for(int i = 0; i < words.size(); i++) {
//				Word word = words.get(i);
//				BigInteger beginSpan = BigInteger.valueOf(word.getSpanStart());
//				BigInteger endSpan = BigInteger.valueOf(word.getSpanFinish());
//				String form = word.getForm();
//				String lemma = word.getLemma();
//				String category = word.getTag();
//				iohandler.addToken(beginSpan, endSpan, form, lemma, category);
//				if(i == 0) beginSentence = beginSpan;
//				if(i == (words.size() - 1)) endSentence = endSpan;
//			}
//			iohandler.addSentence(beginSentence, endSentence);
//		}
		for (int i = 0; i < processedText.size(); i++) {
			Sentence sent = processedText.get(i);
			int numberOfWords = (int) sent.size();
			if((i == (processedText.size() - 1)) && textModified)
				numberOfWords--;
			for(int j = 0; j < numberOfWords; j++) {
				Word word = sent.get(j);
				BigInteger beginSpan = BigInteger.valueOf(word.getSpanStart());
				BigInteger endSpan = BigInteger.valueOf(word.getSpanFinish());
				String form = word.getForm();
				String lemma = word.getLemma();
				String category = word.getTag();
				iohandler.addToken(beginSpan, endSpan, form, lemma, category);
				if(j == 0) beginSentence = beginSpan;
				if(j == (numberOfWords - 1))
					endSentence = endSpan;
			}
			iohandler.addSentence(beginSentence, endSentence);
		}
		iohandler.setOutputPath(outputfile);
		iohandler.write();
	}

}
