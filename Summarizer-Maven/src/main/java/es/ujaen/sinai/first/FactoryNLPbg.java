package es.ujaen.sinai.first;

import java.util.Map;

/**
 * Factory for Bulgarian tool.
 * @author Eduard 
 */
public class FactoryNLPbg implements IFactoryNLPTools  {
	
     public INLPTOOL createNLPTool()
     {
    	 return (new NLPBulgarian());
     }
	
	public Map<String, Object> getParameters()
	{
		return null;
	}

}
