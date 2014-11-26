package client;

import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.File;
import java.io.FileReader;
import java.io.FileWriter;
import java.io.IOException;
import java.net.MalformedURLException;
import java.net.URL;
import java.util.Formatter;
import java.util.HashMap;

import joptsimple.OptionParser;
import joptsimple.OptionSet;
import joptsimple.OptionSpec;

import org.apache.cxf.endpoint.Client;
import org.apache.cxf.endpoint.ClientImpl;
import org.apache.cxf.frontend.ClientProxy;
import org.apache.cxf.transport.http.HTTPConduit;

import com.google.gson.Gson;

import eu.first_asd.service.FormatException_Exception;
import eu.first_asd.service.SyntaxOBService;
import eu.first_asd.service.SyntaxOBServiceImplService;

public class WSClient {

	public static void main(String[] args) throws IOException{
		OptionParser parser = new OptionParser( );
		OptionSpec<File>   inFile = parser.accepts("inFile").withRequiredArg().describedAs( "input file path" ).ofType( File.class );
		OptionSpec<File>   outFile= parser.accepts("outFile").withRequiredArg().describedAs( "output file path" ).ofType( File.class );
		parser.accepts( "inFormat").withRequiredArg().defaultsTo("PLAIN");
		parser.accepts( "outFormat").withRequiredArg().defaultsTo("GATEXML");
		parser.accepts( "markSigns" );	
		parser.accepts( "detectSyntax" );
		parser.accepts( "removeSyntax" );
		parser.accepts( "detectAppositions" );
		parser.accepts( "removeAppositions" );
		parser.accepts( "help" ).forHelp();
		OptionSpec<String> endpoint=parser.accepts("endpoint").withRequiredArg().describedAs("WS endpoint").defaultsTo(endpointv1);
		parser.accepts( "model").withRequiredArg().defaultsTo("meter");
		parser.accepts( "obstacles" ).withRequiredArg().defaultsTo("all");
		
		parser.accepts( "param").withRequiredArg().defaultsTo("JSON");
		parser.accepts( "keepTokenization" ).withRequiredArg().defaultsTo("false");

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

		String docContent=testText;
		if(options.has(inFile)){
			//load a document from a file
			BufferedReader in=new BufferedReader(new FileReader(inFile.value(options)));
			StringBuilder sb=new StringBuilder();
			String line=null;
			while ((line=in.readLine())!=null)
				sb.append(line).append('\n');
			in.close();
			docContent=sb.toString();
		}

		//build parameters
		StringBuffer pars=new StringBuffer();
		pars.append("syntax.language=en");
		pars.append("\nsyntax.obstacles=all");
		for(String par:new String[]{
				"inFormat","outFormat","obstacles", "model" }){
			pars.append("\nsyntax.").append(par).append('=').append(((String)options.valueOf(par)).toLowerCase());
		}
		for(String opt:new String[]{
				"markSigns","detectAppositions","detectSyntax",
				"removeAppositions","removeSyntax","keepTokenization" }){
			pars.append("\nsyntax.").append(opt);
			if (options.has(opt))
				pars.append("=y");
			else
				pars.append("=n");
		}
		//java.properties format
		String parameters=pars.toString();
		//JSON format
		if ("JSON".equalsIgnoreCase((String)options.valueOf("param"))){
			HashMap<String, String> map=new HashMap<String,String>();
			for (String p1:parameters.split("\n")){
				String[] parts=p1.split("=");
				map.put(parts[0], parts[1]);
			}
			Gson gson=new Gson();
			parameters=gson.toJson(map);
		}
		
		//run the SyntacticProcessor WS 
		//detect&annotate all obstacles
		String endpointWS=options.valueOf(endpoint);
		String retDoc=invokeRemoteServiceProcessing(docContent,endpointWS,parameters);	

		if(options.has(outFile)){
			BufferedWriter o=new BufferedWriter(new FileWriter(outFile.value(options)));
			o.write(retDoc);
			o.flush();
			o.close();
		}else{
			System.out.println(retDoc);
			System.out.flush();
		}

	}

	/**
	 * Invoke the remote service
	 * @param docAsString
	 * @param endpoint
	 * @param params
	 * @return
	 */
	protected static String invokeRemoteServiceProcessing(String docAsString, String endpoint, String params) {
		String docRet=null;
		try {
			SyntaxOBService client=buildClient(endpoint);
			docRet=client.simplifySyntax(docAsString, params);
			//log("WS invocation successful");
		} catch (FormatException_Exception e) {
			System.err.println("WebService call failed: unable to parse the format of the document\t"+e.getLocalizedMessage());
			e.printStackTrace();
		} catch (Exception e) {
			System.err.println("Service call failed:\t"+e.getLocalizedMessage());
			e.printStackTrace();
		}
		return docRet;
	}
	
	/**
	 * Connects to the remote web service; This method also sets an indefinite response waiting time
	 * 
	 * @param endpoint wsdl file URL of the remote endpoint
	 * @return the service proxy/stub
	 * @throws MalformedURLException if the endpoint URL is invalid/malformed
	 */
	public static SyntaxOBService buildClient(String endpoint) throws MalformedURLException{
		return buildClient(endpoint, true);
	}

	/**
	 * Connects to the remote web service; This method also sets an indefinite response waiting time
	 * 
	 * @param endpoint wsdl file URL of the remote endpoint
	 * @return the service proxy/stub
	 * @throws MalformedURLException if the endpoint URL is invalid/malformed
	 */
	public static SyntaxOBService buildClient(String endpoint, Boolean indefinite) throws MalformedURLException{
		if (!endpoint.endsWith("?wsdl"))
			endpoint=endpoint+"?wsdl";			

		SyntaxOBServiceImplService service=new SyntaxOBServiceImplService(new URL(endpoint));
		SyntaxOBService remoteProcessor = service.getSyntaxOBServiceImplPort();

		if (indefinite){
			//wait indefinitely -- method 1
			Client client = ClientProxy.getClient(remoteProcessor);
			((ClientImpl)client).setSynchronousTimeout(0);

			//wait indefinitely -- method 2
			HTTPConduit conduit = (HTTPConduit)client.getConduit();
			conduit.getClient().setConnectionTimeout(0);
			conduit.getClient().setReceiveTimeout(0);

			//wait indefinitely -- method 3
			java.util.Map<String, Object> requestContext =
					((javax.xml.ws.BindingProvider)remoteProcessor).getRequestContext();
			requestContext.put("javax.xml.ws.client.connectionTimeout", 0);
			requestContext.put("javax.xml.ws.client.receiveTimeout", 0);
		}
		return remoteProcessor;
	}

	/**
	 * A small sample text to be used if the user does not provide a file
	 */
	static String testText="''The evidence is so thin, it is effectively invisible,'' said Gareth Peirce, representing Eidarous.\n"+
			"The following morning she seemed better but then she worsened very rapidly.\n"+
			"The tiny cubes had gone unnoticed, hidden in batches of onions which found their way into the pancakes during production.\n"+
			"The culprit, the younger of the two, appeared to stagger and look down at his hands and they were covered in blood. \n"+
			"There was always the dread that it was going to be a hung jury and that we'd have to come back and do it all again''.";


	/**
	 * Enum for the input/output formats supported 
	 */
	static enum Format{
		PLAIN, GATEXML, XML
	}

	static String endpointv1="http://clg.wlv.ac.uk:8159/openbook-syntax-service-v1/services/SyntaxOBServiceImplPort";
}