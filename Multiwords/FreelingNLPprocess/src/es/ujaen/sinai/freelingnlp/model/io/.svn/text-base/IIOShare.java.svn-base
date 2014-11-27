/**
 * 
 */
package es.ujaen.sinai.freelingnlp.model.io;

import java.io.FileNotFoundException;
import java.math.BigInteger;

import javax.xml.bind.JAXBException;

import org.xml.sax.SAXException;

/**
 * @author Eugenio Martínez Cámara
 * @date 02/01/2014
 * Inteface for io operations related with the share file.
 *
 */
public interface IIOShare {

	/**
	 * Load the file with share information
	 * @param inputPath
	 * @return
	 * @throws JAXBException 
	 * @throws SAXException 
	 * @throws FileNotFoundException 
	 */
	public String loadText(String inputPath) throws JAXBException, SAXException, FileNotFoundException;
	
	public void setOutputPath(String aOutputPath);
	public void initWriter();
	public void setText(String text);
	public void addToken(BigInteger beginSpan, BigInteger endSpan, String form, String lemma, String category);
	public void addSentence(BigInteger beginSpan, BigInteger endSpan);
	public void write() throws JAXBException;
}
