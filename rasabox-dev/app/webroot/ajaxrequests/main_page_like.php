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
$liketrack_select_query = mysql_query(

	"SELECT * FROM `liketracks`
	WHERE(`user_id`= '".$_POST['user_id']."'AND `main_id` = '".$_POST['model_id']."' AND `product_id` = '".$_POST['model_id']."');"

) or die("Could not query liketracks");

$main_select_query = mysql_query(

	"SELECT * FROM `mains`
	WHERE(`main_id` = '".$_POST['model_id']."');"

) or die("could not query mains");

$product_select_query = mysql_query(

	"SELECT * FROM `products`
	WHERE(`product_id` = '".$_POST['model_id']."');"

) or die("could not query products");

$upload_query = mysql_query(

	"SELECT * FROM `uploads`
	WHERE(`id` = '".$_POST['model_id']."');"

) or die("Could not query liketracks");

//mysql_fetch_array gets the first row and puts it in row_query, as an array.
$row_query = mysql_fetch_array($upload_query);

$numberlikes = $row_query['likes'];
$numberdislikes = $row_query['dislikes'];

//count the number of entries we just searched for in liketracks
$liketrack_duplicates = mysql_num_rows($liketrack_select_query);

//counter number of entries we jsut searched for (either 1 or 0)
$main_exists = mysql_num_rows($main_select_query);

//counter number of entries we jsut searched for (either 1 or 0)
$product_exists = mysql_num_rows($product_select_query);

//if there is 0 etnries (no entries similar to data we just entered)
//then put a query in to enter the liketrack.
//CHANGE `rank` to work on a log scale, simple as that.
if ($liketrack_duplicates == 0){

	//if user "liked" the thing then submitlike < submitdislike and strcmp will return less than 0 which is not !== (equivalent) to 0 so if executes.
	//if the user "disliked" the thing then strcmp will return 0 and this if statement will not execute.
	//IF THE USER LIKED SOMETHING.
	if ( strcmp($_POST['liked_or_disliked'] , "submitdislike") !== 0 ){


		mysql_query(

		"INSERT INTO `liketracks` (`user_id`, `main_id`, `product_id`, `created`, `modified`)
		VALUES ('".$_POST['user_id']."', '".$_POST['model_id']."', '".$_POST['model_id']."', '".date("Y-m-d H:i:s")."', '".date("Y-m-d H:i:s")."');"

		) or die("could not query");

		//insert into table tracking likes for that specific object
		//the user has LIKED something.
		mysql_query(

		"INSERT INTO `".$_POST['model_id']."liketable` (`user_id`, `like_flag`, `created`, `modified`)
		VALUES ('".$_POST['user_id']."', '1', '".date("Y-m-d H:i:s")."', '".date("Y-m-d H:i:s")."');"

		) or die("could not query");

		//update likes/dislikes/rank in uploads
		mysql_query(

		"UPDATE `uploads` SET `likes` = '".($numberlikes+1)."', `dislikes` = '".$numberdislikes."', `rank` = '".(round(log($numberlikes+1-$numberdislikes, 3)*0.95))."', `true_rank` = '".(log($numberlikes+1-$numberdislikes, 3)*0.95)."'
		WHERE `id` = '".$_POST['model_id']."';"

		) or die("Could not query ");


		if ($main_exists == 1){

			//update the likes/dislikes/rank in mains
			mysql_query(

			"UPDATE `mains` SET `likes` = '".($numberlikes+1)."', `dislikes` = '".$numberdislikes."', `rank` = '".(round(log($numberlikes+1-$numberdislikes, 3)*0.95))."', `true_rank` = '".(log($numberlikes+1-$numberdislikes, 3)*0.95)."'
			WHERE `main_id` = '".$_POST['model_id']."';"

			) or die("Could not query ");
		}
		else{
											
			mysql_query(

			"INSERT INTO `mains` (`user_id`, `main_id`, `product_id` , `title`, `description`, `username`, `likes`, `dislikes`, `rank`, `true_rank`, `created`, `modified`)
			VALUES ('".$_POST['user_id']."', '".$_POST['model_id']."', '".$_POST['model_id']."', '".$_POST['title']."', '".$_POST['description']."','".$_POST['artist_username']."',
					'".($numberlikes+1)."','".$numberdislikes."', '".(round(log($numberlikes+1-$numberdislikes, 3)*0.95))."', `true_rank` = '".(log($numberlikes+1-$numberdislikes, 3)*0.95)."', '".date("Y-m-d H:i:s")."', '".date("Y-m-d H:i:s")."');"

			) or die("could not query");

		}

		if($product_exists == 1){

			//update the likes/dislikes/rank in products
			mysql_query(


			"UPDATE `products` SET `likes` = '".($numberlikes+1)."', `dislikes` = '".$numberdislikes."', `rank` = '".(round(log($numberlikes+1-$numberdislikes, 3)*0.95))."', `true_rank` = '".(log($numberlikes+1-$numberdislikes, 3)*0.95)."'
			WHERE `product_id` = '".$_POST['model_id']."';"

			) or die("Could not create new table");

		}
		else{


			mysql_query(

			"INSERT INTO `products` (`product_id`, `main_id`, `number_downloads`,`likes`, `dislikes`, `rank`, `true_rank`, `created`, `modified`)
			VALUES ('".$_POST['model_id']."', '".$_POST['model_id']."', '0','".($numberlikes+1)."','".$numberdislikes."',
					'".(round(log($numberlikes+1-$numberdislikes, 3)*0.95))."', `true_rank` = '".(log($numberlikes+1-$numberdislikes, 3)*0.95)."', '".date("Y-m-d H:i:s")."', '".date("Y-m-d H:i:s")."');"

			) or die("could not query");

		}


		// it isn't sending at all
		//there is something wrong with the post variables
		//there is something wrong with the way we're adding +1 -1 and parentheses (doubt this)

	}

	//if user disliked the thing then submitdislike > submit like and the if executes
	//if the user liked the thing then submitlike !== submitlike and strcmp will return 0 and if will not execute.
	//IF THE USER DISLIKED SOMETHING.
	if ( strcmp($_POST['liked_or_disliked'] , "submitlike") !== 0  ){

		mysql_query(

		"INSERT INTO `liketracks` (`user_id`, `main_id`, `product_id`, `created`, `modified`)
		VALUES ('".$_POST['user_id']."', '".$_POST['model_id']."', '".$_POST['model_id']."', '".date("Y-m-d H:i:s")."', '".date("Y-m-d H:i:s")."');"

		) or die("could not query");

		//insert into table tracking likes for that specific object
		mysql_query(

		"INSERT INTO `".$_POST['model_id']."liketable` (`user_id`, `like_flag`, `created`, `modified`)
		VALUES ('".$_POST['user_id']."', '2', '".date("Y-m-d H:i:s")."', '".date("Y-m-d H:i:s")."');"

		) or die("could not query");


		//update likes/dislikes/rank in uploads
		mysql_query(

		"UPDATE `uploads` SET `likes` = '".$numberlikes."', `dislikes` = '".($numberdislikes+1)."', `rank` = '".(round(log($numberlikes-($numberdislikes+1), 3)*0.95))."', `true_rank` = '".(log($numberlikes-($numberdislikes+1), 3)*0.95)."'
		WHERE `id` = '".$_POST['model_id']."';"

		) or die("Could not query liketracks");


		if ($main_exists == 1){


			//update the likes/dislikes/rank in mains
			mysql_query(

			"UPDATE `mains` SET `likes` = '".$numberlikes."', `dislikes` = '".($numberdislikes+1)."', `rank` = '".(round(log($numberlikes-($numberdislikes+1), 3)*0.95))."', `true_rank` = '".(log($numberlikes-($numberdislikes+1), 3)*0.95)."'
			WHERE `main_id` = '".$_POST['model_id']."';"

			) or die("Could not query liketracks");
		}
		else{

			mysql_query(

			"INSERT INTO `mains` (`user_id`, `main_id`, `product_id` , `title`, `description`, `username`, `likes`, `dislikes`, `rank`,`true_rank`, `created`, `modified`)
			VALUES ('".$_POST['user_id']."', '".$_POST['model_id']."', '".$_POST['model_id']."', '".$_POST['title']."', '".$_POST['description']."','".$_POST['artist_username']."',
					'".($numberlikes)."','".($numberdislikes+1)."', '".(round(log($numberlikes-($numberdislikes+1), 3)*0.95))."', `true_rank` = '".(log($numberlikes-($numberdislikes+1), 3)*0.95)."', '".date("Y-m-d H:i:s")."', '".date("Y-m-d H:i:s")."');"

			) or die("could not query");
		}

		if($product_exists == 1){

			//update the likes/dislikes/rank in products
			mysql_query(


			"UPDATE `products` SET `likes` = '".($numberlikes)."', `dislikes` = '".($numberdislikes+1)."', `rank` = '".(round(log($numberlikes-($numberdislikes+1), 3)*0.95))."', `true_rank` = '".(log($numberlikes-($numberdislikes+1), 3)*0.95)."'
			WHERE `product_id` = '".$_POST['model_id']."';"


			) or die("Could not create new table");

		}
		else{


			mysql_query(

			"INSERT INTO `products` (`product_id`, `main_id`, `number_downloads`,`likes`, `dislikes`, `rank`,`true_rank`, `created`, `modified`)
			VALUES ('".$_POST['model_id']."', '".$_POST['model_id']."', '0','".($numberlikes)."','".($numberdislikes+1)."',
					'".(round(log($numberlikes-($numberdislikes+1), 3)*0.95))."', `true_rank` = '".(log($numberlikes-($numberdislikes+1), 3)*0.95)."', '".date("Y-m-d H:i:s")."', '".date("Y-m-d H:i:s")."');"

			) or die("could not query");


		}
	}
}

//if there is an entry in liketrack were gonna change the flag in the 
//model's specific table to represent the new state of affairs
// this will allow the user to change their vote, or unvote all together
//regardless th entry in that model's specific table is always there now.
//the beauty of this is that we don't need to check if the tables exists.
//because liketrack exists we know the tables exist and can just update them.
else{

	//if user "liked" the thing then submitlike < submitdislike and strcmp will return less than 0 which is not !== (equivalent) to 0 so if executes.
	//if the user "disliked" the thing then strcmp will return 0 and this if statement will not execute.
	//IF THE USER LIKED SOMETHING.
	if ( strcmp($_POST['liked_or_disliked'] , "submitdislike") !== 0 ){


		//if the user presses the like button and he already has like falg 1 (he already liked the thing)
		//this unvotes for it.
		if ($_POST['user_liketable_query'] == 1 /*&& ($_POST['original_liketable_query'] != 2)*/){

			mysql_query(

			"UPDATE`".$_POST['model_id']."liketable` SET `like_flag` = '0'
			WHERE `user_id` = '".$_POST['user_id']."';"

			) or die("could not query");

			//NEXT THREE QUERIES behave in such way as to DECREASE the vote by one (they unvote)
			//they effectively work the same as a dislike above
			//update likes/dislikes/rank in uploads

			//WE need to do a query first and replace $numberlikes-1 below with the info from the query
			//variables to use to increment rank, etc $numberlikes-1

			// for the SET likes and dislikes we could also write it like "likes = likes -1"
			//we have to pull the actual nubmer from the DB to input the ranks though.
			mysql_query(

			"UPDATE `uploads` SET `likes` = '".($numberlikes-1)."', `dislikes` = '".($numberdislikes)."', `rank` = '".(round(log( ($numberlikes-1)-($numberdislikes), 3)*0.95))."', `true_rank` = '".(log( ($numberlikes-1)-($numberdislikes), 3)*0.95)."'
			WHERE `id` = '".$_POST['model_id']."';"

			) or die("Could not query liketracks");

			//update the likes/dislikes/rank in mains
			mysql_query(

			"UPDATE `mains` SET `likes` = '".($numberlikes-1)."', `dislikes` = '".($numberdislikes)."', `rank` = '".(round(log( ($numberlikes-1)-($numberdislikes), 3)*0.95))."', `true_rank` = '".(log( ($numberlikes-1)-($numberdislikes), 3)*0.95)."'
			WHERE `main_id` = '".$_POST['model_id']."';"

			) or die("Could not query liketracks");

			//update the likes/dislikes/rank in products
			mysql_query(


			"UPDATE `products` SET `likes` = '".($numberlikes-1)."', `dislikes` = '".($numberdislikes)."', `rank` = '".(round(log( ($numberlikes-1)-($numberdislikes), 3)*0.95))."', `true_rank` = '".(log( ($numberlikes-1)-($numberdislikes), 3)*0.95)."'
			WHERE `product_id` = '".$_POST['model_id']."';"


			) or die("Could not create new table");
		}
		//if the user is neutral or has disliekd soemthing, this changes his vote to liking the thing.
		//here we only increase the numberlikes by 1 and do nothing to dislieks because were going from a 0 entry to 1.
		else if($_POST['user_liketable_query'] == 0){

			mysql_query(

			"UPDATE`".$_POST['model_id']."liketable` SET `like_flag` = '1'
			WHERE `user_id` = '".$_POST['user_id']."';"

			) or die("could not query");

			//These next threequeries behave in such a way as to increase the vote by 1. (they are the same
			//as the queries above)
			//update likes/dislikes/rank in uploads
			mysql_query(

			"UPDATE `uploads` SET `likes` = '".($numberlikes+1)."', `dislikes` = '".$numberdislikes."', `rank` = '".(round(log($numberlikes+1-$numberdislikes, 3)*0.95))."', `true_rank` = '".(log($numberlikes+1-$numberdislikes, 3)*0.95)."'
			WHERE `id` = '".$_POST['model_id']."';"

			) or die("Could not query ");

			//update the likes/dislikes/rank in mains
			mysql_query(

			"UPDATE `mains` SET `likes` = '".($numberlikes+1)."', `dislikes` = '".$numberdislikes."', `rank` = '".(round(log($numberlikes+1-$numberdislikes, 3)*0.95))."', `true_rank` = '".(log($numberlikes+1-$numberdislikes, 3)*0.95)."'
			WHERE `main_id` = '".$_POST['model_id']."';"

			) or die("Could not query ");

			//update the likes/dislikes/rank in products
			mysql_query(


			"UPDATE `products` SET `likes` = '".($numberlikes+1)."', `dislikes` = '".$numberdislikes."', `rank` = '".(round(log($numberlikes+1-$numberdislikes, 3)*0.95))."', `true_rank` = '".(log($numberlikes+1-$numberdislikes, 3)*0.95)."'
			WHERE `product_id` = '".$_POST['model_id']."';"

			) or die("Could not create new table");
		}

		//here we need to increase the number of likes by 1 and DECRESAE the number of dislikes by 1 (we are)
		//switching our vote from dislike to like. going from a 2 entry to a 1 entry.
		else if($_POST['user_liketable_query'] == 2 ){

			mysql_query(

			"UPDATE`".$_POST['model_id']."liketable` SET `like_flag` = '1'
			WHERE `user_id` = '".$_POST['user_id']."';"

			) or die("could not query");

			//These next threequeries behave in such a way as to increase the vote by 1. (they are the same
			//as the queries above)
			//update likes/dislikes/rank in uploads
			mysql_query(

			"UPDATE `uploads` SET `likes` = '".($numberlikes+1)."', `dislikes` = '".($numberdislikes-1)."', `rank` = '".(round(log($numberlikes+1-($numberdislikes-1), 3)*0.95))."', `true_rank` = '".(log($numberlikes+1-($numberdislikes-1), 3)*0.95)."'
			WHERE `id` = '".$_POST['model_id']."';"

			) or die("Could not query ");

			//update the likes/dislikes/rank in mains
			mysql_query(

			"UPDATE `mains` SET `likes` = '".($numberlikes+1)."', `dislikes` = '".($numberdislikes-1)."', `rank` = '".(round(log($numberlikes+1-($numberdislikes-1), 3)*0.95))."', `true_rank` = '".(log($numberlikes+1-($numberdislikes-1), 3)*0.95)."'
			WHERE `main_id` = '".$_POST['model_id']."';"

			) or die("Could not query ");

			//update the likes/dislikes/rank in products
			mysql_query(


			"UPDATE `products` SET `likes` = '".($numberlikes+1)."', `dislikes` = '".($numberdislikes-1)."', `rank` = '".(round(log($numberlikes+1-($numberdislikes-1), 3)*0.95))."', `true_rank` = '".(log($numberlikes+1-($numberdislikes-1), 3)*0.95)."'
			WHERE `product_id` = '".$_POST['model_id']."';"

			) or die("Could not create new table");

		}
	}

	//if user disliked the thing then submitdislike > submit like and the if executes
	//if the user liked the thing then submitlike !== submitlike and strcmp will return 0 and if will not execute.
	//IF THE USER DISLIKED SOMETHING.
	if ( strcmp($_POST['liked_or_disliked'] , "submitlike") !== 0  ){

		//if the user has already disliked something and they click dislike again, we make their vote neutral
		if ( ($_POST['user_liketable_query'] == 2) /*&& ($_POST['original_liketable_query'] != 1)*/ ){

			mysql_query(

			"UPDATE`".$_POST['model_id']."liketable` SET `like_flag` = '0'
			WHERE `user_id` = '".$_POST['user_id']."';"

			) or die("could not query");

			//These next three queries behave in such a way as to increase the vote by 1. (they are the same
			//as the queries above)
			//update likes/dislikes/rank in uploads
			mysql_query(

			"UPDATE `uploads` SET `likes` = '".($numberlikes)."', `dislikes` = '".($numberdislikes-1)."', `rank` = '".(round(log($numberlikes-($numberdislikes-1), 3)*0.95))."', `true_rank` = '".(log($numberlikes-($numberdislikes-1), 3)*0.95)."'
			WHERE `id` = '".$_POST['model_id']."';"

			) or die("Could not query ");

			//update the likes/dislikes/rank in mains
			mysql_query(

			"UPDATE `mains` SET `likes` = '".($numberlikes)."', `dislikes` = '".($numberdislikes-1)."', `rank` = '".(round(log($numberlikes-($numberdislikes-1), 3)*0.95))."', `true_rank` = '".(log($numberlikes-($numberdislikes-1), 3)*0.95)."'
			WHERE `main_id` = '".$_POST['model_id']."';"

			) or die("Could not query ");

			//update the likes/dislikes/rank in products
			mysql_query(


			"UPDATE `products` SET `likes` = '".($numberlikes)."', `dislikes` = '".($numberdislikes-1)."', `rank` = '".(round(log($numberlikes-($numberdislikes-1), 3)*0.95))."', `true_rank` = '".(log($numberlikes-($numberdislikes-1), 3)*0.95)."'
			WHERE `product_id` = '".$_POST['model_id']."';"

			) or die("Could not create new table");
		}

		//the user is changing their vote from like to dislike
		else if($_POST['user_liketable_query'] == 0) {

			mysql_query(

			"UPDATE`".$_POST['model_id']."liketable` SET `like_flag` = '2'
			WHERE `user_id` = '".$_POST['user_id']."';"

			) or die("could not query");

			//NEXT THREE QUERIES behave in such way as to DECREASE the vote by one (they unvote)
			//they effectively work the same as a dislike above
			//update likes/dislikes/rank in uploads
			mysql_query(

			"UPDATE `uploads` SET `likes` = '".$numberlikes."', `dislikes` = '".($numberdislikes+1)."', `rank` = '".(round(log($numberlikes-($numberdislikes+1), 3)*0.95))."', `true_rank` = '".(log($numberlikes-($numberdislikes+1), 3)*0.95)."'
			WHERE `id` = '".$_POST['model_id']."';"

			) or die("Could not query liketracks");

			//update the likes/dislikes/rank in mains
			mysql_query(

			"UPDATE `mains` SET `likes` = '".$numberlikes."', `dislikes` = '".($numberdislikes+1)."', `rank` = '".(round(log($numberlikes-($numberdislikes+1), 3)*0.95))."', `true_rank` = '".(log($numberlikes-($numberdislikes+1), 3)*0.95)."'
			WHERE `main_id` = '".$_POST['model_id']."';"

			) or die("Could not query liketracks");

			//update the likes/dislikes/rank in products
			mysql_query(


			"UPDATE `products` SET `likes` = '".($numberlikes)."', `dislikes` = '".($numberdislikes+1)."', `rank` = '".(round(log($numberlikes-($numberdislikes+1), 3)*0.95))."', `true_rank` = '".(log($numberlikes-($numberdislikes+1), 3)*0.95)."'
			WHERE `product_id` = '".$_POST['model_id']."';"


			) or die("Could not create new table");
		}
		else if($_POST['user_liketable_query'] == 1 ) {

			mysql_query(

			"UPDATE`".$_POST['model_id']."liketable` SET `like_flag` = '2'
			WHERE `user_id` = '".$_POST['user_id']."';"

			) or die("could not query");

			//NEXT THREE QUERIES behave in such way as to DECREASE the vote by one (they unvote)
			//they effectively work the same as a dislike above
			//update likes/dislikes/rank in uploads
			mysql_query(

			"UPDATE `uploads` SET `likes` = '".($numberlikes-1)."', `dislikes` = '".($numberdislikes+1)."', `rank` = '".(round(log(($numberlikes-1)-($numberdislikes+1), 3)*0.95))."', `true_rank` = '".(log(($numberlikes-1)-($numberdislikes+1), 3)*0.95)."'
			WHERE `id` = '".$_POST['model_id']."';"

			) or die("Could not query liketracks");

			//update the likes/dislikes/rank in mains
			mysql_query(

			"UPDATE `mains` SET `likes` = '".($numberlikes-1)."', `dislikes` = '".($numberdislikes+1)."', `rank` = '".(round(log(($numberlikes-1)-($numberdislikes+1), 3)*0.95))."', `true_rank` = '".(log(($numberlikes-1)-($numberdislikes+1), 3)*0.95)."'
			WHERE `main_id` = '".$_POST['model_id']."';"

			) or die("Could not query liketracks");

			//update the likes/dislikes/rank in products
			mysql_query(


			"UPDATE `products` SET `likes` = '".($numberlikes-1)."', `dislikes` = '".($numberdislikes+1)."', `rank` = '".(round(log(($numberlikes-1)-($numberdislikes+1), 3)*0.95))."', `true_rank` = '".(log(($numberlikes-1)-($numberdislikes+1), 3)*0.95)."'
			WHERE `product_id` = '".$_POST['model_id']."';"


			) or die("Could not create new table");

		}
	}
}

mysql_close($dbhandle);

?>