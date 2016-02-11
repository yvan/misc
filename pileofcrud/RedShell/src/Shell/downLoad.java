package Shell;
import java.io.File;
import java.io.IOException; 
import java.io.FileOutputStream;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.IOException;

import java.util.ArrayList;
import java.util.Collection;
import java.util.Date;
import java.util.List;
import java.util.StringTokenizer;

import java.net.UnknownHostException;


import org.apache.poi.hssf.usermodel.HSSFCell;
import org.apache.poi.hssf.usermodel.HSSFRow;
import org.apache.poi.hssf.usermodel.HSSFSheet;
import org.apache.poi.hssf.usermodel.HSSFWorkbook;


import org.apache.poi.ss.usermodel.Sheet;
import org.apache.poi.ss.usermodel.Row;
import org.apache.poi.ss.usermodel.Cell;
import org.apache.poi.ss.usermodel.WorkbookFactory; // This is included in poi-ooxml-3.6-20091214.jar
import org.apache.poi.ss.usermodel.Workbook;

import org.apache.poi.openxml4j.exceptions.InvalidFormatException;

import com.mongodb.Mongo;
import com.mongodb.DB;
import com.mongodb.DBCollection;
import com.mongodb.BasicDBObject;
import com.mongodb.DBObject;
import com.mongodb.DBCursor;
import com.mongodb.ServerAddress;
import com.mongodb.MongoException;


//CHARACTER ENCODING IN CODERUNNER IS UUTF-8 apparently character encoding in jxl class file paper size is not utf-8
//USE APACHE POI 
//URIMODU
//MASSIVE FUCKING NOTE TO SELF SAVE YOURSELF A FEW PRECIOUS HOURS. JUST MAKE DIRECTORIES CONTAINING CLASS FILES INTO FUCKING
//JAR FILES, ADD THE JARS TO BUILD PATH, FOLDERS w/ CLASSES IN THEM JUST DONT FING WORK.
//compress-->change ending to'.jar' put into eclipse.

class downLoad {
	
	HSSFSheet firstSheet;
	Collection<File> files;
	HSSFWorkbook workbook;
	HSSFSheet worksheet;
	HSSFRow row1;
	HSSFCell[][] cells = new HSSFCell[100][100];
	HSSFRow[] rows = new HSSFRow[100];
	
	FileOutputStream exactFile;
	String priceInt = "0";
	String dateString = "11/21/2012";
	String timeString = "400";
	String name ="PriceObject";
	String[] tagString = new String[50]; //size needs to be adujsted if objects change from 4 bojects.
	Mongo m;
	DB db;
	DBCollection coll;
	DBCollection coll2;
	
	private void parseObjects(String objectString){

		int count = 0;
		String temp= "";
		int flag=0;
		int noDoubler=0;
		
		for (int i=0; i<objectString.length(); i++){
			
			noDoubler = 0;
			
			if (flag == 1 && objectString.charAt(i) == '"'){
				
				flag = 0;
				tagString[count] = temp;
				noDoubler=1;
				count++;
				temp="";
			}
			
			
			if (flag == 1){
				
				temp += objectString.charAt(i);
			}
			
			if (flag == 0 && objectString.charAt(i) == '"' && noDoubler==0){
				
				flag = 1;
			}
			
		}
	}
	
	
	public downLoad() {
		
	}
	
	@SuppressWarnings("deprecation")
	
	public void fileActivity(String paramOne, String paramTwo, String paramThree, String paramFour){
	
		try {
			String new1 = "";
			for (int z = 0; z < paramOne.length(); z++){
				if (paramOne.charAt(z)!=' '){
					new1 += paramOne.charAt(z);
				}
			}
			m = new Mongo("172.26.112.73" , 27017);
			db = m.getDB("SymbolsDB");
			coll = db.getCollection(new1);
			System.out.println(coll);
			
		
		   if (paramOne.equals(" to")){
			
			   exactFile = new FileOutputStream("/Users/yvanscher/Documents/workspace/RedShell/" + paramTwo);
			   workbook = new HSSFWorkbook();
			   worksheet = workbook.createSheet("Data1");
			   row1 = worksheet.createRow((short) 0);
			}
		
			else{
				
				exactFile = new FileOutputStream("/Users/yvanscher/Documents/workspace/RedShell/" + paramFour);
				workbook = new HSSFWorkbook();
				worksheet = workbook.createSheet("Data2");
				
				
				
				for (int i = 0; i< 40; i++){
					
					rows[i] = worksheet.createRow((short)i);
					
					for (int j = 0; j< 40; j++){
						
						cells[i][j] = rows[i].createCell((short) j);
					}
				}
				
				
				DBCursor cursor = coll.find();
				
				System.out.println(cursor.hasNext());
				
				try {
					
					int count = 0;
					
					while(cursor.hasNext()) {
						
						System.out.println("ADsa");
						
						String sCursor = ""+cursor.next();
						System.out.println(sCursor);
						parseObjects(sCursor);
						
						for (int j =0; j<tagString.length; j++){ //j < # of elements in the tag array.
							
							System.out.println(tagString[j]);
		
							
								try{
									cells[count][j].setCellValue(tagString[j]); 
								}
								
								catch (NullPointerException e){
									
								}
						}
						
						
						count++;
				    }
				
				} finally {
					
				  cursor.close();
			 	} 
				
				workbook.write(exactFile);
			}
		 
		 }
		
	    catch(FileNotFoundException e){
	    	
	      System.out.println(e);
	    }
		
	    catch(IOException e){
	    
	      System.out.println(e);
	    }
	}
	
	//split the file manipulations and cell manipulations into 2 seperate methods, call the cellmanipulation method 
	//in the file manipulations method.
	
	public void cellActivity(String paramOne, String paramTwo, String paramThree, String paramFour){
		
	}
}