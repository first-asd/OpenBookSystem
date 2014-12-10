/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package es.ua.first.normalization;

/**
 *
 * @author lcanales
 */
public class NormalizeException extends Exception {
    
    public static final String ERROR1 = NormalizeException.ERROR1.toString() + ":File not found ",
            ERROR2 = NormalizeException.ERROR2.toString() + ": Incorrect file format. Required GATE format.",
            ERROR3 = NormalizeException.ERROR3.toString() + ": TypeWord unsupported in this Web Service - ",
            ERROR4 = NormalizeException.ERROR4.toString() + ": TypeWord unsupported for this language",
            ERROR5 = NormalizeException.ERROR5.toString() + ": Language not supported (ES, EN or BG)";

    public NormalizeException(String message) {
        super(message);
    }

    public NormalizeException(String message, Throwable cause) {
        super(message, cause);
    }

    public NormalizeException(Throwable cause) {
        super(cause);
    }
    
    public NormalizeException (String message, String word) {
        super (message + word);
    }
    
    public NormalizeException (String message, String word, Throwable cause) {
        super (message + word, cause);
    }
}
