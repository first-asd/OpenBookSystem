/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package es.ua.first.coreference;

import static org.junit.Assert.assertEquals;
import org.junit.*;

/**
 *
 * @author imoreno
 */
public class SpanishZeroPronounTest {
    
    static SpanishZeroPronoun zpresolver = null;
    
    public SpanishZeroPronounTest() {
    }

    @BeforeClass
    public static void setUpClass() throws Exception {
        zpresolver = new SpanishZeroPronoun(System.getProperty("user.dir")+"/");
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
    //@Test
//    public void testPerroWikiSimplificado() throws AnaphoraResolutionException {
//        System.out.println("Test 0: ZeroPronounAnaphoraResolution for wikipedia article");
//        StringBuilder sb = new StringBuilder();
//        
//        sb.append("<?xml version='1.0' encoding='UTF-8'?>\n<GateDocument>\n<!-- The document's features-->\n");
//        sb.append("<GateDocumentFeatures>\n<Feature>\n");
//        sb.append("<Name className='java.lang.String'> MimeType</Name>\n");
//        sb.append("<Value className='java.lang.String'> text/xml</Value>\n");
//        sb.append("</Feature>\n</GateDocumentFeatures>");
//        sb.append("<!-- The document content area with serialized nodes -->\n");
//        sb.append("<TextWithNodes xml:space='preserve'>");
//    
//        sb.append("El perro, cuyo nombre científico es Canis lupus familiaris, es un mamífero carnívoro doméstico de la familia de los cánidos. Posee un oído y olfato muy desarrollados.");
//        
//        sb.append("</TextWithNodes>\n");
//        sb.append("<AnnotationSet></AnnotationSet>\n<AnnotationSet Name='Original markups' ></AnnotationSet>\n");
//
//        sb.append("</GateDocument>");
//        String result = zpresolver.resolveAnaphora(sb.toString());
//        
//        System.out.println(result);
//        
//        assertEquals(result,sb.toString());
//    }
    
//    @Test
//    public void testPerroWikiSimplificadoV2() throws AnaphoraResolutionException {
//        System.out.println("Test 1: ZeroPronounAnaphoraResolution for wikipedia article");
//        StringBuilder sb = new StringBuilder();
//        
//        sb.append("<?xml version='1.0' encoding='UTF-8'?>\n<GateDocument>\n<!-- The document's features-->\n");
//        sb.append("<GateDocumentFeatures>\n<Feature>\n");
//        sb.append("<Name className='java.lang.String'> MimeType</Name>\n");
//        sb.append("<Value className='java.lang.String'> text/xml</Value>\n");
//        sb.append("</Feature>\n</GateDocumentFeatures>");
//        sb.append("<!-- The document content area with serialized nodes -->\n");
//        sb.append("<TextWithNodes xml:space='preserve'>");
//    
//        sb.append("El perro pertenece a la familia de los cánidos. Posee un oído y olfato muy desarrollados.");
//        
//        sb.append("</TextWithNodes>\n");
//        sb.append("<AnnotationSet></AnnotationSet>\n<AnnotationSet Name='Original markups' ></AnnotationSet>\n");
//
//        sb.append("</GateDocument>");
//        String result = zpresolver.resolveAnaphora(sb.toString());
//        
//        System.out.println(result);
//        
//        assertEquals(result,sb.toString());
//    }
    
//    @Test
//    public void testGansoWiki() throws AnaphoraResolutionException{
//        
//        System.out.println("Test 2: ZeroPronounAnaphoraResolution for wikipedia article");
//        StringBuilder sb = new StringBuilder();
//        
//        sb.append("<?xml version='1.0' encoding='UTF-8'?>\n<GateDocument>\n<!-- The document's features-->\n");
//        sb.append("<GateDocumentFeatures>\n<Feature>\n");
//        sb.append("<Name className='java.lang.String'> MimeType</Name>\n");
//        sb.append("<Value className='java.lang.String'> text/xml</Value>\n");
//        sb.append("</Feature>\n</GateDocumentFeatures>");
//        sb.append("<!-- The document content area with serialized nodes -->\n");
//        sb.append("<TextWithNodes xml:space='preserve'>");
//        
//        sb.append("El ánsar común, ganso común u oca común (Anser anser) es una especie de ave anseriforme de la familia Anatidae caracterizada por su cuerpo grande, con el pico grueso y de color naranja, plumaje gris pardo, patas rosas y parte caudal inferior blanquecina.\n");
//        sb.append("Su voz es muy fuerte, a modo de trompeteo. Anida en el suelo, tapizando el nido parcialmente; pone de cuatro a seis huevos en una nidada, de mayo a junio. Se alimenta arrancando hierbas y brotes del suelo; a veces excava buscando raíces y bulbos.\n");
//        sb.append("Habita en casi toda Europa, en zonas húmedas y a veces pantanosas. En muchos casos, los individuos introducidos se naturalizan y se hacen residentes, perdiendo en parte su carácter salvaje.\n");
//        sb.append("Existen numerosas razas domésticas que se crían como aves de corral; se consideran pertenecientes a la subespecie Anser anser domesticus.");
//        
//        sb.append("</TextWithNodes>\n");
//        sb.append("<AnnotationSet></AnnotationSet>\n<AnnotationSet Name='Original markups' ></AnnotationSet>\n");
//
//        sb.append("</GateDocument>");
//        String result = zpresolver.resolveAnaphora(sb.toString());
//        
//        System.out.println(result);
//        
//        assertEquals(result,sb.toString());
//    }
    
//    @Test
//    public void testTigre() throws AnaphoraResolutionException{
//        
//        System.out.println("Test 3: ZeroPronounAnaphoraResolution for wikipedia article");
//        StringBuilder sb = new StringBuilder();
//        
//        sb.append("<?xml version='1.0' encoding='UTF-8'?>\n<GateDocument>\n<!-- The document's features-->\n");
//        sb.append("<GateDocumentFeatures>\n<Feature>\n");
//        sb.append("<Name className='java.lang.String'> MimeType</Name>\n");
//        sb.append("<Value className='java.lang.String'> text/xml</Value>\n");
//        sb.append("</Feature>\n</GateDocumentFeatures>");
//        sb.append("<!-- The document content area with serialized nodes -->\n");
//        sb.append("<TextWithNodes xml:space='preserve'>");
//        
//        sb.append("El tigre (Panthera tigris) es una de las seis especies de la subfamilia de los panterinos (familia Felidae) pertenecientes al género Panthera. Se encuentra solamente en el continente asiático; es un predador carnívoro y es la especie de felino más grande del mundo, pudiendo alcanzar un tamaño comparable al de los felinos fósiles de mayor tamaño.\nExisten seis subespecies de tigre, de las cuales la de Bengala es la más numerosa; sus ejemplares constituyen cerca del 80% de la población total de la especie; se encuentra en la India, Bangladesh, Bután, Birmania y Nepal. Es una especie en peligro, y en la actualidad, la mayor parte de los tigres en el mundo viven en cautiverio. El tigre es el animal nacional de Bangladesh y la India.\nEs un animal solitario y territorial que generalmente suele habitar bosques densos, pero también áreas abiertas, como sabanas. Normalmente, el tigre caza animales de tamaño medio o grande, generalmente ungulados. En las seis diferentes subespecies existentes del tigre, hay una variación muy significativa del tamaño. Los tigres machos tienen un tamaño mucho mayor que el de las hembras. Análogamente, el territorio de un macho cubre generalmente un área mayor que el de una hembra.");
//        
//        sb.append("</TextWithNodes>\n");
//        sb.append("<AnnotationSet></AnnotationSet>\n<AnnotationSet Name='Original markups' ></AnnotationSet>\n");
//
//        sb.append("</GateDocument>");
//        String result = zpresolver.resolveAnaphora(sb.toString());
//        
//        System.out.println(result);
//        
//        assertEquals(result,sb.toString());
// }
//    @Test
//    public void testPerroWiki() throws AnaphoraResolutionException{
//    
//        System.out.println("Test 4: ZeroPronounAnaphoraResolution for wikipedia article");
//        StringBuilder sb = new StringBuilder();
//        
//        sb.append("<?xml version='1.0' encoding='UTF-8'?>\n<GateDocument>\n<!-- The document's features-->\n");
//        sb.append("<GateDocumentFeatures>\n<Feature>\n");
//        sb.append("<Name className='java.lang.String'> MimeType</Name>\n");
//        sb.append("<Value className='java.lang.String'> text/xml</Value>\n");
//        sb.append("</Feature>\n</GateDocumentFeatures>");
//        sb.append("<!-- The document content area with serialized nodes -->\n");
//        sb.append("<TextWithNodes xml:space='preserve'>");
//        
//        sb.append("El perro, cuyo nombre científico es Canis lupus familiaris, es un mamífero carnívoro doméstico de la familia de los cánidos, que constituye una subespecie del lobo (Canis lupus). No obstante, su alimentación se ha modificado[cita requerida] notablemente debido principalmente al estrecho lazo que existe con el hombre, hasta el punto en que hoy en día sea alimentado usualmente como si fuese un omnívoro. Su tamaño o talla, su forma y pelaje es muy diverso según la raza de perro. Posee un oído y olfato muy desarrollados, siendo este último su principal órgano sensorial. En las razas pequeñas puede alcanzar una longevidad de cerca de 20 años, con atención esmerada por parte del propietario, de otra forma su vida en promedio es alrededor de los 15 años.");
//         sb.append("</TextWithNodes>\n");
//        sb.append("<AnnotationSet></AnnotationSet>\n<AnnotationSet Name='Original markups' ></AnnotationSet>\n");
//
//        sb.append("</GateDocument>");
//        String result = zpresolver.resolveAnaphora(sb.toString());
//        
//        System.out.println(result);
//        
//        assertEquals(result,sb.toString());
//    }
    
//    @Test
//    public void testCervantesWiki() throws AnaphoraResolutionException{
//    
//        System.out.println("Test 5: ZeroPronounAnaphoraResolution for wikipedia article");
//        StringBuilder sb = new StringBuilder();
//        
//        sb.append("<?xml version='1.0' encoding='UTF-8'?>\n<GateDocument>\n<!-- The document's features-->\n");
//        sb.append("<GateDocumentFeatures>\n<Feature>\n");
//        sb.append("<Name className='java.lang.String'> MimeType</Name>\n");
//        sb.append("<Value className='java.lang.String'> text/xml</Value>\n");
//        sb.append("</Feature>\n</GateDocumentFeatures>");
//        sb.append("<!-- The document content area with serialized nodes -->\n");
//        sb.append("<TextWithNodes xml:space='preserve'>");
//        
//        sb.append("En mayo de 1581 Cervantes se trasladó a Portugal, donde se hallaba entonces la corte de Felipe II, con el propósito de encontrar algo con lo que rehacer su vida y pagar las deudas que había obtenido su familia para rescatarle de Argel. Le encomendaron una comisión secreta en Orán, puesto que él tenía muchos conocimientos de la cultura y costumbres del norte de África. Por ese trabajo recibió 50 escudos. Regresó a Lisboa y a finales de año volvió a Madrid. En febrero de 1582, solicita un puesto de trabajo vacante en las Indias; sin conseguirlo. En estos años, el escritor tiene relaciones amorosas con Ana Villafranca (o Franca) de Rojas, la mujer de Alonso Rodríguez, un tabernero. De la relación nació una hija que se llamó Isabel de Saavedra, que él reconoció.\nCervantes es sumamente original. Parodiando un género que empezaba a periclitar, como el de los libros de caballerías, creó otro género sumamente vivaz, la novela polifónica, donde se superponen las cosmovisiones y los puntos de vista hasta confundirse en complejidad con la misma realidad, recurriendo incluso a juegos metaficcionales. En la época la épica podía escribirse también en prosa, y con el precedente en el teatro del poco respeto a los modelos clásicos de Lope de Vega, le cupo a él en suma fraguar la fórmula del realismo en la narrativa tal y como había sido preanunciada en España por toda una tradición literaria desde el Cantar del Mío Cid, ofreciéndosela a Europa, donde Cervantes tuvo más discípulos que en España.");
//        sb.append("</TextWithNodes>\n");
//        sb.append("<AnnotationSet></AnnotationSet>\n<AnnotationSet Name='Original markups' ></AnnotationSet>\n");
//
//        sb.append("</GateDocument>");
//        String result = zpresolver.resolveAnaphora(sb.toString());
//        
//        System.out.println(result);
//        
//        assertEquals(result,sb.toString());
//    }
    
//    @Test
//    public void testFrancioWiki() throws AnaphoraResolutionException{
//    
//        System.out.println("Test 6: ZeroPronounAnaphoraResolution for wikipedia article");
//        StringBuilder sb = new StringBuilder();
//        
//        sb.append("<?xml version='1.0' encoding='UTF-8'?>\n<GateDocument>\n<!-- The document's features-->\n");
//        sb.append("<GateDocumentFeatures>\n<Feature>\n");
//        sb.append("<Name className='java.lang.String'> MimeType</Name>\n");
//        sb.append("<Value className='java.lang.String'> text/xml</Value>\n");
//        sb.append("</Feature>\n</GateDocumentFeatures>");
//        sb.append("<!-- The document content area with serialized nodes -->\n");
//        sb.append("<TextWithNodes xml:space='preserve'>");
//        
//        sb.append("El francio, antiguamente conocido como eka-cesio y actinio K, es un elemento químico cuyo símbolo es Fr y su número atómico es 87. Su electronegatividad es la más baja conocida y es el segundo elemento menos abundante en la naturaleza (el primero es el astato). El francio es un metal alcalino altamente radiactivo y reactivo que se desintegra generando astato, radio y radón. Como el resto de metales alcalinos, sólo posee un electrón en su capa de valencia. Marguerite Perey descubrió este elemento en 1939. En 1962, ella fue la primera mujer en ser elegida para la Academia de Ciencias Francesa. El químico ruso D. K. Dobroserdov fue el primer científico que aseguró haber descubierto eka-cesio. En 1925, él observó una débil radiactividad en una muestra de potasio, otro metal alcalino, y él concluyó que el eka-cesio contaminaba la muestra. Él también publicó una tesis sobre sus predicciones de las propiedades del eka-cesio, en la que nombraba al elemento con el nombre de russio, en honor a su país de procedencia. Poco tiempo después, Dobroserdov empezó a centrarse en su carrera docente en el Instituto Politécnico de Odessa, abandonando por completo sus esfuerzos por aislar el eka-cesio.");
//        sb.append("</TextWithNodes>\n");
//        sb.append("<AnnotationSet></AnnotationSet>\n<AnnotationSet Name='Original markups' ></AnnotationSet>\n");
//
//        sb.append("</GateDocument>");
//        String result = zpresolver.resolveAnaphora(sb.toString());
//        
//        System.out.println(result);
//        
//        assertEquals(result,sb.toString());
//    }
    
    @Test
    public void testBaughWiki() throws AnaphoraResolutionException{
    
        System.out.println("Test 7: ZeroPronounAnaphoraResolution for wikipedia article");
        StringBuilder sb = new StringBuilder();
        
        sb.append("<?xml version='1.0' encoding='UTF-8'?>\n<GateDocument>\n<!-- The document's features-->\n");
        sb.append("<GateDocumentFeatures>\n<Feature>\n");
        sb.append("<Name className='java.lang.String'> MimeType</Name>\n");
        sb.append("<Value className='java.lang.String'> text/xml</Value>\n");
        sb.append("</Feature>\n</GateDocumentFeatures>");
        sb.append("<!-- The document content area with serialized nodes -->\n");
        sb.append("<TextWithNodes xml:space='preserve'>");
        
        sb.append("Decía Douglas Adams en su impagable Guía del autoestopista galáctico que volar era un arte fácil, que solo requería una habilidad: aprender a arrojarse contra el suelo… y fallar. El domingo, Félix Baumgartner consiguió aplicar esa receta al menos durante 10 interminables minutos. Voló mucho más alto y más rápido que cualquier avión comercial, protegido solo por un traje a presión similar al de un astronauta. Con ello consiguió batir dos de las tres marcas que se había propuesto: salto desde máxima altura y máxima velocidad de caída; el tercero (máximo tiempo en caída libre) no pudo ser y sigue en poder de Joseph Kittinger, quien lo estableció allá por el año 1960.\nPese a las muchas precauciones adoptadas, el salto revestía serio peligro. A todos los efectos, cuando Baumgartner abrió la puerta de su cápsula estaba en Marte: presión inferior a una centésima de atmósfera. Temperatura de 20 grados bajo cero. Y una intensa radiación ultravioleta del Sol, ya que buena parte de la protectora capa de ozono quedaba ya por debajo de sus pies.\nDurante unos segundos, el austriaco cayó sin control.\nSu única protección era la escafandra, similar a las que utilizan los astronautas en sus paseos espaciales o los pilotos de aviones de gran altitud como el U-2 o el SR-71. El visor, muy tintado, le protegía no solo del ultravioleta, sino también del rozamiento del aire.\nEn el vacío virtual de la alta atmósfera, sin apenas aire que frenase su caída, Baumgartner aceleró continuamente hasta alcanzar los casi 1.350 km/h después de caer los primeros 10.000 metros en unos 40 segundos. A esa altura (unos 30 kilómetros), el sonido viaja algo más despacio que al nivel del mar, o sea que oficialmente puede decirse que esa velocidad corresponde a 1.24 Mach.");
        sb.append("</TextWithNodes>\n");
        sb.append("<AnnotationSet></AnnotationSet>\n<AnnotationSet Name='Original markups' ></AnnotationSet>\n");

        sb.append("</GateDocument>");
        String result = zpresolver.resolveAnaphora(sb.toString());
        
        System.out.println(result);
        
        assertEquals(result,sb.toString());
    }
    
    
}
