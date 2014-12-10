/* Copyright © 2013 GPLSI.
 *
 * All rights reserved.
 */
package es.ua.first.exception;

/**
 * Throw this exception when a referenced parameter doesn't exist.
 * @author Paco Agull&oacute;
 */
public class BadParamException extends FirstParserException {

    /** 
     * Constructs a new exception with null as its detail message.
     */
    public BadParamException() {
        super();
    }
    
    /**
     * Constructs a new exception with the specified detail message.
     * @param message the detail message.
     */
    public BadParamException(String message) {
        super(message);
    }
    
    /**
     * Constructs a new exception with the specified detail message and cause.
     * Note that the detail message associated with cause is not automatically 
     * incorporated in this exception's detail message.
     * @param message the detail message.
     * @param cause  the cause (a null value is permitted, and indicates that the 
     * cause is nonexistent or unknown.)
     */
    public BadParamException(String message, Throwable cause) {
        super(message, cause); 
    }
    
    /**
     * Constructs a new exception with the specified cause and a detail message of 
     * (cause==null ? null : cause.toString()) (which typically contains the class 
     * and detail message of cause). This constructor is useful for exceptions that 
     * are little more than wrappers for other throwables.
     * @param cause  the cause (a null value is permitted, and indicates that the 
     * cause is nonexistent or unknown.)
     */
    public BadParamException(Throwable cause) {
        super(cause);
    }
}
