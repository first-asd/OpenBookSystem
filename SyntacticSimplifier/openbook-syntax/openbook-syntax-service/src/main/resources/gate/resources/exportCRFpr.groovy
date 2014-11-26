//author idornescu
//produce mnodes with all necessary features for CRF models
//version 0.3 - Oct 2, 2012
//use POS+ANNIE tokenisation



//Step0: prepare tempfiles for this document
  outFileBuffer="out-crf-132-tmp.txt"
  if (scriptParams.fileBuffer!=null){
    outFileBuffer=scriptParams.fileBuffer
  }
  outf=new BufferedWriter(new FileWriter(outFileBuffer))

//TODO: make these parameters
makeTrain=false;
if ("true".equals(scriptParams.trainMode)) makeTrain=true;

def inputGoldAS="Original markups"
def inputAnnieAS=""
def crfNodeAnn="mnode"

//Step1: each Token becomes a mnode
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
  //use gold sign markup (=sync annotations)
  nodeSet=outputAS.get(crfNodeAnn)
  signsSet=doc.getAnnotations(inputGoldAS).get("sync")
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
//In absence of gold standard, mark the nodes which are known signs
//also merge <punctuation> <conjunction>
else{
  //identify known signs
  //create tags UNK
  nodeSet=outputAS.get(crfNodeAnn).sort(new OffsetComparator())
  def signsPunct=[",",";",":"]
  def signsConj =["and","but","or","that","who","what","when","where","which","while"]
  i=0
  while (i<nodeSet.size()){
    n=nodeSet[i]
    word=n.getFeatures().get("word").toLowerCase()
    if (signsPunct.contains(word) && i+1<nodeSet.size()){
      //complex sign?
      nextword=nodeSet[i+1].getFeatures().get("word").toLowerCase()
      if (signsConj.contains(nextword)){
        outputAS.remove(n)
        outputAS.remove(nodeSet[i+1])
        
        FeatureMap features = Factory.newFeatureMap()
        features.put("word",word+nextword)
        features.put//TODO: check type - if not of interest make an 'other' node M:O OTH 
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
}

//Step3: print mnode features in conll tab format (CRF++ & other)
set1= doc.getAnnotations(inputAnnieAS)
sentList=set1.get("Sentence").sort(new OffsetComparator())

sentList.each{s->
  annList=outputAS.get(crfNodeAnn).getContained(s.start.offset,s.end.offset).sort(new OffsetComparator())
  annList.each{m ->
    ["word","pos","marker"].each{
      outf.write(m.getFeatures().get(it))
      outf.write(" ")
    }
    outf.write(m.getFeatures().get("tag"))
    outf.write("\n")
  }
  outf.write("\n")
  outf.flush()
}
//close tempfile
outf.flush()
outf.close()
 
//Step4: make predictions     
//String[] cmdline=["/bin/bash", "-c", "\"/home/idornescu/apps/CRF++-0.57/crf_test -m target/gate/resources/crf-model-tmp-123 ${outFileBuffer} >${outFileBuffer}.pred\""] //.toArray()  // 
cmdline="/home/idornescu/apps/CRF++-0.57/crf_test -m target/gate/resources/crf-model-tmp-123 ${outFileBuffer} "

Process pr =Runtime.getRuntime().exec(cmdline);
BufferedReader inf = new BufferedReader(new InputStreamReader(pr.getInputStream()));

//Step5: import predictions
set1= doc.getAnnotations(inputAnnieAS)
sentList=set1.get("Sentence").sort(new OffsetComparator())

sentList.each{s->
  annList=outputAS.get(crfNodeAnn).getContained(s.start.offset,s.end.offset).sort(new OffsetComparator())
  annList.each{m ->
    line=inf.readLine()
    //println "${doc.stringFor(m)}\t${line}"
    
    if (line.indexOf("M:Y")>=0){
      predtag=line.split()[-1]
      FeatureMap features = Factory.newFeatureMap()
      features.put("type",predtag)
      features.put("pos",m.getFeatures().get("pos"))
      outputAS.add(m.start(),m.end(),"sync",features)
      //println line
    }
  }
  line=inf.readLine() //should be blank line between sentences
}
inf.close()
exitVal = pr.waitFor();



void beforeCorpus(c) {
    //println c.name
}
    
void afterCorpus(c) {
  //cleanup after corpus
}

void alert(c){
  //log an error occurred
}
