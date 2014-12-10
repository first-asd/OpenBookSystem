/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package es.ua.first.dictionary;

import de.tudarmstadt.ukp.wikipedia.api.DatabaseConfiguration;
import de.tudarmstadt.ukp.wikipedia.api.Page;
import de.tudarmstadt.ukp.wikipedia.api.WikiConstants;
import de.tudarmstadt.ukp.wikipedia.api.WikiConstants.Language;
import de.tudarmstadt.ukp.wikipedia.api.Wikipedia;
import de.tudarmstadt.ukp.wikipedia.api.exception.WikiApiException;
import de.tudarmstadt.ukp.wikipedia.api.exception.WikiInitializationException;
import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;
import javax.xml.parsers.ParserConfigurationException;
import org.w3c.dom.Document;
import org.w3c.dom.Element;
import org.w3c.dom.Text;

/**
 *
 * @author imoreno
 */
public class WiktionaryParser {

    /**
     * The language of this parser.
     */
    private final Language lang;
    /**
     * The Wikipedia API for the wiktionary.
     */
    private Wikipedia wiktionary;

    /**
     * Constructor por defecto
     *
     * @throws DictionaryException
     */
    public WiktionaryParser() throws WikiInitializationException {
        this("localhost", "eswiktionary", "root", "!nTru$0", Language.spanish);
    }

    /**
     * Constructor parametrizado
     *
     * @throws DictionaryException
     */
    public WiktionaryParser(String host, String database, String user, String pwd, WikiConstants.Language lang) throws WikiInitializationException {
        // configure the database connection parameters
        System.out.println("FIRST WSD: En Wiktionary. Parametros: " + database + " " + user + " " + pwd + " " + lang.name());

        DatabaseConfiguration dbConfig = new DatabaseConfiguration();
        dbConfig.setHost(host);
        dbConfig.setDatabase(database);
        dbConfig.setUser(user);
        dbConfig.setPassword(pwd);
        this.lang = lang;
        dbConfig.setLanguage(lang);

        // Create a new Spanish wikipedia.
        System.out.println("FIRST WSD: En Wiktionary. Antes de llamar al constructor");
        wiktionary = new Wikipedia(dbConfig);
        System.out.println("FIRST WSD: En Wiktionary. Después de llamar al constructor. Conexión BD creada");
    }

    /**
     * Process the plain text in wikipedia format and return a XML document with
     * the definitions of a word.
     *
     * @param word The word to obtain the definitions.
     *
     * @return A XML document with the definitions.
     */
    private Document parseSpanish(String word) throws WikiApiException, ParserConfigurationException {
        // Get the wikipedia page from the word
        Page page = getWiktionary().getPage(word);
        //obtenemos el texto plano
        String plaintxt = page.getText();

        // Create the XML document and its root
        DocumentBuilder documentBuilder = DocumentBuilderFactory.newInstance().newDocumentBuilder();
        Document doc = documentBuilder.newDocument();
        Element definitions = doc.createElement("definitions");
        definitions.setAttribute("text", word);
        doc.appendChild(definitions);

        //procesamos el texto plano
        //1. obtenemos la posición del primer ;
        int posicion = plaintxt.indexOf("===");
        String plaindefs = plaintxt.substring(posicion);

        String[] splittedlines = plaindefs.split("\\r?\\n");

        String tipo = "";
        int numdef = 1;
        for (int i = 0; i < splittedlines.length; i++) {
            //si es una definición
            //System.out.println(splittedlines[i]);
            if (splittedlines[i].startsWith(";" + numdef)) {
                Element definition = doc.createElement("definition");
                definition.setAttribute("id", numdef + "");
                definition.setAttribute("type", tipo);
                definitions.appendChild(definition);

                //quitamos el ; e ignoramos las {{ y }} antes de los dos puntos
                int indiceDospuntos = splittedlines[i].indexOf(":");
                String definicion = numdef + splittedlines[i].substring(indiceDospuntos);
                numdef++;
                //quitamos las referencias
                int hayReferencias = definicion.indexOf("<ref");
                if (hayReferencias >= 0) {
                    definicion = definicion.substring(0, hayReferencias);
                }
                //quitamos los subíndices
                int haySubindices = definicion.indexOf("<sub>");
                while (haySubindices >= 0) {
                    int finalSubindice = definicion.indexOf("</sub>", haySubindices);
                    definicion = definicion.substring(0, haySubindices) + definicion.substring(finalSubindice + 6);

                    haySubindices = definicion.indexOf("<sub>");
                }

                //quitamos los comentarios de xml
                int hayComentarios = definicion.indexOf("<!--");
                while (hayComentarios >= 0) {
                    int finalComentario = definicion.indexOf("-->");
                    definicion = definicion.substring(0, hayComentarios) + definicion.substring(finalComentario + 3);
                    hayComentarios = definicion.indexOf("<!--");
                }

                //quitamos los [[ y ]]
                int hayDoblesCorchetes = definicion.indexOf("[[");
                while (hayDoblesCorchetes >= 0) {
                    int finalDoblesCorchetes = definicion.indexOf("]]", hayDoblesCorchetes);
                    int hayBarra = definicion.indexOf("|", hayDoblesCorchetes);

                    if ((finalDoblesCorchetes + 2) > definicion.length()) {
                        finalDoblesCorchetes = definicion.length() - 2;
                    }

                    if (hayBarra >= 0 && hayBarra < finalDoblesCorchetes) {
                        definicion = definicion.substring(0, hayDoblesCorchetes)
                                + definicion.substring(hayBarra + 1, finalDoblesCorchetes)
                                + definicion.substring(finalDoblesCorchetes + 2);
                    } else {
                        definicion = definicion.substring(0, hayDoblesCorchetes)
                                + definicion.substring(hayDoblesCorchetes + 2, finalDoblesCorchetes)
                                + definicion.substring(finalDoblesCorchetes + 2);
                    }

                    hayDoblesCorchetes = definicion.indexOf("[[");
                }

                //quitamos las {{ y }}
                //System.out.println(definicion);
                int hayDoblesLlaves = definicion.indexOf("{{");
                while (hayDoblesLlaves >= 0) {
                    int finalDoblesLlaves = definicion.indexOf("}}", hayDoblesLlaves);
                    int hayBarra = definicion.indexOf("|", hayDoblesLlaves);

                    if ((finalDoblesLlaves + 2) > definicion.length()) {
                        finalDoblesLlaves = definicion.length() - 2;
                    }

                    if (hayBarra >= 0 && hayBarra < finalDoblesLlaves) {
                        definicion = definicion.substring(0, hayDoblesLlaves)
                                + definicion.substring(hayBarra + 1, finalDoblesLlaves)
                                + definicion.substring(finalDoblesLlaves + 2);
                    } else {
                        definicion = definicion.substring(0, hayDoblesLlaves)
                                + definicion.substring(hayDoblesLlaves + 2, finalDoblesLlaves)
                                + definicion.substring(finalDoblesLlaves + 2);
                    }

                    hayDoblesLlaves = definicion.indexOf("{{");
                }

                //quitamos las triples '
                definicion = definicion.replaceAll("'''", "");

                //convertimos los superíndices
                   /*
                 *  ⁰	8304	superscript 0
                 ¹	185	 superscript 1
                 ²	178	 superscript 2
                 ³	179	 superscript 3
                 ⁴	8308	superscript 4
                 ⁵	8309	superscript 5
                 ⁶	8310	superscript 6
                 ⁷	8311	superscript 7
                 ⁸	8312	superscript 8
                 ⁹	8313	superscript 9
                 */
                int haySuperindices = definicion.indexOf("<sup>");
                if (haySuperindices < 0) {
                    definition.setTextContent(definicion);
                } else {
                    int indiceUltimo = 0;
                    while (haySuperindices >= 0) {

                        Text text = doc.createTextNode(definicion.substring(indiceUltimo, haySuperindices));
                        definition.appendChild(text);

                        int finalSuperindice = definicion.indexOf("</sup>", haySuperindices);
                        if ((finalSuperindice + 6) > definicion.length()) {
                            finalSuperindice = definicion.length() - 6;
                        }

                        String superindice = definicion.substring(haySuperindices + 5, finalSuperindice);
                        Element sup = doc.createElement("sup");
                        sup.setTextContent(superindice);
                        definition.appendChild(sup);

                        text = doc.createTextNode(definicion.substring(finalSuperindice + 6));
                        definition.appendChild(text);

                        indiceUltimo = finalSuperindice + 6;
                        haySuperindices = definicion.indexOf("<sup>", finalSuperindice);
                    }
                }

            } else if (splittedlines[i].startsWith("===")) {
                //para obtener la categoría gramatical
                //quitamos los =
                tipo = splittedlines[i].substring(3);
                tipo = tipo.substring(0, tipo.indexOf("="));
                //ignoramos los {{ y }}
                tipo = tipo.replaceAll("\\{\\{", "");
                tipo = tipo.replaceAll("}}", "");
                //ignoramos todo lo que este despues de la |
                int posicionbarra = tipo.indexOf("|");
                if (posicionbarra >= 0) {
                    tipo = tipo.substring(0, tipo.indexOf("|"));
                }
                //System.out.println(tipo);
            }
        }

        return doc;

    }

    private Document parseBulgarian(String word) throws DictionaryException, ParserConfigurationException, WikiApiException {
        // Get the wikipedia page from the word
        Page page = getWiktionary().getPage(word);
        //obtenemos el texto plano
        String plaintxt = page.getText();

        // Create the XML document and its root
        DocumentBuilder documentBuilder = DocumentBuilderFactory.newInstance().newDocumentBuilder();
        Document doc = documentBuilder.newDocument();
        Element definitions = doc.createElement("definitions");
        definitions.setAttribute("text", word);
        doc.appendChild(definitions);
        //procesamos el texto plano
        //Error 6:  There aren't definitons for ${word}
        String[] splittedlines = plaintxt.split("\\r?\\n");

        String tipo = "";

        int numdef = 1;

        for (int i = 0; i < splittedlines.length && !splittedlines[i].startsWith("| РОД"); i++) {
            //si es una definición
            //System.out.println(splittedlines[i]);

            if (splittedlines[i].startsWith("# ''Значението на думата все още не е въведено.")) {
                throw new DictionaryException("Error 6:  There aren't definitons for " + word);
            }

            if (splittedlines[i].startsWith("| ЗНАЧЕНИЕ =")) {
                if (splittedlines[i].length() > "| ЗНАЧЕНИЕ =".length()) {
                    String noMarcado = splittedlines[i].replace("| ЗНАЧЕНИЕ =", "");
                    if (noMarcado.startsWith(" ")) {
                        noMarcado = noMarcado.substring(1);
                    }
                    if (!noMarcado.equals("")) {
                        String[] defsaux = null;
                        if (noMarcado.startsWith("#")) {
                            noMarcado = noMarcado.substring(1);
                            defsaux = noMarcado.split("#");
                            for (String d : defsaux) {
                                Element definition = doc.createElement("definition");
                                definition.setAttribute("id", numdef + "");
                                definition.setAttribute("type", tipo);
                                definitions.appendChild(definition);
                                if (d.startsWith(" ")) {
                                    d = d.substring(1);
                                }
                                //definition.setTextContent(d.substring(1));
                                d = d.replace("#", "");
                                definition.setTextContent(numdef + ". " + d);

                                numdef++;
                            }
                        } else { //en este caso asumo que viene numerado
                            defsaux = noMarcado.split(";");
                            for (String d : defsaux) {
                                Element definition = doc.createElement("definition");
                                definition.setAttribute("id", numdef + "");
                                definition.setAttribute("type", tipo);
                                definitions.appendChild(definition);
                                if (d.startsWith(" ")) {
                                    d = d.substring(1);
                                }
                                //definition.setTextContent(d.substring(1));
                                definition.setTextContent(d);

                                numdef++;
                            }
                        }
                    }
                }
            } else if (splittedlines[i].startsWith("#")) {

                Element definition = doc.createElement("definition");
                definition.setAttribute("id", numdef + "");
                definition.setAttribute("type", tipo);
                definitions.appendChild(definition);

                //quitamos el ; e ignoramos las {{ y }} antes de los dos puntos
                int indiceDospuntos = splittedlines[i].indexOf("#") + 1;
                String definicion = numdef + ".";
                if (splittedlines[i].substring(indiceDospuntos).startsWith(" ")) {
                    definicion += splittedlines[i].substring(indiceDospuntos);
                } else {
                    definicion += " " + splittedlines[i].substring(indiceDospuntos);
                }
                numdef++;
                //quitamos las referencias
                int hayReferencias = definicion.indexOf("<ref");
                if (hayReferencias >= 0) {
                    definicion = definicion.substring(0, hayReferencias);
                }
                //quitamos los subíndices
                int haySubindices = definicion.indexOf("<sub>");
                while (haySubindices >= 0) {
                    int finalSubindice = definicion.indexOf("</sub>", haySubindices);
                    definicion = definicion.substring(0, haySubindices) + definicion.substring(finalSubindice + 6);

                    haySubindices = definicion.indexOf("<sub>");
                }

                //quitamos los comentarios de xml
                int hayComentarios = definicion.indexOf("<!--");
                while (hayComentarios >= 0) {
                    int finalComentario = definicion.indexOf("-->");
                    definicion = definicion.substring(0, hayComentarios) + definicion.substring(finalComentario + 3);
                    hayComentarios = definicion.indexOf("<!--");
                }

                //quitamos los [[ y ]]
                int hayDoblesCorchetes = definicion.indexOf("[[");
                while (hayDoblesCorchetes >= 0) {
                    int finalDoblesCorchetes = definicion.indexOf("]]", hayDoblesCorchetes);
                    int hayBarra = definicion.indexOf("|", hayDoblesCorchetes);

                    if ((finalDoblesCorchetes + 2) > definicion.length()) {
                        finalDoblesCorchetes = definicion.length() - 2;
                    }

                    if (hayBarra >= 0 && hayBarra < finalDoblesCorchetes) {
                        definicion = definicion.substring(0, hayDoblesCorchetes)
                                + definicion.substring(hayBarra + 1, finalDoblesCorchetes)
                                + definicion.substring(finalDoblesCorchetes + 2);
                    } else {
                        definicion = definicion.substring(0, hayDoblesCorchetes)
                                + definicion.substring(hayDoblesCorchetes + 2, finalDoblesCorchetes)
                                + definicion.substring(finalDoblesCorchetes + 2);
                    }

                    hayDoblesCorchetes = definicion.indexOf("[[");
                }

                //quitamos las {{ y }}
                //System.out.println(definicion);
                int hayDoblesLlaves = definicion.indexOf("{{");
                while (hayDoblesLlaves >= 0) {
                    int finalDoblesLlaves = definicion.indexOf("}}", hayDoblesLlaves);
                    int hayBarra = definicion.indexOf("|", hayDoblesLlaves);

                    if ((finalDoblesLlaves + 2) > definicion.length()) {
                        finalDoblesLlaves = definicion.length() - 2;
                    }

                    if (hayBarra >= 0 && hayBarra < finalDoblesLlaves) {
                        definicion = definicion.substring(0, hayDoblesLlaves)
                                + definicion.substring(hayBarra + 1, finalDoblesLlaves)
                                + definicion.substring(finalDoblesLlaves + 2);
                    } else {
                        definicion = definicion.substring(0, hayDoblesLlaves)
                                + definicion.substring(hayDoblesLlaves + 2, finalDoblesLlaves)
                                + definicion.substring(finalDoblesLlaves + 2);
                    }

                    hayDoblesLlaves = definicion.indexOf("{{");
                }

                //quitamos las triples '
                definicion = definicion.replaceAll("'''", "");

                //convertimos los superíndices
                   /*
                 *  ⁰	8304	superscript 0
                 ¹	185	 superscript 1
                 ²	178	 superscript 2
                 ³	179	 superscript 3
                 ⁴	8308	superscript 4
                 ⁵	8309	superscript 5
                 ⁶	8310	superscript 6
                 ⁷	8311	superscript 7
                 ⁸	8312	superscript 8
                 ⁹	8313	superscript 9
                 */
                int haySuperindices = definicion.indexOf("<sup>");
                if (haySuperindices < 0) {
                    definition.setTextContent(definicion);
                } else {
                    int indiceUltimo = 0;
                    while (haySuperindices >= 0) {

                        Text text = doc.createTextNode(definicion.substring(indiceUltimo, haySuperindices));
                        definition.appendChild(text);

                        int finalSuperindice = definicion.indexOf("</sup>", haySuperindices);
                        if ((finalSuperindice + 6) > definicion.length()) {
                            finalSuperindice = definicion.length() - 6;
                        }

                        String superindice = definicion.substring(haySuperindices + 5, finalSuperindice);
                        Element sup = doc.createElement("sup");
                        sup.setTextContent(superindice);
                        definition.appendChild(sup);

                        text = doc.createTextNode(definicion.substring(finalSuperindice + 6));
                        definition.appendChild(text);

                        indiceUltimo = finalSuperindice + 6;
                        haySuperindices = definicion.indexOf("<sup>", finalSuperindice);
                    }
                }

            } else {
                if (splittedlines[i].startsWith("{{")) {
                    tipo = splittedlines[i].substring(2);

                    if (splittedlines[i].indexOf("|") != -1) {

                        //ignoramos todo lo que este despues de la |
                        int posicionbarra = tipo.indexOf("|");
                        if (posicionbarra >= 0) {
                            tipo = tipo.substring(0, tipo.indexOf("|"));
                        }
                    }
                    //System.out.println(tipo);

                }
            }
        }

        return doc;
    }

    private Document parseEnglish(String word) throws DictionaryException, WikiApiException, ParserConfigurationException {
        // Get the wikipedia page from the word
        Page page = getWiktionary().getPage(word);
        //obtenemos el texto plano
        String plaintxt = page.getText();

        // Create the XML document and its root
        DocumentBuilder documentBuilder = DocumentBuilderFactory.newInstance().newDocumentBuilder();
        Document doc = documentBuilder.newDocument();
        Element definitions = doc.createElement("definitions");
        definitions.setAttribute("text", word);
        doc.appendChild(definitions);

        //procesamos el texto plano
        String pos = "===";
        //1. obtenemos la posición del primer ;
        int posicion = plaintxt.indexOf(pos);

            //int posicionfinal = plaintxt.indexOf(pos, posicion+4);
        //para el caso en el que los tipos de palabras estén en el tercer nivel y no en el segundo
        if (plaintxt.contains("===Etymology ")) {
            pos = "====";
            posicion = plaintxt.indexOf(pos);
        }

        if (posicion == -1) {
            throw new DictionaryException("Error 6:  There aren't definitons for " + word);
        }
        String plaindefs = plaintxt.substring(posicion);

        String[] splittedlines = plaindefs.split("\\r?\\n");
        String tipo = "";
        int numdef = 1;
        for (int i = 0; i < splittedlines.length && !splittedlines[i].equals("----"); i++) {
            //si es una definición

            if (splittedlines[i].startsWith("# ")) {
                Element definition = doc.createElement("definition");
                definition.setAttribute("id", numdef + "");
                definition.setAttribute("type", tipo);
                definitions.appendChild(definition);

                //quitamos el # 
                String definicion = numdef + ":" + splittedlines[i].substring(1);
                numdef++;
                //quitamos las referencias
                int hayReferencias = definicion.indexOf("<ref");
                if (hayReferencias >= 0) {
                    definicion = definicion.substring(0, hayReferencias);
                }
                //quitamos los subíndices
                int haySubindices = definicion.indexOf("<sub>");
                while (haySubindices >= 0) {
                    int finalSubindice = definicion.indexOf("</sub>", haySubindices);
                    definicion = definicion.substring(0, haySubindices) + definicion.substring(finalSubindice + 6);

                    haySubindices = definicion.indexOf("<sub>");
                }

                //quitamos los comentarios de xml
                int hayComentarios = definicion.indexOf("<!--");
                while (hayComentarios >= 0) {
                    int finalComentario = definicion.indexOf("-->");
                    definicion = definicion.substring(0, hayComentarios) + definicion.substring(finalComentario + 3);
                    hayComentarios = definicion.indexOf("<!--");
                }

                //quitamos los [[ y ]]
                int hayDoblesCorchetes = definicion.indexOf("[[");
                while (hayDoblesCorchetes >= 0) {
                    int finalDoblesCorchetes = definicion.indexOf("]]", hayDoblesCorchetes);
                    int hayBarra = definicion.indexOf("|", hayDoblesCorchetes);

                    if ((finalDoblesCorchetes + 2) > definicion.length()) {
                        finalDoblesCorchetes = definicion.length() - 2;
                    }

                    if (hayBarra >= 0 && hayBarra < finalDoblesCorchetes) {
                        definicion = definicion.substring(0, hayDoblesCorchetes)
                                + definicion.substring(hayBarra + 1, finalDoblesCorchetes)
                                + definicion.substring(finalDoblesCorchetes + 2);
                    } else {
                        definicion = definicion.substring(0, hayDoblesCorchetes)
                                + definicion.substring(hayDoblesCorchetes + 2, finalDoblesCorchetes)
                                + definicion.substring(finalDoblesCorchetes + 2);
                    }

                    hayDoblesCorchetes = definicion.indexOf("[[");
                }

                    //quitamos las {{ y }}
                //System.out.println(definicion);
                if (definicion.contains(": {{")) {
                    int _inicio = definicion.indexOf("{{");
                    int _final = definicion.indexOf("}}");
                    if (definicion.indexOf("}}{{") != -1) { //tenemos que sustituir, al menos dos veces las llaves

                        String aux = definicion.substring(_inicio, _final + 2);
                        aux = aux.replace("|", ", ");
                        aux = aux.replace("{{", "(");
                        aux = aux.replace("}}", ")");
                        definicion = definicion.substring(0, _inicio) + aux + definicion.substring(_final + 2);

                        _inicio = definicion.indexOf("{{");
                        _final = definicion.indexOf("}}");

                    }
                    String aux = definicion.substring(_inicio, _final + 2);
                    aux = aux.replace("|", ", ");
                    aux = aux.replace("{{", "(");
                    aux = aux.replace("}}", ")");
                    definicion = definicion.substring(0, _inicio) + aux + definicion.substring(_final + 2);

                }

                int hayDoblesLlaves = definicion.indexOf("{{");
                while (hayDoblesLlaves >= 0) {
                    int finalDoblesLlaves = definicion.indexOf("}}", hayDoblesLlaves);
                    int hayBarra = definicion.indexOf("|", hayDoblesLlaves);

                    if ((finalDoblesLlaves + 2) > definicion.length()) {
                        finalDoblesLlaves = definicion.length() - 2;
                    }

                    if (hayBarra >= 0 && hayBarra < finalDoblesLlaves) {
                        definicion = definicion.substring(0, hayDoblesLlaves)
                                + definicion.substring(hayBarra + 1, finalDoblesLlaves)
                                + definicion.substring(finalDoblesLlaves + 2);
                    } else {
                        definicion = definicion.substring(0, hayDoblesLlaves)
                                + definicion.substring(hayDoblesLlaves + 2, finalDoblesLlaves)
                                + definicion.substring(finalDoblesLlaves + 2);
                    }

                    hayDoblesLlaves = definicion.indexOf("{{");
                }

                //quitamos las triples '
                definicion = definicion.replaceAll("'''", "");

                    //convertimos los superíndices
                   /*
                 *  ⁰	8304	superscript 0
                 ¹	185	 superscript 1
                 ²	178	 superscript 2
                 ³	179	 superscript 3
                 ⁴	8308	superscript 4
                 ⁵	8309	superscript 5
                 ⁶	8310	superscript 6
                 ⁷	8311	superscript 7
                 ⁸	8312	superscript 8
                 ⁹	8313	superscript 9
                 */
                int haySuperindices = definicion.indexOf("<sup>");
                if (haySuperindices < 0) {
                    definition.setTextContent(definicion);
                } else {
                    int indiceUltimo = 0;
                    while (haySuperindices >= 0) {

                        Text text = doc.createTextNode(definicion.substring(indiceUltimo, haySuperindices));
                        definition.appendChild(text);

                        int finalSuperindice = definicion.indexOf("</sup>", haySuperindices);
                        if ((finalSuperindice + 6) > definicion.length()) {
                            finalSuperindice = definicion.length() - 6;
                        }

                        String superindice = definicion.substring(haySuperindices + 5, finalSuperindice);
                        Element sup = doc.createElement("sup");
                        sup.setTextContent(superindice);
                        definition.appendChild(sup);

                        text = doc.createTextNode(definicion.substring(finalSuperindice + 6));
                        definition.appendChild(text);

                        indiceUltimo = finalSuperindice + 6;
                        haySuperindices = definicion.indexOf("<sup>", finalSuperindice);
                    }
                }

            } else {

                if (splittedlines[i].startsWith(pos)) {
                        //para obtener la categoría gramatical
                    //quitamos los =
                    tipo = splittedlines[i].substring(pos.length());
                    tipo = tipo.substring(0, tipo.indexOf("="));
                    tipo = tipo.replaceAll("\\{", "");
                    tipo = tipo.replaceAll("}", "");
                    //System.out.println(tipo);
                }

            }
        }

        return doc;

    }

    public Document getDefinitions(String word) throws DictionaryException, WikiApiException, ParserConfigurationException {

        //TO-DO: tener en cuenta si es una página de desambiguación... qué hacemos en ese caso.
        if (lang.equals(WikiConstants.Language.spanish)) {
            return parseSpanish(word);
        }
        if (lang.equals(WikiConstants.Language.english)) {
            return parseEnglish(word);
        }
        if (lang.equals(WikiConstants.Language.bulgarian)) {
            return parseBulgarian(word);
        }
        //no debería llegar aquí
        throw new DictionaryException("Language '" + lang + "'not supported.");
    }

    /**
     * @return the wiktionary
     */
    public Wikipedia getWiktionary() {
        return wiktionary;
    }
}
