**************************************************************************
**************************************************************************
# Concept-Images Replacement Services
**************************************************************************
**************************************************************************

## Description

Concept-Images Replacement encompasses two web services:

* Offline Image Retrieval
* Online Image Retrieval


### Offline Image Retrieval

Offline Image Retrieval is a service that takes as input a text (gate 
document format) with several words, terms or concepts labelled as rare, 
seeks those concepts is a knowledge based of images 
( [image-net](http://www.image-net.org/ “image-net home page”) ), and, 
when the disambiguated word is not found in image-net, the word is 
disambiguated against Wikipedia with the aim of taking the image from Wikipedia.

Online Image Retrieval is a service that takes as input a word, and 
them seeks the corresponding image for that word in Google Images and 
Bing images.

### Resources

For a right execution the software needs the image-net database.


## Dependencies

Both, Offline Image Retrieval and Online Image Retrieval are Maven projects. 
As all Maven projects, in the root folder is the pom.xml with all the 
dependencies of the software. All the dependencies are libraries:

* Gate: gate-core 7.0
* Java Servlet: servlet-api 2.5
* Axis2: axis2-transport-local 1.6.2
* JDOM: jdom2 0.5
* JSON: json-simple 1.1
* JAXB: jaxb-impl 2.2

## Contact information

If you need any information of this service you can write to:

* L. Alfonso Ureña López: laurena@ujaen.es
* M. Teresa Martín Valdivia: maite@ujaen.es
* Eduard Barbu: ebarbu@ujaen.es
* Eugenio Martínez Cámara: emcamara@ujaen.es
