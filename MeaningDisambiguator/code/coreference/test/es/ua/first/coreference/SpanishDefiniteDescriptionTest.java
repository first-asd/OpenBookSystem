/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package es.ua.first.coreference;

import org.junit.*;
import static org.junit.Assert.*;

/**
 *
 * @author imoreno
 */
public class SpanishDefiniteDescriptionTest {
    
    public SpanishDefiniteDescriptionTest() {
    }

    static SpanishDefiniteDescription ddresolver = null;
    
    @BeforeClass
    public static void setUpClass() throws Exception {
        ddresolver = new SpanishDefiniteDescription(System.getProperty("user.dir")+"/");
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
    // @Test
    // public void hello() {}
    //@Test
    public void WikipediaPerro() throws AnaphoraResolutionException{
        System.out.println("Test 0: DefiniteDescriptionAnaphoraResolution for wikipedia article");
        StringBuilder sb = new StringBuilder();
        
        sb.append("<?xml version='1.0' encoding='UTF-8'?>\n<GateDocument>\n<!-- The document's features-->\n");
        sb.append("<GateDocumentFeatures>\n<Feature>\n");
        sb.append("<Name className='java.lang.String'> MimeType</Name>\n");
        sb.append("<Value className='java.lang.String'> text/xml</Value>\n");
        sb.append("</Feature>\n</GateDocumentFeatures>");
        sb.append("<!-- The document content area with serialized nodes -->\n");
        sb.append("<TextWithNodes xml:space='preserve'>");
        sb.append("Posee un oído y olfato muy desarrollados, siendo este último su principal órgano sensorial.");
        
        sb.append("</TextWithNodes>\n");
        sb.append("<AnnotationSet></AnnotationSet>\n<AnnotationSet Name='Original markups' ></AnnotationSet>\n");

        sb.append("</GateDocument>");
        String result = ddresolver.resolveAnaphora(sb.toString());
        
        
        
        assertEquals(result,sb.toString());
        
    }
    
    //@Test
    public void NoticiaRanaToro() throws AnaphoraResolutionException{
        System.out.println("Test 0: DefiniteDescriptionAnaphoraResolution for rana-toro article");
        StringBuilder sb = new StringBuilder();
        
        sb.append("<?xml version='1.0' encoding='UTF-8'?>\n<GateDocument>\n<!-- The document's features-->\n");
        sb.append("<GateDocumentFeatures>\n<Feature>\n");
        sb.append("<Name className='java.lang.String'> MimeType</Name>\n");
        sb.append("<Value className='java.lang.String'> text/xml</Value>\n");
        sb.append("</Feature>\n</GateDocumentFeatures>");
        sb.append("<!-- The document content area with serialized nodes -->\n");
        sb.append("<TextWithNodes xml:space='preserve'>");
        sb.append("El hallazgo de una rana toro en el delta del Ebro, una de las 100 especies invasoras más agresivas del mundo, ha encendido de nuevo las alarmas en esta zona, que ya se encuentra afectada por la plaga del caracol manzana. ");
        sb.append("El ejemplar fue localizado hace cuatro semanas por un agricultor de Deltebre en un huerto cercano al núcleo urbano.");
        sb.append("</TextWithNodes>\n");
        sb.append("<AnnotationSet></AnnotationSet>\n<AnnotationSet Name='Original markups' ></AnnotationSet>\n");

        sb.append("</GateDocument>");
        String result = ddresolver.resolveAnaphora(sb.toString());
        
        System.out.println(result);
        
        
        assertFalse(result.equals(sb.toString()));
    
    }
    
    //@Test
    public void testPP() throws AnaphoraResolutionException{
        System.out.println("Test 0: DefiniteDescriptionAnaphoraResolution for rana-toro article");
        StringBuilder sb = new StringBuilder();
        
        sb.append("<?xml version='1.0' encoding='UTF-8'?>\n<GateDocument>\n<!-- The document's features-->\n");
        sb.append("<GateDocumentFeatures>\n<Feature>\n");
        sb.append("<Name className='java.lang.String'> MimeType</Name>\n");
        sb.append("<Value className='java.lang.String'> text/xml</Value>\n");
        sb.append("</Feature>\n</GateDocumentFeatures>");
        sb.append("<!-- The document content area with serialized nodes -->\n");
        sb.append("<TextWithNodes xml:space='preserve'>");
        sb.append("En sólo unos días el Partido Popular ha diluido su decisión de demandar a Bárcenas por los papeles con sobresueldos cuya autoría se le atribuye. El pasado lunes el partido de Rajoy encargó al vicesecretario de organización, Carlos Floriano, anunciar acciones legales contra todos.");
    
        sb.append("<AnnotationSet></AnnotationSet>\n<AnnotationSet Name='Original markups' ></AnnotationSet>\n");

        sb.append("</GateDocument>");
        String result = ddresolver.resolveAnaphora(sb.toString());
        
        System.out.println(result);
        
        
        assertFalse(result.equals(sb.toString()));
    
    }
    
    //@Test 
    public void FalloWS3() throws AnaphoraResolutionException {
        
        System.out.println("Test: DefiniteDescriptionAnaphoraResolution for Puyol");
        StringBuilder sb = new StringBuilder();
        
        sb.append("<?xml version='1.0' encoding='UTF-8'?>\n<GateDocument>\n<!-- The document's features-->\n");
        sb.append("<GateDocumentFeatures>\n<Feature>\n");
        sb.append("<Name className='java.lang.String'> MimeType</Name>\n");
        sb.append("<Value className='java.lang.String'> text/xml</Value>\n");
        sb.append("</Feature>\n</GateDocumentFeatures>");
        sb.append("<!-- The document content area with serialized nodes -->\n");
        sb.append("<TextWithNodes xml:space='preserve'>");
        
        sb.append("Puyol se recupera con tanta prontitud de sus lesiones como rápidamente vuelve a sufrir un percance. Probablemente, porque su ímpetu y su carácter aguerrido tengan algo que ver tanto en una cosa como en la otra. Él regresó ayer al once, 17 días después de haberse dañado el ligamento cruzado posterior de la rodilla izquierda ante el Getafe. Los médicos estimaban que el plazo de recuperación rondaría las tres semanas, pero ellos volvieron a equivocarse, como tantas otras veces con Puyol. Nadie previó, en cambio, que el día de su vuelta traería otra desgracia, en forma de una aparatosa caída que le produjo una luxación en el codo izquierdo."); 
        sb.append("Cesc, entre otros compañeros, también confía en su capacidad de recuperación y en su fortaleza: 'Estamos todos a tu lado @Carles5puyol, eres de las personas más fuertes que conozco'. El jugador será sometido a un 'tratamiento conservador', lo que significa que no será operado. El impulso de Puyol para rematar un córner a favor, con 0-2 en el marcador, acabó con una violenta caída sobre su brazo izquierdo, y la caída, con una lesión aparatosa que impactó a sus compañeros sobre el césped. El central se perderá el choque ante el Real Madrid, que se disputa el domingo, para el que fue descartado cuando se lesionó en Getafe, y para el que consiguió recuperarse en tiempo récord. Además, el centenario de partidos con la selección española deberá esperar otra vez. Puyol está anclado en los 99 encuentros internacionales desde el amistoso ante Venezuela de febrero de este año, lo que da una idea de cómo está siendo 2012 para él.");
        sb.append("Carles Puyol se ha lesionado cuatro veces en lo que va de año. Él cayó primero en marzo, y fue baja de última hora ante el Bayer Leverkusen en la vuelta de octavos de final de la Liga de Campeones. Luego él sufrió una lesión en el cartílago de la rodilla derecha, y las consecuencias fueron más dolorosas: se perdió la final de la Copa del Rey, disputada y ganada por el Barcelona al Athletic (0-3), y no pudo revalidar en Kiev la Eurocopa conseguida en 2008. Con todo, el curso 2011-2012 fue mejor que el anterior, porque el central acumuló 44 partidos con el Barcelona, por los 27 de la campaña 2010-2011.");
        sb.append("La temporada 2012-2013, para su desgracia y la del Barcelona, no ha empezado bien. Primero se fracturó un pómulo (cuarta vez que le ocurría en su carrera), después de un choque con Lamah, jugador de Osasuna. Fue el 26 de agosto, así que el capitán del Barcelona se perdió la vuelta de la Supercopa, disputada ante el Real Madrid, y el encuentro de Liga ante el Valencia. Después, él reapareció ante el Getafe y sufrió un estiramiento del ligamento cruzado posterior de la rodilla izquierda, aunque acortó en quince días el tiempo estimado de recuperación, de seis semanas. Ayer, él volvió al once, y esta vez crujió su brazo. Probablemente, él volverá antes de lo esperado.");
        
        sb.append("</TextWithNodes>");
        sb.append("<AnnotationSet></AnnotationSet>\n<AnnotationSet Name='Original markups' ></AnnotationSet>\n");

        sb.append("</GateDocument>");
        String result = ddresolver.resolveAnaphora(sb.toString());
        
        System.out.println(result);
        
        
        assertFalse(result.equals(sb.toString()));
        
        
    }
    
    //@Test 
    public void testFalloWS2() throws AnaphoraResolutionException{
        System.out.println("Test: DefiniteDescriptionAnaphoraResolution for Rajoy");
        StringBuilder sb = new StringBuilder();
        
        sb.append("<?xml version='1.0' encoding='UTF-8'?>\n<GateDocument>\n<!-- The document's features-->\n");
        sb.append("<GateDocumentFeatures>\n<Feature>\n");
        sb.append("<Name className='java.lang.String'> MimeType</Name>\n");
        sb.append("<Value className='java.lang.String'> text/xml</Value>\n");
        sb.append("</Feature>\n</GateDocumentFeatures>");
        sb.append("<!-- The document content area with serialized nodes -->\n");
        sb.append("<TextWithNodes xml:space='preserve'>");
      
        sb.append("Rajoy ha anunciado que el año finalizó con un índice situado 'por debajo del 7% del PIB', tal como ha señalado. Ese porcentaje, sin embargo, no contempla (porque Europa así lo acepta) las ayudas a la banca que suman otro 1%. La economía ha sido el primero de los temas que ha abordado el presidente del Gobierno, que ha justificado sus reformas: 'Lo duro habría sido no tomarlas', ha dicho. 'Nada de brotes verdes, la realidad es dura', ha expresado sobre el paro. El presidente del Gobierno sube hoy a la tribuna del Congreso de los Diputados para hacer balance de su primer año en La Moncloa. Ha anunciado que España ya no tiene necesidad de financiación. 'El dogal de la deuda externa ha dejado de atenazarnos', ha dicho. El líder del PP pretende, en su primer debate del estado de la nación al frente del Ejecutivo, retomar la iniciativa política, cuando España vive bajo los efectos del huracán de los casos de corrupción, de la oleada de recortes y de un paro creciente.");
    
        sb.append("</TextWithNodes>");
        sb.append("<AnnotationSet></AnnotationSet>\n<AnnotationSet Name='Original markups' ></AnnotationSet>\n");

        sb.append("</GateDocument>");
        String result = ddresolver.resolveAnaphora(sb.toString());
        
        System.out.println(result);
        
        
        assertFalse(result.equals(sb.toString()));
    
    }
    
    //@Test
    public void testFalloWS() throws AnaphoraResolutionException{
        System.out.println("Test: DefiniteDescriptionAnaphoraResolution for rana-toro article");
        StringBuilder sb = new StringBuilder();
        
        sb.append("<?xml version='1.0' encoding='UTF-8'?>\n<GateDocument>\n<!-- The document's features-->\n");
        sb.append("<GateDocumentFeatures>\n<Feature>\n");
        sb.append("<Name className='java.lang.String'> MimeType</Name>\n");
        sb.append("<Value className='java.lang.String'> text/xml</Value>\n");
        sb.append("</Feature>\n</GateDocumentFeatures>");
        sb.append("<!-- The document content area with serialized nodes -->\n");
        sb.append("<TextWithNodes xml:space='preserve'>");
        
        //sb.append("Decía Douglas Adams en su impagable Guía del autoestopista galáctico que volar era un arte fácil, que solo requería una habilidad: aprender a arrojarse contra el suelo… y fallar. El domingo, Félix Baumgartner consiguió aplicar esa receta al menos durante 10 interminables minutos. Voló mucho más alto y más rápido que cualquier avión comercial, protegido solo por un traje a presión similar al de un astronauta. Con ello consiguió batir dos de las tres marcas que se había propuesto: salto desde máxima altura y máxima velocidad de caída; el tercero (máximo tiempo en caída libre) no pudo ser y sigue en poder de Joseph Kittinger, quien lo estableció allá por el año 1960. Pese a las muchas precauciones adoptadas, el salto revestía serio peligro. A todos los efectos, cuando Baumgartner abrió la puerta de su cápsula estaba en Marte: presión inferior a una centésima de atmósfera. Temperatura de 20 grados bajo cero. Y una intensa radiación ultravioleta del Sol, ya que buena parte de la protectora capa de ozono quedaba ya por debajo de sus pies. Durante unos segundos, el austriaco cayó sin control. Su única protección era la escafandra, similar a las que utilizan los astronautas en sus paseos espaciales o los pilotos de aviones de gran altitud como el U-2 o el SR-71. El visor, muy tintado, le protegía no solo del ultravioleta, sino también del rozamiento del aire. ");
        sb.append("En el vacío virtual de la alta atmósfera, sin apenas aire que frenase su caída, Baumgartner aceleró continuamente hasta alcanzar los casi 1.350 km/h después de caer los primeros 10.000 metros en unos 40 segundos. A esa altura (unos 30 kilómetros), el sonido viaja algo más despacio que al nivel del mar, o sea que oficialmente puede decirse que esa velocidad corresponde a 1.24 Mach.");
        
        sb.append("</TextWithNodes>");
        sb.append("<AnnotationSet></AnnotationSet>\n<AnnotationSet Name='Original markups' ></AnnotationSet>\n");

        sb.append("</GateDocument>");
        String result = ddresolver.resolveAnaphora(sb.toString());
        
        System.out.println(result);
        
        
        assertFalse(result.equals(sb.toString()));
    
    }
    
    @Test 
    public void testFalloWS4() throws AnaphoraResolutionException{
        System.out.println("Test: DefiniteDescriptionAnaphoraResolution for Rajoy 2");
        StringBuilder sb = new StringBuilder();
        
        sb.append("<?xml version='1.0' encoding='UTF-8'?>\n<GateDocument>\n<!-- The document's features-->\n");
        sb.append("<GateDocumentFeatures>\n<Feature>\n");
        sb.append("<Name className='java.lang.String'> MimeType</Name>\n");
        sb.append("<Value className='java.lang.String'> text/xml</Value>\n");
        sb.append("</Feature>\n</GateDocumentFeatures>");
        sb.append("<!-- The document content area with serialized nodes -->\n");
        sb.append("<TextWithNodes xml:space='preserve'>");
      
        
        sb.append("El presidente del Gobierno, Mariano Rajoy, estará más de un mes sin pisar el Congreso, según ha comunicado el Ejecutivo al presidente de la Cámara. La pasada semana no hubo sesión de control por el viaje de Rajoy a Nueva York, esta no hay pleno y para la siguiente La Moncloa ha comunicado que no estarán nueve miembros del Gobierno, entre ellos el presidente, por la celebración de una cumbre hispano-francesa. La siguiente no habrá pleno por las elecciones vascas y gallegas.\n"); 

        sb.append("Después del 21-O será el debate de totalidad de los Presupuestos, por lo que, en principio, Rajoy no irá a una sesión de control en el Congreso hasta el miércoles 31 de octubre. Ese calendario se suma a los bloqueos de la mayoría absoluta del PP que ha impedido sistemáticamente que se tramiten en la Mesa y la Junta de Portavoces las peticiones de todos los grupos para que Rajoy acuda al pleno a hablar de la crisis económica o, en su momento, de la petición de rescate para el sistema financiero español. Tampoco ha habido este año debate sobre el estado de la nación, por deseo del presidente del Gobierno.\n");

        sb.append("Para Soraya Rodríguez, todo eso muestra una actitud 'dictatorial' y de falta de respeto al Parlamento. Ella es una abogada y política española, y actualmente ella es portavoz del PSOE en el Congreso de los Diputados. El PSOE ha presentado un escrito al presidente del Congreso, Jesús Posada, pidiéndole que cambie la hora o la fecha de la sesión de control de la próxima semana para que Rajoy pueda estar presente. Él ha convocado la Junta para mañana jueves a las cinco de la tarde. Rodríguez, además, ha rechazado la posibilidad de que se modifique la ley para restringir el derecho de manifestación.");

        
        sb.append("</TextWithNodes>");
        sb.append("<AnnotationSet></AnnotationSet>\n<AnnotationSet Name='Original markups' ></AnnotationSet>\n");

        sb.append("</GateDocument>");
        String result = ddresolver.resolveAnaphora(sb.toString());
        
        System.out.println(result);
        
        
        assertFalse(result.equals(sb.toString()));
    
    }
    
    @Test 
    public void testFalloWS5() throws AnaphoraResolutionException{
        System.out.println("Test: DefiniteDescriptionAnaphoraResolution for Rajoy 2");
        StringBuilder sb = new StringBuilder();
        
        sb.append("<?xml version='1.0' encoding='UTF-8'?>\n<GateDocument>\n<!-- The document's features-->\n");
        sb.append("<GateDocumentFeatures>\n<Feature>\n");
        sb.append("<Name className='java.lang.String'> MimeType</Name>\n");
        sb.append("<Value className='java.lang.String'> text/xml</Value>\n");
        sb.append("</Feature>\n</GateDocumentFeatures>");
        sb.append("<!-- The document content area with serialized nodes -->\n");
        sb.append("<TextWithNodes xml:space='preserve'>");
      
        
        //sb.append("El presidente del Gobierno, Mariano Rajoy, estará más de un mes sin pisar el Congreso, según ha comunicado el Ejecutivo al presidente de la Cámara. La pasada semana no hubo sesión de control por el viaje de Rajoy a Nueva York, esta no hay pleno y para la siguiente La Moncloa ha comunicado que no estarán nueve miembros del Gobierno, entre ellos el presidente, por la celebración de una cumbre hispano-francesa. La siguiente no habrá pleno por las elecciones vascas y gallegas.\n"); 

        //sb.append("Después del 21-O será el debate de totalidad de los Presupuestos, por lo que, en principio, Rajoy no irá a una sesión de control en el Congreso hasta el miércoles 31 de octubre. Ese calendario se suma a los bloqueos de la mayoría absoluta del PP que ha impedido sistemáticamente que se tramiten en la Mesa y la Junta de Portavoces las peticiones de todos los grupos para que Rajoy acuda al pleno a hablar de la crisis económica o, en su momento, de la petición de rescate para el sistema financiero español. Tampoco ha habido este año debate sobre el estado de la nación, por deseo del presidente del Gobierno.\n");

        sb.append("Cuarenta años después de ser proclamado candidato a la presidencia, el espíritu de John F. Kennedy planeó hoy sobre la convención demócrata de Los Angeles, donde su hija Caroline apostó por renovar la 'nueva frontera'.  Ante una audiencia entregada y nostálgica, que la aclamó a veces con lágrimas en los ojos, la única superviviente del presidente asesinado aseguró que el llamamiento lanzado por su padre a favor de una 'nueva frontera' para EEUU 'no tiene límite temporal' y que 'nosotros somos ahora la nueva frontera'.  Entre vítores, aplausos, gritos y oleadas de pancartas con el apellido Kennedy, Caroline Kennedy llegó al podium del centro Staples para devolver a las filas demócratas el recuerdo de su más adorado presidente.  'Sé que el espíritu de mi padre vive y  os lo agradezco' , dijo Caroline Kennedy en su primera aparición en una convención demócrata en apoyo del candidato del partido al que tradicionalmente pertenece su familia.  La hija del presidente asesinado reivindicó que el programa demócrata es el que mejor defiende los derechos civiles, la diversidad de EEUU y la necesidad de una 'sociedad abierta' , y dijo que, 'ahora que tantos estamos tan bien, es el momento de pedir más de nosotros' . Aseguró que a ella, al igual que el candidato demócrata, Albert Gore, le enseñaron a 'creer que el mundo puede hacerse nuevo cada vez' y   pidió a los estadounidenses que   permitan al actual vicepresidente de EEUU crear el país 'de nuestros ideales'.  Lejos de Los Angeles, Al Gore recogió la antorcha del liderazgo demócrata de manos del presidente estadounidense, Bill Clinton, en un acto simbólico celebrado en Michigan.");

        
        sb.append("</TextWithNodes>");
        sb.append("<AnnotationSet></AnnotationSet>\n<AnnotationSet Name='Original markups' ></AnnotationSet>\n");

        sb.append("</GateDocument>");
        String result = ddresolver.resolveAnaphora(sb.toString());
        
        System.out.println(result);
        
        
        assertFalse(result.equals(sb.toString()));
    
    }
}
