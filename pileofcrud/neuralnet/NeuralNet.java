import java.awt.*;
import javax.swing.*;
import java.util.*;

public class NeuralNet {

	public static int USR_IN_CONST= 4;
	
	public static void main(String[] args) {
		
		boolean exit = false;
		
		int count2=0;
		
		String usrIn_1 = JOptionPane.showInputDialog (null, "Type binary value to learn. It must be divisble by 4.");
		
		NeuronF[] NeuroArray;
		
		NeuroArray = new NeuronF[usrIn_1.length()/4];
		
		for (int p=0; p<NeuroArray.length; p++){

			NeuroArray[p]= new NeuronF();
		}
		
		
		while (!exit){
		
			String usrIn_RT = JOptionPane.showInputDialog (null, "Do you want to train or just test a value? 1-to train, 2-to test a value.");
			
			int usrIn_RTp = Integer.parseInt(usrIn_RT);
			
			if (usrIn_RTp==1){
			
				if (count2!=0){

					usrIn_1 = JOptionPane.showInputDialog (null, "Type binary value to learn. It must be divisble by 4 and the same length as the original input.");
				}
							
				System.out.println("You have entered a "+usrIn_1.length()+" digit long input. Your net will be trained on the value: "+usrIn_1);
									
				int[][] parsed_Array = new int[4][usrIn_1.length()/4];
							
				int count =0;
							
				for (int y=0; y<usrIn_1.length()/4; y++){
					for (int i=0; i<4; i++){

						parsed_Array[i][y] = (int)usrIn_1.charAt(i+count);
					}
					count=count+4;
				}
							
				count=0;
							
				for (int y=0; y<usrIn_1.length()/4; y++){
					for (int i=0; i<4; i++){
						if (parsed_Array[i][y]==49){

							parsed_Array[i][y] = 1;
						}
						else{
							parsed_Array[i][y] = 0;
						}
								
					}
				}
							
							
							
				int[][] dummy_Array = new int[4][1];
							
				for (int p=0; p<NeuroArray.length; p++){
					for (int y=0; y<1; y++){
						for (int i=0; i<4; i++){

							dummy_Array[i][y] = parsed_Array[i][y+p];
						}
					}
					NeuroArray[p].train(dummy_Array);
				}
			}	
			
		else{	
			String usrIn_2 = JOptionPane.showInputDialog (null, "What value would you like to test on the net? It should be "+usrIn_1.length()+" digits.");
			
			int[][] parsed_Array2 = new int[4][usrIn_1.length()/4];
							
			int countz =0;
			
			for (int y=0; y<usrIn_1.length()/4; y++){
				for (int i=0; i<4; i++){

					parsed_Array2[i][y] = (int)usrIn_2.charAt(i+countz);
				}
				countz=countz+4;
			}
						
			countz=0;
			
			for (int y=0; y<usrIn_1.length()/4; y++){
				for (int i=0; i<4; i++){
					if (parsed_Array2[i][y]==49){

						parsed_Array2[i][y] = 1;
					}
					else{

						parsed_Array2[i][y] = 0;
					}
				}			
			}
			
			String final_OUT = "";
			
			int[][] dummy_Array2 = new int[4][1];
			
			for (int p=0; p<NeuroArray.length; p++){
				for (int y=0; y<1; y++){
					for (int i=0; i<4; i++){

							dummy_Array2[i][y] = parsed_Array2[i][y+p];
			
					}
				}
				final_OUT=final_OUT+NeuroArray[p].check(NeuroArray[p].ever, dummy_Array2);
			}
			
			
			System.out.println("Your input "+usrIn_2+" , and the net's output :" +final_OUT);
			
			/*
			String usrIn_3 = JOptionPane.showInputDialog (null, "Do you want to exit? Type '1' for no or '2' for yes.");
			
			int usrIn_3p = Integer.parseInt(usrIn_3);
			
			if (usrIn_3p==2){
				exit=true;
			}
			*/
			
			
		}

		count2+=1;
		}
	}
}
