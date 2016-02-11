package Shell;
import javax.swing.*;
import javax.swing.text.BadLocationException;
import java.awt.*;
import java.awt.Color.*;
import java.awt.*;
import java.awt.event.*;

import javax.swing.Action;

import javax.swing.JButton;
import javax.swing.JFrame;
import javax.swing.JPanel;
import javax.swing.JTextField;
import javax.swing.KeyStroke;

import java.net.UnknownHostException;

//SECOND shell ENTRY does NOT register the string.
//First shell entry is erased, fix these bugs.
//I also need a way to make the login info "xxxxx@Algos " and immutable part of text area
//USE ENUMS INSTEAD OF CHECKING FOR CORRECTNESS AT EACH STEP?  Like certain methods would only accept the Command Enum type, it might save a lot of checking.
//to stop the user deleting the text, just check for it's exists at the end of the enter, if not, it throws the user an error
//fix where one space after a command resets the cycle through up/down commandlist
//fix where extra spaces in between parameters/commands count as parameters 
//if you send the pointer backwards through the input it truncates when you hit enter, the rest of the program execution is unaffected. 
//for some fucking reason the man "error" message lets me cycle through up/down stored commands
//another bug is that the bloody man commands don't fucking work if input on the first line
//--->PROPOSAL TO SOLVE 1st LINE PROBLEM--->as soon as shell opens send an enter code twice to the text area, 
//configure can configure the print settings into excel?

public class ShellMain extends KeyAdapter  {
	
	private static String userName = "yvan@RedShell*$ ";
	
	private int i = 0;
	private int q = 0;
	private int start1 = 0;
	private int end1 = 0;
	private int start2 = 0;
	private int end2 = 0;
	private int startCommand = 0;
	private int endCommand = 0;
	private int errorFlag = 0;
	private int manFlag1 = 0;
	private int manFlag2 = 0;
	private int dlFlag = 0;
	private int upCount = 0;
	private int downCount = 0;
	private int spaceCount = 0;
	
	
	static JTextArea textShell = new JTextArea(userName,10,10);
	
	String line = "";
	String commandString = "";
	String paramOne = "";
	String paramTwo = "";
	String paramThree = "";
	String paramFour = "";
	String prevLine1 = "";
	String prevLine2 = "";
	String prevLine3 = "";
	String prevCmd = "";
	String fullCmd = "";
	
	Commands commandLog = new Commands();
	dataManipulation converter = new dataManipulation();
	manual manualFiles = new manual();
	downLoad downLoader;
	Action UpAction = new UpAction();
	Action DownAction = new DownAction();
	
	public void initializeDL() throws UnknownHostException{
		downLoader = new downLoad();
	}

	public ShellMain(){
		
		textShell.addKeyListener(this);
		textShell.setWrapStyleWord(true);
		textShell.setCaretPosition(textShell.getDocument().getLength());
		textShell.setLineWrap(true);
		textShell.setBackground(Color.black);
		textShell.setForeground(Color.red);
		textShell.setCaretColor(Color.red);
		textShell.setFont(new Font("Menlo", Font.PLAIN, 14));
		
		//if you add a command here also add another marker below
		//also increase the size of stringArray in Commands class
		commandLog.insert(" convert");
		commandLog.insert(" conv");
		commandLog.insert(" configure");//configure username, colors, etc.
		commandLog.insert(" config");
		commandLog.insert(" link");
		commandLog.insert(" lk");
		commandLog.insert(" manual");
		commandLog.insert(" man");
		commandLog.insert(" download");
		commandLog.insert(" dl");
		commandLog.insert(" ");
		commandLog.insert(" #$");
		
		// first line gets the dataField's InputMap and pairs the "ENTER" key to the action "doEnterAction" 

       // second line pairs the AbstractAction enterAction to the action "doEnterAction"
		textShell.getInputMap().put( KeyStroke.getKeyStroke("UP"), "doUpAction");
		
		textShell.getActionMap().put("doUpAction", UpAction);  
		
		textShell.getInputMap().put( KeyStroke.getKeyStroke("DOWN"), "doDownAction");
		
		textShell.getActionMap().put("doDownAction", DownAction); 

	}
	
	
	public void keyPressed(KeyEvent e) {
		// Listen for the key pressed and check it against "Enter"
	   // Then read out of our textarea control and print to screen
		
		if (e.getKeyCode() == e.VK_ENTER) {
			
			try { 
				
				startCommand = textShell.getLineStartOffset(q);
				endCommand = textShell.getLineEndOffset(q);
				line = textShell.getText(startCommand, endCommand-startCommand);
				q++;
				
				int count = 0;
				int count2 = 0;
				
				for (int i=0; i<line.length(); i++){
					
					if (line.charAt(i)==' '){
						
						count = 1;
					}
					
					if(count == 1){
						
						commandString = commandString + line.charAt(i);
						count2=1;
					}
				}
				
				fullCmd = commandString;
				
				String[] parsedCommands = {"","","","","","","","","",""};
				//probably should change so it doesnt call method 9 times.
									
				for (int i=0; i<9; i++){
					
					parsedCommands[i] = commandLog.parseCommand(commandString)[i];
					System.out.println(parsedCommands[i]);
				}
				
				commandString = parsedCommands[0];
				paramOne = parsedCommands[1]; 
				paramTwo = parsedCommands[2]; 
				paramThree = parsedCommands[3];
				paramFour = parsedCommands[4];
								
				if(commandLog.contains(commandString)){
					
					//get previous full command with params, get just the command
					if (commandLog.marker != 10 && commandLog.marker != 11){
						
						if (commandString != " " && paramOne != "" && paramOne != " "){
							
							prevLine1 = fullCmd;
							prevLine2="";
						}
						
						if (commandString != " "){
							
							prevCmd = commandString;
							prevLine3="";
						}
					}
					//honestly we could probably transfer the cuntionality of this switch stright from commandLog.marker to the next 
					//method's print command.
					switch (commandLog.marker) {
						case 0 : 
							converter.convert(paramOne, paramTwo, paramThree);
							break;
						case 1 :
							converter.convert(paramOne, paramTwo, paramThree);
							break;
						case 2 :
						
							break;
						case 3 :
						
							break;
						case 4 :
							
							break;
						case 5 : 
						
							break;
						case 6 :
						
							if (commandLog.contains(paramOne)){
								
								manFlag2 = 1;
							}
							
							else{
								
								manFlag1 = 1;
							}
							break;
						case 7 :
						
							if (commandLog.contains(paramOne)){
								
								manFlag2 = 1;
							}
							
							else{
								
								manFlag1 = 1;
							}
							break;
						case 8 :
							
							dlFlag = 1;
							break;
						case 9 :
							
							dlFlag = 1;
							break;
						case 10:
							
							break;
						case 11:
						
							errorFlag = 0;
							manFlag1 = 0;
							manFlag2 = 0;
							
							break;
						case 12:
							
						default:
							
							break;
					}
					
					
					System.out.println("Registered: "+commandString);
				}
				
				else{
					
					errorFlag = 1;
				}
				
				textShell.setCaretPosition(textShell.getLineEndOffset(i));
			
			} catch (BadLocationException c) {
			
			}
		}
	}
	
	public void keyReleased(KeyEvent e){
	
		if (e.getKeyCode() == e.VK_UP){
			
			if (upCount == 0 && downCount == 0){
				
				
				upCount++;
				
				for (int o = 0; o<prevLine1.length(); o++){
					
					if (prevLine1.charAt(o) != ' ' && spaceCount == 0){
						spaceCount = 1;
					}
					
					if (spaceCount == 1){
						prevLine2 += prevLine1.charAt(o);
					}
				}
				
				spaceCount = 0;
				
				System.out.println("Print: "+prevLine1);
				textShell.append(prevLine2);
			}
		}
		
		if (e.getKeyCode() == e.VK_DOWN){			//cycle through previous commands up or down...		
			if (downCount == 0 && upCount == 0){
			
				downCount++;
				
				for (int p = 0; p < prevCmd.length(); p++){
					
					if (prevCmd.charAt(p) != ' '){
						
						prevLine3 += prevCmd.charAt(p);
					}
				}
				
				System.out.println("Print: "+prevCmd);
				textShell.append(prevLine3);
			}
		}
		
		if (e.getKeyCode() == e.VK_ENTER) {
					  
			upCount=0;
			downCount = 0;
		    try{
		    	
		    	if(dlFlag == 1){
		    		
		    		try {
		    			initializeDL();
		    		}
		    		
		    		catch(UnknownHostException t){
		    			System.out.println("host unknown");
		    		}
		    		
		    		downLoader.fileActivity(paramOne, paramTwo, paramThree, paramFour);
		    		dlFlag = 0;
		    	}
		    	
		    	else{
					commandString="";
					start1 = textShell.getLineStartOffset(i);
					end1   = textShell.getLineEndOffset(i);
					textShell.replaceRange(userName, start1, end1);
		    		
		    	}
			
				if (manFlag1 == 1){
					commandString="";
					start2 = textShell.getLineStartOffset(i);
					end2   = textShell.getLineEndOffset(i);
					textShell.replaceRange(" #$ commands: convert (conv), configure (config), link (lk), manual (man), download (dl)", start2, end2);
				}
				
				else if(manFlag2 == 1){
					
					commandString="";
					start2 = textShell.getLineStartOffset(i);
					end2   = textShell.getLineEndOffset(i);
					
					String[] temp  = manualFiles.toLine(paramOne);
					int counterTemp = 0;
					
					while (temp[counterTemp]!=null){
					
						textShell.append(temp[counterTemp]+"\n");
						counterTemp++;
					}
					
					i=i+counterTemp;
					q=q+counterTemp;

					start1 = textShell.getLineStartOffset(i);
					end1   = textShell.getLineEndOffset(i);
					textShell.replaceRange(userName, start1, end1);
					
					manFlag2 = 0;
					counterTemp=0;
				}
				
				else if (errorFlag == 1){
					
					commandString="";
					start2 = textShell.getLineStartOffset(i);
					end2   = textShell.getLineEndOffset(i);
					textShell.replaceRange(" #$ error: command not recognized", start2, end2);
					upCount = 1;
					downCount = 1;
				}
				
				else {
					
					commandString="";
					start1 = textShell.getLineStartOffset(i);
					end1   = textShell.getLineEndOffset(i);
					textShell.replaceRange(userName, start1, end1);
				}
				
				i++;
				
				//textShell.setCaretPosition(textShell.getLineEndOffset(i));
				textShell.setCaretPosition(textShell.getDocument().getLength());
				
				paramOne = "";
				paramTwo = "";
				paramThree = "";
					
				
			} catch (BadLocationException g){
				
				System.out.println("error caught at line "+i);
			}
		}
	}
}