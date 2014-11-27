package es.ujaen.ImageRetrieval;

public class ConceptImage {
	
	private long startOffset;
	private long endOffset;
	private String conceptName;
	private String wordnetId=null;
	private String wikipediaURL;
	private String wikipediaImageURL=null;
	private String[] imagesURL=null;
	
	public void setStartOffset(long startOffset) {
		this.startOffset = startOffset;
	}
	
	public long getStartOffset() {
		return startOffset;
	}
	
	public void setEndOffset(long endOffset) {
		this.endOffset = endOffset;
	}
	
	public long getEndOffset() {
		return endOffset;
	}
	
	public void setConceptName(String conceptName) {
		this.conceptName = conceptName;
	}
	
	public String getConceptName() {
		return conceptName;
	}
	
	public void setImagesURL(String[] imagesURL) {
		this.imagesURL = imagesURL;
	}
	
	public String[] getImagesURL() {
		return imagesURL;
	}

	public void setWikipediaURL(String wikipediaURL) {
		this.wikipediaURL = wikipediaURL;
	}

	public String getWikipediaURL() {
		return wikipediaURL;
	}

	public void setWikipediaImageURL(String wikipediaImageURL) {
		this.wikipediaImageURL = wikipediaImageURL;
	}

	public String getWikipediaImageURL() {
		return wikipediaImageURL;
	}

	public String getWordnetId() {
		return wordnetId;
	}

	public void setWordnetId(String wordnetId) {
		this.wordnetId = wordnetId;
	}
		

}
