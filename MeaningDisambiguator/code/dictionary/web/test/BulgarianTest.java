/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */

import de.tudarmstadt.ukp.wikipedia.api.WikiConstants;
import de.tudarmstadt.ukp.wikipedia.api.exception.WikiApiException;
import es.ua.first.dictionary.DictionaryException;
import es.ua.first.dictionary.WiktionaryParser;
import es.upv.xmlutils.XMLUtils;
import java.io.IOException;
import javax.xml.parsers.ParserConfigurationException;
import org.junit.*;
import org.w3c.dom.Document;
import org.w3c.dom.Element;
import org.w3c.dom.NodeList;
import org.xml.sax.SAXException;

/**
 *
 * @author imoreno
 */
public class BulgarianTest {
    private static WiktionaryParser bgwiktionary;
    
    public BulgarianTest() {
    }

    @BeforeClass
    public static void setUpClass() throws Exception {
        
        bgwiktionary =  new WiktionaryParser("localhost", "bgwiktionary", "root", "!nTru$0", WikiConstants.Language.valueOf("bulgarian"));
    }

    @AfterClass
    public static void tearDownClass() throws Exception {
    }
    
    @Before
    public void setUp() {
    }
    
    @After
    public void tearDown() {
    }
    // TODO add test methods here.
    // The methods must be annotated with annotation @Test. For example:
    //
    @Test
    public void test1() throws DictionaryException, IOException, ParserConfigurationException, SAXException, WikiApiException {
        Document doc = bgwiktionary.getDefinitions("къща");
        Element documentElement = doc.getDocumentElement();
        NodeList elementsNamed = XMLUtils.getElementsNamed(documentElement, "definition");
        
        Assert.assertEquals(1, elementsNamed.getLength());
         
        Element def = (Element) elementsNamed.item(0);
        Assert.assertEquals("Съществително нарицателно име", def.getAttribute("type"));
        
        String esperada = "1. Невисока сграда предназначена за живеене на хора.";
        Assert.assertEquals(esperada, def.getTextContent());
        
    }
    
    @Test
    public void test2() throws DictionaryException, IOException, ParserConfigurationException, SAXException, WikiApiException {
        Document doc = bgwiktionary.getDefinitions("червен");
        Element documentElement = doc.getDocumentElement();
        NodeList elementsNamed = XMLUtils.getElementsNamed(documentElement, "definition");
        
        if(elementsNamed.getLength()!=2)
            Assert.fail("Debería contener sólo dos definiciones");
        
        Element def = (Element) elementsNamed.item(0);
        Assert.assertEquals(def.getAttribute("type"),"Прилагателно име");
            
        String esperada = "1. имащ цвят на кръв; имащ електромагнитно излъчване с честота ~ 430–480 THz";
        Assert.assertEquals(esperada, def.getTextContent());
        
        def = (Element) elementsNamed.item(1);
        Assert.assertEquals(def.getAttribute("type"),"Прилагателно име");
       
        String esperada2 = "2. комунистически ";
        Assert.assertEquals(esperada2, def.getTextContent());
        
    }
    
    @Test
    public void test3() throws DictionaryException, IOException, ParserConfigurationException, SAXException, WikiApiException {
        Document doc = bgwiktionary.getDefinitions("дърво");
        Element documentElement = doc.getDocumentElement();
        NodeList elementsNamed = XMLUtils.getElementsNamed(documentElement, "definition");
        
        if(elementsNamed.getLength()!=2)
            Assert.fail("Debería contener sólo dos definiciones");
        
        Element def = (Element) elementsNamed.item(0);
        Assert.assertEquals(def.getAttribute("type"),"Съществително нарицателно име");
            
        String esperada = "1. Обощение на големите растителни видове";
        Assert.assertEquals(esperada, def.getTextContent());
        
        def = (Element) elementsNamed.item(1);
        Assert.assertEquals(def.getAttribute("type"),"Съществително нарицателно име");
       
        String esperada2 = "2. първа съставна част на сложни думи: -виден, -делец, - делски, - делство, -добив, -добивен, - обработване, -обработвателен, -подобен, - рез, - резба, - резбар, -резбарство, секач, -точина Богоров 1869, -ядец Богоров 1869";
        Assert.assertEquals(esperada2, def.getTextContent());
        
    }
    
    @Test
    public void test4() throws DictionaryException, IOException, ParserConfigurationException, SAXException, WikiApiException {
        Document doc = bgwiktionary.getDefinitions("мъж");
        Element documentElement = doc.getDocumentElement();
        NodeList elementsNamed = XMLUtils.getElementsNamed(documentElement, "definition");
        
        Assert.assertEquals(4, elementsNamed.getLength());
                
        Element def = (Element) elementsNamed.item(0);
        Assert.assertEquals("Съществително нарицателно име",def.getAttribute("type"));
   
        String esperada = "1. Човек от мъжки пол.";
        Assert.assertEquals(esperada, def.getTextContent());
        
        def = (Element) elementsNamed.item(1);
        Assert.assertEquals("Съществително нарицателно име",def.getAttribute("type"));
   
        String esperada2 = "2. Човек от мъжки пол в зряла възраст.";
        Assert.assertEquals(esperada2, def.getTextContent());
        
        def = (Element) elementsNamed.item(2);
        Assert.assertEquals("Съществително нарицателно име",def.getAttribute("type"));
   
        String esperada3= "3. Деец от някакво обществено поприще. ";
        Assert.assertEquals(esperada3, def.getTextContent());
        
        def = (Element) elementsNamed.item(3);
        Assert.assertEquals("Съществително нарицателно име",def.getAttribute("type"));
   
        String esperada4= "4. Съпруг.";
        Assert.assertEquals(esperada4, def.getTextContent());
        

        
    }
    
    
    @Test
    public void test5() throws DictionaryException, IOException, ParserConfigurationException, SAXException, WikiApiException {
        Document doc = bgwiktionary.getDefinitions("играя");
        Element documentElement = doc.getDocumentElement();
        NodeList elementsNamed = XMLUtils.getElementsNamed(documentElement, "definition");
        
        Assert.assertEquals(1, elementsNamed.getLength());
                
        Element def = (Element) elementsNamed.item(0);
        Assert.assertEquals("Глагол",def.getAttribute("type"));
   
        String esperada = "1. ''Извършване на забавно действие. ";
        Assert.assertEquals(esperada, def.getTextContent());
        
    }
    
    @Test
    public void test6() throws DictionaryException, IOException, ParserConfigurationException, SAXException, WikiApiException {
        Document doc = bgwiktionary.getDefinitions("търся");
        Element documentElement = doc.getDocumentElement();
        NodeList elementsNamed = XMLUtils.getElementsNamed(documentElement, "definition");
        
        Assert.assertEquals(2, elementsNamed.getLength());
                
        Element def = (Element) elementsNamed.item(0);
        Assert.assertEquals("Глагол",def.getAttribute("type"));
   
        String esperada = "1. опитвам се да намеря, полагам усилия (психически или и физически) да установя местонахождението на някого или нещо; издирвам, диря; и в невеществен смисъл: ''Търся си работа.''";
        Assert.assertEquals(esperada, def.getTextContent());
        
        def = (Element) elementsNamed.item(1);
        Assert.assertEquals("Глагол",def.getAttribute("type"));
   
        String esperada2 = "2. ''(по-рядко)'' искам, претендирам. ''Лице, срещу което се търси обезпечение.''";
        Assert.assertEquals(esperada2, def.getTextContent());
        
    }
    
    @Test
    public void test7() throws DictionaryException, IOException, ParserConfigurationException, SAXException, WikiApiException {
        Document doc = bgwiktionary.getDefinitions("красив");
        Element documentElement = doc.getDocumentElement();
        NodeList elementsNamed = XMLUtils.getElementsNamed(documentElement, "definition");
        
        Assert.assertEquals(1, elementsNamed.getLength());
                
        Element def = (Element) elementsNamed.item(0);
        Assert.assertEquals("Прилагателно име",def.getAttribute("type"));
   
        String esperada = "1. Човек, същество, предмет дело на човешка дейност или природна забележителност, което доставя естетическа наслада.";
        Assert.assertEquals(esperada, def.getTextContent());
        
    }
    
    @Test
    public void test8() throws DictionaryException, IOException, ParserConfigurationException, SAXException, WikiApiException {
        Document doc = bgwiktionary.getDefinitions("място");
        Element documentElement = doc.getDocumentElement();
        NodeList elementsNamed = XMLUtils.getElementsNamed(documentElement, "definition");
        
        Assert.assertEquals(1, elementsNamed.getLength());
                
        Element def = (Element) elementsNamed.item(0);
        Assert.assertEquals("Съществително нарицателно име",def.getAttribute("type"));
   
        String esperada = "1. ''Място:[м.p.]Обозначава местоположение, точка на стоене. Пример: " + '"' + "Вчера бях на едно красиво място" +'"' +" или "+ '"' + "Това място е опасно" +'"' + ". .''";
        Assert.assertEquals(esperada, def.getTextContent());
        
    }
    
     @Test
    public void test9() throws DictionaryException, IOException, ParserConfigurationException, SAXException, WikiApiException {
        Document doc = bgwiktionary.getDefinitions("отивам");
        Element documentElement = doc.getDocumentElement();
        NodeList elementsNamed = XMLUtils.getElementsNamed(documentElement, "definition");
        
        Assert.assertEquals(2, elementsNamed.getLength());
                
        Element def = (Element) elementsNamed.item(0);
        Assert.assertEquals("Глагол",def.getAttribute("type"));
   
        String esperada = "1. придвижвам се до място, различно от положението на говорещия (обр: идвам, ела, да дойда). ''Отевам на гости, на море. Отиваш при родителите си.''";
        Assert.assertEquals(esperada, def.getTextContent());
        
        def = (Element) elementsNamed.item(1);
        Assert.assertEquals("Глагол",def.getAttribute("type"));
   
        String esperada2 = "2. ''(прен.)'' придвижвам се. ''Отиди с мишката на иконата'' – приплъзни периферното устройство, така че курсорът да се премести до изображението препратка. ''Това отива в пети раздел'' – (напр.) този абзац ще преместим в друга част на произведението.";
        Assert.assertEquals(esperada2, def.getTextContent());
    }
     
    @Test
    public void test10() throws WikiApiException, ParserConfigurationException {
        try {
            Document definitions = bgwiktionary.getDefinitions("бързо");
            Assert.fail();
        } catch (DictionaryException ex) {
            Assert.assertEquals("Error 6:  There aren't definitons for бързо", ex.getMessage());
        }
         
    }
    
    @Test
    public void test11() throws WikiApiException, ParserConfigurationException {
        try {
            Document definitions = bgwiktionary.getDefinitions("малък");
            Assert.fail();
        } catch (DictionaryException ex) {
            Assert.assertEquals("Error 6:  There aren't definitons for малък", ex.getMessage());
        }
         
    }
     
}
