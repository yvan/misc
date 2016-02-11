package Shell;
class Commands implements CommandLog {
	
	private String[] stringArray = {"","","","","","","","","","","",""};
	private int size = stringArray.length;
	public int marker = 0; 
	
	public void insert(String s){
		
		for (int i=0; i<size; i++){
			//this structure is for development ease, adding more commands from Shell main.
			if (stringArray[i]==""){
				
				stringArray[i]=s;
				break;
			}
		}
	}
	
	
	public boolean contains(String e){
		
		int location = 0;
		int lastindex = stringArray.length-1;
		
		while (location <= lastindex){
			
			if (e.equalsIgnoreCase(stringArray[location])){
				
				marker = location;
				return true;
			}
			
			else{
				location++;
			}
		}
		
		return false;
	}
	
	
	public String[] parseCommand(String e){
		
		String[] parsedCommands = {"","","","","","","","","",""};
		
		int count = 0;
		int track = 0;
		
		for (int i=0; i<e.length(); i++){
			
			if (e.charAt(i)==' ' && count==4 && track !=i){
				count=5;
				track=i;
			}
			
			if (count==5){
				parsedCommands[4]+=e.charAt(i);
			}
			
			if (e.charAt(i)==' ' && count==3 && track!=i){
				count=4;
				track=i;
			}
									
			if(count==4){
				parsedCommands[3]+=e.charAt(i);
			}
			
			
			if (e.charAt(i)==' ' && count==2 && track!=i){
				count=3;
				track=i;
			}
						
			if(count==3){
				parsedCommands[2]+=e.charAt(i);
			}
			
			if (e.charAt(i)==' ' && count==1 && track!=i ){
				count=2;
				track=i;
			}
						
			if (count==2){
				parsedCommands[1]+=e.charAt(i);
			}
			
			if (e.charAt(i)==' ' && count==0){
				count=1;
				track=i;
			}
			
			if(count==1){
				parsedCommands[0]+=e.charAt(i);
			}
					
		}
		
		return parsedCommands;
	}
	
	
	public String toString(int num){
		return stringArray[num];
		
	}
	
	
	public static void main(String[] args) {
			
	}
}