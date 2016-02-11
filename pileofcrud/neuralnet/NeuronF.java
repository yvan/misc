public class NeuronF{

	public static void main(String[] args){}
	
	int[][] ever = new int[NeuralNet.USR_IN_CONST][NeuralNet.USR_IN_CONST];
	
	int[][] combination = new int[NeuralNet.USR_IN_CONST][NeuralNet.USR_IN_CONST];
	
	public void train(int[][] input){
	
			int[][] inverse = new int[1][NeuralNet.USR_IN_CONST];
					
					
			for (int i=0; i<input.length; i++){

				if (input[i][0]==0){

					input[i][0]=-1;
				}
				
			}
					
			for (int j=0; j<input.length; j++){

				inverse[0][j]=input[j][0];
			}
					
			for (int t=0; t<input.length; t++){
				
				for (int r=0; r<input.length; r++){

					combination[t][r]=input[t][0]*inverse[0][r];

					if (t==r){

						combination[t][r]=0;
					}
				}	
			}
			
			for (int t=0; t<input.length; t++){
																
				for (int r=0; r<input.length; r++){
					
					ever[t][r]=ever[t][r]+combination[t][r];				
				}
			}
		}
		
	int[] exit_Matrix = new int[4];
	
	public String check(int[][] ever, int[][] input){
		
		String sum = "";
		
		for (int t=0; t<4; t++){

			if (input[t][0]==-1){

				input[t][0]=0;
			}
		}
		
		for (int t=0; t<4; t++){

			for (int i=0; i<4; i++){

				exit_Matrix[t]=exit_Matrix[t]+(input[i][0]*ever[t][i]);
			}
		}
		for (int t=0; t<4; t++){
			
			if(exit_Matrix[t]<=0){

				exit_Matrix[t]=0;
			}
			else{

				exit_Matrix[t]=1;
			}
		}
		
		for (int t=0; t<4; t++){
			
			sum=sum+exit_Matrix[t];
		}
		
		return sum;	
	}
}
