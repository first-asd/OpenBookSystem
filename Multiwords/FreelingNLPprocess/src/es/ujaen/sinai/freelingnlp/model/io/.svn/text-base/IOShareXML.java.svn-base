	/**
 * 
 */
package es.ujaen.sinai.freelingnlp.model.io;

import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.math.BigInteger;

import javax.xml.XMLConstants;
import javax.xml.bind.JAXBContext;
import javax.xml.bind.JAXBElement;
import javax.xml.bind.JAXBException;
import javax.xml.bind.Marshaller;
import javax.xml.bind.Unmarshaller;
import javax.xml.validation.SchemaFactory;

import org.xml.sax.SAXException;

import es.ujaen.sinai.freelingnlp.model.utils.PropertiesFields;
import es.ujaen.sinai.freelingnlp.model.utils.PropertiesManagement;
import es.ujaen.sinai.nlptoolsshare.*;

/**
 * @author Eugenio Martínez Cámara
 * @date 02/01/2014
 * Specific IOShare that read and write a xml share file.
 *
 */
public class IOShareXML implements IIOShare{
	
	/**
	 * Root element of the xml output file.
	 */
	private NlptoolsshareType nlptoshare;
	
	private DocumentType document;
	
	private TokensType tokens;
	
	/**
	 * Output path.
	 */
	private String outputPath;

	
	public IOShareXML() {
		nlptoshare = null;
		outputPath = null;
		document = null;
		tokens = null;
	}
	
	/**
	 * @throws JAXBException 
	 * @throws SAXException 
	 * @throws FileNotFoundException 
	 * @see es.ujaen.sinai.freelingnlp.model.io.IIOShare#loadText(java.lang.String)
	 */
	public String loadText(String inputPath) throws JAXBException, SAXException, FileNotFoundException {
		JAXBContext jxbcontext = JAXBContext.newInstance("es.ujaen.sinai.nlptoolsshare");
		Unmarshaller unmarshall = jxbcontext.createUnmarshaller();
		SchemaFactory sf = SchemaFactory.newInstance(XMLConstants.W3C_XML_SCHEMA_NS_URI);
		String xsdFile = PropertiesManagement.getPropertyValue(PropertiesFields.SCHEMAFILE.toString());
		unmarshall.setSchema(sf.newSchema(new File(xsdFile)));
		unmarshall.setEventHandler(new XMLValidation());
		JAXBElement<NlptoolsshareType> xml = (JAXBElement<NlptoolsshareType>) unmarshall.unmarshal(new FileInputStream(inputPath));
		return (xml.getValue().getDocument().getText());
	}
	
	/**
	 * Set the output path.
	 * @param aOutputPath
	 */
	public void setOutputPath(String aOutputPath) {
		outputPath = aOutputPath;
	}
	
	
	/**
	 * Initiate the written process. 
	 */
	public void initWriter(){
		nlptoshare = new NlptoolsshareType();
		document = new DocumentType();
		tokens = new TokensType();
	}
	
	/**
	 * Set the text.
	 * @param text
	 */
	public void setText(String text) {
		document.setText(text);
	}
	
	/**
	 * Add token to be written.
	 * @param beginSpan
	 * @param endSpan
	 * @param form
	 * @param lemma
	 * @param category
	 */
	public void addToken(BigInteger beginSpan, BigInteger endSpan, String form, String lemma, String category) {
		TokenType token = new TokenType();
		token.setBeginspan(beginSpan);
		token.setEndspan(endSpan);
		token.setForm(form);
		token.setLemma(lemma);
		token.setCategory(category);
		tokens.getToken().add(token);
	}
	
	/**
	 * Method to write in a xml file.
	 * @throws JAXBException 
	 */
	public void write() throws JAXBException {
		document.setTokens(tokens);
		
		nlptoshare.setDocument(document);
		JAXBContext jxbcontext = (JAXBContext) JAXBContext.newInstance("es.ujaen.sinai.nlptoolsshare");
		Marshaller marshaller = jxbcontext.createMarshaller();
		marshaller.setProperty(Marshaller.JAXB_FORMATTED_OUTPUT, true);
		marshaller.setProperty("com.sun.xml.bind.namespacePrefixMapper", new XMLPrefixMapper());
		ObjectFactory factory = new ObjectFactory();
		JAXBElement<NlptoolsshareType> xml = factory.createNlptoolsshare(nlptoshare);
		marshaller.marshal(xml, new File(outputPath));
	}

	@Override
	public void addSentence(BigInteger beginSpan, BigInteger endSpan) {
		SentenceType sentence = new SentenceType();
		sentence.setBeginspan(beginSpan);
		sentence.setEndspan(endSpan);
		document.getSentence().add(sentence);
	}

}
