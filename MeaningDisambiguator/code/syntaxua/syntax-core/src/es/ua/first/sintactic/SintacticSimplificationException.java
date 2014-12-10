package es.ua.first.sintactic;

/**
 * Se lanza esta excepción cuando se produce algún tipo de excepción en 
 * la simplificación sintáctica.
 * @author Isabel Moreno
 */
public class SintacticSimplificationException extends Exception {

    public SintacticSimplificationException(){
        super();
    }
    
    /** Constructor que permite cambiar el mensaje de la excepción.
     * @param msj Mensaje a visualizar cuando se lanza la excepción.
     */
    public SintacticSimplificationException(String msj) {
        super(msj);
    }

    /** Constructor que permite cambiar el mensaje de la excepción e indicar
     * la causa de la excepción.
     * @param msj Mensaje a visualizar cuando se lanza la excepción.
     * @param cause Causa de la excepción.
     */
    public SintacticSimplificationException(String msj, Throwable cause) {
        super(msj,cause);
    }

    /** Constructor que permite saber qué ha sido la causa de esta excepción.
     * @param cause Causa de la excepción.
     */
    public SintacticSimplificationException(Throwable cause) {
        super(cause);
    }
    
}
