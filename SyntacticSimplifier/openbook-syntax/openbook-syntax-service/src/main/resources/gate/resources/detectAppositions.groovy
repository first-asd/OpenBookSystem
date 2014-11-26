//author idornescu
//version 0.3 - Mar, 2013
//use perl implementation

prefix="/home/idornescu/workspace/openbook-syntax-service/src/main/resources/gate/"
if (scriptParams.prefix!=null) prefix=scriptParams.prefix

workerId="1234-dnm.meter"
if (scriptParams.workerId!=null) workerId=scriptParams.workerId

fileprefix=prefix //"../../"
relativePath=fileprefix //"../../"
if (scriptParams.fileprefix!=null) fileprefix=scriptParams.fileprefix
fileAraw="temp${workerId}-App-raw.txt"
fileBann="temp${workerId}-App-ann.txt"
//fileCout="${relativePath}temp${workerId}-out.xml"

inputAnnieAS=""
signAnn="sync"
outSentAnn="Apposition"
if (scriptParams.outSentAnn!=null) outSentAnn=scriptParams.outSentAnn

clearAnnie=false
if (scriptParams.clearAnnie!=null) outSentAnn=scriptParams.clearAnnie

//Step1: prepare input for rule engine
prepareInput(inputAnnieAS,signAnn,fileprefix+fileAraw,fileprefix+fileBann)

//if (true) return;

//Step2: run rule engine
sents=runRuleEngine(inputAnnieAS, relativePath+fileAraw, relativePath+fileBann/*, fileCout*/)

//Step3: import sentences
addTaggedSentenceAnn(sents,inputAnnieAS,signAnn,outSentAnn)

//Step4: cleanup
if (clearAnnie)
  doc.getAnnotations(inputAnnieAS).clear()

void prepareInput(inputAnnieAS,signAnn,fileAraw,fileBann){
  set1= doc.getAnnotations(inputAnnieAS)
  sentList=set1.get("Sentence").sort(new OffsetComparator())

  BufferedWriter outRaw=new BufferedWriter(new FileWriter(fileAraw))
  BufferedWriter outAnn=new BufferedWriter(new FileWriter(fileBann,true))

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

//Updated for missing sentences in the output of the rule engine
//TOFIX: assumes same order of sentences
def runRuleEngine(inputAnnieAS, fileAraw, fileBann/*, fileCout*/){
  //cmdline= "chmod +x ${fileprefix}resources/SyntacticSimplification/simplify.sh"    
  cmdline= "chmod +x ${fileprefix}resources/AppositionDetection/detectAppositions.sh"
  pr =Runtime.getRuntime().exec(cmdline);
  pr.waitFor()
      
  //cmdline = "${fileprefix}resources/SyntacticSimplification/simplify.sh ${fileAraw} ${fileBann} "
  cmdline = "${fileprefix}resources/AppositionDetection/detectAppositions.sh ${fileAraw} ${fileBann} "
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
      s=sentList[idxS]
     
      if (derived.length()>0){    //this sentence has an annotation
        while(idxS<sentList.size() && s!=null && doc.stringFor(s) != original){
          idxS=idxS+1
          s=sentList[idxS]
          //println "skip"
        }
        if (s!=null && doc.stringFor(s) == original){
          sentences[s] = derived
        }
        ////println s
        //println "ann:\t${derived}\norig:\t${original}\nsrc:\t${doc.stringFor(s)}\n"
      }
      else{
        ////println "ann:\tN/A\norig:\t${original}\nsrc:\t${doc.stringFor(s)}\n${idxS}\n"
      }
      original=""
      derived=""
      idxS=idxS+1
    }
    else if (line.startsWith("<ORIGINAL>")){
      original=line.replaceAll("</?ORIGINAL>","").trim()
    }
    else if (line.startsWith("<S DERIVATION")){
      idxa=line.indexOf(">")
      derived=derived+" "+line[(idxa+1)..-5]
    }else{
      ////println "debug${line}" //ignored lines
    }
  }
  inf.close()
  exitVal = pr.waitFor();
  ////println "Exited with error code ${exitVal}"
  ////println sentences

  return sentences
}

void addTaggedSentenceAnn(sentences,inputAnnieAS,signAnn,outSentAnn){
  set1= doc.getAnnotations(inputAnnieAS)
  sentList=set1.get("Sentence").sort(new OffsetComparator())
  
  //TODO: for each sign one sentenceusing {text...text [sign] text...text} 1 tag
  sentList.each{s->
    mysentence=sentences[s]
    /*if (mysentence!=null){
      FeatureMap features = Factory.newFeatureMap()
      features.put("alternative",mysentence)
      features.put("complexity",0.33)
      features.put("confidence",0.53)
      features.put("type","SSCCV-78a, CMV1-17b, CCV-1b")
      outputAS.add(s.start(),s.end(),outSentAnn,features) 
    } */ //OLD markup 
    if (mysentence!=null){
      //println mysentence
      while (mysentence.indexOf("<MODIFIER>")>=0){
        java.util.regex.Pattern pattern = java.util.regex.Pattern.compile("^(.*)<MODIFIER>([^<>]+)</MODIFIER>(.*)\$")
        java.util.regex.Matcher matcher = pattern.matcher(mysentence);
        if(matcher.matches()) {
          startOff=s.start()+matcher.group(1).replaceAll("</?MODIFIER>","").length()
          endOff=startOff+matcher.group(2).replaceAll("</?MODIFIER>","").length()
          FeatureMap features = Factory.newFeatureMap()
          outputAS.add(startOff,endOff,outSentAnn,features) 
          mysentence=matcher.group(1)+matcher.group(2)+matcher.group(3)
        }  
        ////mysentence=mysentence.replaceFirst("(.*)<MODIFIER>([^<>]+)</MODIFIER>(.*)","\$1\$2\$3") 
        //println mysentence
      }
      
    }
  }
}