package Shell;
import java.io.*;

class manual {
	
	private String[] sArray = new String[100];
	
	public String[] toLine(String paramOne){
			
			 //may not fit all file lines in future is arbitrary
			
			try {
				
				String path = System.getProperty("user.home");
				
				//change path to end user directory structure
				File Manual = new File(path+"/Documents/code/AnaphoraShell/manFiles/"+paramOne+".txt");
				
				//Importing file
				
				FileInputStream ManualStream = new FileInputStream(Manual);
				//Opening input stream

				BufferedReader ManReader = new BufferedReader(new InputStreamReader(ManualStream));
				//Reading input stream, parsing through buffered reader
				
				String ManLine;
				//declaring string to be returned
				
				int count = 0;
				
				while((ManLine = ManReader.readLine()) != null) {					//Each time BufferedReader.readLine() is called, the next complete single line is returned
					//Looping while each line is not null
					
					sArray[count] = ManLine;
					//System.out.println(ManLine);
					//Printing line by line	
					count++;
				}
				
				ManualStream.close();
				//Closing input stream
				
			} catch(NullPointerException e){
				
				System.out.println("File not found");
				//Need to figure this one out/find out what triggers the catch, if any. Should be file import but may trigger as subset of IOException.
			}
			
			catch (IOException f) {
				
				System.out.println("Command not found");
			};
			
			return sArray;

	}

	//Testing
	
	public static void main(String[] args) {
		
	}
}