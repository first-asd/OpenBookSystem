//author idornescu
//use perl implementation
import gate.util.OffsetComparator
import gate.FeatureMap

prefix="/home/idornescu/workspace/openbook-syntax-service/src/main/resources/gate/"
if (scriptParams.prefix!=null) prefix=scriptParams.prefix

workerId="1234-dnm.meter"
if (scriptParams.workerId!=null) workerId=scriptParams.workerId

fileprefix=prefix //"../../"
if (scriptParams.fileprefix!=null) fileprefix=scriptParams.fileprefix
relativePath=fileprefix //"../../"
if (scriptParams.relativePath!=null) relativePath=scriptParams.relativePath
fileAraw="temp${workerId}-raw.txt"
fileBann="temp${workerId}-ann.txt"
//fileCout="${relativePath}temp${workerId}-out.xml"

clearAnnie=false
if (scriptParams.clearAnnie!=null) outSentAnn=scriptParams.clearAnnie

def inputAnnieAS="ENtokens"
if (scriptParams.inputAnnieAS!=null) inputAnnieAS=scriptParams.inputAnnieAS
signAnn="sync"
outSentAnn="AltSentences"

processorDir="SyntacticProcessor-v2" //"SyntacticSimplification"
if (scriptParams.processorDir!=null) processorDir=scriptParams.processorDir

diagnosisDir="SyntacticDiagnosis-v1" 
if (scriptParams.diagnosisDir!=null) diagnosisDir=scriptParams.diagnosisDir

//parameter for disabling diagnosis
runDiagnosis=true
if (scriptParams.runDiagnosis!=null) runDiagnosis=scriptParams.runDiagnosis

//output annotation set diagnosis
diagnosisAS="SentenceDetection" 
if (scriptParams.diagnosisAS!=null) diagnosisAS=scriptParams.diagnosisAS

//Step1: prepare input for rule engine
prepareInput(inputAnnieAS,signAnn,fileprefix+fileAraw,fileprefix+fileBann)

//if (true) return;

//Step2: run rule engine
results=runRuleEngine(inputAnnieAS, relativePath+fileAraw, relativePath+fileBann/*, fileCout*/)

//Step3: import sentences
addTaggedSentenceAnn(results,inputAnnieAS,signAnn,outSentAnn)

//Step 4: run diagnosis
if (runDiagnosis)
	runDiagnosisEngine(inputAnnieAS, diagnosisAS, relativePath+fileAraw, relativePath+fileBann)


//Step4: cleanup
if (clearAnnie)
	doc.getAnnotations(inputAnnieAS).clear()

void prepareInput(inputAnnieAS,signAnn,fileAraw,fileBann){
	set1= doc.getAnnotations(inputAnnieAS)
	sentList=set1.get("Sentence").sort(new OffsetComparator())

	BufferedWriter outRaw=new BufferedWriter(new FileWriter(fileAraw))
	BufferedWriter outAnn=new BufferedWriter(new FileWriter(fileBann,true))

	//println "Opened files ${new File(fileAraw).getAbsolutePath()} ${new File(fileBann).getAbsolutePath()}"

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
	cmdline= "chmod +x ${fileprefix}resources/${processorDir}/simplify.sh"
	pr =Runtime.getRuntime().exec(cmdline);
	pr.waitFor()

	//cmdline="${prefix}resources/SyntacticSimplification/perl syntactic_simplifier_xml.pl ${fileAraw} ${fileBann} 2>/dev/null " //1>${fileCout}"
	cmdline = "${fileprefix}resources/${processorDir}/simplify.sh ${fileAraw} ${fileBann} "
	//println cmdline
	pr =Runtime.getRuntime().exec(cmdline);
	BufferedReader inf = new BufferedReader(new InputStreamReader(pr.getInputStream()));

	def sentences = [:]
	def rules = [:]
	idxS=0
	original=""
	derived=""
	rule=""

	while (( line=inf.readLine())!=null){
		//println line
		line=line.trim()
		line=line.replaceFirst("<SENTENCE ASSESSMENT=\"(IN)?CORRECT\">","")

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
					rules[s] = rule.substring(2)
				}
				////println s
				//println "ann:\t${derived}\norig:\t${original}\nsrc:\t${doc.stringFor(s)}\n"
			}
			else{
				////println "ann:\tN/A\norig:\t${original}\nsrc:\t${doc.stringFor(s)}\n${idxS}\n"
			}

			original=""
			derived=""
			rule=""
			idxS=idxS+1
		}
		else if (line.startsWith("<ORIGINAL>")){//<SENTENCE ASSESSMENT="INCORRECT"><ORIGINAL>
			original=line.replaceAll("</?ORIGINAL>","").trim()
		}
		else if (line.startsWith("<S DERIVATION")){ //ASSESSMENT="INCORRECT"
			idxa=line.indexOf(">")
			derived=derived+" "+line[(idxa+1)..-5]
			idxb=line.indexOf("\"")
			rule=rule+"/ "+line[(idxb+1)..(idxa-2)]
		}
	}
	inf.close()
	exitVal = pr.waitFor()
	//println "Exited with error code ${exitVal}"
	//println sentences.size()

	return [sentences,rules]
}

void addTaggedSentenceAnn(results,inputAnnieAS,signAnn,outSentAnn){
	sentences=results[0]
	rules=results[1]
	set1= doc.getAnnotations(inputAnnieAS)
	sentList=set1.get("Sentence").sort(new OffsetComparator())

	sentList.each{s->
		mysentence=sentences[s]
		myrule=rules[s]
		if (mysentence!=null){
			FeatureMap features = Factory.newFeatureMap()
			features.put("alternative",mysentence)
			features.put("complexity",0.33)
			features.put("confidence",0.53)
			//features.put("type","SSCCV-78a, CMV1-17b, CCV-1b")
			features.put("type",myrule)
			features.put("origtext",doc.getContent().getContent(s.start(),s.end()).toString() )
			
			if(!features.get("origtext").toString().equalsIgnoreCase(features.get("alternative").toString()))
				outputAS.add(s.start(),s.end(),outSentAnn,features)
			//else	print features.get("origtext").toString()+"\n"+features.get("alternative").toString()+"\n\n"
			//print features
		}
	}
}

def runDiagnosisEngine(inputAnnieAS, diagnosisAS, fileAraw, fileBann){
	cmdline= "chmod +x ${fileprefix}resources/${diagnosisDir}/diagnose.sh"
	pr =Runtime.getRuntime().exec(cmdline);
	pr.waitFor()

	cmdline = "${fileprefix}resources/${diagnosisDir}/diagnose.sh ${fileAraw} ${fileBann} "
	//println cmdline
	pr =Runtime.getRuntime().exec(cmdline);
	BufferedReader inf = new BufferedReader(new InputStreamReader(pr.getInputStream()));

	def sentences = [:]
	def rules = [:]
	idxS=0
	original=""
	derived=""
	rule=""

	inside=false
	info=""

	content=doc.getContent().toString()
	

	
	
	set1=doc.getAnnotations(inputAnnieAS).get("Sentence")

	while (( line=inf.readLine())!=null){
		if (line.indexOf("###STARTDIAGNOSIS")>=0){
			//start of new sentence info
			inside=true
		} else if (inside && line.indexOf("###STARTSENTENCE")<0){
			//collect html markup
			info=info + line.trim()+"\n"	
		} else if (inside && line.indexOf("###STARTSENTENCE")>=0){	
			//collect original sentence and find its annotation
			line=inf.readLine()
			sentence=line.trim()
			sentT=sentence.replaceAll("</?OBSERVATION[^>]*>","")
			idxS=content.indexOf(sentT)
			if (idxS>=0){	
				sentList=set1.getContained(idxS,idxS+sentT.length())
				sentList.each{s->
					if (doc.stringFor(s).equals(sentT)){
						val="<ul class=\"structure\">${info.trim()}</ul>"
						val=val.replaceAll("<","&lt;").replaceAll(">","&gt;")
						s.getFeatures().put("diagnosis.structure",val)
					}
				}
			}
			info=""
			inside=false
		} else if (line.indexOf("###ENDDIAGNOSIS")>=0){
			info=""
			inside=false
		}
		//print "\ninput: ${line}"
	}
	
	inf.close()
	exitVal = pr.waitFor()
	//println "Exited with error code ${exitVal}"

	sentAS=doc.getAnnotations(diagnosisAS)
	sentList=doc.getAnnotations(inputAnnieAS).get("Sentence")
	sentList.each{s->
		sentAS.add(s.start(),s.end(),"Sentence",s.getFeatures().toFeatureMap())
		//println s.getFeatures()
	}
	
	//println doc.toXml()
	//println doc.getAnnotations("SentenceDetection")
	return
}
