**************************************************************************
**************************************************************************
# Summarizer
**************************************************************************
**************************************************************************

## Description 


The summarizer is a service that compress a text, in plain English, 
summarizer generate a summary of a text. The sumarizer developed by the 
University of Jaén for OpenBook System follows the approach knows as 
summarizer by sentence. This kind of summarizer selects the most 
representative sentences of a text. For that purpose, the method assign a 
score to each sentence that measures the relevance of each sentence. 
The scores is a combination of the score calculated of a tailored version 
of PageRank, and an heuristic based on the position of the sentences.


## Dependencies

Summarizer is a Maven projects. As all Maven projects, in the root folder is
the pom.xml with all the dependencies of the software. All the dependencies
are libraries:

* Gate: gate-core 7.0
* Java Servlet: servlet-api 2.5
* Axis2: axis2-transport-local 1.6.2
* JDOM: jdom2 0.5
* JSON: json-simple 1.1
* JAXB: jaxb-impl 2.2
* JGRAPHT: jgrapht 0.7.3
* Commons Lang: commons-lang3 3.1


## Contact information

If you need any information of this service you can write to:

* L. Alfonso Ureña López: laurena@ujaen.es
* M. Teresa Martín Valdivia: maite@ujaen.es
* Eduard Barbu: ebarbu@ujaen.es
* Eugenio Martínez Cámara: emcamara@ujaen.es