package wlv.openbook.service;

import eu.first_asd.service.FormatException_Exception;
import gate.Annotation;
import gate.AnnotationSet;
import gate.Document;
import gate.Factory;
import gate.FeatureMap;
import gate.corpora.DocumentContentImpl;
import gate.creole.ResourceInstantiationException;
import gate.util.GateException;

import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.File;
import java.io.FileReader;
import java.io.FileWriter;
import java.io.IOException;
import java.util.Formatter;
import java.util.HashMap;

import joptsimple.OptionException;
import joptsimple.OptionParser;
import joptsimple.OptionSet;
import joptsimple.OptionSpec;

/**
 * A launcher class to run the Syntax Processor 
 * locally as a stand-alone application
 * 
 * @author idornescu
 */
public class SimpleSyntaxApp {
	
	/**
	 * Initialise Gate to be used in embedded mode 
	 * @throws GateException Gate could not be initialised
	 * @throws IOException Gate configuration files not accessible
	 */
	static void gateInit() throws GateException, IOException{
		if(!GateInitialiser.isGateInitialised()){
			GateInitialiser.gateInit("src/main/resources/gate");
		}
	}

	/**
	 * Main entry of the application
	 * Parses the arguments and executes the required processing
	 * @param args
	 */
	public static void main(String[] args) {
		try {
			gateInit();
			
			//test
			sampleTest();
		} catch (GateException | IOException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}		
	}

	/**
	 * Main entry of the application
	 * Parses the arguments and executes the required processing
	 * @param args
	 */
	public static void mainOld(String[] args) {
		OptionParser parser = new OptionParser( );
		OptionSpec<File>   inFile = 	 parser.accepts("inFile").withRequiredArg().describedAs( "input file path" ).ofType( File.class );
		OptionSpec<String> inFormat= parser.accepts("inFormat").withRequiredArg().defaultsTo("PLAIN");
		OptionSpec<File>   outFile= 	 parser.accepts("outFile").withRequiredArg().describedAs( "output file path" ).ofType( File.class );
		OptionSpec<String> outFormat=parser.accepts("outFormat").withRequiredArg().defaultsTo("GATEXML");
		parser.accepts( "help" ).forHelp();
		parser.accepts( "markSigns" );	
		parser.accepts( "detectSyntax" );
		parser.accepts( "removeSyntax" );
		parser.accepts( "detectAppositions" );
		parser.accepts( "removeAppositions" );
		parser.accepts( "keepTokenization" ).withRequiredArg().defaultsTo("false");
		
		//mode: apposition, syntax | detect vs remove
		//.requiredIf( "ftp" )

		try {	
			OptionSet options =parser.parse(args);

			if (options.has("help")){
				StringBuilder sb=new StringBuilder();
				Formatter formatter=new Formatter(sb);
				for (Format f:Format.values())
					formatter.format(" %s ", f);
				formatter.close();
				String formats="Possible formats are: "+sb.toString();
				parser.printHelpOn(System.out);
				System.out.println(formats);
				System.exit(0);
			}

			gateInit();
			
			//get inFile content
			Document doc=null;
			String fin= inFormat.value(options);
			if(options.has(inFile)){
				//load a document from a file
				if (fin.equals("PLAIN")){
					BufferedReader in=new BufferedReader(new FileReader(inFile.value(options)));
					StringBuilder sb=new StringBuilder();
					String line=null;
					while ((line=in.readLine())!=null)
						sb.append(line).append('\n');
					in.close();

					doc=Factory.newDocument(sb.toString());
					doc.setName(inFile.value(options).getName());
				} 
				else if (fin.equals("GATEXML")){
					doc=Factory.newDocument(inFile.value(options).toURI().toURL());
					doc.setName(inFile.value(options).getName());
				}
				else if (fin.equals("XML")){
					doc=Factory.newDocument(inFile.value(options).toURI().toURL());
					doc.setName(inFile.value(options).getName());
				}
				if (doc==null){
					System.out.println("Problem with input file");
					System.exit(1);
				}	
			}
			if (!options.has(inFile) || doc==null){
				//ignore input format
				doc=Factory.newDocument(testText);
				doc.setName("testText");
				//System.out.println(doc.toString());
			}

			//run the SyntacticProcessor (via Gate)
			ObstacleProcessor processor=getSyntaxProcessor();
			//TODO add parameters for invocation mode
			HashMap<String,String> params=new HashMap<String, String>();
			params.put("syntax.diagnosis", "y");
			doc=processor.process(doc);			 

			//markup of detected signs
			if (!options.has("markSigns")){
				//remove 'sync' annotations if not requested
				doc.getAnnotations("syntax").removeAll(
						doc.getAnnotations("syntax").get("sync"));
			}else{
				for (Annotation a:doc.getAnnotations("syntax").get("sync")){
					a.getFeatures().remove("complexity");
					a.getFeatures().remove("confidence");
					a.getFeatures().remove("pos");
				}
			}
			//Remove text marked as apposition
			if (options.has( "removeAppositions" )){
				//delete content within annotation
				for (Annotation a: doc.getAnnotations("syntax").get("Apposition")){
					doc.edit(a.getStartNode().getOffset(), 
							a.getEndNode().getOffset(), 
							new DocumentContentImpl(""));
				}
			}
			else if (!options.has( "detectAppositions" )){
				//remove 'Apposition' annotation
				doc.getAnnotations("syntax").removeAll(
						doc.getAnnotations("syntax").get("Apposition"));
			}
			
			//Replace complex sentences with simpler alternatives when available
			if (options.has( "removeSyntax" )){
				AnnotationSet altSents=doc.getAnnotations("syntax").get("AltSentences");
				for (Annotation alt:altSents){
					Long start=alt.getStartNode().getOffset();
					Long end=alt.getEndNode().getOffset();
					String oldContent=doc.getContent().getContent(start, end).toString();
					String content=alt.getFeatures().get("alternative").toString();
					doc.edit(start, end, new DocumentContentImpl(content));
					FeatureMap feats=Factory.newFeatureMap();
					feats.put("text", oldContent);
					doc.getAnnotations("syntax").add(start,start+content.length(),"OrigSentences",feats);
				}
			}
			if (!options.has( "detectSyntax" )){
				//remove 'AltSentences' annotations if not requested
				doc.getAnnotations("syntax").removeAll(
						doc.getAnnotations("syntax").get("AltSentences"));
				doc.getAnnotations("syntax").removeAll(
						doc.getAnnotations("syntax").get("OrigSentences"));
			}else{
				for (Annotation a:doc.getAnnotations("syntax").get("AltSentences")){
					a.getFeatures().remove("complexity");
					a.getFeatures().remove("confidence");
				}
			}
			
			String outContent=null;
			String fout=outFormat.value(options);
			if (fout.equals("PLAIN"))
				outContent=doc.getContent().toString();
			if (fout.equals("GATEXML"))
				outContent=doc.toXml();
			if (fout.equals("XML")){
				outContent=doc.toXml(doc.getAnnotations("syntax"), true)
						.replaceAll(" ?gate:gateId=\"[^\"]+\" ?", " ")
						.replaceAll(" gate:annotMaxId=\"[0-9]+\"", "");
				if(!outContent.startsWith("<?xml "))
					outContent="<?xml  version=\"1.0\" encoding=\"UTF-8\"?><root>\n"+
							outContent+	"\n</root>";
			}
			if(options.has(outFile)){
				BufferedWriter o=new BufferedWriter(new FileWriter(outFile.value(options)));
				o.write(outContent);
				o.flush();
				o.close();
			}else{
				System.out.println(outContent);
			}
			
			sampleTest();
		} catch (OptionException e){
			System.err.println(e.getLocalizedMessage());
			try {
				parser.printHelpOn(System.out);
			} catch (IOException e1) {
				e1.printStackTrace();
			}
		} catch (GateException e) {
			e.printStackTrace();
		} catch (IOException e) {
			e.printStackTrace();
		}
	}

	/**
	 * Initialise a SyntacticProcessor
	 * @return
	 * @throws GateException Gate could not be initialised
	 * @throws IOException Gate configuration files not accessible
	 */
	private static ObstacleProcessor getSyntaxProcessor() throws GateException, IOException {
		gateInit();
		return new SyntacticProcessor();
	}

	/**
	 * Enum for the input/output formats supported 
	 */
	static enum Format{
		PLAIN, GATEXML, XML
	}

	/**
	 * A small sample text to be used if the user does not provide a file
	 */
	static String testText="''The evidence is so thin, it is effectively invisible,'' said Gareth Peirce, representing Eidarous.\n"+
			"The following morning she seemed better but then she worsened very rapidly.\n"+
			"The tiny cubes had gone unnoticed, hidden in batches of onions which found their way into the pancakes during production.\n"+
			"John Doe, the younger of the two, appeared to stagger and look down at his hands and they were covered in blood. \n"+
			"There was always the dread that it was going to be a hung jury and that we'd have to come back and do it all again''.";

	/**
	 * Run the SyntacticProcessor on a small sample text
	 */
	public static void sampleTest(){
		try {
			
			Document doc=Factory.newDocument("It is freezing inside and it is raining outside. President Koroma said the move had been a success but had exposed \"areas of greater challenges\", which was why other areas were being quarantined. Bruno even dared to say that space was endless and contained many other suns, each with its own planets. "); //"The move follows a three-day nationwide lockdown that ended on Sunday night.");//"During Sierra Leone's three-day curfew, more than a million households were surveyed and 130 new cases discovered, the authorities say.");
			doc.setName("testText");
			HashMap<String,String> params=new HashMap<String, String>();
			//params.put("syntax.diagnosis", "y");
			params.put("languageCode", "en");
			params.put("sentenceLevel", "y");
			//"{\"languageCode\":\"en\",\"sentenceLevel\":\"y\"}"
			
			//SyntacticProcessor processor=new SyntacticProcessor();//new File("target/gate/SimpleSyntax.gapp"));
			//processor.process(doc, params);
			
			SyntaxOBServiceImpl soben=new SyntaxOBServiceImpl();
			//soben.gateInited=true;
			try {
				String document=doc.toXml();
				String result=soben.simplifySyntax( document, "{\"syntax.outFormat\"=\"gatexml\", \"languageCode\":\"en\", \"syntax.appositions\":\"detect\", \"syntax.diagnose\":\"n\"}");
				System.out.println(result);
			} catch (FormatException_Exception e) {
				// TODO Auto-generated catch block
				//e.printStackTrace();
			}
			//System.out.println(doc.toString());
		} catch (ResourceInstantiationException e) {
			e.printStackTrace();
		}
	}

}
