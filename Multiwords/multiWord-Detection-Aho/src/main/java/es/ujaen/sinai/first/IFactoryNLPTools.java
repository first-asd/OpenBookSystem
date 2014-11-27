/**
 * 
 */
package es.ujaen.sinai.first;

import java.util.Map;

import es.ujaen.sinai.first.io.ManageProperties;


/**
 * This interface difines the method for NLPTools factories.
 * @author Eugenio Martínez Cámara
 *
 */
public interface IFactoryNLPTools {

	/**
	 * Method that create the right NLPTool
	 * @return
	 */
	public INLPTOOL createNLPTool();
	
	public Map<String, Object> getParameters();
	
}
