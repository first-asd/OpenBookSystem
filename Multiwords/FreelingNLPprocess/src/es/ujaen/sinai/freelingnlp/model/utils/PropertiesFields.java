/**
 * 
 */
package es.ujaen.sinai.freelingnlp.model.utils;

/**
 * @author Eugenio Martínez Cámara
 * @date 02/01/2014
 * Configuration properties for the application.
 *
 */
public enum PropertiesFields {
	/**
	 * Language of the imput text.
	 */
	LANG,
	
	/**
	 * Freeling home path.
	 */
	FREELINGDIR,
	
	/**
	 * Directory path of freeling share data.
	 */
	FREELINGDATA,
	
	/**
	 * Name of the configuration file for the tokenizer.
	 */
	FREELINGTOKENIZER,
	
	/**
	 * Name of the configuration file for the spitter.
	 */
	FREELINGSPLITTER,
	
	/**
	 * Name of the configuration file for the locution module.
	 */
	FREELINGLOCUTIONS,
	
	/**
	 * Name of the configuration file for the quantities module.
	 */
	FREELINGQUANTITIES,
	
	/**
	 * Name of the configuration file for the afixos module.
	 */
	FREELINGAFIXOS,
	
	/**
	 * Name of the Freeling probabilities file.
	 */
	FREELINGPROBABILITIES,
	
	/**
	 * Name of the Freeling dictionary file.
	 */
	FREELINGDICC,
	
	/**
	 * Name of the configuration Freeling for name entity module.
	 */
	FREELINGNP,
	
	/**
	 * Name of the configuration Freeling for punctuation module.
	 */
	FREELINGPUNCT,
	
	/**
	 * Name of the configuration Freeling for corrector module.
	 */
	FREELINGCORRECTOR,
	
	/**
	 * Name of the configuration Freeling for tagger module.
	 */
	FREELINGTAGGER,
	
	/**
	 * Name of freeling java api
	 */
	FREELINGJAVAAPI,
	
	/**
	 * Factory name for io operations.
	 */
	IOSHAREFACTORY,
	
	/**
	 * Path to the schema file.
	 */
	SCHEMAFILE;
	
	
	public String toString() {
		switch (this) {
		case LANG: return("LANG");
		case FREELINGDIR: return("FREELINGDIR");
		case FREELINGDATA: return("FREELINGDATA");
		case FREELINGTOKENIZER: return("FREELINGTOKENIZER");
		case FREELINGSPLITTER: return("FREELINGSPLITTER");
		case FREELINGLOCUTIONS: return("FREELINGLOCUTIONS");
		case FREELINGQUANTITIES: return("FREELINGQUANTITIES");
		case FREELINGAFIXOS: return("FREELINGAFIXOS");
		case FREELINGPROBABILITIES: return("FREELINGPROBABILITIES");
		case FREELINGDICC: return("FREELINGDICC");
		case FREELINGNP: return("FREELINGNP");
		case FREELINGPUNCT: return("FREELINGPUNCT");
		case FREELINGCORRECTOR: return("FREELINGCORRECTOR");
		case FREELINGTAGGER: return("FREELINGTAGGER");
		case FREELINGJAVAAPI: return("FREELINGJAVAAPI");
		case IOSHAREFACTORY: return("IOSHAREFACTORY");
		case SCHEMAFILE: return("SCHEMAFILE");
		default:
			return(null);
		}
	}
}
