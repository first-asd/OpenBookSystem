package es.ujaen.test;


import java.io.File;
import java.rmi.RemoteException;

import org.apache.commons.io.FileUtils;
import org.apache.log4j.Logger;

import ujaen.es.clients.AnaphoraResolutionExceptionException;
import ujaen.es.clients.FormatExceptionException;
import es.ujaen.aggregator.AggregatorWS;
import es.ujaen.aggregator.Pipeline;
import es.ujaen.clients.CoreferenceSpanishClient;
import gate.Annotation;
import gate.AnnotationSet;
import gate.Document;
import gate.Factory;
import gate.FeatureMap;
import gate.Utils;
import gate.creole.ResourceInstantiationException;

/***
 * Test the unit that renames the correference annnotation set of UA to be compatible with UW.
 * @author Eduard
 */
public class TestRenameCoreferenceAlicante {

	private static String inputDirectory ="/opt/dist/008_first/Aggregator/inputFiles/";
	private static String outputDirectory ="/opt/dist/008_first/Aggregator/inputFiles/";

	private static String parameters = "{\"languageCode\":\"es\"}";
	private static Logger logger = Logger.getLogger(TestRenameCoreferenceAlicante.class);
	private static  int connectionReadTimeout=5*60*1000 ; 
	
	private static Document readDocument (String gateDocumentString) throws ResourceInstantiationException
	{
		Document gateDocument= (Document) Factory.createResource("gate.corpora.DocumentImpl", Utils.featureMap("stringContent", gateDocumentString, "mimeType", "text/xml", "encoding", "UTF-8"));
		return gateDocument;
	}

	private static String getSpanishCoreferenceResults(String gateInputString, String languageCode) throws RemoteException, AnaphoraResolutionExceptionException
	{
		CoreferenceSpanishClient cac =new CoreferenceSpanishClient ();
		cac.setConnectionTimeout(connectionReadTimeout);
		logger.debug("Get Spanish Coreference Alicante Client Response:");

		long startTime = System.currentTimeMillis();
		String gateResponse =cac.getClientResponse(gateInputString, languageCode);
		long estimatedTime = System.currentTimeMillis() - startTime;
		logger.error("Spanish Coreference time:"+estimatedTime);

		logger.debug("Finish Spanish Coreference Alicante ");
		
		 //gateResponse=normaliseEsCoreferenceAnnotations(gateResponse);
	     logger.debug("Normalised Spanish Coreference Annotations ");

		return gateResponse;
	}
	

	private static String normaliseEsCoreferenceAnnotations(String document){
        Document doc=null;
        try {
            doc=readDocument(document);
            String providerAsName="Pronominal Anaphora markups";
            String providerAnn="PronounAnaphora";
            String targetAsName="Coreference";
            String targetAnn="CorefEntity";
            AnnotationSet asToCopy=doc.getAnnotations(providerAsName).get(providerAnn);
            AnnotationSet targetAS=doc.getAnnotations(targetAsName);

            for(Object obj:asToCopy) {
                Annotation oneAnn = (Annotation)obj;

                String text=Utils.stringFor(doc, oneAnn); 
                String chain=(String)oneAnn.getFeatures().get("chain");
                if (chain!=null){
                    FeatureMap fm=Factory.newFeatureMap();
                    fm.put("text", text);                
                    fm.put("chain", chain);
                    targetAS.add(oneAnn.getStartNode(), oneAnn.getEndNode(),targetAnn, fm);
                }
                //else: some pronouns are not resolved automatically: 
                //UI should show the obstacle was detected 
            }

            document= doc.toXml();
        } catch (ResourceInstantiationException e) {
            logger.error("Failed to normalise Spanish Coreference Annotations "+e.getLocalizedMessage());
        }finally{
            if (doc!=null)
                Factory.deleteResource(doc);
        }
            return document;
        }
        

	public static void main(String[] args) throws Exception
	{
		String inputFile=inputDirectory+"inputSpanish-1.xml";	
		
		Pipeline pl = new Pipeline ();
		pl.initGate();
		
		String gateInputString=FileUtils.readFileToString(new File(inputFile), "UTF-8");
		String correferenceString=getSpanishCoreferenceResults(gateInputString, parameters);

		String coreferenceOutputFile = outputDirectory +"outputSpanishRenameCoreference-2.xml";
		FileUtils.write(new File(coreferenceOutputFile), correferenceString, "UTF-8");
	}



}
