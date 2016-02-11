package Shell;

import com.mongodb.BasicDBObject;
import com.mongodb.Mongo;
import com.mongodb.Mongo;
import com.mongodb.DB;
import com.mongodb.DBCollection;
import com.mongodb.BasicDBObject;
import com.mongodb.DBObject;
import com.mongodb.DBCursor;
import com.mongodb.ServerAddress;
import com.mongodb.MongoException;

import java.net.UnknownHostException;

public class DatabasePopulator {
	//this class basically pumps dummy data into our mongoDB, for testing purposes
	
	Mongo m;
	DB db;
	DBCollection coll;
	DBCollection coll2;
	String priceInt = "0";
	String dateString = "11/21/2012";
	String timeString = "400";
	String name ="PriceObject";
	
	public DatabasePopulator() throws UnknownHostException{
		
		//must switch ip everytime you switch location 
		
		
		//put all this crap into a seperate populate class, for populating the db for testing.
		m = new Mongo("172.26.112.73" , 27017);

		db = m.getDB("SymbolsDB");
		
		//needs to be commented and uncommented to clear the database.
		//m.dropDatabase("SymbolsDB");
		
		coll = db.getCollection("AAPL");
		coll2 = db.getCollection("MSFT");
		
		//right now for example purposes well create a collection here, but in the future this will be handled by the upLoad class
		//BasicDBObject doc = new BasicDBObject();
		//BasicDBObject doc2 = new BasicDBObject();
	}
	
	public void populateDB(){
		
		for (int i=0; i<40; i++){
			priceInt = "" + 100*i ;
			timeString = "" + 9*i;
			
			BasicDBObject priceObject2 = new BasicDBObject();
			BasicDBObject priceObject = new BasicDBObject();
			
			priceObject.put("Name", name+i);
			priceObject.put("Price", priceInt);
			priceObject.put("Date", dateString);
			priceObject.put("Time", timeString);
			
				
			priceObject2.put("Name", name+i);
			priceObject2.put("Price", priceInt);
			priceObject2.put("Date", dateString);
			priceObject2.put("Time", timeString);
			
			coll.insert(priceObject);
			coll2.insert(priceObject2);
		}
		System.out.println(coll);
	}
	
	public static void main(String[] args) throws UnknownHostException {
		
		DatabasePopulator POP = new DatabasePopulator();
		POP.populateDB();
	}

}
