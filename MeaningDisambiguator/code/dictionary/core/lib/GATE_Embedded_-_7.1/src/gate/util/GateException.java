/*
 *  GateException.java
 *
 *  Copyright (c) 1995-2012, The University of Sheffield. See the file
 *  COPYRIGHT.txt in the software or at http://gate.ac.uk/gate/COPYRIGHT.txt
 *
 *  This file is part of GATE (see http://gate.ac.uk/), and is free
 *  software, licenced under the GNU Library General Public License,
 *  Version 2, June 1991 (in the distribution as file licence.html,
 *  and also available at http://gate.ac.uk/gate/licence.html).
 *
 *  Hamish Cunningham, 19/01/2000
 *
 *  $Id: GateException.java 15333 2012-02-07 13:18:33Z ian_roberts $
 */

package gate.util;

/** A superclass for exceptions in the GATE packages. Can be used
  * to catch any internal exception thrown by the GATE libraries.
  * (Of course
  * other types of exception may be thrown, but these will be from other
  * sources such as the Java core API.)
  */
public class GateException extends Exception {

  public GateException() {
    super();
  }

  public GateException(String s) {
    super(s);
  }

  public GateException(Throwable e) {
    super(e);
  }

  public GateException(String message, Throwable e) {
    super(message, e);
  }
  
} // GateException
