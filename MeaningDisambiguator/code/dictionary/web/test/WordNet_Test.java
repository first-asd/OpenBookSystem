//
//import es.ua.dictionary.DisambiguationException;
//import es.ua.dictionary.DisambiguationService;
//import java.io.BufferedReader;
//import java.io.File;
//import java.io.FileReader;
//import java.io.IOException;
//import javax.xml.parsers.ParserConfigurationException;
//import net.didion.jwnl.JWNLException;
//import org.junit.Test;
//import org.xml.sax.SAXException;
//
///*
// * To change this template, choose Tools | Templates
// * and open the template in the editor.
// */
///**
// *
// * @author lcanales
// */
//public class WordNet_Test {
//
//    private static DisambiguationService WordNet;
//
//    public WordNet_Test() throws DisambiguationException {
//        WordNet = new DisambiguationService();
//        WordNet.init(null);
//    }
//
//    @Test
//    public void testGate() throws IOException, ParserConfigurationException, SAXException, JWNLException, DisambiguationException {
//
//        System.out.println("Entrada y Salida Gate");
//
//        StringBuilder textFile = new StringBuilder();
//        String line = "";
//        File f = new File("/home/lcanales/Dropbox/FIRST_ISA_LEA/Anafora/ejemplos_salida/example_text1.xml");
////        File f = new File("/home/lcanales/corpus/EN/GATE/notice1.xml");
////        File f = new File("/home/lcanales/corpus/BG/GATE/noticia1.xml");
//        BufferedReader reader = null;
//        reader = new BufferedReader(new FileReader(f));
//        while ((line = reader.readLine()) != null) {
//            textFile.append(line).append("\n");
//        }
//        reader.close();
//
//        String definition = WordNet.disambiguate(textFile.toString(), DisambiguationService.Language.ES, DisambiguationService.MethodDisambiguation.MFS, DisambiguationService.Information.DEFSYN, DisambiguationService.TypeWords.POLYSEMIC);
//        System.out.println(definition);
//
//        String definition1 = WordNet.disambiguate(textFile.toString(), DisambiguationService.Language.ES, DisambiguationService.MethodDisambiguation.UKB, DisambiguationService.Information.DEFSYN, DisambiguationService.TypeWords.POLYSEMIC);
////        String definition = WordNet.disambiguate(textFile.toString(), DisambiguationService.Language.BG, DisambiguationService.MethodDisambiguation.MFS, DisambiguationService.Information.DEFINITIONS, DisambiguationService.TypeWords.RARE);
//        System.out.println(definition1);
//
//        System.out.println();
//        System.out.println();
//
//    }
////     @Test
////    public void testBGPolitica() throws IOException, ParserConfigurationException, SAXException, JWNLException, DisambiguationException {
////
////        System.out.println("STANDART (BG) - POLITICA");
////
////        String text = "София. Синдикатите предлагат Кристалина Георгиева за служебен премиер. "
////                + "Това е единственият останал авторитет, който може да оглави служебен кабинет в тази взривоопасна "
////                + "ситуация, в която се намираме, заяви лидерът на КНСБ Пламен Димитров. Нейното име е гаранция, че "
////                + "служебното правителство ще свърши работа. Самият Пламен Димитров отрече да е получавал предложение "
////                + "от президента да стане служебен министър на труда, каквито слухове се появиха.";
////
////        String definition = WordNet.disambiguate(text, DisambiguationService.Language.BG, DisambiguationService.MethodDisambiguation.MFS, DisambiguationService.Information.DEFINITIONS, DisambiguationService.TypeWords.RARE);
////        System.out.println(definition);
////        
////        System.out.println();
////        System.out.println();
////
////    }
////    @Test
////    public void testBGTecnologia() throws IOException, ParserConfigurationException, SAXException, JWNLException, DisambiguationException {
////
////        System.out.println("STANDART (BG) - TECNOLOGIA");
////
////        String text = "Hewlet-Packard (HP) показа новия си таблет Slate 7. Официалното представяне се случи по "
////                + "време на световното изложение за модерни технологии World Mobile Congress (WMC), което се "
////                + "провежда в Барселона, предаде The New York Times. Новият 7-ичнов таблет използва операционната "
////                + "система Android 4.1 Jelly Bean на Google. Устройството има двуядрен процесор ARM Cortex-A9, работещ "
////                + "на 1,6 GHz с подкрепата на 1 GB оперативна памет и 8 GB флаш-памет за съхранение, разширяема "
////                + "посредством слот за microSD карти. Осигурена е Wi-Fi b/g/n и Bluetooth 2.1 безжична връзка, "
////                + "а камерите са две: лицева VGA и 3-мегапикселна на задния панел. Целта на HP е да отмие срама "
////                + "от фиаското, което предизвика TouchPad. Моделът се оказа слабо търсен и впоследствие спрян от "
////                + "производство. От компанията обещават, че това ще бъде първият таблет от серия, използваща различни "
////                + "операционни системи. HP Slate 7 ще се търгува на цената от $170. Очаква се продажбите на устройството "
////                + "да започнат в началото на лятото.";
////
////        String definition = WordNet.disambiguate(text, DisambiguationService.Language.BG, DisambiguationService.MethodDisambiguation.MFS, DisambiguationService.Information.DEFINITIONS, DisambiguationService.TypeWords.RARE);
////        System.out.println(definition);
////        
////        System.out.println();
////        System.out.println();
////
////    }
////    
////        @Test
////    public void testBGPolitica2() throws IOException, ParserConfigurationException, SAXException, JWNLException, DisambiguationException {
////
////        System.out.println("STANDART (BG) - POLITICA 2");
////
////        String text = "Първото, което ще направим е да стартираме проекта АЕЦ 'Белене', която да бъде построена от "
////                + "руснаци. Така бившият вътрешен министър в правителството на Тройната коалиция и депутат в БСП Михаил "
////                + "Миков отговаря на въпроса на руското издание 'Новости', как социалистите ще се справят с енергийните "
////                + "проблеми на България, ако спечелят изборите. 'Експлоатационния живот на сега действащите реактори "
////                + "приключва това десетилетие', казва Миков в интервюто.Според него нова атомна електроцентрала е "
////                + "необходима на страната, тъй като тя ще привлече инвестиции и ще създаде нови работни места. "
////                + "'Най-важното е, че благодарение на АЕЦ 'Белене' цената на електроенергията ще падне, а енергийната "
////                + "независимост на България ще бъде възстановена', смята червеният депутат. Миков иска да засили "
////                + "сътрудничеството между България и Русия. 'През последните години, поради политически причини, "
////                + "позициите на България на руския пазар бяха загубени. Ние ги искаме обратно - не само в енергийния "
////                + "сектор, но и в областта на туризма, леката промишленост', каза Миков.";
////
////        String definition = WordNet.disambiguate(text, DisambiguationService.Language.BG, DisambiguationService.MethodDisambiguation.MFS, DisambiguationService.Information.DEFINITIONS, DisambiguationService.TypeWords.RARE);
////        System.out.println(definition);
////        
////        System.out.println();
////        System.out.println();
////    }
////
//////    @Test
////    public void testENSucesos() throws IOException, ParserConfigurationException, SAXException, JWNLException, DisambiguationException {
////
////        System.out.println("DAILY NEWS (EN) - SUCESOS");
////
////        String text = "Oscar Pistorius is today facing the possibility of months in jail before a trial after a "
////                + "magistrate ruled that he faces a charge of premeditated murder in the death of his girlfriend "
////                + "Reeva Steenkamp. The judge said he will consider downgrading the charge later during the "
////                + "emotionally-charged bail hearing, but the news brought Pistoruis and his family to tears. "
////                + "Today the sportsman was accused of grabbing his gun and strapping on his prosthetic legs before "
////                + "walking seven metres and shooting dead the model. The court appearance comes on the same day as "
////                + "Miss Steenkamp's funeral, expected to be a private service, after her body was returned to her "
////                + "home town of Port Elizabeth.";
////
////        String definition = WordNet.disambiguate(text, DisambiguationService.Language.EN, DisambiguationService.MethodDisambiguation.MFS, DisambiguationService.Information.DEFSYN, DisambiguationService.TypeWords.RARE);
////
//////        Assert.assertEquals(definition, "buildings for carrying on industrial labor; \"they built a large plant to manufacture automobiles\"");
////        System.out.println(definition);
////        
////                System.out.println();
////        System.out.println();
////
//////        
//////        Document doc = XMLUtils.readXML(definition, "UTF-8");
//////        Element documentElement = doc.getDocumentElement();
//////        NodeList elementsNamed = XMLUtils.getElementsNamed(documentElement, "definition");
//////        
//////        Assert.assertEquals(1, elementsNamed.getLength());
//////         
//////        Element def = (Element) elementsNamed.item(0);
////////        Assert.assertEquals("Съществително нарицателно име", def.getAttribute("type"));
//////        
//////        String esperada = "buildings for carrying on industrial labor; \"they built a large plant to manufacture automobiles\"";
//////        Assert.assertEquals(esperada, def.getTextContent());
////    }
////
////    @Test
////    public void testENDeportes() throws IOException, ParserConfigurationException, SAXException, JWNLException, DisambiguationException {
////
////        System.out.println("DAILY NEWS (EN) - DEPORTES");
////
////        String text = "The Gunners, who are fifth, face Aston Villa at the Emirates on Saturday in a potentially "
////                + "explosive clash as anger grows among supporters. Wenger, under pressure after eight years without "
////                + "a trophy, is preparing to make sweeping changes to the squad in the summer. But despite fan "
////                + "discontent he is under no threat from the board and his contract, which runs to 2014, is expected "
////                + "to be fulfilled by both sides. Wenger was shocked by the gulf in class between his side and Bayern "
////                + "on Tuesday, but will be told there is significant money to spend this summer.Failure to finish in "
////                + "the top four could affect his plans and there is a back-up plan if they miss out for the first time "
////                + "since Wenger joined in 1996.";
////
////        String definition = WordNet.disambiguate(text, DisambiguationService.Language.EN, DisambiguationService.MethodDisambiguation.UKB, DisambiguationService.Information.DEFSYN, DisambiguationService.TypeWords.RARE);
////        System.out.println(definition);
////        
////                System.out.println();
////        System.out.println();
////
////    }
////
////    @Test
////    public void testENSalud() throws IOException, ParserConfigurationException, SAXException, JWNLException, DisambiguationException {
////
////        System.out.println("DAILY NEWS (EN) - SALUD");
////
////        String text = "One in four parents admit their child has never had an eye test, according to a report. "
////                + "The figure has almost doubled in a year from 14 per cent in 2011, despite two-yearly sight tests "
////                + "being free to children under 16 or older teenagers in full-time education. A further one in ten of "
////                + "the 4,300 parents surveyed cannot remember the last time their child had a sight test or believe it "
////                + "was more than ten years ago, says the report by the College of Optometrists.";
////
////        String definition = WordNet.disambiguate(text, DisambiguationService.Language.EN, DisambiguationService.MethodDisambiguation.MFS, DisambiguationService.Information.DEFSYN, DisambiguationService.TypeWords.SPECIALIZED);
////        System.out.println(definition);
////        
////                System.out.println();
////        System.out.println();
////
////    }
////    
////     @Test
////    public void testENPalabras() throws IOException, ParserConfigurationException, SAXException, JWNLException, DisambiguationException {
////
////        System.out.println("DAILY NEWS (EN) - SALUD");
////
////        String text = "42541: delivery, obstetrical_delivery,  142361: checkup, medical_checkup, medical_examination, medical_exam, medical, health_check,  148242: ligation,  148446: tubal_ligation,  153105: medical_diagnosis,  153288: prenatal_diagnosis,  153499: differential_diagnosis,  153665: prognosis, prospect, medical_prognosis,  177127: diagnostic_procedure, diagnostic_technique,  177783: emergency_procedure,  185438: breech_delivery, breech_birth, breech_presentation,  185612: frank_breech, frank_breech_delivery,  185778: cesarean_delivery, caesarean_delivery, caesarian_delivery, cesarean_section, cesarian_section, caesarean_section, caesarian_section, C-section, cesarean, cesarian, caesarean, caesarian, abdominal_delivery,  186251: forceps_delivery,  186549: midwifery,  226107: spasm,  226511: bronchospasm,  226711: cardiospasm,  226951: heave, retch,  227137: laryngismus,  227264: strangulation,  230324: abortion,  230475: spontaneous_abortion, miscarriage, stillbirth,  230703: habitual_abortion,  230824: imminent_abortion, threatened_abortion,  230997: incomplete_abortion, partial_abortion,  231161: induced_abortion,  231315: aborticide, feticide,  231412: therapeutic_abortion,  258695: rubdown,  322962: intradermal_injection,  323056: intramuscular_injection,  323152: intravenous_injection,  323262: fix,  323436: subcutaneous_injection,  323766: exchange_transfusion,  324056: transfusion, blood_transfusion,  395654: circumcision,  434844: crucifix,  435013: dip,  435182: double_leg_circle,  435401: grand_circle,  435563: cardiopulmonary_exercise,  435778: gymnastic_exercise,  436187: handstand,  436339: hang,  436609: bent_hang,  436702: inverted_hang,  436817: lever_hang,  436953: reverse_hang,  437067: straight_hang,  437219: piked_reverse_hang,  437321: kick_up,  438338: kip, upstart,  438606: long_fly,  438725: scissors,  438893: straddle,  485632: jump_rope,  485815: double_Dutch,  612160: medicine, practice_of_medicine, ";
////
////        String definition = WordNet.disambiguate(text, DisambiguationService.Language.EN, DisambiguationService.MethodDisambiguation.MFS, DisambiguationService.Information.DEFSYN, DisambiguationService.TypeWords.SPECIALIZED);
////        System.out.println(definition);
////        
////                System.out.println();
////        System.out.println();
////
////    }
////    @Test
////    public void testENEconomia() throws IOException, ParserConfigurationException, SAXException, JWNLException, DisambiguationException {
////
////        System.out.println("DAILY NEWS (EN) - ECONOMIA");
////
////        String text = "The Bank of England yesterday locked horns with the Treasury over the economy as the ‘friendless’ "
////                + "pound took another hammering on the financial markets. Documents published by the Bank showed it is "
////                + "edging closer to turning on the printing presses for a fourth time in a desperate effort to kick-start "
////                + "the recovery. But the interest-rate setting monetary policy committee also demanded ‘targeted "
////                + "interventions’ to boost the economy from ‘other UK authorities’. It was widely seen as a challenge "
////                + "to George Osborne to take radical action in next month’s Budget to bolster growth and avert a "
////                + "triple-dip recession. The comments, in the minutes of the MPC’s latest meeting, added weight to calls "
////                + "from the Chancellor’s critics for tax cuts, an assault on red tape and increased investment in "
////                + "transport projects and housing. The report also showed that Bank governor Sir Mervyn King wanted to "
////                + "launch a fourth round of quantitative easing this month – but was outvoted by other members of the MPC.";
////
////        String definition = WordNet.disambiguate(text, DisambiguationService.Language.EN, DisambiguationService.MethodDisambiguation.UKB, DisambiguationService.Information.SYNONYMS, DisambiguationService.TypeWords.BOTH);
////        System.out.println(definition);
////        
////                System.out.println();
////        System.out.println();
////
////    }
////
////    @Test
////    public void testESPolitica() throws IOException, ParserConfigurationException, SAXException, JWNLException, DisambiguationException {
////
////        System.out.println("ELPAIS (ES) - POLITICA");
////
////        String text = "Sostienen el Gobierno y el PP que Mariano Rajoy tiene en mente aprovechar su "
////                + "primer debate sobre el estado de la nación para intentar recuperar la iniciativa "
////                + "política. Para eso, subirá hoy a la tribuna del Congreso y hará balance del primer "
////                + "año en La Moncloa en la primera parte de su discurso; a continuación explicará cómo "
////                + "aprovechar las reformas estructurales e impopulares de los últimos 12 meses y "
////                + "rematará con una serie de reformas legales para hacer frente a la corrupción. "
////                + "Habrá compromiso para futuras reducciones de impuestos y medidas para incentivar "
////                + "el crecimiento. Rajoy no dará aún la cifra de déficit de 2012, pero sí otros datos, "
////                + "como los de balanza comercial o exportaciones para dar a entender que ya se ha "
////                + "tocado fondo en la crisis económica. Hará un reconocimiento a los ciudadanos "
////                + "por haber asumido el esfuerzo y habrá autocomplacencia por haber evitado recurrir "
////                + "a un segundo rescate de la Unión Europea.";
////
////        // String text = "Uno de los testigos citados por el juez Desmod Nair durante el juicio de asesinato en el que está acusado el exatleta paralímpico Oscar Pistorius, ha declarado haber escuchado gritos continuados desde el interior de la casa durante la noche del 14 de febrero antes de producirse los disparos. Una revelación que pone en entredicho la versión de Pistorius, que en todo momento ha defendido la idea de que disparó a través del cristal del cuarto de baño tras haber confundido a su pareja, Reeva Steenkamp, con un ladrón. En su declaración el deportista remarcó que antes de los hechos se encontraba durmiendo por lo que el presunto asesinato no se habría producido de manera premeditada como defiende la Fiscalía.";
////        String definition = WordNet.disambiguate(text, DisambiguationService.Language.ES, DisambiguationService.MethodDisambiguation.MFS, DisambiguationService.Information.DEFSYN, DisambiguationService.TypeWords.RARE);
////        System.out.println(definition);
////        
////                System.out.println();
////        System.out.println();
////
////    }
////    @Test
////    public void testESDeportes() throws IOException, ParserConfigurationException, SAXException, JWNLException, DisambiguationException {
////
////        System.out.println("EL PAIS (ES) - DEPORTES");
////
////        String text = "Jamás se ganó un partido sin tirar a portería y cuando no se marca un gol en campo contrario "
////                + "se puede haber firmado la eliminación en la Copa de Europa. Inanimado, el equipo azulgrana aceptó "
////                + "sin rechistar una inesperada y merecida derrota en San Siro, desactivado por el Milan. A los "
////                + "azulgrana les pudo un exceso de previsibilidad y un empacho de centrocampismo ante la pared levantada "
////                + "por Allegri. Ni Messi pudo con Abbiati, y ya se sabe que el Barça suele perder cuando faltan los "
////                + "goles del 10, acostumbrado a tomar por lo menos un tanto por partido. Anoche fueron dos, ambos "
////                + "cuando se suponía que el Barcelona había jugado para madurar el partido y desgastar al Milan, "
////                + "los dos un fiel compendio de lo que fue el encuentro. Una falta tonta de Alves, un error del "
////                + "árbitro al no apreciar las manos de Zapata y el tiro de gracia de Boateng. La jugada episódica "
////                + "marca de la casa en Italia: 1-0. El 2-0 lo firmó Muntari después de una asistencia de El "
////                + "Shaarawy a pase de Niang. La contra de siempre en Italia. Hay camisetas que convierten a jugadores "
////                + "discretos en grandes futbolistas, y una es la rossonera.";
////
////        String definition = WordNet.disambiguate(text, DisambiguationService.Language.ES, DisambiguationService.MethodDisambiguation.UKB, DisambiguationService.Information.DEFSYN, DisambiguationService.TypeWords.RARE);
////        System.out.println(definition);
////        
////        System.out.println();
////        System.out.println();
////
////    }
////    @Test
////    public void testESCultura() throws IOException, ParserConfigurationException, SAXException, JWNLException, DisambiguationException {
////
////        System.out.println("EL PAIS (ES) - CULTURA (CINE)");
////
////        String text = "Dos largometrajes producidos en parte por Israel y críticos con la ocupación de Palestina, "
////                + "Cinco cámaras rotas y The gatekeepers,se enfrentan este año en la categoría de mejor documental "
////                + "en los premios Oscar que la Academia de cine estadounidense entregará el próximo domingo. Ambos "
////                + "recogen puntos de vista que en principio parecen opuestos, el del ocupador y el del ocupado. Frente "
////                + "a los poderosos exdirectores del Shin Bet, la agencia de seguridad interior de Israel, que "
////                + "protagonizan uno de los documentales, se encuentran los habitantes de una pequeña villa amenazada "
////                + "en Cisjordania, el tema del otro. Inesperadamente, ambas producciones llegan a una conclusión "
////                + "muy similar: la de que la clase política de Israel ha desaprovechado la oportunidad de hacer de "
////                + "los palestinos compañeros en la paz.";
////
////        String definition = WordNet.disambiguate(text, DisambiguationService.Language.ES, DisambiguationService.MethodDisambiguation.MFS, DisambiguationService.Information.SYNONYMS, DisambiguationService.TypeWords.SPECIALIZED);
////        System.out.println(definition);
////        
////        System.out.println();
////                System.out.println();
////
////    }
////    @Test
////    public void testESMedico() throws IOException, ParserConfigurationException, SAXException, JWNLException, DisambiguationException {
////
////        System.out.println("COMPUMEDICINA(ES) - NOTICIA");
////
////        String text = "Aspirina, antibióticos, anticoagulantes, antiplaquetarios, antidepresivos, corticoides, tratamiento. Un estudio reciente halla que los bebés expuestos al VIH al nacer pero que no resultan infectados con "
////                + "el virus tienen menores niveles de anticuerpos para enfermedades como la tos ferina, el tétanos y el "
////                + "neumococo. Los investigadores recopilaron muestras séricas de 104 mujeres sudafricanas infectadas y no "
////                + "infectadas por VIH y de cien de sus bebés al nacer, y de 93 de los bebés a las 16 semanas de nacidos. "
////                + "Las muestras fueron analizadas para detectar niveles de anticuerpos específicos";
////
////        String definition = WordNet.disambiguate(text, DisambiguationService.Language.ES, DisambiguationService.MethodDisambiguation.UKB, DisambiguationService.Information.DEFSYN, DisambiguationService.TypeWords.BOTH);
////        System.out.println(definition);
////
////        System.out.println();
////        System.out.println();
////    }
////        @Test
////    public void testESTextCorpus() throws IOException, ParserConfigurationException, SAXException, JWNLException, DisambiguationException {
////
////        System.out.println("NOTICIA CORPUS");
////
////        String text = "España saca un bien. Solo un bien La receta catalana para mejorar: autonomía y más evaluación /*Ángel Gabilondo*/ (San Sebastián, 1949) responde a esta entrevista sin chaqueta ni corbata, en un Ministerio de Educación vacío, casi fantasmal. Los funcionarios están apurando el puente de la Constitución y ayer era festivo, al menos en el calendario, no tanto en el ministerio: los resultados del informe PISA sobre las destrezas en lectura, matemáticas y ciencias de los chicos de 15 años de 65 países se acaban de publicar. Y la interpretación que se hace de ellos no convence a los responsables educativos del Gobierno. Pregunta. ¿España está instalada en la mediocridad? Si no es así, ¿podría calificar usted mismo la situación educativa tras la prueba PISA? Respuesta. Yo pondría en cuestión lo de que está instalada. La educación está precisamente en ebullición, en actividad, en una búsqueda permanente, en un trabajo continuo desde todos los ángulos para encontrar los caminos más adecuados. Si hay que decir en qué situación nos encontramos, en términos educativos se dice bien, está bien. Bien no es sobresaliente ni notable, pero tampoco aprobado ni suspenso. España saca un bien, solo bien. Y no me conformo, porque nosotros vamos hacia procesos de excelencia. Tenemos que trabajar para mejorar mucho. P. ¿Por qué el sistema educativo no alcanza la media en los resultados de la OCDE? R. No estamos satisfechos, pero hay que saber de dónde venimos y reconocer el esfuerzo que ha hecho este país para avanzar, se han incorporado miles y miles de estudiantes y con un sistema muy inclusivo, que atiende necesidades muy específicas. Nos ha costado desde el punto de vista presupuestario y de la participación de toda la sociedad. Eso ya ha cambiado. También hay cosas que no hemos hecho bien: la rigidez del sistema, los valores que han imperado de éxito rápido y fácil... P. Pasa el tiempo y España parece que no se mueve en la tabla de resultados. ¿No calan las medidas en la escuela? R. Avanzamos, pero lo hacen demás países. Han calado muchas cosas: objetivos, escolarización. Que España tenga un sistema educativo de los más equitativos es absolutamente determinante. Podemos decir a todas las familias españolas que sean de la condición y el nivel cultural, social o económico que sean van a tener oportunidades educativas. ¿Esto no es noticiable? muy especiales, gentes de otros países, más profesores, programas individualizados. P. Pero la equidad ya salía bien en anteriores pruebas de PISA. ¿Por qué no se salta a la calidad? R. Hay que dar ese salto de calidad. Requiere inversión, pero también participación y el esfuerzo de toda la comunidad: familias, profesores, estudiantes; implicación y consenso, ese es el camino. Esto incentivaría mucho a los profesores. Y programas específicos para lectura, ciencias, para los que tienen peores resultados, para incorporar a los que vienen de otras culturas. Y un poquito de dinero. P. Dicen que los resultados están afectados por los muchos repetidores que han participado en la prueba. R. El 36% era repetidor. Se suele decir que en España el sistema es un coladero, pero no pueden ser verdad las dos cosas: que sea un coladero y que a la vez repita el 36%. Igual es más exigente de lo que creemos. P. ¿Si la repetición, tal cual está, no sirve, por qué no la eliminan o la cambian? R. No estoy en contra de ella, pero es más importante la individualización, la atención personalizada de los alumnos, el papel del profesor, programas de recuperación. Como en Finlandia. P. La educación personalizada tampoco es algo nuevo, se lleva insistiendo en ello hace tiempo. R. Y en algunos centros ya da muy buenos resultados. Hay muchas diferencias entre los alumnos, de dónde proceden, de los libros que hay en casa, de si el ámbito es rural o no. La condición y el entorno socioeconómico determinan mucho la educación, pero hay centros que trabajan con muy buenos resultados a pesar de ello. Todos los datos confirman que el papel del profesor, del centro y la programación singularizada son determinantes, pero eso no se logra de un día para otro. No va a haber milagros, ni con este Gobierno ni con ninguno. El papel de los centros es lo importante, la organización de los centros y cómo distribuye sus recursos y las prioridades que tiene. Tenemos programas para apoyarles en sus objetivos. No quiero que los profesores sientan desaliento al ver este informe. Yo les animo a que estén tranquilos y persistan en su trabajo. P. Los métodos de enseñanza de los docentes es una de las prácticas más inamovibles del sistema educativo. ¿Cree que también es de las más antiguas en la escuela Española? R. En general hemos tenido un sistema docente bastante convencional, de alguien que se sienta y transmite el saber. Pero los métodos de participación, de democratización, las nuevas tecnologías, la innovación, favorecen el éxito en los resultados. Dejemos de satanizar la innovación. En España ha habido un gran esfuerzo pedagógico serio, pero también algunas resistencias. P. ¿Por parte de los docentes? R. No, en general. Lo difícil es buscar el equilibrio. Conocimientos, competencias y valores tienen que ir juntos. A algunos profesores lo que les pasa es que han oído ya muchos discursos, han visto pasar leyes, ministros y ministras, cada uno con su buena nueva, y ya no es que duden de la buena voluntad de cada uno, es que acaban pensando que lo que se necesita es estabilidad normativa y claridad en los objetivos que se plantean. P. Pero ¿la formación docente es buena o habría que cambiar el sistema de acceso de los maestros a las escuelas con un periodo previo de prácticas, como propuso el ministro Rubalcaba recientemente? R. Hay cosas que se aprenden teóricamente y luego se aplican, pero otras solo se aprenden con la práctica, por eso me parece bueno el acceso del profesorado vinculado a la formación práctica. Siempre con el consenso. Ya tenemos la madurez suficiente para ir planteándolo, sin alarmas. P. ¿Cabe la posibilidad de que los equipos directivos decidan a qué profesores contratan, como ocurre en Finlandia? R. Creo que sí, pero dentro de lo que podría ser una oferta en igualdad de oportunidades y respetando los derechos adquiridos de todo el profesorado y los acuerdos con los agentes sociales. Pero habría que ver primero cómo se conforman esos equipos directivos; ese es otro debate. P. Tanto PISA como la evaluación de Primaria del ministerio dibujan un mapa con la mitad norte más exitosa que la sur. R. La relación entre la sociología, el sistema productivo y los resultados educativos es muy estrecha. Si se mira el abandono y el fracaso escolar, se dan en zonas con más turismo, más construcción, más servicios. Tiene más que ver con esto que con las políticas educativas. No es solo el sur, también parte de levante hasta Baleares, donde concurren muchos factores. P. En todo caso hay comunidades con peores resultados, siempre, que el resto. ¿No habría que compensarlas con una especie de fondo de cohesión? R. Sin querer quitarle importancia, no siempre es un problema de inversión. También lo es de una verdadera transformación sobre la importancia que da la sociedad a la educación. El presidente de Andalucía, José Antonio Griñán, ha convertido la educación en el corazón de su política como la vía para la transformación del modelo económico andaluz, es una orientación valiente y atinada. Hace falta una renovación cultural y sociológica. Es lo que pasa en Corea, no solo están los resultados de los alumnos, también la importancia que da toda la sociedad coreana a la educación. Por cierto, que Corea no es mi modelo educativo, aunque hay cosas que admiro, pero hay una concepción de la educación muy competitiva, con internados para el acceso a la universidad donde les apagan la luz y van con linternas a los baños para seguir estudiando. Es una mentalidad que respeto, pero no sé si se corresponde con el modelo español de vida y de sociedad. P. Si los factores socioeconómicos se quedan cortos para explicar la situación y lo importante es la organización interna de los centros, ¿hay que pensar que en algunas comunidades los colegios no lo están haciendo tan bien como en otras? R. No, lo que tenemos que pensar es que esto de dejar los estudios para ir a trabajar a la construcción no es la panacea, lo de emplearse cuanto antes sin tener la formación adecuada para luego quedarte en el paro y sin formación es el camino equivocado. Tenemos que hacer otras políticas, como son certificar lo que cada uno sabe, decirle qué complementos de formación puede conseguir.  P. ¿No es frustrante no avanzar lo suficiente cuando hay países que sí lo han hecho en el mismo tiempo? R. Yo creo que sí avanzaremos. Y no será una cosa del Ministerio de Educación sino de todo el país, porque existe la percepción en toda la sociedad de que la educación es una prioridad. Si no decaemos yo creo que va a haber un cambio en pocos años. No creo en discursos de resignación, es un mal mensaje no esperar más de este país. Podemos más como país. Y yo estoy viendo que las comunidades que se lo han tomado en serio han logrado buenos resultados. P. ¿Andalucía y Baleares no se lo han tomado en serio? R. Sí, pero de nuevo está la construcción, 1,2 millones de puestos de trabajo que se han venido abajo. La construcción seguirá existiendo, espero que con sistemas un poco más diversificados, y el turismo también, pero no va a emplear a tanta gente. Ahora hay que reorientarles profesionalmente. Además, en la Ley de Economía Sostenible flexibilizamos todo el sistema de FP. El año 2011 será el año de la FP.";
////
////        String definition = WordNet.disambiguate(text, DisambiguationService.Language.ES, DisambiguationService.MethodDisambiguation.MFS, DisambiguationService.Information.DEFSYN, DisambiguationService.TypeWords.RARE);
////        System.out.println(definition);
////
////        System.out.println();
////        System.out.println();
////    }
////    @Test
////    public void testESMedico2() throws IOException, ParserConfigurationException, SAXException, JWNLException, DisambiguationException {
////
////        System.out.println("COMPUMEDICINA(ES) - NOTICIA_2");
////
////        String text = "El valproato se receta para la epilepsia, y también para ciertos trastornos psiquiátricos y las "
////                + "migrañas. Otros estudios han mostrado que su uso durante el embarazo se asocia con defectos del "
////                + "nacimiento, y más recientemente, con un coeficiente intelectual (CI) más bajo en los niños de edad "
////                + "escolar. La Academia Americana de Neurología (American Academy of Neurology) desaconseja el uso del "
////                + "valproato en el embarazo, y algunos expertos consideran que no debe ser utilizado por las mujeres en "
////                + "edad fértil. Las mujeres para quienes el tratamiento con valproato es una opción deben discutir los "
////                + "riesgos y los beneficios de este fármaco con el médico antes del embarazo, para asegurar que su salud "
////                + "y la de su hijo potencial se vean optimizadas, planteó Rebecca Bromley, psicóloga clínica y asociada de "
////                + "investigación de la Universidad de Liverpool, quien dirigió el nuevo estudio. Planificar un embarazo "
////                + "en colaboración con el médico es importante si se toman antiepilépticos, añadió. Y la evidencia sugiere"
////                + " que el daño al feto ocurre a principios del embarazo, según el estudio.Pero las mujeres no deben alterar "
////                + "sus medicamentos sin hablar con el médico, anotó.";
////
////        String definition = WordNet.disambiguate(text, DisambiguationService.Language.ES, DisambiguationService.MethodDisambiguation.MFS, DisambiguationService.Information.DEFSYN, DisambiguationService.TypeWords.SPECIALIZED);
////        System.out.println(definition);
////
////        System.out.println();
////        System.out.println();
////    }
////    @Test
////    public void testESMedico3() throws IOException, ParserConfigurationException, SAXException, JWNLException, DisambiguationException {
////
////        System.out.println("COMPUMEDICINA(ES) - NOTICIA_3");
////
////        String text = "Los investigadores utilizaron electroencefalografías (EEG) para rastrear la actividad eléctrica de los "
////                + "cerebros de 30 niños autistas, y detectaron ciertas características en las conexiones cerebrales, según "
////                + "l estudio, que aparece en la edición el 27 de febrero de la revista BMC Medicine. En comparación con otros "
////                + "niños, los autistas tenían más conexiones de corto alcance dentro de distintas regiones del cerebro, pero "
////                + "menos conexiones entre las áreas más distantes, señalaron los investigadores del Hospital Pediátrico de "
////                + "Boston. Apuntaron que los hallazgos podrían ayudar a mejorar la comprensión sobre ciertas conductas de los "
////                + "niños autistas. Una red cerebral que tenga más conexiones de corto alcance que conexiones de largo alcance "
////                + "ayuda a explicar por qué un niño autista podría distinguirse en tareas específicas y enfocadas como "
////                + "memorizar las calles, pero no puede integrar información entre distintas áreas del cerebro para crear "
////                + "conceptos más amplios, plantearon los investigadores. Por ejemplo, un niño autista podría no comprender "
////                + "por qué un rostro parece realmente enojado, porque los centros visuales y los centros emocionales de su "
////                + "cerebro tienen menos comunicación entre sí, comentó el autor coprincipal del estudio, el Dr. Jurriaan "
////                + "Peters, en un comunicado de prensa del hospital. El cerebro no puede integrar esas áreas. Hace mucho con "
////                + "la información localmente, pero no la envía al resto del cerebro.";
////
////        String definition = WordNet.disambiguate(text, DisambiguationService.Language.ES, DisambiguationService.MethodDisambiguation.MFS, DisambiguationService.Information.DEFINITIONS, DisambiguationService.TypeWords.BOTH);
////        System.out.println(definition);
////
////        System.out.println();
////        System.out.println();
////    }
//}
