/**
 * 
 */
package es.ujaen.sinai.freelingnlp.controller;

import java.io.FileNotFoundException;
import java.io.IOException;

import javax.xml.bind.JAXBException;

import org.xml.sax.SAXException;

import es.ujaen.sinai.freelingnlp.model.FreelingNLPprocess;
import es.ujaen.sinai.freelingnlp.model.IModel;

/**
 * @author Eugenio Mart??nez C??mara
 * @date 03/01/2014
 * Controller of the application
 *
 */
public class FreelingNLPController implements IController {
	
	/**
	 * Application model or backend.
	 */
	private IModel model;
	
	/**
	 * Input file to be processed.
	 */
	private String inputPath;
	
	
	public FreelingNLPController() {
		model = new FreelingNLPprocess();
	}

	/**
	 * Initiate the model
	 * @see es.ujaen.sinai.freelingnlp.controller.IController#init(java.lang.String, java.lang.String)
	 */
	public void init(String confPath, String outputfile, String aInputPath) {
		inputPath = aInputPath;
		
			try {
				model.init(confPath, outputfile);
			} catch (FileNotFoundException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			} catch (ClassNotFoundException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			} catch (InstantiationException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			} catch (IllegalAccessException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			} catch (IOException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
		

	}

	/**
	 * Execute the application.
	 * @see es.ujaen.sinai.freelingnlp.controller.IController#execute()
	 */
	public void execute() {
		
			try {
				model.loadText(inputPath);
			} catch (FileNotFoundException e1) {
				// TODO Auto-generated catch block
				e1.printStackTrace();
			} catch (JAXBException e1) {
				// TODO Auto-generated catch block
				e1.printStackTrace();
			} catch (SAXException e1) {
				// TODO Auto-generated catch block
				e1.printStackTrace();
			}
		
		model.processText();
		try {
			model.writeOutput();
		} catch (JAXBException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
	}

}
