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


## Licence (see also LICENCE.txt)

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.

## Contact information

If you need any information of this service you can write to:

* L. Alfonso Ureña López: laurena@ujaen.es
* M. Teresa Martín Valdivia: maite@ujaen.es
* Eduard Barbu: ebarbu@ujaen.es
* Eugenio Martínez Cámara: emcamara@ujaen.es