package Shell;
public interface CommandLog{
	
	public void insert(String e);
	public boolean contains(String e);
	public String toString();
	public String[] parseCommand(String e);
	
}