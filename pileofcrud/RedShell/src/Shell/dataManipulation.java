package Shell;
public class dataManipulation {
	
	public static void convert(String paramOne, String paramTwo, String paramThree){
		
		if (paramOne.equalsIgnoreCase(" csv")){ /*important*/
			convertToCSV(paramTwo);
		}
		
		if (paramOne.equalsIgnoreCase(" ts")){
			convertToTS(paramTwo);
		}
		
		if (paramOne.equalsIgnoreCase(" json")){
			convertToJSON(paramTwo);
		}
		
		if (paramOne.equalsIgnoreCase(" txt")){ /*important*/
			convertToTXT(paramTwo);
		}
		
		if(paramOne.equalsIgnoreCase(" xml")){
			convertToXML(paramTwo);
		}
		
		if(paramOne.equalsIgnoreCase(" xls")){ /*important*/
			convertToXML(paramTwo);
		}
	}
	
	private static void convertToCSV(String paramTwo){
		
	}
	
	private static void convertToTS(String paramTwo){
		
	}
	
	private static void convertToJSON(String paramTwo){
		
	}
	
	private static void convertToTXT(String paramTwo){
		
	}
	
	private static void convertToXML(String paramTwo){
		
	}
	
	public static void main(String[] args) {
	//this file contains the method to decide which conversion method to use 
	//as well as the actual conversion methods
	 System.out.println(System.getProperty("user.home"));
	}
}