package es.ua.first.coreference;

/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */


import javax.servlet.ServletContext;
import static org.junit.Assert.assertEquals;
import static org.junit.Assert.fail;
import org.junit.*;

/**
 *
 * @author imoreno
 */
public class AnaphoraResolutionServiceTest {
    private static AnaphoraResolutionUtils resolver;
    
    public AnaphoraResolutionServiceTest() {
    }
    
    
    @BeforeClass
    public static void setUpClass() throws Exception {
        
        resolver = new AnaphoraResolutionUtils();/*no sé si es necesario*/
        resolver.initialize(System.getProperty("user.dir")+"/");
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

    private String resolution(String text, String lang) throws AnaphoraResolutionException{
         if(lang.equals("es")){
            String nText = AnaphoraResolutionUtils.resolveAnaphors(text, System.getProperty("user.dir")+"/");
            return nText;
        } else {
            AnaphoraResolutionException ex =  new AnaphoraResolutionException("Error 1: Language not supported.");
            throw ex;
        }
    }
    
    @Test
    public void pruebaDelfines() throws AnaphoraResolutionException{
        //es.ua.coreference.client.AnaphoraResolution service = new es.ua.coreference.client.AnaphoraResolution();
        //es.ua.coreference.client.AnaphoraResolutionService port = service.getAnaphoraResolutionServicePort();
        
        System.out.println("Test 0: pronominalAnaphoraResolution for wikipedia article");
        StringBuilder sb = new StringBuilder();
        
        sb.append("<?xml version='1.0' encoding='UTF-8'?>\n<GateDocument>\n<!-- The document's features-->\n");
        sb.append("<GateDocumentFeatures>\n<Feature>\n");
        sb.append("<Name className='java.lang.String'> MimeType</Name>\n");
        sb.append("<Value className='java.lang.String'> text/xml</Value>\n");
        sb.append("</Feature>\n</GateDocumentFeatures>");
        sb.append("<!-- The document content area with serialized nodes -->\n");
        sb.append("<TextWithNodes xml:space='preserve'>");
//        sb.append("Los delfínidos (Delphinidae), llamados normalmente delfines oceánicos (a diferencia de los platanistoideos o delfines de río) son una familia de cetáceos odontocetos bastante heterogénea, que alberga unas 34 especies.\n");
//        sb.append("Miden entre 2 y 9 metros de largo, con el cuerpo fusiforme y la cabeza grande, el hocico alargado y un solo espiráculo en la parte superior de la cabeza (orificio respiratorio que muchos animales marinos tienen como contacto del aire o agua con su sistema respiratorio interno). Son carnívoros estrictos.\n");
//        sb.append("Están entre las especies más inteligentes que habitan el planeta. Se encuentran relativamente cerca de las costas y a menudo interactúan con el ser humano.\n");
//        sb.append("Como otros cetáceos, los delfines utilizan los sonidos, la danza y el salto para comunicarse, orientarse y alcanzar sus presas; además utilizan la ecolocalización. Hoy en día, las principales amenazas a las que están expuestos son de naturaleza antrópica.\n");
        //francio
        //sb.append("El francio, antiguamente conocido como eka-cesio y actinio K, es un elemento químico cuyo símbolo es Fr y su número atómico es 87. Su electronegatividad es la más baja conocida y es el segundo elemento menos abundante en la naturaleza (el primero es el astato). El francio es un metal alcalino altamente radiactivo y reactivo que se desintegra generando astato, radio y radón. Como el resto de metales alcalinos, sólo posee un electrón en su capa de valencia. Marguerite Perey descubrió este elemento en 1939. En 1962, ella fue la primera mujer en ser elegida para la Academia de Ciencias Francesa. El químico ruso D. K. Dobroserdov fue el primer científico que aseguró haber descubierto eka-cesio. En 1925, él observó una débil radiactividad en una muestra de potasio, otro metal alcalino, y él concluyó que el eka-cesio contaminaba la muestra. Él también publicó una tesis sobre sus predicciones de las propiedades del eka-cesio, en la que nombraba al elemento con el nombre de russio, en honor a su país de procedencia. Poco tiempo después, Dobroserdov empezó a centrarse en su carrera docente en el Instituto Politécnico de Odessa, abandonando por completo sus esfuerzos por aislar el eka-cesio.");
        
        //sb.append("El químico ruso D. K. Dobroserdov fue el primer científico que aseguró haber descubierto eka-cesio. En 1925, él observó una débil radiactividad en una muestra de potasio, otro metal alcalino, y él concluyó que el eka-cesio contaminaba la muestra. Él también publicó una tesis sobre sus predicciones de las propiedades del eka-cesio, en la que nombraba al elemento con el nombre de russio, en honor a su país de procedencia. Poco tiempo después, Dobroserdov empezó a centrarse en su carrera docente en el Instituto Politécnico de Odessa, abandonando por completo sus esfuerzos por aislar el eka-cesio.");
        
        //rajoy
//        sb.append("Para Soraya Rodríguez, todo eso muestra una actitud “dictatorial” y de falta de respeto al Parlamento. Ella es una abogada y política española, y actualmente ella es portavoz del PSOE en el Congreso de los Diputados. El PSOE ha presentado un escrito al presidente del Congreso, Jesús Posada, pidiéndole que cambie la hora o la fecha de la sesión de control de la próxima semana para que Rajoy pueda estar presente. Él ha convocado la Junta para mañana jueves a las cinco de la tarde. Rodríguez, además, ha rechazado la posibilidad de que se modifique la ley para restringir el derecho de manifestación.");
//        sb.append("El presidente del Gobierno, Mariano Rajoy, estará más de un mes sin pisar el Congreso, según ha comunicado el Ejecutivo al presidente de la Cámara. La pasada semana no hubo sesión de control por el viaje de Rajoy a Nueva York, esta no hay pleno y para la siguiente La Moncloa ha comunicado que no estarán nueve miembros del Gobierno, entre ellos el presidente, por la celebración de una cumbre hispano-francesa. La siguiente no habrá pleno por las elecciones vascas y gallegas. Después del 21-O será el debate de totalidad de los Presupuestos, por lo que, en principio, Rajoy no irá a una sesión de control en el Congreso hasta el miércoles 31 de octubre. Ese calendario se suma a los bloqueos de la mayoría absoluta del PP que ha impedido sistemáticamente que se tramiten en la Mesa y la Junta de Portavoces las peticiones de todos los grupos para que Rajoy acuda al pleno a hablar de la crisis económica o, en su momento, de la petición de rescate para el sistema financiero español. Tampoco ha habido este año debate sobre el estado de la nación, por deseo del presidente del Gobierno. Para Soraya Rodríguez, todo eso muestra una actitud “dictatorial” y de falta de respeto al Parlamento. Ella es una abogada y política española, y actualmente ella es portavoz del PSOE en el Congreso de los Diputados. El PSOE ha presentado un escrito al presidente del Congreso, Jesús Posada, pidiéndole que cambie la hora o la fecha de la sesión de control de la próxima semana para que Rajoy pueda estar presente. Él ha convocado la Junta para mañana jueves a las cinco de la tarde. Rodríguez, además, ha rechazado la posibilidad de que se modifique la ley para restringir el derecho de manifestación.");
//        sb.append("El hallazgo de una rana toro en el delta del Ebro, una de las 100 especies invasoras más agresivas del mundo, ha encendido de nuevo las alarmas en esta zona, que ya se encuentra afectada por la plaga del caracol manzana. El ejemplar fue localizado hace cuatro semanas por un agricultor de Deltebre en un huerto cercano al núcleo urbano; inmediatamente lo llevó a las oficinas del parque, donde, tras certificar que era una rana toro, fue sacrificada y congelada. Al parecer, era una mascota exótica abandonada en el campo, un hecho cada día menos extraño, pero que puede causar auténticos estragos.");
//        sb.append('"');
//        sb.append("Es un anfibio que puede llegar al kilo de peso. Está considerada una de las especies más invasoras del mundo y puede provocar daños importantes en la flora y fauna autóctonas");
//        sb.append('"');
//        sb.append(", reconoce el director del parque natural, Francesc Vidal, quien, después de varias prospecciones, considera que era ");
//        sb.append('"');
//        sb.append("un ejemplar aislado");
//        sb.append('"');
//        sb.append('.');
        
//        sb.append("Así se ha expresado Feijóo en un desayuno informativo en el que ha sido presentado por el presidente del Gobierno, Mariano Rajoy.");
//        sb.append("Decía Douglas Adams en su impagable Guía del autoestopista galáctico que volar era un arte fácil, que solo requería una habilidad: aprender a arrojarse contra el suelo… y fallar. El domingo, Félix Baumgartner consiguió aplicar esa receta al menos durante 10 interminables minutos. Voló mucho más alto y más rápido que cualquier avión comercial, protegido solo por un traje a presión similar al de un astronauta. Con ello consiguió batir dos de las tres marcas que se había propuesto: salto desde máxima altura y máxima velocidad de caída; el tercero (máximo tiempo en caída libre) no pudo ser y sigue en poder de Joseph Kittinger, quien lo estableció allá por el año 1960.");
//        sb.append("\n");
//        sb.append("Pese a las muchas precauciones adoptadas, el salto revestía serio peligro. A todos los efectos, cuando Baumgartner abrió la puerta de su cápsula estaba en Marte: presión inferior a una centésima de atmósfera. Temperatura de 20 grados bajo cero. Y una intensa radiación ultravioleta del Sol, ya que buena parte de la protectora capa de ozono quedaba ya por debajo de sus pies.");
//        sb.append("\n");
//        sb.append("Durante unos segundos, el austriaco cayó sin control.");
//        sb.append("\n");
//        sb.append("Su única protección era la escafandra, similar a las que utilizan los astronautas en sus paseos espaciales o los pilotos de aviones de gran altitud como el U-2 o el SR-71. El visor, muy tintado, le protegía no solo del ultravioleta, sino también del rozamiento del aire.");
//        sb.append("\n");
//        sb.append("En el vacío virtual de la alta atmósfera, sin apenas aire que frenase su caída, Baumgartner aceleró continuamente hasta alcanzar los casi 1.350 km/h después de caer los primeros 10.000 metros en unos 40 segundos. A esa altura (unos 30 kilómetros), el sonido viaja algo más despacio que al nivel del mar, o sea que oficialmente puede decirse que esa velocidad corresponde a 1.24 Mach.");
        
        //sb.append("El alcalde de la ciudad, Michael Bloomberg, ha asegurado que el servicio de emergencia está recibiendo 10.000 llamadas cada media hora, diez veces más que en una situación normal. \"Llamen solo si su vida está amenazada\", ha pedido. Además, Bloomberg ha admitido que la crecida es mayor de lo que esperaba: \"En un par de horas debería empezar a retirarse el agua, con la marea baja\". El alcalde ha explicado que se ha evacuado la zona en la que ha caído una grúa este lunes, en la calle 57. Entre los edificios afectados se encuentra un hotel. El gobernador de Estado, Andrew Cuomo, ha publicado en su Twitter que 1.591.335 habitantes del Estado de Nueva York están sin suministro eléctrico. Además, 375.000 personas que viven en zonas bajas de la ciudad habían sido evacuadas de manera preventiva.\n\nCon el paso de las horas y las fuertes lluvias persistentes en la ciudad, las autoridades neoyorquinas se han planteado que el servicio de metro quede suspendido durante una semana. Las inundaciones han sido peor que hace un año con el huracán Irene. El sistema de transporte metropolitano da servicio a 15 millones de personas en Nueva York y conecta a los empleados que acuden a la ciudad de los rascacielos desde grandes urbes como Nueva Jersey o Connecticut.");
        
        sb.append("EL FANTASMA DE MARLEY\n" +
"\n" +
"Marley estaba muerto; eso para empezar. No cabe la menor duda al respecto. El clérigo, el funcionario, el propietario de la funeraria y el que presidió el duelo habían firmado el acta de su enterramiento. También Scrooge había firmado, y la firma de Scrooge, de reconocida solvencia en el mundo mercantil, tenía valor en cualquier papel donde apareciera. El viejo Marley estaba tan muerto como el clavo de una puerta.\n" +
"¡Atención! No pretendo decir que yo sepa lo que hay de especialmente muerto en el clavo de una puerta. Yo, más bien, me había inclinado a considerar el clavo de un ataúd como el más muerto de todos los artículos de ferretería. Pero en el símil se contiene el buen juicio de nuestros ancestros, y no serán mis manos impías las que lo alteren. Por consiguiente, permítaseme repetir enfáticamente que Marley estaba tan muerto como el clavo de una puerta.\n" +
"¿Sabía Scrooge que estaba muerto? Claro que sí. ¿Cómo no iba a saberlo? Scrooge y él habían sido socios durante no sé cuántos años. Scrooge fue su único albacea testamentario, su único administrador, su único asignatario, su único heredero residual, su único amigo y el único que llevó luto por él. Y ni siquiera Scrooge quedó terriblemente afectado por el luctuoso suceso; siguió siendo un excelente hombre de negocios el mismísimo día del funeral, que fue solemnizado por él a precio de ganga.\n" +
"La mención del funeral de Marley me hace retroceder al punto en que empecé. No cabe duda de que Marley estaba muerto. Si no estuviésemos completamente convencidos de que el padre de Hamlet ya había fallecido antes de levantarse el telón, no habría nada notable en sus paseos nocturnos por las murallas de su propiedad, con viento del Este, como para causar asombro ‑en sentido literal‑ en la mente enfermiza de su hijo.");
        
        sb.append("</TextWithNodes>\n");
        sb.append("<AnnotationSet></AnnotationSet>\n<AnnotationSet Name='Original markups' ></AnnotationSet>\n");

        sb.append("</GateDocument>");
        //String resultado2 = port.pronominalAnaphoraResolution(sb.toString(), "es");
        //String resultado2 = spa.resolveAnaphora(sb.toString());
        String resultado2 = resolution(sb.toString(),"es");

        assertEquals(resultado2,resultado2);
       System.out.println(resultado2);
        
        //org.junit.Assert.assertFalse(sb.toString().equals(resultado2));
        
        
    }
    
    //@Test 
    public void pruebaPelicula(){
        //es.ua.coreference.client.AnaphoraResolution service = new es.ua.coreference.client.AnaphoraResolution();
        //es.ua.coreference.client.AnaphoraResolutionService port = service.getAnaphoraResolutionServicePort();
       
        System.out.println("Test 1: pronominalAnaphoraResolution for movie summary");
        StringBuilder sb = new StringBuilder();
        //Película: LO MEJOR DE EVA
        //Eva (Leonor Watling) es una prometedora jueza tan entregada a su trabajo
        //que no distingue entre su vida privada y su profesión, hasta que 
        //conoce a Rocco (Miguel Ángel Silvestre), gigoló que era novio de una
        //bailarina cuyo asesinato ella investiga.
        sb.append("<?xml version='1.0' encoding='UTF-8'?>\n<GateDocument>\n<!-- The document's features-->\n");
        sb.append("<GateDocumentFeatures>\n<Feature>\n");
        sb.append("<Name className='java.lang.String'> MimeType</Name>\n");
        sb.append("<Value className='java.lang.String'> text/xml</Value>\n");
        sb.append("</Feature>\n</GateDocumentFeatures>");
        
        sb.append("<!-- The document content area with serialized nodes -->\n");
        sb.append("<TextWithNodes xml:space='preserve'>");
        sb.append("Película: LO MEJOR DE EVA.\n");
        sb.append("Eva (Leonor Watling) es una prometedora jueza tan entregada a");
        sb.append(" su trabajo que no distingue entre su vida privada y su profesión, ");
        sb.append("y su profesion, ");
        sb.append("hasta que conoce a Rocco (Miguel Ángel Silvestre), gigoló que ");
        sb.append("era novio de una bailarina cuyo asesinato ella investiga.");
        sb.append("</TextWithNodes>\n");
        sb.append("<AnnotationSet></AnnotationSet>\n<AnnotationSet Name='Original markups' ></AnnotationSet>\n");

        sb.append("</GateDocument>");
        
        //String resultado = port.pronominalAnaphoraResolution(sb.toString(), "es");//spa.resolveAnaphora(sb.toString());

        //assertEquals(resultado,resultado);
        
        //org.junit.Assert.assertFalse(resultado.equals(sb.toString()));
        
        //System.out.println(resultado);
        
        
    }
    
    //@Test 
    public void prueba() throws AnaphoraResolutionException{
        
        //María compro un perro en la tienda de animales. 
        
        StringBuilder sb = new StringBuilder();
        
        sb.append("<?xml version='1.0' encoding='UTF-8'?>\n<GateDocument>\n<!-- The document's features-->\n");
        sb.append("<GateDocumentFeatures>\n<Feature>\n");
        sb.append("<Name className='java.lang.String'> MimeType</Name>\n");
        sb.append("<Value className='java.lang.String'> >text/xml</Value>\n");
        sb.append("</Feature>\n</GateDocumentFeatures>");
        //"María compró un perro en la tienda de animales. Ella lo llamó Chispas. Ella lo quiere mucho."
        sb.append("<!-- The document content area with serialized nodes -->\n");
        sb.append("<TextWithNodes xml:space='preserve'>");
        sb.append("<Node id='0'/>María<Node id='5'/> <Node id='6'/>compró<Node id='12'/> <Node id='13'/>un<Node id='15'/> ");
        sb.append("<Node id='16'/>gato<Node id='20'/> <Node id='21'/>en<Node id='23'/> <Node id='24'/>la<Node id='26'/> ");
        sb.append("<Node id='27'/>tienda<Node id='33'/> <Node id='34'/>de<Node id='36'/> <Node id='37'/>mascotas<Node id='45'/>.<Node id='46'/> ");
        sb.append("<Node id='47'/>Ella<Node id='51'/> <Node id='52'/>lo<Node id='54'/> <Node id='55'/>");
        sb.append("llamo<Node id='59'/> <Node id='60'/>chispas<Node id='67' />.<Node id='68' />");
        sb.append("</TextWithNodes>\n");
        
        sb.append("<AnnotationSet></AnnotationSet>\n<AnnotationSet Name='Original markups' ></AnnotationSet>\n");
       
        
        /*sb.append("<AnnotationSet Name='Discourse Entity markups' >\n");
        sb.append("<Annotation Id='100' Type='DiscourseEntity' StartNode='0' EndNode='5'></Annotation>");
        sb.append("<Annotation Id='101' Type='DiscourseEntity' StartNode='16' EndNode='20'></Annotation>");
        sb.append("</AnnotationSet>\n");
        
        sb.append("<AnnotationSet Name='Anaphora markups' >\n");
        sb.append("<Annotation Id='200' Type='PronounAnaphora' StartNode='47' EndNode='51'>\n");
        sb.append("<Feature> \n <Name className='java.lang.String'>StartNodeAntecedent</Name>\n");
        sb.append("<Value className='java.lang.String'>0</Value>\n</Feature>\n");
        sb.append("<Feature>\n<Name className='java.lang.String'>EndNodeAntecedent</Name>\n");
        sb.append("<Value className='java.lang.String'>5</Value>\n</Feature>\n");
        sb.append("<Feature>\n<Name className='java.lang.String'>confidence</Name>\n");
        sb.append("<Value className='java.lang.String'>0.70</Value>\n</Feature>\n");
        sb.append("<Feature>\n<Name className='java.lang.String'>AntecedentId</Name>\n");
        sb.append("<Value className='java.lang.String'>100</Value>\n</Feature>\n");      
        sb.append("</Annotation>\n");
        
        sb.append("<Annotation Id='201' Type='PronounAnaphora' StartNode='52' EndNode='54'>\n");
        sb.append("<Feature> \n <Name className='java.lang.String'>StartNodeAntecedent</Name>\n");
        sb.append("<Value className='java.lang.String'>16</Value>\n</Feature>\n");
        sb.append("<Feature>\n<Name className='java.lang.String'>EndNodeAntecedent</Name>\n");
        sb.append("<Value className='java.lang.String'>20</Value>\n</Feature>\n");
        sb.append("<Feature>\n<Name className='java.lang.String'>confidence</Name>\n");
        sb.append("<Value className='java.lang.String'>0.70</Value>\n</Feature>\n");
        sb.append("<Feature>\n<Name className='java.lang.String'>AntecedentId</Name>\n");
        sb.append("<Value className='java.lang.String'>101</Value>\n</Feature>\n");      
        sb.append("</Annotation>\n");

        sb.append("</AnnotationSet>\n");*/
        
        sb.append("</GateDocument>");
            
        //String resultado = spa.resolveAnaphora(sb.toString());
        String resultado = resolution(sb.toString(),"es");
    
        assertEquals(resultado,resultado);
    
    }
    
    /**
     * Test of hello method, of class AnaphoraResolutionService.
     */
 

    /**
     * Tests of pronominalAnaphoraResolution method, of class AnaphoraResolutionService.
     */
    //@Test
    public void testPronominalAnaphoraResolution1() {
        System.out.println("Test 1: pronominalAnaphoraResolution for english");
        String text = "Mary bought a cat. It is blue.";
        String lang = "en";
        
//        es.ua.coreference.client.AnaphoraResolution service = new es.ua.coreference.client.AnaphoraResolution();
//        es.ua.coreference.client.AnaphoraResolutionService port = service.getAnaphoraResolutionServicePort();
       
        String expResult = "This language is not implemented yet";
        try{
//            String result = port.pronominalAnaphoraResolution(text, lang);
            fail("Expected UnsupportedOperationException when lang is not spanish (es).");
        } catch (Exception ex){
            System.out.println(ex.getClass());
            assertEquals(expResult, ex.getMessage());
        }
                
        //assertEquals(expResult, result);
        // TODO review the generated test code and remove the default call to fail.
        //fail("The test case is a prototype.");
    }
    
    /*@Test(expected = UnsupportedOperationException.class)  
    public void testPronominalAnaphoraResolution2() throws UnsupportedOperationException {
        System.out.println("Test 2: pronominalAnaphoraResolution for bulgarian");
        String text = "Мария купи котка. Той е син.";
        String lang = "bl";
        es.ua.coreference.AnaphoraResolution service = new es.ua.coreference.AnaphoraResolution();
        es.ua.coreference.AnaphoraResolutionService port = service.getAnaphoraResolutionServicePort();
        
        String expResult = "";
        String result = port.pronominalAnaphoraResolution(text, lang);
        //assertEquals(expResult, result);
        // TODO review the generated test code and remove the default call to fail.
        //fail("The test case is a prototype.");
    }*/
    
    
   // @Test  
    public void testPronominalAnaphoraResolution3() throws UnsupportedOperationException {
        System.out.println("Test 3: pronominalAnaphoraResolution for spanish");
        String text = "María compró un gato en la tienda de mascotas. Ella lo llamo chispas.";
        String lang = "es";
//        es.ua.coreference.client.AnaphoraResolution service = new es.ua.coreference.client.AnaphoraResolution();
//        es.ua.coreference.client.AnaphoraResolutionService port = service.getAnaphoraResolutionServicePort();
       
        StringBuilder sb = new StringBuilder();
        
        sb.append("<?xml version='1.0' encoding='UTF-8'?>\n<GateDocument>\n<!-- The document's features-->\n");
        sb.append("<GateDocumentFeatures>\n<Feature>\n");
        sb.append("<Name className='java.lang.String'> MimeType</Name>\n");
        sb.append("<Value className='java.lang.String'> >text/xml</Value>\n");
        sb.append("</Feature>\n</GateDocumentFeatures>");
        
        sb.append("<!-- The document content area with serialized nodes -->\n");
        sb.append("<TextWithNodes>\n");
        sb.append("<Node id='0'/>María<Node id='5'/> <Node id='6'/>compró<Node id='12'/> <Node id='13'/>un<Node id='15'/> ");
        sb.append("<Node id='16'/>gato<Node id='20'/> <Node id='21'/>en<Node id='23'/> <Node id='24'/>la<Node id='26'/> ");
        sb.append("<Node id='27'/>tienda<Node id='33'/> <Node id='34'/>de<Node id='36'/> <Node id='37'/>mascotas<Node id='45'/>.<Node id='46'/> ");
        sb.append("<Node id='47'/>Ella<Node id='51'/> <Node id='52'/>lo<Node id='54'/> <Node id='55'/>");
        sb.append("llamo<Node id='59'/> <Node id='60'/>chispas<Node id='67' />.<Node id='68' />");
        sb.append("\n</TextWithNodes>\n");
        
        sb.append("<AnnotationSet></AnnotationSet>\n<AnnotationSet Name='Original markups' ></AnnotationSet>\n");
        
        
        sb.append("<AnnotationSet Name='Discourse Entity markups' >\n");
        sb.append("<Annotation Id='100' Type='DiscourseEntity' StartNode='0' EndNode='5'></Annotation>");
        sb.append("<Annotation Id='101' Type='DiscourseEntity' StartNode='16' EndNode='20'</Annotation>");
        sb.append("</Annotation>\n");
        
        sb.append("<AnnotationSet Name='Anaphora markups' >\n");
        sb.append("<Annotation Id='200' Type='PronounAnaphora' StartNode='47' EndNode='51'>\n");
        sb.append("<Feature> \n <Name className='java.lang.String'>StartNodeAntecedent</Name>\n");
        sb.append("<Value className='java.lang.String'>0</Value>\n</Feature>\n");
        sb.append("<Feature>\n<Name className='java.lang.String'>EndNodeAntecedent</Name>\n");
        sb.append("<Value className='java.lang.String'>5</Value>\n</Feature>\n");
        sb.append("<Feature>\n<Name className='java.lang.String'>confidence</Name>\n");
        sb.append("<Value className='java.lang.String'>0.70</Value>\n</Feature>\n");
        sb.append("<Feature>\n<Name className='java.lang.String'>AntecedentId</Name>\n");
        sb.append("<Value className='java.lang.String'>100</Value>\n</Feature>\n");      
        sb.append("</Annotation>\n");
        
        sb.append("<Annotation Id='201' Type='PronounAnaphora' StartNode='52' EndNode='54'>\n");
        sb.append("<Feature> \n <Name className='java.lang.String'>StartNodeAntecedent</Name>\n");
        sb.append("<Value className='java.lang.String'>16</Value>\n</Feature>\n");
        sb.append("<Feature>\n<Name className='java.lang.String'>EndNodeAntecedent</Name>\n");
        sb.append("<Value className='java.lang.String'>20</Value>\n</Feature>\n");
        sb.append("<Feature>\n<Name className='java.lang.String'>confidence</Name>\n");
        sb.append("<Value className='java.lang.String'>0.70</Value>\n</Feature>\n");
        sb.append("<Feature>\n<Name className='java.lang.String'>AntecedentId</Name>\n");
        sb.append("<Value className='java.lang.String'>101</Value>\n</Feature>\n");      
        sb.append("</Annotation>\n");

        sb.append("</AnnotationSet>\n</GateDocument>");
        
                
        String expResult = sb.toString();
        System.out.println(expResult);
//        String result = port.pronominalAnaphoraResolution(text, lang);
//        assertEquals(expResult, result);
        
        
        // TODO review the generated test code and remove the default call to fail.
        //fail("The test case is a prototype.");
    }

    /**
     * Test of init method, of class AnaphoraResolutionService.
     */
    @Test
    public void testInit() throws Exception {
        System.out.println("init");
        ServletContext servletContext = null;
        AnaphoraResolutionService.init(servletContext);
        // TODO review the generated test code and remove the default call to fail.
        fail("The test case is a prototype.");
    }

    /**
     * Test of destroy method, of class AnaphoraResolutionService.
     */
    @Test
    public void testDestroy() {
        System.out.println("destroy");
        ServletContext servletContext = null;
        AnaphoraResolutionService.destroy(servletContext);
        // TODO review the generated test code and remove the default call to fail.
        fail("The test case is a prototype.");
    }

    /**
     * Test of AnaphoraResolution method, of class AnaphoraResolutionService.
     */
    @Test
    public void testAnaphoraResolution() throws Exception {
        System.out.println("AnaphoraResolution");
        String text = "";
        String jsonParameters = "";
        AnaphoraResolutionService instance = new AnaphoraResolutionService();
        String expResult = "";
        String result = instance.AnaphoraResolution(text, jsonParameters);
        assertEquals(expResult, result);
        // TODO review the generated test code and remove the default call to fail.
        fail("The test case is a prototype.");
    }

   
    
}
