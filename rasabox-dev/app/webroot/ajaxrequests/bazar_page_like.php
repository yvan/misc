<?php

//echo "POST IS  " . print_r($_POST);
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

//search for entries in liketrack that match the data we just recived.
$select_query = mysql_query(

	"SELECT * FROM `bazarliketracks`
	WHERE(`user_id`= '".$_POST['current_user_id']."'AND `bazar_id` = '".$_POST['bazar_id']."');"

) or die("Could not query bazarliketracks");

//count the number of entries we just searched for in liketracks
$liketrack_duplicates = mysql_num_rows($select_query);

//if there is 0 etnries (no entries similar to data we just entered)
//then put a query in to enter the liketrack.
//CHANGE `rank` to work on a log scale, simple as that.
if ($liketrack_duplicates == 0){

	//if user "liked" the thing then submitlike < submitdislike and strcmp will return less than 0 which is not !== (equivalent) to 0 so if executes.
	//if the user "disliked" the thing then strcmp will return 0 and this if statement will not execute.

	if ( strcmp($_POST['liked_or_disliked'] , "submitdislike") !== 0 ){


		mysql_query(

		"INSERT INTO `bazarliketracks` (`user_id`, `bazar_id`, `created`, `modified`)
		VALUES ('".$_POST['current_user_id']."', '".$_POST['bazar_id']."', '".date("Y-m-d H:i:s")."', '".date("Y-m-d H:i:s")."');"

		) or die("could not query");

		//update likes/dislikes/rank in uploads
		mysql_query(

		"UPDATE `bazars` SET `likes` = '".($_POST['numberlikes']+1)."', `dislikes` = '".$_POST['numberdislikes']."', `rank` = '".(round(log($_POST['true_rank']+1, 3)*0.95))."', `true_rank` = '".(log10($_POST['true_rank']+1)*0.95)."'
		WHERE `bazar_id` = '".$_POST['bazar_id']."';"

		) or die("Could not query ");
	}

	//if user disliked the thing then submitdislike > submit like and the if executes
	//if the user liked the thing then submitlike !== submitlike and strcmp will return 0 and if will not execute.
	if ( strcmp($_POST['liked_or_disliked'] , "submitlike") !== 0  ){

		mysql_query(

		"INSERT INTO `bazarliketracks` (`user_id`, `bazar_id`, `created`, `modified`)
		VALUES ('".$_POST['current_user_id']."', '".$_POST['bazar_id']."', '".date("Y-m-d H:i:s")."', '".date("Y-m-d H:i:s")."');"

		) or die("could not query");

		//update likes/dislikes/rank in uploads
		mysql_query(

		"UPDATE `bazars` SET `likes` = '".($_POST['numberlikes'])."', `dislikes` = '".($_POST['numberdislikes']+1)."', `rank` = '".(round(log($_POST['true_rank']-1, 3)*0.95))."', `true_rank` = '".(log10($_POST['true_rank']-1)*0.95)."'
		WHERE `bazar_id` = '".$_POST['bazar_id']."';"

		) or die("Could not query ");
	}
}

mysql_close($dbhandle);

?>