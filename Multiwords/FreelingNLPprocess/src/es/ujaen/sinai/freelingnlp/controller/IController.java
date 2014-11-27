/**
 * 
 */
package es.ujaen.sinai.freelingnlp.controller;

/**
 * @author Eugenio Mart??nez C??mara
 * @date 03/01/2014
 * Controller interface
 *
 */
public interface IController {

	/**
	 * Initiate the controller.
	 * @param confPath
	 * @param outputfile
	 */
	public void init(String confPath, String outputfile, String aInputPath);
	
	/**
	 * Execute the application.
	 */
	public void execute();
}
