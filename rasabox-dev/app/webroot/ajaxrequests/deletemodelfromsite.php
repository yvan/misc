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

	"INSERT INTO `". $_POST['strip_userid'] . $_POST['list_que'] ."` (`model_title`, `model_size`, `model_id`, `user_id`, `user_name`, `file_exten`, `model_description`, `likes`, `dislikes`, `rank`, `true_rank`, `num_pics`, `num_mods`, `file_types`, `created`, `modified`)
	VALUES ('".$_POST['model_title']."', '0', '".$_POST['model_id']."', '".$_POST['artist_id']."','". $_POST['artist_username']."','". $_POST['extension'] ."','".$_POST['description']."','".$_POST['numberlikes']."','".$_POST['numberdislikes']."','".$_POST['rank']."','".$_POST['true_rank']."','".$_POST['number_pics']."','".$_POST['number_models']."','".$_POST['file_types']."','".date("Y-m-d H:i:s")."','".date("Y-m-d H:i:s")."');"

) or die("Could not query ".  $_POST['strip_userid'] . $_POST['list_que']);

mysql_close($dbhandle);

?>


		