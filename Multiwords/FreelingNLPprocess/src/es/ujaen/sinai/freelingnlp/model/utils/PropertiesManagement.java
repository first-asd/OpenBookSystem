/**
 * 
 */
package es.ujaen.sinai.freelingnlp.model.utils;

import java.io.BufferedReader;
import java.io.FileNotFoundException;
import java.io.FileReader;
import java.io.IOException;
import java.util.Properties;

/**
 * @author geni
 *
 */
public class PropertiesManagement {

	
	private static Properties properties = new Properties();
	
	/**
	 * Load configuration file.
	 * @param path Path of the configuration file.
	 * @throws FileNotFoundException
	 * @throws IOException
	 */
	public static void loadProperties(String path) throws FileNotFoundException, IOException{
		properties.load(new BufferedReader(new FileReader(path)));
	}
	
	/**
	 * Return the value of a configuration field.
	 * @param key
	 * @return
	 */
	public static String getPropertyValue(String key) {
		return(properties.getProperty(key));
	}
}
