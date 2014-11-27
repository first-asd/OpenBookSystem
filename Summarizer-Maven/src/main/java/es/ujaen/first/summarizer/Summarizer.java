package es.ujaen.first.summarizer;
/**
 * Summarizer interface
 * @author Eduard
 */
import java.util.List;

import gate.Document;

import org.apache.log4j.Logger;

public interface Summarizer {
	
	public void setDocument (Document gateDocument);
	public void summarize ();
	public List <String> getSummary(double percent);
	public List <String> getSummary(int nSentences);

}
