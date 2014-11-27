import es.ujaen.sinai.freelingnlp.controller.FreelingNLPController;
import es.ujaen.sinai.freelingnlp.controller.IController;

/**
 * 
 */

/**
 * @author Eugenio Martínez Cámara
 * @date 03/01/2014
 * Param 1 --> configuration file
 * Param 2 --> output file name
 * Param 3 --> input file path
 *
 */
public class Main {

	/**
	 * @param args
	 */
	public static void main(String[] args) {
		IController controller = new FreelingNLPController();
		controller.init(args[0], args[1], args[2]);
		controller.execute();
	}

}
