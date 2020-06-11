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
//model_id is product id
$dbhandle = mysql_connect($myServer, $myUser, $myPass, false, 65536);

mysql_select_db($myDB) or die("Could not select " . $myDB);

mysql_query(		

		"INSERT INTO `comments` (`comment_id`, `product_id`, `user_id`, `username`, `text`, `likes`, `dislikes`, `rank`, `true_rank`, `created`, `modified`)
		VALUES ('".$_POST['comment_id']."', '".$_POST['model_id']."', '".$_POST['user_id']."', '".$_POST['username']."', '".$_POST['text']."', '".$_POST['numberlikes']."','".$_POST['numberdislikes']."', '".$_POST['rank']."', '".$_POST['true_rank']."', '".date("Y-m-d H:i:s")."', '".date("Y-m-d H:i:s")."');"

) or die("Could not query blah blah lbhal");


mysql_close($dbhandle);

?>