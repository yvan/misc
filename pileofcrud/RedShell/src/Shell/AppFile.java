package Shell;
import java.awt.*;
import javax.swing.*;
import java.awt.Color.*;

import java.net.UnknownHostException;

public class AppFile extends JFrame{
	
	ShellMain shell = new ShellMain();

	public AppFile() {
		
		JPanel p1 = new JPanel();
		p1.setLayout(new GridLayout(1,1,1,1));
		p1.setSize(500,500);
		
		JScrollPane consoleShell = new JScrollPane(shell.textShell);
		
		p1.add(consoleShell);
		p1.setLocation(0,0);
		add(p1);
	}
	//MASSIVE FUCKING NOTE TO SELF DO NOT FUCKING ADD CLASS FILES 
	//TO THE MOTHER FUCKING BUILD PATH
	//IT WILL BREAK THE MOTHERFUCKING IDE (eclipse) AND IT WILL NOT WORK.
	//ONLY ADD JARS AND ADD .CLASS FILES ONLY IN PACKAGES
	
	public static void main(String[] args) {
		
		AppFile frame = new AppFile();
		frame.setSize(700,500);
		frame.setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
		frame.setVisible(true);
	}
}