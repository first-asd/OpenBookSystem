package es.ujaen.aggregator;

public class Eol {
	
	long startOffset;
	long endOffset;
	boolean isParagraph;
	
	public long getStartOffset() {
		return startOffset;
	}
	
	public void setStartOffset(long startOffset) {
		this.startOffset = startOffset;
	}
	
	public long getEndOffset() {
		return endOffset;
	}
	
	public void setEndOffset(long endOffset) {
		this.endOffset = endOffset;
	}
	
	public boolean isParagraph() {
		return isParagraph;
	}
	public void setParagraph(boolean isParagraph) {
		this.isParagraph = isParagraph;
	}
	
	

}
