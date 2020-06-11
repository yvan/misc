<?php

//the reason no post shows up when we load add_to_que.php seperately
//is because we have sent it no $_POST data.

$myServer = "localhost";
$myUser = "yvan";
$myPass = "test";
$myDB = "cakeBasicTutorial";

//model_id is product id
$dbhandle = mysql_connect($myServer, $myUser, $myPass, false, 65536);

mysql_select_db($myDB) or die("Could not select " . $myDB);

$_POST['quetitle'] = str_replace(" ", "_", $_POST['quetitle']);

mysql_query(

	"DELETE FROM `".$_POST['strip_userid'].$_POST['quetitle']."`
	WHERE `model_id` = '".$_POST['model_id']."' limit 1;"

) or die("Could not query ".  $_POST['strip_userid'] . $_POST['list_que']);

mysql_close($dbhandle);

?>


		