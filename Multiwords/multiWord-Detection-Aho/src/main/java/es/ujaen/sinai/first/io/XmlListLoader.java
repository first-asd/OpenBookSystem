
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
 * @author Eduard
 */
public class XmlListLoader implements IListLoader {
	
	private Logger 	logger = Logger.getLogger(XmlListLoader.class);

	public List<MultiWordUnit> load(String path) {
		SAXBuilder xmlParser = new SAXBuilder();
		File xmlFile = new File(path);
		List<MultiWordUnit> mwUnits = new Vector<MultiWordUnit>();
		try {
			Document doc = xmlParser.build(xmlFile);
			Element rootNode = doc.getRootElement();
			List<Element> multiwordUnits = rootNode.getChildren("MultiWordUnit");
			for(int i = 0; i < multiwordUnits.size(); i++) {
				
				MultiWordUnit mwUnit = new MultiWordUnit();
				String text = "";
				text = multiwordUnits.get(i).getChildText("string").toLowerCase();
				if(text != null)
					mwUnit.setString(text);
				text = multiwordUnits.get(i).getChildText("lemma").toLowerCase();
					if(text != null)
						mwUnit.setLemma(text);
				text = multiwordUnits.get(i).getChildText("definition");
				if(text != null)
					mwUnit.setDefinition(text);
				text = multiwordUnits.get(i).getChildText("wikipediaURL");
				if(text != null)
					mwUnit.setWikipediaURL(text);
				
				mwUnits.add(mwUnit);
			}
			
		} catch (JDOMException e) {
			logger.error ("JDOMException Error when parsing one of the mw Lists"+e);
		} catch (IOException e) {
			logger.error ("IO Exception when parsing one of the mw Lists"+e);
		}
		
		return (mwUnits);
	}

}
