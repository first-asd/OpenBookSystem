/*
 *  TestXSchema.java
 *
 *  Copyright (c) 1995-2012, The University of Sheffield. See the file
 *  COPYRIGHT.txt in the software or at http://gate.ac.uk/gate/COPYRIGHT.txt
 *
 *  This file is part of GATE (see http://gate.ac.uk/), and is free
 *  software, licenced under the GNU Library General Public License,
 *  Version 2, June 1991 (in the distribution as file licence.html,
 *  and also available at http://gate.ac.uk/gate/licence.html).
 *
 *  Cristian URSU, 11/Octomber/2000
 *
 *  $Id: TestXSchema.java 15333 2012-02-07 13:18:33Z ian_roberts $
 */

package gate.creole;

import java.io.ByteArrayInputStream;

import junit.framework.*;

import gate.*;
import gate.util.Out;

/** Annotation schemas test class.
  */
public class TestXSchema extends TestCase
{
  /** Debug flag */
  private static final boolean DEBUG = false;

  /** Construction */
  public TestXSchema(String name) { super(name); }

  /** Fixture set up */
  public void setUp() {
  } // setUp

  /** A test */
  public void testFromAndToXSchema() throws Exception {

    ResourceData resData = (ResourceData)
      Gate.getCreoleRegister().get("gate.creole.AnnotationSchema");

    FeatureMap parameters = Factory.newFeatureMap();
    parameters.put(
      AnnotationSchema.FILE_URL_PARAM_NAME, Gate.getUrl("tests/xml/POSSchema.xml"));

    AnnotationSchema annotSchema = (AnnotationSchema)
      Factory.createResource("gate.creole.AnnotationSchema", parameters);

    String s = annotSchema.toXSchema();
    // write back the XSchema fom memory
    // File file = Files.writeTempFile(new ByteArrayInputStream(s.getBytes()));
    // load it again.
    //annotSchema.fromXSchema(file.toURI().toURL());
    annotSchema.fromXSchema(new ByteArrayInputStream(s.getBytes()));
  } // testFromAndToXSchema()

  /** Test creation of annotation schemas via gate.Factory */
  public void testFactoryCreation() throws Exception {

    ResourceData resData = (ResourceData)
      Gate.getCreoleRegister().get("gate.creole.AnnotationSchema");

    FeatureMap parameters = Factory.newFeatureMap();
    parameters.put(
      AnnotationSchema.FILE_URL_PARAM_NAME, Gate.getUrl("tests/xml/POSSchema.xml"));

    AnnotationSchema schema = (AnnotationSchema)
      Factory.createResource("gate.creole.AnnotationSchema", parameters);

    if(DEBUG) {
      Out.prln("schema RD: " + resData);
      Out.prln("schema: " + schema);
    }

  } // testFactoryCreation()

  /** Test suite routine for the test runner */
  public static Test suite() {
    return new TestSuite(TestXSchema.class);
  } // suite

} // class TestXSchema
