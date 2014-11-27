package es.ujaen.sinai.first.io;
import java.io.File;
import java.io.IOException;
import java.util.List;
import java.util.Vector;

import org.apache.log4j.Logger;
import org.jdom2.Document;
import org.jdom2.Element;
import org.jdom2.JDOMException;
import org.jdom2.input.SAXBuilder;
import es.ujaen.sinai.first.MultiWordUnit;

/**
 * Here I load the Configuration of MultiWords Lists.
 * @author Eduard
 */

public class MultiWordListConfigurationLoader {
	
	private Logger 	logger = Logger.getLogger(MultiWordListConfigurationLoader.class);

	public List<ListConfigurationUnit> load(String path) {
		SAXBuilder xmlParser = new SAXBuilder();
		File xmlFile = new File(path);
		List<ListConfigurationUnit> listUnits = new Vector<ListConfigurationUnit>();
		try {
			Document doc = xmlParser.build(xmlFile);
			Element rootNode = doc.getRootElement();
			List<Element> listConfigurationUnits = rootNode.getChildren("listDescription");
			for(int i = 0; i < listConfigurationUnits .size(); i++) {
				ListConfigurationUnit listUnit = new ListConfigurationUnit();
				
				String languageCode = "";
				 languageCode= listConfigurationUnits .get(i).getChildText("languageCode");
				if( languageCode!= null)
					listUnit.setLanguageCode( languageCode);
				
				String name = "";
				name= listConfigurationUnits .get(i).getChildText("name");
				if(name != null)
					listUnit.setName(name);
				
				String type = "";
				type= listConfigurationUnits .get(i).getChildText("type");
				if(type != null)
					listUnit.setType(type);
				
				String location= "";
				location =listConfigurationUnits .get(i).getChildText("location");
				if(location != null)
					listUnit.setLocation(location);
				
				String outputAnnotationSetName= "";
				outputAnnotationSetName= listConfigurationUnits .get(i).getChildText("outputAnnotationSetName");
				if(outputAnnotationSetName != null)
					listUnit.setOutputAnnotationSetName(outputAnnotationSetName);
				
				String outputAnnotationName= "";
				outputAnnotationName = listConfigurationUnits .get(i).getChildText("outputAnnotationName");
				if(outputAnnotationName != null)
					listUnit.setOutputAnnotationName(outputAnnotationName);
				
				listUnits.add(listUnit);
			}
			
		} catch (JDOMException e) {
			logger.error ("JDOMException Error when parsing one of the mw Lists"+e);
		} catch (IOException e) {
			logger.error ("IO Exception when parsing one of the mw Lists"+e);
		}
		
		return (listUnits);
	}

}
