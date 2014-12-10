/*
 *  Relation.java
 *
 *  Copyright (c) 1995-2012, The University of Sheffield. See the file
 *  COPYRIGHT.txt in the software or at http://gate.ac.uk/gate/COPYRIGHT.txt
 *
 *  This file is part of GATE (see http://gate.ac.uk/), and is free
 *  software, licenced under the GNU Library General Public License,
 *  Version 2, June 1991 (in the distribution as file licence.html,
 *  and also available at http://gate.ac.uk/gate/licence.html).
 *
 *  Valentin Tablan, 27 Feb 2012
 *
 *  $Id: Relation.java 15485 2012-02-28 11:08:09Z valyt $
 */
package gate.relations;

import java.io.Serializable;

/**
 * Interface representing a relation between GATE annotations.
 */
public interface Relation extends Serializable {
  
  /**
   * Get the type of the relation (e.g. {@link #COREF}).
   * @return the relation type. 
   */
  public String getType();
  
  /**
   * Gets the members of the relation. 
   * @return an array containing annotation IDs.
   */
  public int[] getMembers();
  
  /**
   * Some relations may have associated arbitrary data; this method can be used 
   * to retrieve it.
   * @return the user data that was previously added to this relation.
   */
  public Serializable getUserData();
  
  /**
   * Associates some arbitrary user data to this relation.
   * @param data the user data value.
   */
  public void setUserData(Serializable data);
  
  
  /**
   * Relation type for co-reference relations. 
   */
  public static final String COREF = "coref";
  
}
