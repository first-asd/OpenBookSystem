package wlv.openbook.service;

import gate.Annotation;
import gate.AnnotationSet;
import gate.Factory;
import gate.FeatureMap;
import gate.creole.AbstractLanguageAnalyser;
import gate.creole.ExecutionException;
import gate.creole.metadata.CreoleParameter;
import gate.creole.metadata.CreoleResource;
import gate.creole.metadata.Optional;
import gate.creole.metadata.RunTime;
import gate.util.OffsetComparator;

import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.FileNotFoundException;
import java.io.FileReader;
import java.io.FileWriter;
import java.io.IOException;
import java.util.ArrayList;
import java.util.Collections;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Map;

/**
 * A wrapper for a CRF model for processing 
 * Stub implementation of GATE plugin wrapping CRF++ library
 */
@CreoleResource(name = "Coordinator Tagger", comment = "GATE wrapper over CRF++", helpURL = "http://clg.wlv.ac.uk")
public class CoordinatorTagger extends AbstractLanguageAnalyser {
	public static final long serialVersionUID = 1L;

	private static final Map<String, String> friendlyNames =
			new HashMap<String, String>();

	static {
		friendlyNames.put("PROTEIN", "Protein");
		friendlyNames.put("CELL_LINE", "CellLine");
		friendlyNames.put("CELL_TYPE", "CellType");
		friendlyNames.put("DNA", "DNA");
		friendlyNames.put("RNA", "RNA");
	}

	/**
	 * The annotation set from which token information will be extracted.
	 */
	private String inputASName = null;
	/**
	 * The annotation set in which new annotations will be created
	 */
	private String outputASName = null;

	
	//private Long gateDocumentIndex = null;
	//private CoordRunMode coordMode = null;
	//private ????Tagger coordTagger;

	/*  @RunTime
    @CreoleParameter(defaultValue = "BIOCREATIVE", comment = "This option allows tow different models to be used for tagging. Namely: NLPBA and BIOCREATIVE. NLPBA entity types are Gene, DNA, RNA, Cell Lines, Cell cultures. BIOCREATIVE entity type is Gene.")
    public void setcoordMode(coordRunMode a) {
       coordMode = a;
    }

    public coordRunMode getcoordMode() {
       return coordMode;
    }*/

/*	private static final Logger logger = Logger.getLogger(CoordinatorTagger.class);

	private static final char[] compartibleChars = "[,.;:?!-+]{}\"`'()"
			.toCharArray();
*/
	@RunTime
	@Optional
	@CreoleParameter(comment = "The annotation set in which new annotations will be created")
	public void setOutputASName(String a) {
		outputASName = a;
	}

	public String getOutputASName() {
		return outputASName;
	}

	@RunTime
	@Optional
	@CreoleParameter(comment = "The annotation set from which token information will be extracted")
	public void setIntputASName(String a) {
		outputASName = a;
	}

	public String getIntputASName() {
		return outputASName;
	}

	/**
	 * The name of the annotation to create, if blank (or null) the type is used as name
	 */
	private String annotationName = null;
	
	@RunTime
	@Optional
	@CreoleParameter(defaultValue = "Tagger", comment = "The name of the annotation to create, if blank (or null) the type is used as name")
	public void setAnnotationName(String annotationName) {
		this.annotationName = annotationName;
	}

	public String getAnnotationName() {
		return annotationName;
	}

	/**
	 * This is the method that executes the CRF model
	 */
	public void execute() throws ExecutionException {
		

		/*
		 gateDocumentIndex = 0L; 
		 if(coordTagger == null
            || !(coordTagger.getMode() == getcoordMode().getValue())) {
      try {
        coordTagger = new Tagger(getcoordMode().getValue());
      } catch(Exception e) {
        throw new ExecutionException("Can not instantiate coord", e);
      }
    }*/
		//TODO: prepare CRF tool

		StringBuffer sb=new StringBuffer();
		try {

			//TODO: configuration token annotations (runtime)
			//TODO: configuration feature templates (runtime)
			//for each sentence and for each token extract features (Word POS TAG)			
			AnnotationSet annIn = document.getAnnotations(inputASName);
			List<Annotation> slist=new ArrayList<Annotation>(annIn.get("Sentence"));
			Collections.sort(slist,new OffsetComparator());
			//for each sentence
			for (Annotation s:slist){
				List<Annotation> tlist= new ArrayList<Annotation>(
						annIn.getContained(s.getStartNode().getOffset(), 
								s.getEndNode().getOffset()).get("Token"));
				Collections.sort(tlist,new OffsetComparator());
				//for each token
				for (Annotation t:tlist){
					String word=(String)t.getFeatures().get("string");
					word=word.trim();
					//word
					sb.append(word);
					sb.append('\t');
					//pos
					sb.append(t.getFeatures().get("category"));
					sb.append('\t');
					//ismarker
					if (word.toLowerCase().matches("and"))
						sb.append("M:Y");
					else
						sb.append("M:N");
					sb.append('\t');
					//tag
					//TODO: make training data
					sb.append("ukn");
					sb.append('\n');
				}
				sb.append('\n');
			}
			if (sb.length()>0)
				sb.setLength(sb.length()-1);

			BufferedWriter w=new BufferedWriter(new FileWriter("temp-crf-data"));
			w.write(sb.toString());
			w.flush();
			w.close();
		} catch(Exception e) {
			e.printStackTrace();
		}

		//invoke external process: CRF++ //mallet!
		//"temp-crf-data" -> "temp-crf-pred"
		//TODO:

		//collect predictions
		try {
			BufferedReader r=new BufferedReader(new FileReader("temp-crf-pred"));
			String line=null;
			AnnotationSet annIn = document.getAnnotations(inputASName);
			AnnotationSet annOut = document.getAnnotations(outputASName);
			List<Annotation> tlist= new ArrayList<Annotation>(annIn.get("Token"));
			Collections.sort(tlist,new OffsetComparator());
			Iterator<Annotation> tokens=tlist.iterator();
			
			StringBuffer sbo=new StringBuffer();
			
			while ((line=r.readLine())!=null){
				if (line.trim().length()==0){
					//sbo.append("\n");
					sbo.setCharAt(sbo.length()-1, '\n');
					continue;
				}
				//debug: token string vs word
				String[]feats=line.split("[ \t]+");
				String predictedTag=feats[feats.length-1];
				sbo.append(feats[0]);

				Annotation t=tokens.next();
				if (feats[2].equalsIgnoreCase("M:Y")){
					FeatureMap features=Factory.newFeatureMap();
					features.put("type", predictedTag);
					//TODO: annotation confidence!
					annOut.add(t.getStartNode(),t.getEndNode(),"sync",features);
					sbo.append("|"+predictedTag);
				}
				sbo.append(' ');
			}
			
			BufferedWriter w=new BufferedWriter(new FileWriter("temp-crf-res"));
			w.write(sbo.toString());
			w.flush();
			w.close();

			
			r.close();
		} catch (FileNotFoundException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		} catch (IOException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}

	}

	/*
	private static boolean iscoordCompartible(char ch) {
		boolean bool = false;
		for(char element : compartibleChars) {
			if(element == ch) bool = true;
		}
		return bool;
	}

	private static String removeNonASCII(String document) {

		char[] charDoc = null;
		charDoc = document.toCharArray();
		char[] returnDoc = document.toCharArray();

		for(int i = 0; i < charDoc.length; i++) {
			if(iscoordCompartible(charDoc[i])) {
				returnDoc[i] = charDoc[i];
			} else if(Character.getNumericValue(charDoc[i]) > 255
					|| Character.getNumericValue(charDoc[i]) < 0) {
				returnDoc[i] = ' ';
			} else {
				returnDoc[i] = charDoc[i];
			}
		}

		StringBuffer a = new StringBuffer();

		for(char c : returnDoc) {
			a.append(c);
		}

		return a.toString();
	}

	private static boolean isASCII(char ch) {
		if(iscoordCompartible(ch)) {
			return true;
		} else if(Character.getNumericValue(ch) > 255
				|| Character.getNumericValue(ch) < 0) {
			return false;
		} else {
			return true;
		}

	}

/*	private int[] findLength(String phrase) {
		int length = 0;
		int endIndex = 0;

		long phraseSize = (long)(200 + phrase.length());
		endIndex =
				(int)((document.getContent().size() - gateDocumentIndex) < phraseSize
						? phrase.length()
								+ ((document.getContent().size() - gateDocumentIndex) - (long)phrase
										.length())
										: phrase.length() + 200);
		//

		char[] origSentence = new char[10];
		char[] parsePhrase = new char[10];

		try {
			origSentence =
					document.getContent()
					.getContent(gateDocumentIndex,
							gateDocumentIndex + endIndex).toString()
							.toCharArray();

			parsePhrase = phrase.toCharArray();

		} catch(InvalidOffsetException e) {
			logger.error("The Gate document offset are not correct: " + e + "\n");
		}
		// start to compare
		int gateIndex = 0;
		int parseIndex = 0;
		 most probably true 
		boolean isStartWhite = false;
		int start = 0;
		if(Character.isWhitespace(origSentence[0])) isStartWhite = true;

		try {
			// to see indexes
			while(parseIndex < parsePhrase.length) {
				if(origSentence[gateIndex] != parsePhrase[parseIndex]) {
					if(Character.isWhitespace(origSentence[gateIndex])) {
						length++;
						gateIndex++;
						if(isStartWhite) start++;
					} else if(!isASCII(origSentence[gateIndex])) {
						length++;
						gateIndex++;
					} else if(parsePhrase[parseIndex] == ' ') {
						parseIndex++;
						// do nothing it was parsed
					} else {
						throw new IOException("The parsed element is not interval but: "
								+ parsePhrase[parseIndex] + "\n");
					}

				} else {
					if(isStartWhite) isStartWhite = false;
					length++;
					gateIndex++;
					parseIndex++;
				}
			}

			gateDocumentIndex += gateIndex;
		} catch(IOException e) {
			logger.error("Error: " + e.toString());
		}
		int result[] = {start, length};

		return result;
	}*/
	
}