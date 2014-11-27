/**
 * 
 */
package es.ujaen.sinai.first;

/**
 * Class representing 
 * @author Eduard
 *
 */
public class MultiWordUnit {

	private String multiWordString="";
	private String multiWordLemma="";
	private String multiWordDefinition="";
	private String wikipediaURL="";
	

	public String getString() {
		return multiWordString;
	}

	public void setString(String multiWordString) {
		this.multiWordString = multiWordString;
	}
	
	public String getLemma() {
		return multiWordLemma;
	}

	public void setLemma(String lemma) {
		this.multiWordLemma = lemma;
	}
	
	public String getDefinition() {
		return multiWordDefinition;
	}

	
	public void setDefinition(String definition) {
		this.multiWordDefinition= definition;
	}

	public String getWikipediaURL() {
		return wikipediaURL;
	}

	public void setWikipediaURL(String wikipediaURL) {
		this.wikipediaURL = wikipediaURL;
	}

	
	
	
	
}
