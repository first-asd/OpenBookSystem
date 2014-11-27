/**
 * 
 */
package es.ujaen.sinai.first;

/**
 * Enum type for define the configuration fields of the service
 * @author Eugenio Martínez Cámara
 *
 */
public enum PropertiesFields {
	
	/**
	 * Path of the directory which stored the different idioms lists.
	 */
	FIGLNDIR,
	
	/**
	 * Name of the Spanish figurative language list.
	 */
	FIGLNLISTES,
	
	/**
	 * Name of the English figurative language list.
	 */
	FIGLNLISTEN,
	
	/**
	 * Name of the Bulgarian figurative language list.
	 */
	FIGLNLISTBL,
	
	/**
	 * The path of the directory where the temporal files of the services are stored.
	 */
	INTERMEDIARYFILESDIR,
	
	/**
	 * Location of the Gate Data Store.
	 */
	DSLOCATION,
	
	/**
	 * Location of the Gate Index
	 */
	INDEXLOCATION,
	
	/**
	 * Path location of the Gate Index.
	 */
	INDEXPATHLOCATION,
	
	/**
	 * Path location of the Gate Data Store.
	 */
	DSPATHLOCATION,
	
	/**
	 * Encoding of the text 
	 */
	ENCODING,
	
	/**
	 * Name of the class which load the figurative languages lists.
	 */
	FACTORYLISTLOADERCLASS,
	
	/**
	 * Path to the gate home.
	 */
	GATEHOME,
	
	/**
	 * Name of the class that implements the factory class for languages nlp tasks. In
	 * the configuration file must have three values:
	 * 	NLPTOOL_es
	 * 	NLPTOOL_en
	 * 	NLPTOOL_bl
	 */
	NLPTOOL_,
	
	/**
	 * Path to the external Spanish nlp tool.
	 */
	NLPTOOLFORSPANISH,
	
	/**
	 * Path to the configuration file of the Spanish nlp tool.
	 */
	NLPTOOLFORSPANISHCONFPATH,
	
	/**
	 * Path to the schema file.
	 */
	SCHEMAFILE;
	
	
	/**
	 * The method toString of the class is override to return an specific string.
	 */
	public String toString() {
		switch (this) {
			case FIGLNDIR: return("FIGLNDIR");
			case FIGLNLISTES: return("FIGLNLISTES");
			case FIGLNLISTEN: return("FIGLNLISTEN");
			case FIGLNLISTBL: return("FIGLNLISTBL");
			case INTERMEDIARYFILESDIR: return("INTERMEDIARYFILESDIR");
			case DSLOCATION: return("DSLOCATION");
			case INDEXLOCATION: return("INDEXLOCATION");
			case DSPATHLOCATION: return("DSPATHLOCATION");
			case INDEXPATHLOCATION: return("INDEXPATHLOCATION");
			case ENCODING: return("ENCODING");
			case FACTORYLISTLOADERCLASS: return("FACTORYLISTLOADERCLASS");
			case GATEHOME: return("GATEHOME");
			case NLPTOOL_: return("NLPTOOL_");
			case NLPTOOLFORSPANISH: return("NLPTOOLFORSPANISH");
			case NLPTOOLFORSPANISHCONFPATH: return("NLPTOOLFORSPANISHCONFPATH");
			case SCHEMAFILE: return("SCHEMAFILE");
			default: return("");
		}
	}

}
