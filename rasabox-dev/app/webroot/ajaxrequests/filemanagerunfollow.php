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

//NO $_POST['quetitle'] = str_replace(" ", "_", $_POST['quetitle']); BECAUSE quetitle is always "useridself" here.

mysql_query(

	"DELETE FROM `followtracks`
	WHERE `followed_user_id` = '".$_POST['followed_user_id']."' AND `follower_user_id` = '".$_POST['filemanager_user_id']."';"
) or die("Could not query followtracks");

mysql_query(

	"DELETE FROM `".$_POST['strip_userid']."`
	WHERE `quetitle` = '".$_POST['quetitle']."';"

) or die("Could not query followtracks");

mysql_query(

	"UPDATE users
	SET number_followers = number_followers - 1
	WHERE `id`='".$_POST['followed_user_id']."';"
	
) or die("Could not decrease # followers");

mysql_close($dbhandle);

?>


		