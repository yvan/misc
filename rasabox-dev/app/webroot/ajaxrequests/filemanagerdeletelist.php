<?php



//echo "POST IS  " . print_r($_POST);
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

	"DELETE FROM `".$_POST['strip_userid']."`
	WHERE `quetitle` = '".str_replace(" ", "_", $_POST['quetitle'])."';"

) or die("Could not query followtracks");

mysql_query(

	"DROP TABLE `".$_POST['strip_userid'].str_replace("'", "''", $_POST['quetitle'])."`;"

) or die("could not query the table");


mysql_query(

	"DELETE FROM `filemanagers`
	WHERE `quetitle` = '".str_replace(" ", "_", $_POST['quetitle'])."';"

) or die("Could not query followtracks");

mysql_close($dbhandle);

?>


		