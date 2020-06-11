<?php


//echo "POST IS  " . print_r($_POST);
//the reason no post shows up when we load add_to_que.php seperately
//is because we have sent it no $_POST data.

$myServer = "localhost";
$myUser = "yvan";
$myPass = "test";
$myDB = "cakeBasicTutorial";

//model_id is product id
$dbhandle = mysql_connect($myServer, $myUser, $myPass);

mysql_select_db($myDB) or die("Could not select " . $myDB);
//539225aea8e841f1b24c3e4ca93f502diamawalrus
//539225aea8e841f1b24c3e4ca93f502diamawalrus
mysql_query(

	"DELETE FROM `comments`
	WHERE `comment_id` = '".$_POST['comment_id']."';"

) or die("Could not query comments");

mysql_close($dbhandle);

?>


		