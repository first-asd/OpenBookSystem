//author idornescu
//version 0.2 - Oct 11, 2012
//use perl implementation

prefix="/home/idornescu/workspace/openbook-syntax-service/target/gate/"
if (scriptParams.prefix!=null) prefix=scriptParams.prefix

workerId="1234"
if (scriptParams.workerId!=null) workerId=scriptParams.workerId

fileprefix="../../" //prefix
relativePath="../../"
if (scriptParams.fileprefix!=null) fileprefix=scriptParams.fileprefix
fileAraw="temp${workerId}-raw.txt"
fileBann="temp${workerId}-ann.txt"
//fileCout="${relativePath}temp${workerId}-out.xml"

inputAnnieAS=""
signAnn="sync"
outSentAnn="AltSentences"

//Step1: prepare input for rule engine
prepareInput(inputAnnieAS,signAnn,fileprefix+fileAraw,fileprefix+fileBann)

//Step2: run rule engine
sents=runRuleEngine(inputAnnieAS, relativePath+fileAraw, relativePath+fileBann/*, fileCout*/)

//Step3: import sentences
addTaggedSentenceAnn(sents,inputAnnieAS,signAnn,outSentAnn)

//Step4: cleanup
outputAS.get("mnode").each{it->
  outputAS.remove(it)
}
doc.getAnnotations().clear()

void prepareInput(inputAnnieAS,signAnn,fileAraw,fileBann){
  set1= doc.getAnnotations(inputAnnieAS)
  sentList=set1.get("Sentence").sort(new OffsetComparator())

  BufferedWriter outRaw=new BufferedWriter(new FileWriter(fileAraw))
  BufferedWriter outAnn=new BufferedWriter(new FileWriter(fileBann))

  println "Opened files ${new File(fileAraw).getAbsolutePath()} ${new File(fileBann).getAbsolutePath()}"
  
  sentList.each{s->
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
         //println text
         outAnn.write("${text}\n")
      }
    }
    mysentence+=doc.getContent().getContent(startOff,s.end()) 
    //println mysentence
    outRaw.write("${doc.stringFor(s)}\n")
  }
  outRaw.flush()
  outRaw.close()
  outAnn.flush()
  outAnn.close()
}

def runRuleEngine(inputAnnieAS, fileAraw, fileBann/*, fileCout*/){
  cmdline= "chmod +x ${fileprefix}resources/SyntacticSimplification/simplify.sh"	
  pr =Runtime.getRuntime().exec(cmdline);
  pr.waitFor()
  	
  //cmdline="${prefix}resources/SyntacticSimplification/perl syntactic_simplifier_xml.pl ${fileAraw} ${fileBann} 2>/dev/null " //1>${fileCout}"
  cmdline = "${fileprefix}resources/SyntacticSimplification/simplify.sh ${fileAraw} ${fileBann} "
  //println cmdline
  pr =Runtime.getRuntime().exec(cmdline);
  BufferedReader inf = new BufferedReader(new InputStreamReader(pr.getInputStream()));

  def sentences = [:]
  idxS=0
  original=""
  derived=""
  
  while (( line=inf.readLine())!=null){
    //println line 
    line=line.trim()
  
    if (line.startsWith("</SENTENCE>")){
      derived=derived.trim()
      if (derived.length()>0){
        s=sentList[idxS]
        sentences[s] = derived
        //println "${derived}\n${doc.stringFor(sentList[idxS])}\n"
      }
      //println "${original}\n${doc.stringFor(sentList[idxS])}\n"
      
      original=""
      derived=""
      idxS=idxS+1
    }
    else if (line.startsWith("<ORIGINAL>")){
      original=line.replaceAll("</?ORIGINAL>","")
    }
    else if (line.startsWith("<S DERIVATION")){
      idxa=line.indexOf(">")
      derived=derived+" "+line[(idxa+1)..-5]
    }
  }
  inf.close()
  exitVal = pr.waitFor();
  //println "Exited with error code ${exitVal}"
  //println sentences

  return sentences
}

void addTaggedSentenceAnn(sentences,inputAnnieAS,signAnn,outSentAnn){
  set1= doc.getAnnotations(inputAnnieAS)
  sentList=set1.get("Sentence").sort(new OffsetComparator())
  
  //TODO: for each sign one sentenceusing {text...text [sign] text...text} 1 tag
  sentList.each{s->
    mysentence=sentences[s]
    if (mysentence!=null){
      FeatureMap features = Factory.newFeatureMap()
      features.put("alternative",mysentence)
      features.put("complexity",0.33)
      features.put("confidence",0.53)
      features.put("type","SSCCV-78a, CMV1-17b, CCV-1b")
      outputAS.add(s.start(),s.end(),outSentAnn,features) 
    }  
  }
}