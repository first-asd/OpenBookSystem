/**
 * 
 */
package es.ujaen.sinai.nlptoolsshare;

import javax.xml.bind.ValidationEvent;
import javax.xml.bind.ValidationEventHandler;

/**
 * @author Eugenio Martínez Cámara
 * @date 03/01/2014
 * Validate xml files
 *
 */
public class XMLValidation implements ValidationEventHandler {

	@Override
	public boolean handleEvent(ValidationEvent event) {
		System.out.println("\nEVENT");
        System.out.println("SEVERITY:\t" + event.getSeverity());
        System.out.println("MESSAGE:\t" + event.getMessage());
        System.out.println("LINKED EXCEPTION:\t" + event.getLinkedException());
        System.out.println("LOCATOR");
        System.out.println("\t\tLINE NUMBER:\t" + event.getLocator().getLineNumber());
        System.out.println("\t\tCOLUMN NUMBER:\t" + event.getLocator().getColumnNumber());
        System.out.println("\t\tOFFSET:\t" + event.getLocator().getOffset());
        System.out.println("\t\tOBJECT:\t" + event.getLocator().getObject());
        System.out.println("\t\tNODE:\t" + event.getLocator().getNode());
        System.out.println("\t\tURL:\t" + event.getLocator().getURL());
		return true;
	}

}
