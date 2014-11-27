/**
 * 
 */
package es.ujaen.sinai.first;

import java.util.HashMap;
import java.util.Map;

import es.ujaen.sinai.first.io.ManageProperties;

/**
 * @author Eugenio Martínez Cámara
 *
 */
public class FactoryNLPes implements IFactoryNLPTools {

	/**
	 * This method create an instance of NLPFreeling class.
	 * @see es.ujaen.sinai.first.IFactoryNLPTools#createNLPTool()
	 */
	public INLPTOOL createNLPTool() {
		// TODO Auto-generated method stub
		return (new NLPFreeling());
	}

	
	public Map<String, Object> getParameters() {
		Map<String, Object> params = new HashMap<String, Object>();
		ManageProperties properties = ManageProperties.getInstance();
		params.put(PropertiesFields.INTERMEDIARYFILESDIR.toString(), properties.getValue(PropertiesFields.INTERMEDIARYFILESDIR.toString()));
		params.put(PropertiesFields.NLPTOOLFORSPANISH.toString(), properties.getValue(PropertiesFields.NLPTOOLFORSPANISH.toString()));
		params.put(PropertiesFields.NLPTOOLFORSPANISHCONFPATH.toString(), properties.getValue(PropertiesFields.NLPTOOLFORSPANISHCONFPATH.toString()));
		params.put(PropertiesFields.SCHEMAFILE.toString(), properties.getValue(PropertiesFields.SCHEMAFILE.toString()));
		return (params);
	}

}
