/**
 * 
 */
package es.ujaen.sinai.first.io;

import java.util.List;

import es.ujaen.sinai.first.MultiWordUnit;

/**
 * @author Eugenio Martínez Cámara
 *
 */
public interface IListLoader {
	
	
	public List<MultiWordUnit> load(String path);

}
