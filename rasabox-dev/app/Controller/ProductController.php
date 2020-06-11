<?php

class ProductController extends AppController{

	public $helpers = array('Js');

	public function index(){

		$userid = $this->Auth->user('id');
		$strip_userid = str_replace("-", "", $userid);
		$model_id = $this->params['named']['id'];
		$search_value = $this->params['named']['search_value'];

		//this is a temporary script that will convert previously uploaded files and give them zips
		/*$dash = '';
	    $zip = new ZipArchive();
	    $zip->open(APP . 'webroot' . DS . 'img'. DS . 'models' . DS .$model_id.'-zip.zip', ZipArchive::CREATE);

	    for ($i=0; $i<$number_models; $i++){

	      if ($i==0){

	        $i = '';
	        $dash = '';
	      }

	      if(file_exists(APP .'webroot' . DS . 'img'. DS . 'models' . DS .$model_id.$dash.$i.'.stl')){

	        $zip->addFile(APP . 'webroot' . DS . 'img'. DS . 'models' . DS .$model_id.$dash.$i.'.stl', 'model'.$dash.$i.'.stl');
	      }
	     	if(file_exists(APP .'webroot' . DS . 'img'. DS . 'models' . DS .$model_id.$dash.$i.'.obj')){

	        $zip->addFile(APP . 'webroot' . DS . 'img'. DS . 'models' . DS .$model_id.$dash.$i.'.obj', 'model'.$dash.$i.'.obj');
	      }
	      else{

	        //INSERT SOME KIND OF ERROR HERE.
	      }

	      if ($i == ''){

	        $i = 0;
	        $dash = '-';
	      }

	    }

	    $zip->close();*/

	    $uploadObject = $this->Product->Upload->find('first', 

			array(

				'conditions' => array('Upload.id' => $model_id)
			)
		);

	    //set the file_types array to be the file_types string (the several digit string telling us)
	    //what files we have, from the upload object.
		$file_types = $uploadObject['Upload']['file_types'];

		$file_ext = array();
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

   				case 4;

   					$file_ext[$i] = 'jpeg';

   				break;

   				default;
			}
		}

		$model_types = $uploadObject['Upload']['model_types'];

		$model_ext = array();

		for ($i=0 ; $i < strlen($model_types); $i++){

			switch($model_types[$i]){

				case 1;

					$model_ext[$i] = 'stl';
    
   				break;

   				case 2;

   					$model_ext[$i] = 'obj';

   				break;

   				default;
			}
		}

		$like_flag = 0;

		// find if this user has liked the thing.
		$liketable_result = $this->Product->query(

			"SELECT * FROM `".$model_id."liketable"."`
	      	WHERE( `user_id` = '".$userid."') limit 1;"
		);

		//set liketable flag to 1 or 2 if it exists, set it to 0 if it doesn't
		if ($liketable_result){

			$like_flag = $liketable_result['0'][$model_id."liketable"]['like_flag'];	
		}
		else{

			$like_flag = 0;
		}

		//print_r($like_flag);

		$this->set('model_id', $model_id);
		$this->set('userid', $userid);
		$this->set('title', $uploadObject['Upload']['title']);
		$this->set('extension', $file_ext['0']);
		$this->set('description', str_replace("&sect;", "/", $uploadObject['Upload']['description']));
		$this->set('numberlikes', $uploadObject['Upload']['likes']);
		$this->set('numberdislikes', $uploadObject['Upload']['dislikes']);
		$this->set('rank', $uploadObject['Upload']['rank']);
		$this->set('true_rank', $uploadObject['Upload']['true_rank']);
		$this->set('artistid', $uploadObject['Upload']['user_id']);//user_id here is pulled from the database and is the user id of the creating user, the artist.
		$this->set('strip_userid', $strip_userid);
		$this->set('number_pics', strlen($file_types) - 1);
		$this->set('number_models', $uploadObject['Upload']['number_stls']);
		$this->set('like_flag', $like_flag);
		$this->set('file_ext', $file_ext);
		$this->set('file_types', $file_types);
		$this->set('model_types', $model_types);
		$this->set('model_ext', $model_ext);
		$this->set('artist_username', $uploadObject['Upload']['username']);//artist username
		$this->set('current_username', $this->Auth->user('username'));
		$this->set('search_value', $search_value);
		$authUser = $this->Auth->user();
		$this->set('authUser', $authUser); // to check whether a user is logged in or not.

		//setup a temp username for the user to use (stop being lazy sounds good)
		//
		if (!$authUser){
			

			$this->set('temporary_username', "IamLazy");
		}


		if ($authUser){

			$this->Product->query(

			"CREATE TABLE IF NOT EXISTS `". $strip_userid."`
			(`quetitle` char(50), 
			`quesize` char(50),
			`que_follow_flag` int(1),
			`followed_user_id` char(36),
			`created` datetime,
			`modified` datetime);"
            	
        	);

			//$queflag = 1;

			$table_que_list = $this->Product->query(

				"SELECT *
				FROM `".$strip_userid."`;"
			);

			if (!$table_que_list){

				//anytime you edit the urls leading to the page you gotta edit these tables to include the new data.
				$this->Product->query(

					"INSERT INTO `". $strip_userid ."` (`quetitle`, `quesize`, `que_follow_flag`, `followed_user_id`)
	        		VALUES ('Que1', '0', '0', '0');".

	        		"CREATE TABLE IF NOT EXISTS `".$strip_userid."Que1`
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

	        	$table_que_list = $this->Product->query(

					"SELECT *
					FROM `".$strip_userid."`;"
				);
			}
		}
		
		$this->set('table_que_list', $table_que_list);

		$comments = $this->Product->Comment->find('all',

			array(

				'conditions' => array( 'Comment.product_id' => $model_id) 
			)
		);

		$this->set('comments', $comments);

		$userfollow = $this->Product->Followtrack->find('first',

			array(
											
				'conditions' => array( 'Followtrack.followed_user_id' => $artist_id, 'Followtrack.follower_user_id' =>  $this->Auth->user('id')) 
			)
		);

		if ($userfollow){

			$this->set('userFollowedAlready', 1);
		}

		if ($this->request->is('post')){

			$searchflag = 0;
			$followflag = 0;
			$queflag = 0;
			$added_que = 0;
			$userlikeflag = 0;
			$search_triggered = 0;

			//with submissions on the search bar we need to be careful that it does not conflict with other post
			//requests that are coming in. To deal with this here we added search_triggered varaible.
			if ($this->request->data['Product']['search']){

				$this->redirect('/main/index/search:'.$this->request->data['Product']['search']);
			}

			else{

				$search_triggered = 1;
			}

			if ($this->request->data['Product']['search']){

				$searchnodes = array();
				
				foreach ($nodeparents as $nodeparent) {

					if(strstr( strtolower($nodeparent['title']), strtolower($this->request->data['Product']['search'])) 

					|| strstr(strtolower($nodeparent['description']), strtolower($this->request->data['Product']['search'])) 
					
					|| strstr(strtolower($nodeparent['username']), strtolower($this->request->data['Product']['search']))
					
					){

						$searchnodes[$nodeparent['imageid']]['imagepath'] = 'uploads' . DS . $nodeparent['imageid'] . '.' . $nodeparent['file_ext'];
						$searchnodes[$nodeparent['imageid']]['title'] = $nodeparent['title'];
						$searchnodes[$nodeparent['imageid']]['imageid'] = $nodeparent['imageid'];
						$searchnodes[$nodeparent['imageid']]['username'] = $nodeparent['username'];
						$searchnodes[$nodeparent['imageid']]['description'] = $nodeparent['description'];
						$searchnodes[$nodeparent['imageid']]['user_id'] = $nodeparent['user_id'];
						$searchnodes[$nodeparent['imageid']]['file_ext'] = $nodeparent['file_ext'];
					}
				}

				$searchflag = 1;
				$this->set('searchflag', $searchflag);	
				$this->set('searchnodes', $searchnodes);
			}

			if($this->request->data['Product']['search']=='' && (!$followflag && !$queflag && !$added_que && !$comment_flag && !$userlikeflag && !$search_triggered) ){

				$followflag = 0;
				$this->set('searchflag', 0);
				$this->redirect('/main');
			}
		}
	}
}

?>