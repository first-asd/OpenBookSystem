package es.ujaen.sinai.first;

import gate.Document;

import java.util.Map;

public interface INLPTOOL {
	
	/**
	 * Initiate the NLP tool.
	 * @param params
	 */
	public void init(Map<String, Object> params);
	
	/**
	 * Set the content to process.
	 * @param doc
	 */
	public void setContent(Document doc);
	
	
	/**
	 * Return the content processed
	 * @return
	 */
	public Object getContent();
	
	/**
	 * Tokenize the content.
	 */
	public void tokenize();
	
	/**
	 * Split the content.
	 */
	public void splitter();
	
	
	/**
	 * Lemmatize the content.
	 */
	public void lemmatize();
	
	/**
	 * This method runs a typical nlp process which covers: tokenization
	 * splitting, lematization and pos-tagging.
	 */
	public void nlpTokSplitMorphPos();

}
