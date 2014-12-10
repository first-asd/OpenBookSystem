/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package es.ua.first.acronyms;

/**
 *
 * @author lcanales
 */
public class AcronymsException extends Exception {

    public static final String ERROR1 = "ERROR 1: List of acronyms not available for ",
            ERROR2 = "ERROR 2: Language not supported (ES, EN or BG)";

    public AcronymsException(String error, Throwable cause) {
        super(error, cause);
    }

    public AcronymsException(String error, String word, Throwable cause) {
        super(error + word, cause);
    }

    public AcronymsException(Throwable cause) {
        super(cause);
    }

    public AcronymsException(String error) {
        super(error);
    }

    public AcronymsException(String error, String word) {
        super(error + word);
    }
}
