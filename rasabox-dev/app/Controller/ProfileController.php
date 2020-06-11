<?php

class ProfileController extends AppController{

	public function index(){

		$this->set('userid', $this->Auth->user('id'));
		$this->set('passed_id', $this->params['named']['id']);
		$this->set('current_username', $this->Auth->user('username'));
		$this->set('profile_username', $this->params['named']['username']);
		$authUser = $this->Auth->user();
		$this->set('authUser', $authUser); // to check whether a user is logged in or not.

		//setup a temp username for the user to use (stop being lazy sounds good)
		//if the anonymous non logged in user tries to like, comment, wtvr, he gets the 
		//javascript redirect to create a new user.
		if (!$authUser){

			$this->set('temporary_username', "IamLazy");
		}
		//The reason I call params to set the variables for the ctp/view file and then again to set 
		//normal varaibles below for this controller file is because editing the files later can cause
		//issues if you just set the view variables to the same ones used here, if you forget (and you will)
		//the names of the variables and accidentally reuse the name, will save frustration.
		$passed_id = $this->params['named']['id'];
		$passed_username = $this->params['named']['username'];
		$userid = $this->Auth->user('id');
		$count = 0;
		$strip_passed_id = str_replace("-", "", $passed_id);

		//first input to array used to be 'Followtrack.followed_user_id' => $_POST
		$userfollow = $this->Profile->Followtrack->find('first',

			array(
										
				'conditions' => array( 'Followtrack.followed_user_id' => $passed_id, 'Followtrack.follower_user_id' =>  $userid) 
			)
		);


		//CREATES THE SELF TABLE FOR THIS USER WHOSE PRILFE IS BEING VISITED IF IT DOES NOT ALREADY EXIST.
		$this->Profile->query(

      	  "CREATE TABLE IF NOT EXISTS `". $strip_passed_id."self"."`
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
      	);

		//PULL MODELS FROM THE VISITED USER'S PAGE
		$models_from_que_temp = $this->Profile->query(

			"SELECT * 
			FROM `".$strip_passed_id."self`;"
		);

		foreach ($models_from_que_temp as $key => $temp) {

			$models_from_que[$count] = $temp;
			$count++;
		}

		if ($userfollow){

			$this->set('userFollowedAlready', 1);
		}

		$all_users = $this->Profile->User->find('first',

			array(

				'conditions' => array('User.id' => $this->params['named']['id'])

			)
		);

		$number_followers = $all_users['User']['number_followers'];
		$this->set('number_followers', $number_followers);
		$this->set('models_from_que', $models_from_que);
		$this->set('quetitle', $strip_passed_id."self");

		if ($this->request->is('post')){

			
			//this next if is temporary and should be replaced when we put in ajax, in the future the redicret willl come from teh ajax
			//section in the view just like all the other redirects for non logged in people.
			if (!$authUser){
			

				$this->redirect('/users/login');
			}

			//with submissions on the search bar we need to be careful that it does not conflict with other post
			//requests that are coming in.
			if ($this->request->data['Profile']['search']){

				$this->redirect('/main/index/search:'.$this->request->data['Profile']['search']);
			}

			if(!$userfollow && isset($_POST['follow'])){

				$followed_models = $this->Profile->Upload->find('all',

					array(	

						'conditions' => array('Upload.profile_id' => $_POST['follow'])
					)
				);

				$models = $this->Profile->query();

				$strip_userid = str_replace("-", "", $userid);

				//get teh followed user's username
				$followed_username = $this->params['named']['username'];

				//creates the base table for the user to hold his ques
				$this->Profile->query(

				"CREATE TABLE IF NOT EXISTS `". $strip_userid."`
	        	(`quetitle` char(50), 
	        	`quesize` char(50),
        		`que_follow_flag` int(1),
        		`followed_user_id` char(36));"
				);

				/*ADD TO WEBSITE**/
				//NOTE STRIP_PASSED_ID in next two queries.
				$this->Profile->query(

          			"INSERT INTO `". $strip_userid ."` (`quetitle`, `quesize`, `que_follow_flag`, `followed_user_id`,`created`, `modified`)
                	VALUES ('".str_replace("'", "''", $strip_passed_id."self")."', '0', '1', '".$_POST['follow'] ."', '".date("Y-m-d H:i:s")."', '".date("Y-m-d H:i:s")."');"
            	);

            	$this->Profile->query(
            		
                "CREATE TABLE IF NOT EXISTS `". $strip_passed_id."self". "`
                (`model_title` char(50), 
                `model_size` char(50),
                `model_id` char(36), 
                `user_id` char(36),
                `user_name` varchar(45),
                `file_exten` char(10),
                `model_description` text,
                `likes` int(11),
                `dislikes` int(11),
                `rank` float,
                `num_pics` int(11),
                `num_mods` int(11),
                `file_types` int(11),
                `created` datetime,
	            `modified` datetime);"

                );
               // print_r($followed_models);
				
                foreach ($followed_models as $followed_model) {

                	$file_ext = array();
					$file_types = ''.$followed_model['Upload']['file_types'];

					//loop through the numbers in the $file_types string and determine which
					//file extensions to use for each file.
					for ($i=0 ; $i < strlen($file_types); $i++){

						switch($file_types[$i]){


							case 1;

								$file_ext[$i] = 'jpg';
		       				break;

		       				case 2;

		       					$file_ext[$i] = 'gif';
		       				break;

		       				case 3;

		       					$file_ext[$i] = 'png';
		       				break;

		       				default;
						}
					}	
                	
                	/*$this->Profile->query(

					"INSERT INTO `". $strip_userid . $followed_username."'s que" ."` (`model_title`, `model_size`, `model_id`, `user_id`, `user_name`, `file_exten`, `model_description`,`likes`,`dislikes`,`num_pics`,`num_mods`,`file_types`, `created`, `modified`)
               		 VALUES ('".str_replace("'", "''", $followed_model['Upload']['title'])."', '0', '".$followed_model['Upload']['id']."', '".$followed_model['Upload']['user_id']."','". $followed_model['Upload']['username']."','". $file_ext[0] ."','".str_replace("'", "''", $followed_model['Upload']['description'])."','".$followed_model['Upload']['likes']."','".$followed_model['Upload']['dislikes']."','". strlen($followed_model['Upload']['file_types'])."','".$followed_model['Upload']['number_stls']."','".$followed_model['Upload']['file_types']."','".date("Y-m-d H:i:s")."','".date("Y-m-d H:i:s")."');"

					);*/
                }
                ///cakephp-cakephp-0a6d85c/product/index/id:52cfb994-24dc-4202-bab9-4992a93f502d/exten:png/title:File1/descrip:File1/artistid:52cf6c6a-fa14-40da-84cc-4711a93f502d/likes:0/dislikes:1/num_pics:2/num_mods:2/file_types:33"
                //
				$this->request->data['Followtrack']['followed_user_id'] = $_POST['follow'];
				$this->request->data['Followtrack']['follower_user_id'] = $userid;

				//if all is successful and we add an entry to the followtracks table
				//then we can increment the number of followers by 1

				$this->request->data = Sanitize::clean($this->request->data);
				if($this->Profile->Followtrack->save($this->request->data)){
					
					$this->Profile->query(

						"UPDATE users
						SET number_followers = number_followers + 1
						WHERE `id`='".$passed_id."';"
					);
				}
			}

			if($userfollow && isset($_POST['unfollow'])){

				$strip_userid = str_replace("-", "", $userid);

				$user_to_unfollow = $this->params['named']['username'];

				$this->Profile->query(

				"DELETE FROM `followtracks`
				WHERE `followed_user_id` = '".$_POST['unfollow']."' AND `follower_user_id` = '".$userid."';"
				.
				"DELETE FROM `".$strip_userid."`
				WHERE `quetitle` = '".$strip_passed_id."self"."';"
				//.
				//"DROP TABLE `".$strip_userid.$user_to_unfollow."'s que"."`;"
				.
				"UPDATE users
				SET number_followers = number_followers - 1
				WHERE `id`='".$passed_id."';"

				);
			}
		}
	}
}

?>