package es.ujaen.ImageRetrieval;

import java.io.BufferedReader;
import java.io.FileInputStream;
import java.io.InputStreamReader;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.Map;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

public class ReadConfigurationFile {
	
	
	public static  ArrayList <Credential>  getEngineCredentials(String configurationFilePath )
	   {
		   
		  ArrayList <Credential> credentials = new ArrayList <Credential> (); 
		   
		   try{
				BufferedReader input = new BufferedReader(new InputStreamReader(new FileInputStream(configurationFilePath ),"UTF-8"));
				String  currentLine;
				 while ((currentLine = input.readLine()) != null)
				 {
					 String[] pairs=currentLine.split("@@");
					 
					 //UserId or Equivalent
					 String[] componentsOne =pairs[0].split("###");
					 String userId=componentsOne[1];
					
					 //Password or Equivalent
					 String[] componentsTwo =pairs[1].split("###");
					 String password=componentsTwo[1];
					
					 Credential currentCredential = new Credential ();
					 
					 currentCredential.setUserId(userId);
					 currentCredential.setPassword(password);
					 currentCredential.setValidKey(true);
					 
					 credentials.add(currentCredential);
				 }
				 input.close();
			}
			catch(Exception e){
				
			}
		   
		   return credentials; 
	   }

}
