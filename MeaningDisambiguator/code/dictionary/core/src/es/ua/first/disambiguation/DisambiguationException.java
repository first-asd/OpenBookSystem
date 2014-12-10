/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package es.ua.first.disambiguation;

/**
 *
 * @author lcanales
 */
public class DisambiguationException extends Exception {

    public static final String ERROR1 = "ERROR 1: Error in constructor JWNL (Library WordNet)",
            ERROR2 = "ERROR 2: File not found ",
            ERROR3 = "ERROR 3: Type words unsupported (use RARE, SPECIALIZED, LONGWORD or POLYSEMIC).",
            ERROR4 = "ERROR 4: Language not supported (ES, EN or BG)",
            ERROR5 = "ERROR 5: Disambiguation method not supported (MFS or UKB)",
            ERROR6 = "ERROR 6: Error accessing the library JWNL (WordNet)",
            ERROR7 = "ERROR 7: There is no word: ",
            ERROR8 = "ERROR 8: There aren't definitons for: ",
            ERROR9 = "ERROR 9: Problem parsing content of: ",
            ERROR10 = "ERROR 10: Can not find the word in WordNet: ",
            ERROR12 = "ERROR 12: Disambiguation method unsupported by the Bulgarian",
            ERROR13 = "ERROR 13: Incorrect file format. Required GATE format.",
            ERROR14 = "ERROR 14: Type words unsupported by this language",
            ERROR15 = "ERROR 15: Param returnInfo have value incorrect";

    public DisambiguationException(String error, Throwable cause) {
        super(error, cause);
    }

    public DisambiguationException(String error, String word, Throwable cause) {
        super(error + word, cause);
    }

    public DisambiguationException(Throwable cause) {
        super(cause);
    }

    public DisambiguationException(String error) {
        super(error);
    }

    public DisambiguationException(String error, String word) {
        super(error + word);
    }
}
