/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package es.ua.first.dictionary;

/**
 *
 * @author imoreno
 */
public class DictionaryException extends Exception {
    
    public DictionaryException(){
        super();
    }
    
    /** Constructor que permite cambiar el mensaje de la excepción.
     * @param msj Mensaje a visualizar cuando se lanza la excepción.
     */
    public DictionaryException(String msj) {
        super(msj);
    }

    /** Constructor que permite cambiar el mensaje de la excepción e indicar
     * la causa de la excepción.
     * @param msj Mensaje a visualizar cuando se lanza la excepción.
     * @param cause Causa de la excepción.
     */
    public DictionaryException(String msj, Throwable cause) {
        super(msj,cause);
    }

    /** Constructor que permite saber qué ha sido la causa de esta excepción.
     * @param cause Causa de la excepción.
     */
    public DictionaryException(Throwable cause) {
        super(cause);
    }
    
}
