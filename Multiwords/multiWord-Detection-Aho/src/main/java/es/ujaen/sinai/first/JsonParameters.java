package es.ujaen.sinai.first;
import org.apache.log4j.Logger;
import org.json.simple.JSONObject;
import org.json.simple.parser.JSONParser;
import org.json.simple.parser.ParseException;

public class JsonParameters {
	
	private JSONObject jsonObject;
	private boolean isJson=true;
	private Logger logger= Logger.getLogger(JsonParameters.class);
	
	public boolean isJsonParameter ()
	{
		return isJson;
	}
	
	public JsonParameters (String parameters)
	{
		JSONParser parser = new JSONParser();
		 try {
			jsonObject = (JSONObject)parser.parse(parameters);
		} catch (ParseException e) {
			isJson=false;
			logger.debug("The parameters cannot be parsed",e);
		}
	}
	
	public String getValue (String parameter)
	{
		String parameterValue= (String) jsonObject.get(parameter);
		if (parameterValue==null)
		{
			parameterValue="y";
		}
		return parameterValue;
	}

}