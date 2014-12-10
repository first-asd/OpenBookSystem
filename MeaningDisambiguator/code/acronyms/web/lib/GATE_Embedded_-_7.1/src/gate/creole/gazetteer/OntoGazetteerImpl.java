/*
 * OntoGazetteerImpl.java
 *
 * Copyright (c) 2002, The University of Sheffield.
 *
 * This file is part of GATE (see http://gate.ac.uk/), and is free
 * software, licenced under the GNU Library General Public License,
 * Version 2, June1991.
 *
 * A copy of this licence is included in the distribution in the file
 * licence.html, and is also available at http://gate.ac.uk/gate/licence.html.
 *
 * borislav popov 02/2002
 *
 */
package gate.creole.gazetteer;

import gate.*;
import gate.creole.ExecutionException;
import gate.creole.ResourceInstantiationException;

/** OntoGazetteerImpl <br>
 *  An ontology-aware gazetteer, producing additional annotations
 *  with features [class] and [ontology].
 */
public class OntoGazetteerImpl extends AbstractOntoGazetteer {

  public OntoGazetteerImpl() {
  }

  public java.util.Set lookup(String singleItem) {
    return gaz.lookup(singleItem);
  }

  /** Initialize this onto gazetteer
   *  @return .*/
  public Resource init() throws ResourceInstantiationException {
    try {
      checkParameters();

      // load gazetteer class from GATE classloader
      Class cl = Class.forName(gazetteerName, true, Gate.getClassLoader());

      FeatureMap params = Factory.newFeatureMap();

      mappingDefinition = new MappingDefinition();
      mappingDefinition.setURL(mappingURL);
      mappingDefinition.load();

      params.put("caseSensitive",caseSensitive);
      params.put("listsURL",listsURL);
      params.put("encoding",encoding);
      params.put("mappingDefinition",mappingDefinition);
      gaz = (Gazetteer)Factory.createResource(cl.getName(),params);

    } catch (ClassNotFoundException e) {
      throw new RuntimeException("ClassNotFoundException : "+e.getMessage());
    } catch (InvalidFormatException e) {
      throw new ResourceInstantiationException(e);
    }
    return this;
  } // init

  /** Executes this onto gazetteer over a pre-set document
   *  @throws ExecutionException if something goes wrong with the execution */
  public void execute()throws ExecutionException {
    if (null == gaz) {
      throw new ExecutionException("gazetteer not initialized (null).");
    }

    gaz.setDocument(document);
    gaz.setAnnotationSetName(annotationSetName);
    gaz.setEncoding(encoding);
    gaz.setCorpus(corpus);
    gaz.execute();
  } // execute

  /**
   * Checks the parameters set to this gazetteer
   * @throws ResourceInstantiationException if something goes wrong
   */
  private void checkParameters() throws ResourceInstantiationException {
    boolean set = null!=gazetteerName;
    set &= null!=listsURL;
    set&=null!=mappingURL;
    if (!set) {
     throw new ResourceInstantiationException("some parameters are not set (e.g.gazetteerName,"
        +"listURL,mappingDefinition, document");
    }

  } // checkParameters

  /**
   * Removes a single string item from the gazetteer model
   * @param singleItem removes a string item from the gazetteer model
   * @return true if the string is removed from the model, otherwise - false
   */
  public boolean remove(String singleItem) {
    return gaz.remove(singleItem);
  }

  /**
   * Adds a string item to the model and associates it with a Lookup
   * @param singleItem the string item to be added
   * @param lookup the lookup to be associated with the string item
   * @return true if the item has been added, otherwise - false.
   */
  public boolean add(String singleItem, Lookup lookup) {
    return gaz.add(singleItem,lookup);
  }

} // OntoGazetteerImpl
