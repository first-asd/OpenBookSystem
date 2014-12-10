/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package es.ua.first.coreference;

import java.io.File;
import org.w3c.dom.Document;
import org.w3c.dom.Element;

/**
 *
 * @author imoreno
 */
public interface AnaphoraResolutionInterface {
    
    public String resolveAnaphora(String text) throws AnaphoraResolutionException;
    
    public String resolveAnaphora(String text, File outputFreeling, int nextID, Element as, Document doc) throws AnaphoraResolutionException;
}
