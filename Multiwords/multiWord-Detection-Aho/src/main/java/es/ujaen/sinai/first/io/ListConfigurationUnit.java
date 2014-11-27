package es.ujaen.sinai.first.io;

public class ListConfigurationUnit {
	
	private String languageCode="";
	private String name="";
	private  String location="";
	private String type="";
	private String outputAnnotationSetName="";
	private String outputAnnotationName="";
	
	public String getLanguageCode() {
		return languageCode;
	}
	public void setLanguageCode(String languageCode) {
		this.languageCode = languageCode;
	}
	public String getName() {
		return name;
	}
	public void setName(String name) {
		this.name = name;
	}
	public String getLocation() {
		return location;
	}
	public void setLocation(String location) {
		this.location = location;
	}
	public String getOutputAnnotationSetName() {
		return outputAnnotationSetName;
	}
	public void setOutputAnnotationSetName(String outputAnnotationSetName) {
		this.outputAnnotationSetName = outputAnnotationSetName;
	}
	public String getOutputAnnotationName() {
		return outputAnnotationName;
	}
	public void setOutputAnnotationName(String outputAnnotationName) {
		this.outputAnnotationName = outputAnnotationName;
	}
	public String getType() {
		return type;
	}
	public void setType(String type) {
		this.type = type;
	}

}
