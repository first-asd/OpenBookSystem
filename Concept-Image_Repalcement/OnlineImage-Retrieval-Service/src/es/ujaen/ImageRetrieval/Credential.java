package es.ujaen.ImageRetrieval;

public class Credential {
	
	private String userId;
	private String password;
	private boolean isValidKey;
	
	
	public void setUserId(String userId) {
		this.userId = userId;
	}
	
	public String getUserId() {
		return userId;
	}
	
	public void setPassword(String password) {
		this.password = password;
	}
	
	
	public String getPassword() {
		return password;
	}

	public void setValidKey(boolean isValidKey) {
		this.isValidKey = isValidKey;
	}

	public boolean isValidKey() {
		return isValidKey;
	}
	
	

}
