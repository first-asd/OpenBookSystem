/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package es.ua.first.multiwords;

/**
 *
 * @author lcanales
 */
public class MultiWordsException extends Exception {

    public static final String ERROR1 = "ERROR 1: There is no list of multiwords stored for ",
            ERROR2 = "ERROR 2: Language not supported (ES, EN or BG)";

    public MultiWordsException(String error, Throwable cause) {
        super(error, cause);
    }

    public MultiWordsException(String error, String word, Throwable cause) {
        super(error + word, cause);
    }

    public MultiWordsException(Throwable cause) {
        super(cause);
    }

    public MultiWordsException(String error) {
        super(error);
    }

    public MultiWordsException(String error, String word) {
        super(error + word);
    }
}
