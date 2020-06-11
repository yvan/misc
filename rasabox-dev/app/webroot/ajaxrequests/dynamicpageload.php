<?php

//This file is basically the same as the main_page_like.php file.
//the reason no post shows up when we load add_to_que.php seperately
//is because we have sent it no $_POST data.

$myServer = "localhost";
$myUser = "yvan";
$myPass = "test";
$myDB = "cakeBasicTutorial";

//NO bloody idea what the 4th argument does.
//5th argument is the mode, code 65536 for 5th argument allows submission of multiple statements
//this seems to have fixed the problem where the update query was fucking up all the other queries
//altho i'm not really sure why it was to begin with because it was a separate query. whatever it works.
$dbhandle = mysql_connect($myServer, $myUser, $myPass, false, 65536);

mysql_select_db($myDB) or die("Could not select " . $myDB);

//selects 12 rows starting from the current number of loaded models (so if we have originally loaded 12 models this will be zero)
//and the first row called in will be the first row. If we have 24 loaded (we have dynamically called once) then we will start with row
//24-12 +1 row 13, and load in the next 12 rows of the table (each row is a main page node).
$upload_query = mysql_query(

	"SELECT * FROM `uploads` order by rank DESC limit ".($_POST['num_models_already_loaded']).",12;" // 4 MUST BE CHANGED TO 12 BEFORE UPLOADING TO MAIN SITE!!!

) or die("Could not query liketracks");

//gets each row and prints out new nodes. These nodes will be returned to the calling page (index.ctp-main) and dynmaically loaded.
//we will make a switch that assigns each index number to a value that corresponds to imageid, username, description, title.

$return_array = array();

$count = 0;
//we cannot use mysql_fetch_array() bec. we can't pass associative arrays through json back to our ajax script
while($row_query = mysql_fetch_row($upload_query))
{   

	$return_array[$count] = $row_query;

	//search for entries in liketrack that match the data we just recived.
	//tried to do an individual column select on like_flag, that shit just didn't work.
	$liketable_query = mysql_query(

		"SELECT * FROM `".$row_query[0]."liketable`
		WHERE(`user_id` = '".$_POST['voterid']."') limit 1;"

	) or die("Could not query liketracks");

	if($liketable_row = mysql_fetch_row($liketable_query)){

		$return_array[$count][18] = $liketable_row[2];
	}
	else{
		$return_array[$count][18] = 0;
	}

	$count++;
}

echo json_encode($return_array);

mysql_close($dbhandle);

?>