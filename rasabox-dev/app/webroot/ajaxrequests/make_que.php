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

$_POST['quetitle'] = str_replace(" ", "_", $_POST['quetitle']);
            
$select_query = mysql_query(

	"SELECT * FROM `filemanagers` WHERE(`quetitle`= '".$_POST['quetitle']."' AND `user_id` = '".$_POST['filemanager_user_id']."');"

) or die("Could not query the DB for queue");


$userCreatedQue = mysql_num_rows($select_query);


if ($userCreatedQue == 0){

	mysql_query(		

		"INSERT INTO `". $_POST['strip_user_id'] ."` (`quetitle`, `quesize`, `que_follow_flag`, `followed_user_id`, `created`, `modified`)
    	VALUES ('".str_replace("'", "''", $_POST['quetitle'])."', '0', '0', '0', '".date("Y-m-d H:i:s")."', '".date("Y-m-d H:i:s")."');"

	) or die("Could not query because user has created que already");
}

mysql_query(
		
    "CREATE TABLE IF NOT EXISTS `". $_POST['strip_user_id'] . $_POST['quetitle']. "`
    (`model_title` char(50), 
    `model_size` char(50),
    `model_id` char(36), 
    `user_id` char(36),
    `user_name` varchar(45),
    `file_exten` char(10),
    `model_description` text,
    `likes` int(11),
    `dislikes` int(11),
    `rank` int(11),
    `true_rank` float,
    `num_pics` int(11),
    `num_mods` int(11),
    `file_types` int(11),
    `created` datetime,
    `modified` datetime);"

) or die("Could not query to create new que table");


mysql_query(

		"INSERT INTO `filemanagers` (`quetitle`, `filemanager_id`, `user_id`, `created`, `modified`)
    	VALUES ('".str_replace("'", "''", $_POST['quetitle'])."', '".$_POST['filemanager_id']."', '".$_POST['filemanager_user_id']."', '".date("Y-m-d H:i:s")."', '".date("Y-m-d H:i:s")."');"


) or die("could not insert into filemanagers");


mysql_close($dbhandle);

?>