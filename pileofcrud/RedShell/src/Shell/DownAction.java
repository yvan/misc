package Shell;
import javax.swing.AbstractAction;
import java.awt.event.ActionEvent;


public class DownAction extends AbstractAction {
	
	public void actionPerformed( ActionEvent tf ){
	
	            // provides feedback to the console to show that the enter key has
	
	            // been pressed
	
	            System.out.println( "The Down key has been pressed." );

	            // pressing the enter key then 'presses' the enter button by calling

	            // the button's doClick() method

	            //enterButton.doClick();
	
	} // end method actionPerformed()
	
 
	public static void main(String[] args) {
		
	}
}