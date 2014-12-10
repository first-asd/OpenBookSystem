/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package es.ua.first.coreference;

/**
 * Se lanza esta excepción cuando se produce algún tipo de excepción en las
 * la resolución de la anáfora.
 * @author Isabel Moreno
 */

public class AnaphoraResolutionException extends Exception {
 
    public AnaphoraResolutionException(){
        super();
    }
    
    /** Constructor que permite cambiar el mensaje de la excepción.
     * @param msj Mensaje a visualizar cuando se lanza la excepción.
     */
    public AnaphoraResolutionException(String msj) {
        super(msj);
    }

    /** Constructor que permite cambiar el mensaje de la excepción e indicar
     * la causa de la excepción.
     * @param msj Mensaje a visualizar cuando se lanza la excepción.
     * @param cause Causa de la excepción.
     */
    public AnaphoraResolutionException(String msj, Throwable cause) {
        super(msj,cause);
    }

    /** Constructor que permite saber qué ha sido la causa de esta excepción.
     * @param cause Causa de la excepción.
     */
    public AnaphoraResolutionException(Throwable cause) {
        super(cause);
    }
}
