//author idornescu
//produce mnodes with all necessary features for CRF models
//train new models
//use models to make predictions
//version 0.6 - Oct 11, 2012
//use POS+ANNIE tokenisation + syntactic features

//TODO: FIX for classes deemed too detailed for the prototype M:O OTH

//parameters
//prefixes
prefix="/home/idornescu/workspace/openbook-syntax-service/target/gate/"
if (scriptParams.prefix!=null) prefix=scriptParams.prefix
crfprefix="/apps/CRF++-0.57/" //"/home/idornescu/apps/CRF++-0.57/"
if (scriptParams.crfprefix!=null) crfprefix=scriptParams.crfprefix
//execution flags
makeTrain=false
makePredictions=false
if ("true".equals(scriptParams.trainMode)) makeTrain=true;
if ("true".equals(scriptParams.predictMode)) makePredictions=true;
useSyntax=false
if ("true".equals(scriptParams.useSyntax)) useSyntax=true;
makeNewModel=false
if ("true".equals(scriptParams.buildModel)) makeNewModel=true;  

//FIXME: the following are two hidden parameters... possible collisions
//files
modelFile="crf-model-tmp-123" //pos-only model
templateFile="template-crf.txt"
if (useSyntax){
  modelFile="crf-model-syntax-123" //pos+syntax model
  templateFile="template-crf-syntax.txt"
}
//FIXME: concurrency problem!  
outFileBuffer="out-crf-132-tmp.txt"
if (scriptParams.fileBuffer!=null) outFileBuffer=scriptParams.fileBuffer

//annotations
def inputGoldAS="Original markups"
def inputAnnieAS=""
def crfNodeAnn="mnode"
def signAnn="sync" 

//Start processing
//Step1: each Token becomes a mnode
//TODO: check that Token annotations exist!!!
tokensSet=doc.getAnnotations(inputAnnieAS).get("Token")
tokensSet.each{token->
  FeatureMap features = Factory.newFeatureMap();
  features.put("tag","NA")
  features.put("marker","M:N")
  features.put("word",token.getFeatures().get("string"))
  features.put("pos",token.getFeatures().get("category"))
  outputAS.add(token.start(), token.end(), crfNodeAnn, features)
}  

//Step2: use gold standard (merge nodes, sign classification)  
if (makeTrain){  
  useGoldStdSigns(inputGoldAS,signAnn,crfNodeAnn)
}
//In absence of gold standard, mark the nodes which are known signs
//also merge <punctuation> <conjunction>
else{
  detectPossibleSigns(crfNodeAnn)
}

//Step2bis: add syntactic features
if(useSyntax){
  //println "Adding syntax features"
  addSyntaxFeatures(inputAnnieAS)
}

//Step3: print mnode features in conll tab format (CRF++ & other)
writeFeaturestoFile("${prefix}${outFileBuffer}",inputAnnieAS,crfNodeAnn)

//Step3bis: build new  model
if(makeTrain && makeNewModel){
  println "Training new CRF++ model"
  //fixme chmod +x
  //crf_learn -f 3 template datafile mofeloutfile
  cmdline="${crfprefix}crf_learn -f 3 ${prefix}resources/${templateFile} ${prefix}${outFileBuffer} ${prefix}resources/${modelFile}"
  println "crf_learn -f 3 resources/${templateFile} ${outFileBuffer} resources/${modelFile}" 
  println cmdline
  Process pr =Runtime.getRuntime().exec(cmdline);
  BufferedReader inf = new BufferedReader(new InputStreamReader(pr.getInputStream()));
  while((line=inf.readLine())!=null){
    println line
  }  
  inf.close()
  exitVal = pr.waitFor();
  println "Building model<${modelFile}>... ${exitVal}"
}

//Step4: make predictions     
if (makePredictions){
  addPredictions(inputAnnieAS,crfNodeAnn,signAnn)

//STEP6: Add complex sentence annotations
//addTaggedSentenceAnn(signAnn)

}

//println doc.toXml()

void useGoldStdSigns(inputGoldAS,signAnn,crfNodeAnn){
  //use gold sign markup (=sync annotations)
  nodeSet=outputAS.get(crfNodeAnn)
  signsSet=doc.getAnnotations(inputGoldAS).get(signAnn)
  signsSet.each{sign->
    node=nodeSet.get(crfNodeAnn,sign.start(),sign.end()).sort(new OffsetComparator())
    node.each{n->
      outputAS.remove(n)
    }
    if(!node.isEmpty()){      
      FeatureMap features = Factory.newFeatureMap()
      //TODO: check type - if not of interest make an 'other' node M:O OTH 
      features.put("marker","M:Y")
      features.put("tag",sign.getFeatures().get("type")) 
      word=doc.getContent().getContent(sign.start(),sign.end())
      features.put("word",word.toString().replaceAll(" ",""))
      nodeAnn=node[-1]
      tokenAnn=doc.getAnnotations("").get("Token").getContained(nodeAnn.start()-1,nodeAnn.end()+1).sort(new OffsetComparator())[0]
      pos=tokenAnn.getFeatures().get("category")
      features.put("pos",pos) 
      outputAS.add(sign.start(), sign.end(), crfNodeAnn, features) //test
    }    
  }  
}

void detectPossibleSigns(crfNodeAnn){
  //identify known signs
  //create tags M:Y UNK
  nodeSet=outputAS.get(crfNodeAnn).sort(new OffsetComparator())
  
  ///println "Identifying known signs"
  
  def signsPunct=[",",";",":"]
  def signsConj =["and","but","or","that","who","what","when","where","which","while"]
  i=0
  while (i<nodeSet.size()){
    n=nodeSet[i]
    //BUG: uppercase signs to be ignored (beginning of sentence)
    word=n.getFeatures().get("word") //.toLowerCase()
    if (signsPunct.contains(word) && i+1<nodeSet.size()){
      nextword=nodeSet[i+1].getFeatures().get("word").toLowerCase()
      if (["and","but","or"].contains(nextword)){
        outputAS.remove(n)
        outputAS.remove(nodeSet[i+1])
        
        FeatureMap features = Factory.newFeatureMap()
        features.put("word",word+nextword)
        //features.put//TODO: check type - if not of interest make an 'other' node M:O OTH 
        features.put("marker","M:Y")
        features.put("tag","UKN") 
        features.put("pos",nodeSet[i+1].getFeatures().get("pos")) 
        outputAS.add(n.start(), nodeSet[i+1].end(), crfNodeAnn, features) //test2
        
        i=i+1
      }
    }
    if (signsPunct.contains(word) || signsConj.contains(word)){
        n.getFeatures().put("marker","M:Y")
        n.getFeatures().put("tag","UKN")
    }
    i=i+1  
  }
  return
}


void addSyntaxFeatures(inputAnnieAS){
  set1= doc.getAnnotations(inputAnnieAS)
  sentList=set1.get("Sentence").sort(new OffsetComparator())
  sentList.each{s->
    //println doc.stringFor(s)
    nodes=outputAS.getContained(s.start(),s.end()).sort(new OffsetComparator())
  
    nodes.each{n->
      FeatureMap features = Factory.newFeatureMap()
      if (["mnode"].contains(n.type)){
        processSyntax(s,n,n.features)
        //println "${doc.stringFor(n)}\t$features}"
      }
    }
    //println " "
  }
}


//get the syntactic siblings of node n in sentence s
//FIXME: set1, s...
void processSyntax(s,n,feats){
       //println "Process syntax: ${doc.stringFor(s)}\t${doc.stringFor(n)}"
       if(s.start()<=n.start())
         set2=set1.get("SyntaxTreeNode").getContained(s.start(),s.end())
         set3=set2.findAll{it.start()>=n.start() && it.end()<=n.end()}.sort()
         if (set3.size<=0){
           println "Missing syntax nodes!!" // ${doc.stringFor(s)}\t${doc.stringFor(n)}\t" //${set1.get('SyntaxTreeNode').getContained(s.start(),s.end())}"
           return
         }
         signNode=set3[-1]
         parentNode=set2.find{
           consts=it.getFeatures().get("consists")
           consts!=null && consts.contains(signNode.id)
         }
         if (parentNode!=null){
           parentChunk=parentNode.features.cat
           signChunk=signNode.features.cat
           siblings=parentNode.features.consists.collect{myid->
             set2.find{it.id==myid}
           }
           siblings=siblings.findAll{it->
             //!(it.start()>=n.start() && it.end()<=n.end()) && 
             it.features.cat.matches("[A-Za-z]+") || (it.start()==n.start() && it.end()==n.end())
           }
           prevChunk="NA"
           if (siblings.collect{it.id}.any{it<signNode.id}){
             prevChunk=siblings.findAll{it.id<signNode.id}[-1].features.cat
           }           
           nextChunk="NA"
           if (siblings.collect{it.id}.any{it>signNode.id}){
             nextChunk=siblings.findAll{it.id>signNode.id}[0].features.cat
           }
           //siblings.each{it->println "${it.features.cat}\t${it.id}\t${doc.stringFor(it)}"}
           //println "${parentChunk} (${prevChunk} ${signChunk} ${nextChunk})"
           //
           feats.put("parentC",parentChunk)
           feats.put("prevC" ,prevChunk)
           feats.put("signC" ,signChunk)
           feats.put("nextC" ,nextChunk)
         }else{
           println "Node missing: id=${signNode.id} ${parentNode}"
         }
       
   return    
}

void writeFeaturestoFile(filePath,inputAnnieAS,crfNodeAnn){
  println "Writing sign features to ${filePath}"    
  outf=new BufferedWriter(new FileWriter(filePath))
  set1= doc.getAnnotations(inputAnnieAS)
  sentList=set1.get("Sentence")
  sentList=sentList.sort(new OffsetComparator())

 
  featuresList=["word","pos","marker"]
  if (useSyntax)
    featuresList=["word","pos","marker","parentC","prevC","signC","nextC"]
  //println "${useSyntax} ${featuresList}"
  //TODO: FIX use a string buffer/builder
  sentList.each{s->
    annList=outputAS.get(crfNodeAnn).getContained(s.start.offset,s.end.offset).sort(new OffsetComparator())
    annList.each{m ->
      featuresList.each{
        feats=m.getFeatures().get(it)
        if (feats==null) {
          //FIXME: tokens not in sentences have null siblings.. skip from crf output?
          outf.write("null") 
          //println "Null syntax: ${it}\t${doc.stringFor(m)} "
        }else
          outf.write(feats)
        outf.write(" ")
      }
      outf.write(m.getFeatures().get("tag"))
      outf.write("\n")
      //println "${m}\t${doc.stringFor(m)} "
    }
    //println "${s}\t${doc.stringFor(s)} "
    outf.write("\n")
    outf.flush()
  }

  outf.flush()
  outf.close()
  return
}

void testSycmd(){
    cmdline="ls -l /"
    Process pr =Runtime.getRuntime().exec(cmdline);
    BufferedReader inf = new BufferedReader(new InputStreamReader(pr.getInputStream()));
   
    while((line=inf.readLine())!=null){
      println line
    }
}

void addPredictions(inputAnnieAS,crfNodeAnn,signAnn){
  //testSycmd()
  cmdline="chmod +x ${crfprefix}crf_test"
  Process pr =Runtime.getRuntime().exec(cmdline);
  exitVal = pr.waitFor();
      
  cmdline="${crfprefix}crf_test -m ${prefix}resources/${modelFile} ${prefix}${outFileBuffer} "
  println cmdline
  pr =Runtime.getRuntime().exec(cmdline);
  BufferedReader inf = new BufferedReader(new InputStreamReader(pr.getInputStream()));
  
  //Step5: import predictions
  set1= doc.getAnnotations(inputAnnieAS)
  sentList=set1.get("Sentence").sort(new OffsetComparator())
  ///println sentList

  sentList.each{s->
    annList=outputAS.get(crfNodeAnn).getContained(s.start.offset,s.end.offset).sort(new OffsetComparator())
    annList.each{m ->
      line=inf.readLine()
      //println "${doc.stringFor(m)}\t${line}"
    
      if (line!=null && line.indexOf("M:Y")>=0){
        predtag=line.split()[-1]
        FeatureMap features = Factory.newFeatureMap()
        features.put("type",predtag)
        features.put("pos",m.getFeatures().get("pos"))
        features.put("complexity",0.33)
        features.put("confidence",0.53)
        outputAS.add(m.start(),m.end(),signAnn,features)
        //println line
      }
    }
    line=inf.readLine() //should be blank line between sentences
  }
  inf.close()
  exitVal = pr.waitFor();
  //println "Exited with error code ${exitVal}"
}

/*
void addTaggedSentenceAnn(signAnn){
  //TODO: for each sign one sentenceusing {text...text [sign] text...text} 1 tag
  sentList.each{s->
    //println doc.stringFor(s)
    mysentence=""
    nodes=outputAS.getContained(s.start(),s.end()).sort(new OffsetComparator())
    content=doc.getContent()
    startOff=s.start()
    nodes.each{n->
      if (n.type==signAnn){
         if (startOff<n.start())
           mysentence+=content.getContent(startOff,n.start())
         mysentence+="[${doc.stringFor(n)} ${n.features.type}]"
         startOff=n.end()   
         
         text="{${content.getContent(s.start(),n.start())}[${doc.stringFor(n)}]${content.getContent(n.end(),s.end())}} 1 ${n.features.type}"
         println text
      }
    }
    mysentence+=doc.getContent().getContent(startOff,s.end()) 
    println mysentence+"\n"
    FeatureMap features = Factory.newFeatureMap()
    features.put("signs",mysentence)
    outputAS.add(s.start(),s.end(),"cplxSent",features) 
  }
}
*/

void beforeCorpus(c) {
    //println c.name
}



void afterCorpus(c) {
    //outf.flush()
    //outf.close()
    //preftax-service/target/gate/"
    //cmdline="/bin/sh -c '/home/idornescu/apps/CRF++-0.57/crf_test -m ${prefix}resources/crf-model-tmp-123 ${prefix}${outFileBuffer} >${prefix}${outFileBuffer}.pred'"
    //cmdline="/bin/bash -c \"pwd\""
    //println cmdline
    //Process pr =Runtime.getRuntime().exec(cmdline);
    //exitVal = pr.waitFor();
    //println "Exited with error code ${exitVal}"
}
