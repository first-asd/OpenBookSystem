/**
 * 
 */
package es.ujaen.sinai.first.io.xml.nlptoolsshare;

import com.sun.xml.bind.marshaller.NamespacePrefixMapper;

/**
 * es.ujaen.sinai.nlptoolsshare
 * @author Eugenio Martínez Cámara
 * @since  10/01/2014
 * Class for customize the xml prefix in the marshaller process
 *
 */
public class XMLPrefixMapper extends NamespacePrefixMapper{

	@Override
	public String getPreferredPrefix(String uri, String suggest, boolean require) {
		if("http://sinai.ujaen.es/nlptoolsshare".equals(uri) ){return "";}
		return suggest;
	}
	
	public String[] getPreDeclaredNamespaceUris()
	  {
	    return new String[0];
	  }

}
