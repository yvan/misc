package Shell;
import com.mongodb.Mongo;
import com.mongodb.DB;
import com.mongodb.DBCollection;
import com.mongodb.BasicDBObject;
import com.mongodb.DBObject;
import com.mongodb.DBCursor;
import com.mongodb.ServerAddress;

import java.util.Arrays;
import java.net.UnknownHostException;

class upLoad {

	public upLoad(){
		
	}
	
	public static void main(String[] args) throws UnknownHostException{
		
	float priceInt = 0;
	String dateString = "";
	String timeString = "";
	String dummyFile = "dummy"; //dummy for inputFile maybe it has to be a stream? Or there needs to be a more complex mechanism
	
	Mongo m = new Mongo("172.29.160.146" , 27017);
	DB db = m.getDB("QuotesDB");
	
	DBCollection coll = db.getCollection("AAPL");
	
	//use for loop to put input from TS file into the DB
	
	BasicDBObject doc = new BasicDBObject();
	
	BasicDBObject priceObject = new BasicDBObject();
	
	for (int i=0; i<dummyFile.length(); i++){
			
		priceObject.put("Price", priceInt);
		priceObject.put("Date", dateString);
		priceObject.put("Time", timeString);
			
		doc.put("priceObject"+i, priceObject);
	}
	
	coll.insert(doc);
	
	DBCursor cursor = coll.find();
	
	try {
		
		while(cursor.hasNext()) {
			
	    	System.out.println(cursor.next());
	    }
	
	} finally {
		
  	  cursor.close();
 	}

	coll.createIndex(new BasicDBObject("i",1));
	
	System.out.println(coll.getCount()); //#of docs in testCollection
	
	m.dropDatabase("mydb");
		
	}
}