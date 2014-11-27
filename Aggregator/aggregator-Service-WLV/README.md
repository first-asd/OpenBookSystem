**************************************************************************
**************************************************************************
# Aggregator Service
**************************************************************************
**************************************************************************


The Aggregator web service is the main web service of the back-end of 
OpenBook System, because it has the responsibility of the take the input
of the user, calls each of the Natural Language Processing (NLP) Services,
takes the output of all of them and builds the output in XML format of the 
system.

The aggergator-Service-WLV stores a Maven project with the code of the 
Aggregator. As all Maven project, in the root folder is the pom.xml with all 
the dependencies of the software. The dependencies can be divided in 
libraries and clients of the web services of OpenBook System.

* Libraries:
..* Gate: gate-core 7.0
..* Java Servlet: servlet-api 2.5
..* Axis2: axis2-transport-local 1.6.2
..* XMLBeans: xmlbeans 2.4
..* JSON: json-simple 1.1
* Clientes:
..* Summarizer: summarizer-ujuw-production 0.1
..* Sintactic simpliciation: SyntacticSimplification-ujuw-production 0.1,
..* SyntacticSimplification-UA-production 0.1
..* Essential processing: EssentialProcessing-production 0.1
..* Correference: CoreferenceBulgarian-production 0.1, 
..* CoreferenceEnglish-production 0.1, CoreferenceSpanish-production 0.1
..* Disambiguation: Disambiguation-production 0.1
..* Sintax: Syntax-UW-development 0.1
..* Acronyms: Acronyms-UA-production 0.1
..* Multiwords: MultiWordDetection-UA-development 0.1
..* Keywords: Keywords-UA-development 0.1