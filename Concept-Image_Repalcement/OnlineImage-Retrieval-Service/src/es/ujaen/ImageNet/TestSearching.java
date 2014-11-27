package es.ujaen.ImageNet;

import java.io.IOException;

import org.apache.lucene.queryParser.ParseException;

public class TestSearching {
	
	public static void main(String[] args) throws IllegalArgumentException,
	IOException, ParseException {
		String answers[]=SearchImages.search("PRESIDENT");
		for (int i=0;i<answers.length;i++)
		{
			System.out.println ("Found\t"+answers[i]);
		}
	}
}
