/*
 *  Copyright (c) 1995-2012, The University of Sheffield. See the file
 *  COPYRIGHT.txt in the software or at http://gate.ac.uk/gate/COPYRIGHT.txt
 *
 *  This file is part of GATE (see http://gate.ac.uk/), and is free
 *  software, licenced under the GNU Library General Public License,
 *  Version 2, June 1991 (in the distribution as file licence.html,
 *  and also available at http://gate.ac.uk/gate/licence.html).
 *
 *  Valentin Tablan 08/10/2001
 *
 *  $Id: ConditionalSerialAnalyserController.java 15551 2012-03-08 13:16:34Z johann_p $
 *
 */

package gate.creole;

import java.util.*;

import gate.*;
import gate.creole.metadata.*;
import gate.event.CreoleEvent;
import gate.util.*;

/**
 * This class implements a SerialController that only contains
 * {@link gate.LanguageAnalyser}s.
 * It has a {@link gate.Corpus} and its execute method runs all the analysers in
 * turn over each of the documents in the corpus.
 * This is a copy of the {@link SerialAnalyserController}, the only difference
 * being that it inherits from {@link ConditionalSerialController} rather than
 * from {@link SerialController} which makes it a <b>conditional</b> serial
 * analyser controller.
 * <p>
 * NOTE: if at the time when execute() is invoked, the document is not null,
 * it is assumed that this controller is invoked from another controller and
 * only this document is processed while the corpus (which must still be
 * non-null) is ignored. If the document is null, all documents in the corpus
 * are processed in sequence. 
 * 
 */
@CreoleResource(name = "Conditional Corpus Pipeline",
    comment = "A serial controller for conditionally run PR pipelines "
        + "over corpora.",
    helpURL = "http://gate.ac.uk/userguide/sec:developer:cond")
public class ConditionalSerialAnalyserController
       extends ConditionalSerialController
       implements CorpusController, LanguageAnalyser {

  /** Debug flag */
  private static final boolean DEBUG = false;

  
  /**
   * @return the document
   */
  public Document getDocument() {
    return document;
  }

  /**
   * @param document the document to set
   */
  @Optional
  @RunTime
  @CreoleParameter
  public void setDocument(Document document) {
    this.document = document;
  }
  
  public gate.Corpus getCorpus() {
    return corpus;
  }

  public void setCorpus(gate.Corpus corpus) {
    this.corpus = corpus;
  }

  /** Run the Processing Resources in sequence. */
  protected void executeImpl() throws ExecutionException{
    interrupted = false;
    if(corpus == null) throw new ExecutionException(
      "(ConditionalSerialAnalyserController) \"" + getName() + "\":\n" +
      "The corpus supplied for execution was null!");
    
    benchmarkFeatures.put(Benchmark.CORPUS_NAME_FEATURE, corpus.getName());
    
    
    if(document == null){
      //running as a top-level controller -> execute over all documents in 
      //sequence
      // iterate through the documents in the corpus
      for(int i = 0; i < corpus.size(); i++) {
        String savedBenchmarkId = getBenchmarkId();
        try {
          if(isInterrupted()) {
            throw new ExecutionInterruptedException("The execution of the "
              + getName() + " application has been abruptly interrupted!");
          }
  
          boolean docWasLoaded = corpus.isDocumentLoaded(i);
  
          // record the time before loading the document
          long documentLoadingStartTime = Benchmark.startPoint();
  
          Document doc = (Document)corpus.get(i);
  
          // include the document name in the benchmark ID for sub-events
          setBenchmarkId(Benchmark.createBenchmarkId("doc_" + doc.getName(),
                  getBenchmarkId()));
          // report the document loading
          benchmarkFeatures.put(Benchmark.DOCUMENT_NAME_FEATURE, doc.getName());
          Benchmark.checkPoint(documentLoadingStartTime,
                  Benchmark.createBenchmarkId(Benchmark.DOCUMENT_LOADED,
                          getBenchmarkId()), this, benchmarkFeatures);
  
          // run the system over this document
          // set the doc and corpus
          for(int j = 0; j < prList.size(); j++) {
            ((LanguageAnalyser)prList.get(j)).setDocument(doc);
            ((LanguageAnalyser)prList.get(j)).setCorpus(corpus);
          }
  
          try {
            if(DEBUG)
              Out.pr("SerialAnalyserController processing doc=" + doc.getName()
                + "...");
  
            super.executeImpl();
            if(DEBUG) Out.prln("done.");
          }
          finally {
            // make sure we unset the doc and corpus even if we got an exception
            for(int j = 0; j < prList.size(); j++) {
              ((LanguageAnalyser)prList.get(j)).setDocument(null);
              ((LanguageAnalyser)prList.get(j)).setCorpus(null);
            }
          }
  
          if(!docWasLoaded) {
            long documentSavingStartTime = Benchmark.startPoint();
            // trigger saving
            corpus.unloadDocument(doc);
            Benchmark.checkPoint(documentSavingStartTime,
                    Benchmark.createBenchmarkId(Benchmark.DOCUMENT_SAVED,
                            getBenchmarkId()), this, benchmarkFeatures);
            
            // close the previously unloaded Doc
            Factory.deleteResource(doc);
          }
        }
        finally {
          setBenchmarkId(savedBenchmarkId);
        }
      }      
    }else{
      //document is set, so we run as a contained controller (i.e. as a compound
      //Language Analyser
      // run the system over this document
      // set the doc and corpus
      for(int j = 0; j < prList.size(); j++) {
        ((LanguageAnalyser)prList.get(j)).setDocument(document);
        ((LanguageAnalyser)prList.get(j)).setCorpus(corpus);
      }

      try {
        if(DEBUG)
          Out.pr("SerialAnalyserController processing doc=" + document.getName()
            + "...");

        super.executeImpl();
        if(DEBUG) Out.prln("done.");
      }
      finally {
        // make sure we unset the doc and corpus even if we got an exception
        for(int j = 0; j < prList.size(); j++) {
          ((LanguageAnalyser)prList.get(j)).setDocument(null);
          ((LanguageAnalyser)prList.get(j)).setCorpus(null);
        }
      }
    }//document was not null

    
    
//    //iterate through the documents in the corpus
//    for(int i = 0; i < corpus.size(); i++){
//      if(isInterrupted()) throw new ExecutionInterruptedException(
//        "The execution of the " + getName() +
//        " application has been abruptly interrupted!");
//      
//      boolean docWasLoaded = corpus.isDocumentLoaded(i);
//      
//      // record the time before loading the document
//      long documentLoadingStartTime = Benchmark.startPoint();
//
//      Document doc = (Document)corpus.get(i);
//
//      // report the document loading
//      benchmarkFeatures.put(Benchmark.DOCUMENT_NAME_FEATURE, doc.getName());
//      Benchmark.checkPoint(documentLoadingStartTime,
//              Benchmark.createBenchmarkId(Benchmark.DOCUMENT_LOADED,
//                      getBenchmarkId()), this, benchmarkFeatures);
//      //run the system over this document
//      //set the doc and corpus
//      for(int j = 0; j < prList.size(); j++){
//        ((LanguageAnalyser)prList.get(j)).setDocument(doc);
//        ((LanguageAnalyser)prList.get(j)).setCorpus(corpus);
//      }
//
//      try{
//        if (DEBUG) 
//          Out.pr("ConditionalSerialAnalyserController processing doc=" + doc.getName()+ "...");      
//        super.executeImpl();
//        if (DEBUG) 
//          Out.prln("done.");      
//      }
//      finally {
//        // make sure we unset the doc and corpus even if we got an exception
//        for(int j = 0; j < prList.size(); j++){
//          ((LanguageAnalyser)prList.get(j)).setDocument(null);
//          ((LanguageAnalyser)prList.get(j)).setCorpus(null);
//        }
//      }
//
//      if(!docWasLoaded){
//        long documentSavingStartTime = Benchmark.startPoint();
//        // trigger saving
//        corpus.unloadDocument(doc);
//        Benchmark.checkPoint(documentSavingStartTime,
//                Benchmark.createBenchmarkId(Benchmark.DOCUMENT_SAVED,
//                        getBenchmarkId()), this, benchmarkFeatures);
//        //close the previoulsy unloaded Doc
//        Factory.deleteResource(doc);
//      }
//    }
  }

  /**
   * Overidden from {@link SerialController} to only allow
   * {@link LanguageAnalyser}s as components.
   */
  public void add(ProcessingResource pr){
    checkLanguageAnalyser(pr);
    super.add(pr);
  }
  
  /**
   * Overidden from {@link SerialController} to only allow
   * {@link LanguageAnalyser}s as components.
   */
  public void add(int index, ProcessingResource pr) {
    checkLanguageAnalyser(pr);
    super.add(index, pr);
  }

  /**
   * Throw an exception if the given processing resource is not
   * a LanguageAnalyser.
   */
  protected void checkLanguageAnalyser(ProcessingResource pr) {
    if(!(pr instanceof LanguageAnalyser)) {
      throw new GateRuntimeException(getClass().getName() +
                                     " only accepts " +
                                     LanguageAnalyser.class.getName() +
                                     "s as components\n" +
                                     pr.getClass().getName() +
                                     " is not!");
    }
  }
  
  /**
   * Sets the current document to the memeber PRs
   */
  protected void setDocToPrs(Document doc){
    Iterator prIter = getPRs().iterator();
    while(prIter.hasNext()){
      ((LanguageAnalyser)prIter.next()).setDocument(doc);
    }
  }


  /**
   * Checks whether all the contained PRs have all the required runtime
   * parameters set. Ignores the corpus and document parameters as these will
   * be set at run time.
   *
   * @return a {@link List} of {@link ProcessingResource}s that have required
   * parameters with null values if they exist <tt>null</tt> otherwise.
   * @throws {@link ResourceInstantiationException} if problems occur while
   * inspecting the parameters for one of the resources. These will normally be
   * introspection problems and are usually caused by the lack of a parameter
   * or of the read accessor for a parameter.
   */
  public List getOffendingPocessingResources()
         throws ResourceInstantiationException{
    //take all the contained PRs
    ArrayList badPRs = new ArrayList(getPRs());
    //remove the ones that no parameters problems
    Iterator prIter = getPRs().iterator();
    while(prIter.hasNext()){
      ProcessingResource pr = (ProcessingResource)prIter.next();
      ResourceData rData = (ResourceData)Gate.getCreoleRegister().
                                              get(pr.getClass().getName());
      //this is a list of lists
      List parameters = rData.getParameterList().getRuntimeParameters();
      //remove corpus and document
      List newParameters = new ArrayList();
      Iterator pDisjIter = parameters.iterator();
      while(pDisjIter.hasNext()){
        List aDisjunction = (List)pDisjIter.next();
        List newDisjunction = new ArrayList(aDisjunction);
        Iterator internalParIter = newDisjunction.iterator();
        while(internalParIter.hasNext()){
          Parameter parameter = (Parameter)internalParIter.next();
          if(parameter.getName().equals("corpus") ||
             parameter.getName().equals("document")) internalParIter.remove();
        }
        if(!newDisjunction.isEmpty()) newParameters.add(newDisjunction);
      }

      if(AbstractResource.checkParameterValues(pr, newParameters)){
        badPRs.remove(pr);
      }
    }
    return badPRs.isEmpty() ? null : badPRs;
  }


  protected gate.Corpus corpus;

  
  /**
   * The document being processed. This is part of the {@link LanguageAnalyser} 
   * interface, so this value is only used when the controller is used as a 
   * member of another controller.
   */
  protected Document document;
  
  
  /**
   * Overridden to also clean up the corpus value.
   */
  public void resourceUnloaded(CreoleEvent e) {
    super.resourceUnloaded(e);    
    if(e.getResource() == corpus){
      setCorpus(null);
    }
  }
}
