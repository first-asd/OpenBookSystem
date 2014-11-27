/**
 * 
 */
package es.ujaen.sinai.first;

import java.util.HashMap;
import java.util.Map;

import es.ujaen.sinai.first.io.ManageProperties;

/**
 * @author geni
 *
 */
public class FactoryNLPen implements IFactoryNLPTools {

	/* (non-Javadoc)
	 * @see es.ujaen.sinai.first.IFactoryNLPTools#createNLPTool()
	 */
	public INLPTOOL createNLPTool() {
		return (new NLPGate());
	}

	/**
	 * Method that returns the specific parameters to the GATE nlp tool.
	 */
	public Map<String, Object> getParameters() {
		Map<String, Object> params = new HashMap<String, Object>();
		ManageProperties properties = ManageProperties.getInstance();
		params.put("ENCODING", properties.getValue(PropertiesFields.ENCODING.toString()));
		return (params);
	}

}
