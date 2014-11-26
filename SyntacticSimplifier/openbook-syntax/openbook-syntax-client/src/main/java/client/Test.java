package client;

import java.util.regex.Matcher;
import java.util.regex.Pattern;

public class Test {

	/**
	 * @param args
	 */
	public static void main(String[] args) {
		// TODO Auto-generated method stub

		String type="SSCCV";//theInstance.getFeatures().get("type");
		if (type.matches("(STQ|COMBINATORY|SPECIAL|HELP)")){
			//theInstance.getFeatures().put("chunk",type);
		}else {
			Pattern p=Pattern.compile("(SS|ES|C)(P|L|M|C|I)(V|N|A|Adv|P|Q|I|M|CV)([1-5]?)");
			Matcher m=p.matcher(type);
			if (m.matches()){
				m.group(1);
				m.group(2);
				m.group(3);
				if (m.groupCount()>3){
					//m.group(3)+m.group(4);
				}
			}else{
				System.err.println("Unparsed sync annotation type: "+ type);
			}
		} 
	}

}
