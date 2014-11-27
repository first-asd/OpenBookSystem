/**
 * 
 */
package es.ujaen.sinai.freelingnlp.model;

import java.io.FileNotFoundException;
import java.io.IOException;

import javax.xml.bind.JAXBException;

import org.xml.sax.SAXException;

/**
 * @author Eugenio Martínez Cámara
 * @date 02/01/2014
 * Interface of the application model or backend.
 *
 */
public interface IModel {

	/**
	 * Init the model
	 * @param confPath Configuration path of the application
	 * @throws IOException 
	 * @throws FileNotFoundException 
	 * @throws ClassNotFoundException 
	 * @throws IllegalAccessException 
	 * @throws InstantiationException 
	 */
	public void init(String confPath, String aOutputfile) throws FileNotFoundException, IOException, ClassNotFoundException, InstantiationException, IllegalAccessException;
	
	/**
	 * Path of the input file.
	 * @param inputPath
	 * @throws SAXException 
	 * @throws JAXBException 
	 * @throws FileNotFoundException 
	 */
	public void loadText(String inputPath) throws FileNotFoundException, JAXBException, SAXException;
	
	/**
	 * Do the nlp stuff.
	 */
	public void processText();
	
	/**
	 * Write the output.
	 * @throws JAXBException 
	 */
	public void writeOutput() throws JAXBException;
}
