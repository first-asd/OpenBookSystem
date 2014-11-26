package wlv.openbook.service;

import java.util.Map;

import gate.Document;

/**
 * Generic class for processing a document 
 * (usually manipulation of document annotations)
 * 
 * @author idornescu
 *
 */
public abstract class ObstacleProcessor {

	public Document process(Document doc){
		return this.process(doc,null);
	}
	
	abstract public Document process(Document doc, Map<String,String> params);
	
}
