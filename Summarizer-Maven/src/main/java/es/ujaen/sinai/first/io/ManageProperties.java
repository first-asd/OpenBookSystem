/**
 * 
 */
package es.ujaen.sinai.first.io;

import java.io.BufferedReader;
import java.io.FileNotFoundException;
import java.io.FileReader;
import java.io.IOException;
import java.util.Properties;

/**
 * This class manages the configuration properties load.
 * @author Eugenio Martínez Cámara
 */
public class ManageProperties {
	
	
	private static ManageProperties INSTANCE = null;
	
	private static Properties properties;
	
	/**
	 * Default constructor.
	 */
	private ManageProperties(){
		properties = new Properties();
	}
	
	/**
	 * Method that create the instance of this singleton class.
	 * It's safe multithrading.
	 */
	private final static void createInstance() {
		if(INSTANCE == null) {
			synchronized (ManageProperties.class) {
				if(INSTANCE == null)
					INSTANCE = new ManageProperties();
			}
		}
	}
	
	/**
	 * Returns the unique instance of the class.
	 * @return
	 */
	public final static ManageProperties getInstance() {
		createInstance();
		return(INSTANCE);
	}
	
	/**
	 * The clone method is overridden to avoid the cloning of an object of this
	 * class.
	 */
	public final Object clone() throws CloneNotSupportedException {
		throw new CloneNotSupportedException();
	}
	
	/**
	 * Load the properties file.
	 * @param path Path of the configuration file.
	 * @throws FileNotFoundException
	 * @throws IOException
	 */
	public final void loadProperties(String path) throws FileNotFoundException, IOException {
		properties.load(new BufferedReader(new FileReader(path)));
	}
	
	/**
	 * It returns the value of the property key.
	 * @param key
	 * @return
	 */
	public final String getValue(String key) {
		return(properties.getProperty(key, ""));
	}

}
