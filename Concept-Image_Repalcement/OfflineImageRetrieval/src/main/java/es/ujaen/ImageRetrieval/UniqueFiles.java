package es.ujaen.ImageRetrieval;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.Calendar;
import java.util.Date;
import java.util.GregorianCalendar;


/**
 * The Purpose of this Class is to obtain Unique File Names using the time system.
 * In the context of multitasking is not feasible to have only one file to save the content of the gate File received as input.
 * @author Eduard
 */
public class UniqueFiles {	
	
	
	public String getFileidentifier (String fileName, String extension)
	{
		Calendar cal = new GregorianCalendar();
	    Date creationDate = cal.getTime();
	    SimpleDateFormat date_format = new SimpleDateFormat("dd-MMM-yyyy-hh.mm.ss.SSSS");
	    String identifier=date_format.format(creationDate);
	    String finalFileName=fileName+"-"+identifier+"."+extension;
		return finalFileName;
	}

}
