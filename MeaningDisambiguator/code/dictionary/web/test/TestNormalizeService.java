//
//import es.ua.dictionary.NormalizeException;
//import es.ua.dictionary.NormalizeService;
//import net.sf.json.JSONArray;
//import net.sf.json.JSONObject;
//import net.sf.json.JSONSerializer;
//import org.junit.Test;
//
///*
// * To change this template, choose Tools | Templates
// * and open the template in the editor.
// */
//
///**
// *
// * @author lcanales
// */
//public class TestNormalizeService {
//    private static NormalizeService normalize;
//
//    public TestNormalizeService() {
//        normalize = new NormalizeService();
//    }
//    
//    @Test
//    public void testJSONParameters() throws NormalizeException {
//
//        String JSONParam = "{\"lang\": \"es\", \"methodDisam\": \"MFS\",\"returnInfo\": \"DEFSYN\",\"numMaxDefinitions\": 2,"
//                + "\"typeWords\": [\"OOV\",\"ACRONYMS\"]}";
//        
//        JSONObject obj = (JSONObject) JSONSerializer.toJSON(JSONParam);
//        String lang = obj.getString("lang");
//        int numDef = obj.getInt("numMaxDefinitions");
//        JSONArray typeWords = obj.getJSONArray("typeWords");
//        
//        
//        normalize.normalize("es", obj.toString());
//    }
//    
//    
//}
