/**
 * 
 */
package es.ujaen.sinai.first;

import es.ujaen.sinai.first.io.ManageProperties;
import es.ujaen.sinai.first.io.UniqueFiles;
import es.ujaen.sinai.first.io.xml.nlptoolsshare.DocumentType;
import es.ujaen.sinai.first.io.xml.nlptoolsshare.NlptoolsshareType;
import es.ujaen.sinai.first.io.xml.nlptoolsshare.ObjectFactory;
import es.ujaen.sinai.first.io.xml.nlptoolsshare.SentenceType;
import es.ujaen.sinai.first.io.xml.nlptoolsshare.TokenType;
import es.ujaen.sinai.first.io.xml.nlptoolsshare.TokensType;
import es.ujaen.sinai.first.io.xml.nlptoolsshare.XMLPrefixMapper;
import es.ujaen.sinai.first.io.xml.nlptoolsshare.XMLValidation;
import gate.AnnotationSet;
import gate.Document;
import gate.Factory;
import gate.FeatureMap;
import gate.Utils;
import gate.corpora.DocumentContentImpl;
import gate.creole.ResourceInstantiationException;
import gate.util.InvalidOffsetException;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.io.InputStreamReader;
import java.util.Iterator;
import java.util.Map;

import javax.xml.XMLConstants;
import javax.xml.bind.JAXBContext;
import javax.xml.bind.JAXBElement;
import javax.xml.bind.JAXBException;
import javax.xml.bind.Marshaller;
import javax.xml.bind.Unmarshaller;
import javax.xml.validation.SchemaFactory;

import org.xml.sax.SAXException;


/**
 * es.ujaen.sinai.first
 * @author Eugenio Martínez Cámara
 * @since  10/01/2014
 * This class implements the methods to work with the nlp tool Freeling.
 *
 */
public class NLPFreeling implements INLPTOOL {
	
	/**
	 * The xml root element.
	 */
	private NlptoolsshareType xmldoc;
	
	/**
	 * Path of the temporal dir.
	 */
	private String workDirPath;
	
	/**
	 * Path of the freeling nlp tool.
	 */
	private String freelingpath;
	
	/**
	 * Path of the configuration file of the freeling nlp tool.
	 */
	private String freelingconf;
	
	private String xsdFile;

	/** (non-Javadoc)
	 * @see es.ujaen.sinai.first.INLPTOOL#init(java.util.Map)
	 */
	public void init(Map<String, Object> params) {
		xmldoc = null;
		workDirPath = (String) params.get(PropertiesFields.INTERMEDIARYFILESDIR.toString());
		freelingpath = (String) params.get(PropertiesFields.NLPTOOLFORSPANISH.toString());
		freelingconf = (String) params.get(PropertiesFields.NLPTOOLFORSPANISHCONFPATH.toString());
		xsdFile = (String) params.get(PropertiesFields.SCHEMAFILE.toString());
	}

	/**
	 * Set the content to be processed.
	 * @param Doc The doc to be processed.
	 * @see es.ujaen.sinai.first.INLPTOOL#setContent(java.lang.Object)
	 */
	public void setContent(Document doc) {
		String text = doc.getContent().toString();
		xmldoc = new NlptoolsshareType();
		DocumentType docxml = new DocumentType();
		docxml.setText(text);
		xmldoc.setDocument(docxml);
	}

	/**
	 * Return the content processed.
	 * @see es.ujaen.sinai.first.INLPTOOL#getContent()
	 */
	public Object getContent() {
		ManageProperties properties = ManageProperties.getInstance();
		Document gateDoc = null;
		try {
			gateDoc = (Document) Factory.createResource("gate.corpora.DocumentImpl", Utils.featureMap("encoding", properties.getValue(PropertiesFields.ENCODING.toString())));
			DocumentType doc = xmldoc.getDocument();
			gateDoc.setContent(new DocumentContentImpl(doc.getText()));
			AnnotationSet defaultSet = gateDoc.getAnnotations();
			TokensType tokens = doc.getTokens();
			Iterator<TokenType> iterTokens = tokens.getToken().iterator();
			while(iterTokens.hasNext()) {
				TokenType token = iterTokens.next();
				FeatureMap tokenFeatures = Factory.newFeatureMap();
				tokenFeatures.put("string", token.getForm());
				tokenFeatures.put("root", token.getLemma());
				tokenFeatures.put("category", token.getCategory());
				defaultSet.add(token.getBeginspan().longValue(), token.getEndspan().longValue(), "Token", tokenFeatures);
			}
			
			Iterator<SentenceType> iterSentences = doc.getSentence().iterator();
			while(iterSentences.hasNext()) {
				SentenceType sent = iterSentences.next();
				defaultSet.add(sent.getBeginspan().longValue(), sent.getEndspan().longValue(), "Sentence", Factory.newFeatureMap());
			}
		} catch (ResourceInstantiationException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		} catch (InvalidOffsetException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		return (gateDoc);
	}

	/* (non-Javadoc)
	 * @see es.ujaen.sinai.first.INLPTOOL#tokenize()
	 */
	@Override
	public void tokenize() {
		// TODO Auto-generated method stub

	}

	/* (non-Javadoc)
	 * @see es.ujaen.sinai.first.INLPTOOL#splitter()
	 */
	@Override
	public void splitter() {
		// TODO Auto-generated method stub

	}

	/* (non-Javadoc)
	 * @see es.ujaen.sinai.first.INLPTOOL#lemmatize()
	 */
	@Override
	public void lemmatize() {
		// TODO Auto-generated method stub

	}
	
	/**
	 * This method builds the input for the freeling nlp tool.
	 * @param inputPath The path for the input file.
	 */
	private void buildInput(String inputPath) {
		try {
			JAXBContext jxbcontext = (JAXBContext) JAXBContext.newInstance("es.ujaen.sinai.first.io.xml.nlptoolsshare");
			Marshaller marshaller = jxbcontext.createMarshaller();
			marshaller.setProperty(Marshaller.JAXB_FORMATTED_OUTPUT, true);
			marshaller.setProperty("com.sun.xml.bind.namespacePrefixMapper", new XMLPrefixMapper());
			ObjectFactory factory = new ObjectFactory();
			JAXBElement<NlptoolsshareType> xml = factory.createNlptoolsshare(xmldoc);
			marshaller.marshal(xml, new File(inputPath));
		} catch (JAXBException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
	}
	
	/**
	 * This method runs the freeling nlp tool
	 * @param inputFile Path of the input file.
	 * @param outputPath Path of the output file.
	 */
	private void exec(String inputFile, String outputPath) {
		Runtime runtime = Runtime.getRuntime();
		String[] args = {"java", "-jar",freelingpath,freelingconf, outputPath, inputFile};
		try {
			Process p = runtime.exec(args);
			p.waitFor();
			//System.out.println(p.exitValue());
		} catch (IOException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		} catch (InterruptedException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
	}
	
	private void loadProcessed(String outputFile) {
		JAXBContext jxbcontext;
		JAXBElement<NlptoolsshareType> xml = null;
		try {
			jxbcontext = (JAXBContext) JAXBContext.newInstance("es.ujaen.sinai.first.io.xml.nlptoolsshare");
			Unmarshaller unmarshal = jxbcontext.createUnmarshaller();
			SchemaFactory sf = SchemaFactory.newInstance(XMLConstants.W3C_XML_SCHEMA_NS_URI);
			unmarshal.setSchema(sf.newSchema(new File(xsdFile)));
			unmarshal.setEventHandler(new XMLValidation());
			xml = (JAXBElement<NlptoolsshareType>) unmarshal.unmarshal(new FileInputStream(outputFile));
		} catch (JAXBException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		} catch (SAXException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		} catch (FileNotFoundException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		xmldoc = xml.getValue();
	}

	public void nlpTokSplitMorphPos() {
		UniqueFiles filenamesGenerator = new UniqueFiles();
		String inputPath = filenamesGenerator.getFileidentifier("inputFreeling", "xml");
		inputPath = workDirPath + File.separator + inputPath;
		buildInput(inputPath);
		String outputPath = filenamesGenerator.getFileidentifier("outputFreeling", "xml");
		outputPath = workDirPath + File.separator + outputPath;
		exec(inputPath, outputPath);
		loadProcessed(outputPath);
	}

}
