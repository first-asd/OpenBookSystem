/* Copyright © 2013 GPLSI.
 *
 * All rights reserved.
 */
package es.ua.first.exception;

import es.ua.first.*;

/**
 * Some error parsing a Sensei XML document or crawling some web with Sensei crawler.
 * 
 * @author Jos&eacute; M. G&oacute;mez
 */
public class FirstParserException extends Exception {
    /**
     * Constructs a new exception with the specified cause and a detail message of 
     * (cause==null ? null : cause.toString()) (which typically contains the class 
     * and detail message of cause). This constructor is useful for exceptions that 
     * are little more than wrappers for other throwables.
     * @param cause  the cause (a null value is permitted, and indicates that the 
     * cause is nonexistent or unknown.)
     */
    public FirstParserException(Throwable cause) {
        super(cause);
    }

    /**
     * Constructs a new exception with the specified detail message and cause.
     * Note that the detail message associated with cause is not automatically 
     * incorporated in this exception's detail message.
     * @param message the detail message.
     * @param cause  the cause (a null value is permitted, and indicates that the 
     * cause is nonexistent or unknown.)
     */
    public FirstParserException(String message, Throwable cause) {
        super(message, cause);
    }

    /**
     * Constructs a new exception with the specified detail message.
     * @param message the detail message.
     */
    public FirstParserException(String message) {
        super(message);
    }

    /** 
     * Constructs a new exception with null as its detail message.
     */
    public FirstParserException() {
        super();
    }
}
