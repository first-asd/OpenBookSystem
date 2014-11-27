package es.ujaen.images.common;

public class QueryResponse {
	
	private String imageTitle="";
	private String imageURL="";
	private String query="";
	
	
	public  void setTitle (String title)
	{
		this.imageTitle=title;
	}
	
	public void setImageUrl (String imageURL)
	{
		this.imageURL=imageURL;
	}
	
	public void setQuery (String query)
	{
		this.query=query;
	}
	
	public String getQuery ()
	{
		return query;
	}
	
	public String getTitle ()
	{
		return this.imageTitle;
	}
	
	public String getImageURL ()
	{
		return this.imageURL;
	}

}
