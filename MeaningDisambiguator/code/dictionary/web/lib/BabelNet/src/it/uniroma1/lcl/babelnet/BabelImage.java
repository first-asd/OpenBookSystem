package it.uniroma1.lcl.babelnet;

import it.uniroma1.lcl.jlt.util.Language;
import it.uniroma1.lcl.jlt.util.Strings;
import it.uniroma1.lcl.jlt.web.WGet;

import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.UnsupportedEncodingException;
import java.net.HttpURLConnection;
import java.net.MalformedURLException;
import java.net.URI;
import java.net.URISyntaxException;
import java.net.URL;
import java.net.URLDecoder;
import java.util.ArrayList;
import java.util.List;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import org.apache.commons.codec.digest.DigestUtils;

/**
 * An image in BabelNet.
 * 
 * @author ponzetto
 *
 */
public class BabelImage
{
	/*
	 * Used to capture Wikipedia image redirections
	 */
	Pattern CANONICAL_PATTERN =
		Pattern.compile("<link rel=\"canonical\" href=\".*/(.*?)\" />");
	
	/*
	 * The default English Wikipedia HOST
	 * 
	 */
	private static final String EN_WIKIPEDIA_HOST = "en.wikipedia.org";

	/*
	 * The default English Wikipedia PATH
	 * 
	 */
	private static final String EN_WIKIPEDIA_PATH = "/wiki/";
	
	/*
	 * The default image URL
	 * 
	 */
	private static final String URL_PREFIX = "http://upload.wikimedia.org/wikipedia/commons/";

	/*
	 * Sometimes image-URL are .../wikipedia/LANGUAGE/
	 */
	private static final String BACKOFF_URL_PREFIX = "http://upload.wikimedia.org/wikipedia/";
	
	/**
	 * The short name / MediaWiki page name for the image, e.g.
	 * 
	 * "File:Haile-newyork-cropforfocus.jpg"
	 */
	private final String name;

	/**
	 * The language of the Wikipedia from which <b>this</b> image comes from
	 */
	private final Language language;
	
	/**
	 * The URL to the actual image, e.g.
	 * 
	 * http://upload.wikimedia.org/wikipedia/commons/9/94/Haile-newyork-cropforfocus.jpg
	 * 
	 */
	private final String url;
	
	/**
	 * Creates a new instance of {@link BabelImage}
	 * 
	 * @param imageName
	 *            the MediaWiki page name for the image - something like
	 *            "LANGUAGE:Image:..."
	 */
	public BabelImage(String imageName)
	{
		// identifies the language
		int colonIdx = imageName.indexOf(":");
		if (colonIdx == -1) 
			throw new RuntimeException("Invalid image name: " + imageName);
		Language language = Language.valueOf(imageName.substring(0, colonIdx));
		
		// removes trailing "File:" or "Image:"
		String cleanImageName = imageName.substring(colonIdx+1);
		colonIdx = cleanImageName.indexOf(":");
		if (colonIdx != -1) cleanImageName = cleanImageName.substring(colonIdx+1);
		cleanImageName = Strings.forceFirstCharUppercase(cleanImageName);
		
		// e.g. "Paula_Radcliffe.jpg"
		this.name = cleanImageName.trim();
		// Language.EN for instance
		this.language = language;
		// http://upload.wikimedia.org/wikipedia/commons/a/ae/Paula_Radcliffe.jpg
		this.url = createURL(name);
	}
	
	/**
	 * Gets the MediaWiki page name for <b>this</b> image.
	 * 
	 * @return the MediaWiki page name for <b>this</b> image.
	 */
	public String getName()
	{
		return name;
	}

	/**
	 * Gets the full URL <b>this</b> image.
	 * 
	 * @return the URL from which <b>this</b> image can be retrieved.
	 */
	public String getUrl()
	{
		return url;
	}

	/**
	 * Gets a verified version of the full URL <b>this</b> image. Checks whether
	 * possible URLs of this image (including <b>redirections</b>) exist or
	 * return 404.
	 * 
	 * @return a validated, known-to-exists, URL from which <b>this</b> image
	 *         can be retrieved.
	 */
	public String getValidatedUrl()
	{
		// try the "base" search first
		String validated = getValidatedUrl(url, language);
		if (validated != null) return validated;
		
		// otherwise check whether it's a redirection
		//
		// e.g. http://en.wikipedia.org/wiki/File:Cheese_07_bg_042906.jpg
		try
		{
			URI uri = new URI(
				"http", 
				    EN_WIKIPEDIA_HOST, 
				    EN_WIKIPEDIA_PATH+"File:"+name,
				    null);
			String wikiUrl = uri.toASCIIString();
			
			// get the page content
			ByteArrayOutputStream os = new ByteArrayOutputStream();
			WGet.wGet(wikiUrl, os);
			String content = os.toString();
			
			// check for a URL labeled as "canonical"
			Matcher matcher = CANONICAL_PATTERN.matcher(content);
			if (matcher.find())
			{
				// got it, e.g. File:Mozzarella_cheese.jpg
				String redirectedName = matcher.group(1);
				String cleanRedirectedName = redirectedName;
				int colonIdx = redirectedName.indexOf(":");
				if (colonIdx != -1) cleanRedirectedName = cleanRedirectedName.substring(colonIdx+1);
				cleanRedirectedName =
					Strings.forceFirstCharUppercase(cleanRedirectedName).trim();
				
				// create the redirection's URL and check it exists
				String redirectedURL = createURL(cleanRedirectedName);
				return getValidatedUrl(redirectedURL, language);
			}
			return null;
		}
		catch (URISyntaxException e)
		{
			return null;
		}
	}

	/**
	 * Gets a verified version of the full URL <b>this</b> image. Checks whether
	 * possible URLs of this image exist or return 404.
	 * 
	 * @return a validated, known-to-exists, URL from which <b>this</b> image
	 *         can be retrieved.
	 */
	public String getSimpleValidatedUrl()
	{
		return getValidatedUrl(url, language);
	}
	
	/**
	 * Gets a verified version of the full input URL <b>this</b> image. Checks
	 * whether possible URLs of this image exist or return 404.
	 * 
	 * @return a validated, known-to-exists, URL from which an image can be
	 *         retrieved.
	 */
	private static String getValidatedUrl(String url, Language language)
	{
		String validated = "";
		if (testURLexists(url))
			validated = url;
		else
		{
			String alternateUrl =
				BACKOFF_URL_PREFIX + language.name().toLowerCase() + "/" +
				url.substring(URL_PREFIX.length());
			if (testURLexists(alternateUrl))
				validated = alternateUrl;
		}
		
		// not much to do here...
		if (validated.isEmpty()) return null;
		// check that it is not already URL encoded
		if (isURLEncoded(validated)) return validated;
		
		try
		{
			// encode the URL in an appropriate way
			int idx = validated.indexOf("/", 7);
			String host = validated.substring(7, idx);
			String path = validated.substring(idx);
			URI uri = new URI("http", host,  path, null);
			return uri.toASCIIString();
		}
		catch (URISyntaxException e) { return null; }
	}
	
	@Override
	public String toString()
	{
		return "<a href=\"" + url + "\">" + name + "</a>"; 
	}

	/**
	 * Checks whether a given URL exists, namely it does return a 404 error
	 * code
	 * 
	 * @param urlString
	 * @return whether an input URL returns a 404.
	 */
	private static boolean testURLexists(String urlString)
	{
		try
		{
			int responseCode = getResponseCode(urlString);
			return (responseCode == HttpURLConnection.HTTP_OK);
		}
		catch (MalformedURLException mue) { return false; }
		catch (IOException ioe) { return false; }
	}
	
	/**
	 * Gets the response code for an input URL string
	 * 
	 * @param urlString
	 * @return the response code for an input URL
	 * @throws MalformedURLException
	 * @throws IOException
	 */
	public static int getResponseCode(String urlString) throws MalformedURLException, IOException
	{
	    URL url = new URL(urlString); 
	    HttpURLConnection huc =  (HttpURLConnection)  url.openConnection(); 
	    huc.setRequestMethod("HEAD");
	    huc.connect();
	    return huc.getResponseCode();
	}
	
	/**
	 * Creates a full-fledged URL from an image name
	 * 
	 * @param name
	 * @return
	 */
	private static String createURL(String name)
	{
		String url = "";
		
		try
		{
			byte[] nameBytes = name.getBytes("UTF-8");
			// e.g. "aeda0affe44d1e537748dbed05a82a68"
			String md5Hex = DigestUtils.md5Hex(nameBytes);
			// "a"
			String hash1 = md5Hex.substring(0, 1);
			// "ae"
			String hash2 = md5Hex.substring(0, 2);
			// http://upload.wikimedia.org/wikipedia/commons/a/ae/Paula_Radcliffe.jpg
			url = URL_PREFIX + hash1 + "/" + hash2 + "/" + name;
		}
		catch (UnsupportedEncodingException uee)
		{
			throw new RuntimeException("Cannot init: " + uee);
		}
		
		return url;
	}
	
	private static boolean isURLEncoded(String urlString)
	{
        try
		{
			if (urlString.equals(URLDecoder.decode(urlString, "UTF-8")))
				return false;
			else
				return true;
		}
		catch (UnsupportedEncodingException e)
		{
			return false;
		}
	}
	
	/**
	 * Use for testing
	 * 
	 * @param args
	 */
	public static void main(String[] args)
	{
		try
		{
			List<String> tests = new ArrayList<String>();
			
			// some examples of image redirections
			tests.add("EN:Image:☑.svg");
			tests.add("EN:File:Cheese_07_bg_042906.jpg");
			// some personal heroes
			tests.add("EN:File:Abebe_Bikila_1968c.jpg");
			tests.add("EN:File:Oscar_Pistorius_2_Daegu_2011.jpg");
			// babelnet itself
			tests.add("EN:File:The_BabelNet_structure.png");
			// some images in languages other than English
			tests.add("DE:Bild:Porte-Soufflante.jpg");
			tests.add("ES:Archivo:Han_Dynasty_100_BCE.png");
			tests.add("FR:Fichier:Youri_Djorkaeff_2011.jpg");
			tests.add("IT:File:Bombolo.jpeg");
			// an image with a complex label
			tests.add("EN:File:Bundesarchiv_Bild_183-77625-0001,_Brigade_Komsomol\"_schreibt_an_den_Staatsrat\".jpg");
			// and yet another complex one...
			tests.add("EN:File:Malus_domestica_-_Köhler–s_Medizinal-Pflanzen-108.jpg");
			// and its redirection!
			tests.add("EN:File:Koeh-108.jpg");
			
			for (String test : tests)
			{
				BabelImage img = new BabelImage(test);
				System.out.println(
					"TESTING FOR IMAGE: " + test +
					"\n\tURL: " + img.getUrl() +
					"\n\tSIMPLE VALIDATED URL: " + img.getSimpleValidatedUrl() +
					"\n\tFULL VALIDATED URL: " + img.getValidatedUrl()+
					"\n-----");
			}
		}
		catch (Exception e)
		{
			e.printStackTrace();
		}
	}
}