package es.ujaen.aggregator;

public class TestSplit {

	public static void main(String[] args) {
		
		String test="\n";
		
		String [] arTest=test.split("");
		
		for (String letter:arTest)
		{
			if (letter.compareTo("\n")==0)
			{
				System.out.println("EOL");
			}
				else
				{
					System.out.println(letter);
				}
			
		}
		
		System.out.println("Gata");
		
		

	}

}
