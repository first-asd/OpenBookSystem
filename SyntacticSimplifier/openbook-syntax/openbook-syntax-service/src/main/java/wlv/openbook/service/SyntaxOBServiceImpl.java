package wlv.openbook.service;

import java.io.File;
import java.io.IOException;
import java.io.StringReader;
import java.util.ArrayList;
import java.util.Collections;
import java.util.HashMap;
import java.util.Map;

import javax.annotation.Resource;
import javax.jws.WebParam;
import javax.jws.WebService;
import javax.servlet.ServletContext;
import javax.xml.stream.FactoryConfigurationError;
import javax.xml.stream.XMLInputFactory;
import javax.xml.stream.XMLStreamException;
import javax.xml.stream.XMLStreamReader;
import javax.xml.ws.WebServiceContext;
import javax.xml.ws.handler.MessageContext;

import com.google.gson.Gson;
import com.google.gson.JsonSyntaxException;

import eu.first_asd.service.FormatException_Exception;
import eu.first_asd.service.SyntaxOBService;
import gate.Annotation;
import gate.AnnotationSet;
import gate.Document;
import gate.DocumentContent;
import gate.Factory;
import gate.FeatureMap;
import gate.Gate;
import gate.corpora.DocumentContentImpl;
import gate.corpora.DocumentImpl;
import gate.corpora.DocumentStaxUtils;
import gate.creole.ResourceInstantiationException;
import gate.util.GateException;
import gate.util.InvalidOffsetException;
import gate.util.OffsetComparator;

/**
 * Web service which wraps a gate application for tackling 
 * structural (syntactical) obstacles
 * @author idornescu
 */
@WebService(targetNamespace = "http://first-asd.eu/service/", name = "SyntaxOBService")
public class SyntaxOBServiceImpl implements SyntaxOBService {

	@Resource 
	private WebServiceContext wsc;

	//TODO: make this smarter (configuration app/page/context param/etc)

	
	/**
	 * The underlying obstacle processor
	 */
	ObstacleProcessor processor;
	
	@Override
	public String simplifySyntax(
			@WebParam(name = "gateDocument", targetNamespace = "")
			String gateDocument, 
			@WebParam(name = "params", targetNamespace = "")
			String params)
					throws FormatException_Exception {
		Document doc=null;
		Document docRet=null;
		Map<String,String> parameters=getParameters(params);
		try {
			gateInit(wsc);
			//read and convert input document
			doc=readInputDocument(gateDocument,parameters);
			docRet=doc;
			
			if (!"y".equals(parameters.get("syntacticSimplification"))){
				docRet.getAnnotations("syntax");
				docRet.getFeatures().put("syntax", "processing disabled");
				System.out.println(parameters);
				return prepareOutputDocument(docRet,parameters); 
			}
			String language="en";
			if (parameters.get("syntax.language")!=null){
				language=parameters.get("syntax.language");
			}
			if ("taggedsigns".equals(parameters.get("syntax.outFormat"))){
				//parameters.put("syntax.processAppositions","false");
				//parameters.put("syntax.processSyntax","false");
				//switch off processing
				parameters.put("syntax.diagnose", "n");		 
				parameters.put("syntax.appositions", "ignore");  
				parameters.put("syntax.structure", "ignore");
				docRet=getProcessor(language).process(docRet,parameters);
				gateDocument= prepareOutputDocument(docRet,parameters);
				System.out.println(parameters);
				return gateDocument;
			}
			
			//Tackle one operation at a time
			String obstacles=parameters.get("syntax.obstacles");
			String[] operations=obstacles.split(",");
			for (String operation:operations){
				for (String obstacle:operation.split("/")){
					//docRet=getProcessor().process(docRet,parameters);
					docRet=processObstacle(obstacle,docRet,parameters);
				}
			}
			
			//return output document
			gateDocument= prepareOutputDocument(docRet,parameters);
			System.out.println(parameters);
		} catch (XMLStreamException e) {
			e.printStackTrace();
			throw new FormatException_Exception(
					"Invalid document format! "+e.getMessage());
		} catch (ResourceInstantiationException e) {
			e.printStackTrace();
			throw new FormatException_Exception(
					"Could not build the GATE Document "+e.getMessage());
		} catch (FactoryConfigurationError e) {
			e.printStackTrace();
			throw new FormatException_Exception(
					"Bad GATE configuration "+e.getMessage());
		} catch (GateException e) {
			e.printStackTrace();
			throw new FormatException_Exception(
					"Bad GATE configuration "+e.getMessage());
		} catch (IOException e) {
			e.printStackTrace();
			throw new FormatException_Exception(
					"Bad GATE configuration "+e.getMessage());
		} finally{
			// Release the document, as it is no longer needed
			if (docRet!=null) Factory.deleteResource(docRet);
			if (doc!=null) Factory.deleteResource(doc);
		}
		return gateDocument;
	}

	/**
	 * Process one obstacle at a time
	 * TODO: when removing obstacles and editing the document text,
	 * the new content needs to be re-analysed
	 * @param obstacle
	 * @param doc
	 * @param parameters
	 * @return 
	 */
	protected Document processObstacle(String obstacle, Document doc,
			Map<String, String> parameters) {
		parameters=getParameters(parameters);
		AnnotationSet syntaxAS=doc.getAnnotations("syntax");
		if ("appositions".equals(obstacle)){
			parameters.put("syntax.structure", "ignore");
			parameters.put("syntax.diagnose", "n");
			syntaxAS.removeAll(syntaxAS.get("Apposition"));
		}else if ("syntax".equals(obstacle)){
			parameters.put("syntax.appositions", "ignore");
			parameters.put("syntax.diagnose", "n");
			syntaxAS.removeAll(syntaxAS.get("AltSentences"));
		}else if ("signs".equals(obstacle)){
			parameters.put("syntax.structure", "ignore");
			parameters.put("syntax.appositions", "ignore");
			parameters.put("syntax.diagnose", "n");
			syntaxAS.removeAll(syntaxAS.get("sync"));
		}
		//delete existing annotated signs (avoid multiple/duplicate annotations)
		syntaxAS.removeAll(syntaxAS.get("sync"));
		//process the document
		String language=parameters.get("syntax.language");
		doc=getProcessor(language).process(doc,parameters);
		
		syntaxAS=doc.getAnnotations("syntax");
		//markup of detected signs
		if ("signs".equals(obstacle) || "all".equals(obstacle)){
			if (!"y".equals(parameters.get("syntax.markSigns"))){
				//remove 'sync' annotations if not requested
				syntaxAS.removeAll(syntaxAS.get("sync"));
			}else{
				//TODO: should we provide the confidence scores produced by CRF model
				for (Annotation a:doc.getAnnotations("syntax").get("sync")){
					a.getFeatures().remove("complexity");
					a.getFeatures().remove("confidence");
					a.getFeatures().remove("pos");
				}
			}
		}
		//Remove text marked as apposition
		if ("appositions".equals(obstacle) || "all".equals(obstacle)){
			if ("remove".equals(parameters.get("syntax.appositions" ))){
				//delete content within annotation
				for (Annotation a: doc.getAnnotations("syntax").get("Apposition")){
					try {
						doc.edit(a.getStartNode().getOffset(), 
								a.getEndNode().getOffset(), 
								new DocumentContentImpl(""));
					} catch (InvalidOffsetException e) {
						//TODO: better error logging
						//"Could not edit the text document "+e.getMessage());
						e.printStackTrace();
					}
				}
			}
			else if ("ignore".equals(parameters.get("syntax.appositions" ))){
				//remove 'Apposition' annotation if not requested
				syntaxAS.removeAll(syntaxAS.get("Apposition"));
			}
		}
		//Replace complex sentences with simpler alternatives when available
		if ("syntax".equals(obstacle) || "all".equals(obstacle)){
			if ("remove".equals(parameters.get("syntax.structure" ))){
				AnnotationSet altSents=doc.getAnnotations("syntax").get("AltSentences");
				for (Annotation alt:altSents){
					Long start=alt.getStartNode().getOffset();
					Long end=alt.getEndNode().getOffset();
					try {
						String oldContent=doc.getContent().getContent(start, end).toString();
						String content=alt.getFeatures().get("alternative").toString();
						doc.edit(start, end, new DocumentContentImpl(content));
						FeatureMap feats=Factory.newFeatureMap();
						feats.put("origtext", oldContent);
						feats.put("alternative", content);
						doc.getAnnotations("syntax").add(start,start+content.length(),"OrigSentences",feats);
					} catch (InvalidOffsetException e) {
						//TODO: better error logging
						//"Could not edit the text document "+e.getMessage());
						e.printStackTrace();
					}
				}
			}
			else if ("ignore".equals(parameters.get("syntax.structure" ))){
				//remove 'AltSentences' annotations if not requested
				syntaxAS.removeAll(syntaxAS.get("AltSentences"));
				syntaxAS.removeAll(syntaxAS.get("OrigSentences"));
			}else{
				for (Annotation a:syntaxAS.get("AltSentences")){
					a.getFeatures().remove("complexity");
					a.getFeatures().remove("confidence");
				}
			}
		}
		//Remove ANNIE annotations
		//doc.removeAnnotationSet("");
		return doc;
	}

	/**
	 * Encode the resulting document into the requested format
	 * TODO: refactor - this method was repeatedly patched due to evolving requirements
	 * needs a complete re-think based on the final specification
	 * @param doc the processed document (in which obstacles have been annotated or removed) 
	 * @param parameters 
	 * @return
	 */
	private String prepareOutputDocument(Document doc, Map<String, String> parameters) {	
		String outContent=null;
		if (doc==null)
			return outContent;
		String fout=parameters.get("syntax.outFormat");
		
		if (fout.equals("taggedsigns")){
			try {
				outContent=getTaggedSigns(doc);
			} catch (InvalidOffsetException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
				outContent="Processing error: 34";
			}
			return outContent;
		}
		
		if (!"true".equalsIgnoreCase(parameters.get("syntax.keepTokenization")))
			doc.removeAnnotationSet("ENtokens");
		if (!"y".equalsIgnoreCase(parameters.get("syntax.diagnose")))
			doc.removeAnnotationSet("SentenceDetection");
		
		if (fout.equals("plain"))
			outContent=doc.getContent().toString();
		if (fout.equals("gatexml"))
			outContent=doc.toXml();
		if (fout.equals("xml")){
			outContent=doc.toXml(doc.getAnnotations("syntax"), true)
					.replaceAll(" ?gate:gateId=\"[^\"]+\" ?", " ")
					.replaceAll(" gate:annotMaxId=\"[0-9]+\"", "");
			if(!outContent.startsWith("<?xml "))
				outContent="<?xml  version=\"1.0\" encoding=\"UTF-8\"?><root>\n"+
						outContent+	"\n</root>";
		}
		
		return outContent;
	}

	/**
	 * Parse the input data and create a GATE Document
	 * @param gateDocument
	 * @param parameters
	 * @return
	 * @throws XMLStreamException
	 * @throws FactoryConfigurationError
	 * @throws ResourceInstantiationException
	 */
	protected Document readInputDocument(String gateDocument,
			Map<String, String> parameters) throws XMLStreamException, FactoryConfigurationError, ResourceInstantiationException {
		//TODO: log System.out.println(gateDocument);
		String inFormat=parameters.get("syntax.inFormat");
		if (inFormat==null)
			inFormat=defaultParameters().get("syntax.inFormat");
		Document doc=null;
		if (inFormat.equals("gatexml")){
			XMLStreamReader xsr=XMLInputFactory.newFactory()
					.createXMLStreamReader(new StringReader(gateDocument));
			xsr.nextTag();
			doc=new DocumentImpl();
			DocumentStaxUtils.readGateXmlDocument(xsr, doc);
		}else if (inFormat.equals("xml")){
			//should auto detect if generic xml or gatexml
			
			//doc=new DocumentImpl(gateDocument);
			
			
			doc=Factory.newDocument(gateDocument);
			//doc.init();
		} else if (inFormat.equals("plain")){
			doc=Factory.newDocument(gateDocument);
			////doc.setName(DateFormat .format(new Date()));
		}
		return doc;
	}

	/**
	 * Output sign classification in the original annotation format
	 * {text...text [sign] text...text} 1 tag
	 * @param doc a Gate document with annotations
	 * @return a string with the classified signs in the required format
	 * @throws InvalidOffsetException
	 */
	protected static String getTaggedSigns(Document doc) throws InvalidOffsetException {
		StringBuilder sb=new StringBuilder();
		//todo: make these a config/param
		String signAnn="sync";
		String inputAnnieAS="ENtokens";
		String outASname="syntax";
		String sentenceAnn="Sentence";

		AnnotationSet set1= doc.getAnnotations(inputAnnieAS);
		set1=set1.get(sentenceAnn);
		ArrayList<Annotation> sentList=new ArrayList<Annotation>();
		sentList.addAll(set1);
		Collections.sort(sentList, new OffsetComparator());
		AnnotationSet outputAS=doc.getAnnotations(outASname);
		DocumentContent content=doc.getContent();
		
		for (Annotation s:sentList){
			//println doc.stringFor(s)
			String mysentence="";
			Long sstart=s.getStartNode().getOffset();
			Long send=s.getEndNode().getOffset();
			ArrayList<Annotation> nodesList=new ArrayList<Annotation>();
			AnnotationSet set2=outputAS.getContained(sstart,send);
			nodesList.addAll(set2);
			Collections.sort(nodesList, new OffsetComparator());
			

			Long nstart=null,nend=null;
			for (Annotation n: nodesList){
				if (n.getType().equals(signAnn)){
					nstart=n.getStartNode().getOffset();
					nend=n.getEndNode().getOffset();
					mysentence="{"+content.getContent(sstart, nstart).toString();
					mysentence+="["+content.getContent(nstart, nend).toString()+"]";
					mysentence+=content.getContent(nend, send).toString()+"} 1 "+n.getFeatures().get("type");
					mysentence=mysentence.replaceAll("\\r\\n|\\r|\\n", " ");
					mysentence=mysentence.replaceAll("\n+", " ");
					mysentence=mysentence.replaceAll("\r+", " ");
					sb.append(mysentence).append('\n');
					
					//text="{${content.getContent(s.start(),n.start())}[${doc.stringFor(n)}]${content.getContent(n.end(),s.end())}} 1 ${n.features.type}"
					//println text
				} 
			}
		}
		if (sb.length()>0)
			sb.setLength(sb.length()-1);
		return sb.toString();
	}
	
	/**
	 * The underlying processor which analyses the Document
	 * and creates annotations for the detected obstacles with suggestions
	 * for their removal
	 * @param language 
	 * @return
	 */
	protected ObstacleProcessor getProcessor(String language){
		
		if (!GateInitialiser.isGateInitialised()){
			try {
				gateInit(wsc);
			} catch (GateException e) {
				e.printStackTrace();
			} catch (IOException e) {
				e.printStackTrace();
			}
		}
		
		if (processor!=null)
			return processor;

		processor=new SyntacticProcessor(language);
		return processor;
	}

	/**
	 * Initialise Gate to be used in embedded mode
	 * @param wsc the WebServiceContext provided by the Servlet container 
	 * @throws GateException Gate could not be initialised
	 * @throws IOException Gate configuration files not accessible
	 */
	static void gateInit(WebServiceContext wsc) throws GateException, IOException{
		if (!GateInitialiser.isGateInitialised()){
			GateInitialiser.gateInit(wsc);
		}
	}

	/**
	 * Parse the service invocation parameters 
	 * @param encodedParams a sting encoding all parameters and their values
	 * @return a map of parameter (name, value) pairs
	 */
	public static Map<String,String> getParameters(String encodedParams){
		Map<String,String> map=defaultParameters();
		//parse and set parameter values
		
		try {
			Gson gson = new Gson();
			Map<String,String> mapIn=gson.fromJson(encodedParams, map.getClass());
			if (mapIn!=null){
				for (String key:map.keySet()){
					if (!mapIn.containsKey(key)){
						mapIn.put(key, map.get(key));
					}
				}
				return mapIn;
			}
		} catch (JsonSyntaxException e) {
			//e.printStackTrace();
		}
		
		String[]params=encodedParams.split("[#\n]+");
		for (String p:params){
			String[] pv=p.split("=",2);
			if (pv.length==2)
				map.put(pv[0],pv[1].toLowerCase().trim());
			//else log
		}
		//TODO: log System.out.println(map);
		return map;
	}

	/**
	 * Copy a set of parameters (first initialise the default values)
	 * @param params parameter to be copied
	 * @return a new set of parameters in which default values 
	 * 			are overwritten by the input values
	 */
	public static Map<String,String> getParameters(Map<String,String> params){
		Map<String,String> map=defaultParameters();
		for (String key:params.keySet())
			map.put(key, params.get(key));
		return map;
	}
	
	/**
	 * Initialise the default parameters
	 * @return
	 */
	public static Map<String,String> defaultParameters(){
		HashMap<String,String> map=new HashMap<String,String>();
		//set default parameter values
		
		map.put("syntacticSimplification","y");  //y n
		map.put("syntax.appositions", "detect"); //ignore detect replace 
		map.put("syntax.structure", "detect");   //ignore detect replace
		map.put("syntax.diagnose", "y");		 //y n
		map.put("syntax.complexity", "low");	 //low medium high 
		
		map.put("syntax.inFormat","gatexml");	//gatexml	plaintext ?xml?
		map.put("syntax.outFormat","gatexml");	//gatexml xml plaintext taggedsigns

		map.put("syntax.obstacles", "all");	//pipeline?
		
		map.put("syntax.language", "en");
		map.put("syntax.keeptokens", "n");	//tokenisation annotation set?
		map.put("syntax.markSigns", "n");	//label signs of syntactic complexity
		
		//ouputAnnotationSetName="syntax"
		
		//TODO: override these values from a configuration file
		return map;
	}
}
