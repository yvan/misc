<?php

class FilemanagerController extends AppController{


	public function index(){
		
		//get information about the user visiting and user 
		//who's profile is being visited
		$userid = $this->params['named']['id'];
		$strip_userid = str_replace("-", "", $userid); //also replace ;
		

		//creates an SQLSTATE [42000] error on the actual live server
		//the way to fix this issue is to add the `` s you see below in
		//each SQL statement. Anywhere there's a ' you should add a `. 
		//DO NOT replace the ' for actual table values with `. ` is ONLY
		//for the parts of each query that will be non dynamic in the final table.
		//creates the base table for the user to hold his ques
		$this->Filemanager->query(

			"CREATE TABLE IF NOT EXISTS `". $strip_userid."`
        	(`quetitle` char(50), 
        	`quesize` char(50),
        	`que_follow_flag` int(1),
        	`followed_user_id` char(36),
        	`created` datetime,
        	`modified` datetime);"
		);

		$user_table_querys = $this->Filemanager->query(

		"SELECT *
		FROM `".$strip_userid."`;"

		);

		$models_from_que = array();

		$count = 0;
		/*THIS NEXT PART ADD TO WEBSITE*/
		foreach ($user_table_querys as $user_table_query) {
			
			if (substr($user_table_query[$strip_userid]['quetitle'], strrpos($user_table_query[$strip_userid]['quetitle'], "self")) == "self"){


				$models_from_que_temp = $this->Filemanager->query(

					"SELECT * 
					FROM `".$user_table_query[$strip_userid]['quetitle']."`;"
				);

			}
			else{

				$models_from_que_temp = $this->Filemanager->query(

					"SELECT * 
					FROM `". $strip_userid . $user_table_query[$strip_userid]['quetitle']."`;"
				);


			}


			foreach ($models_from_que_temp as $key => $temp) {

				$models_from_que[$count] = $temp;

				$count++;
			}
		}

		//print_r($models_from_que);
		$this->set('userid', $userid);
		$this->set('current_username', $this->Auth->user('username'));
		$this->set('strip_userid', $strip_userid);
		$this->set('queinfos', $user_table_querys);
		$this->set('models_from_que', $models_from_que);
		$this->set('username', $this->Auth->user('username'));
		
		//th reason we always get teh list regardless of a post request
		//or not is because if we don't then teh user can immediately 
		//resubmit the name a of the que they just made and crash
		//the database (trying to make same table 2x).
		//still havent resolved 100%, but now if we wait like 10 
		// seconds its fine, maybe a global var of the thing we 
		//just made?

		if ($this->request->is('post')){

			//with submissions on the search bar we need to be careful that it does not conflict with other post
			//requests that are coming in.
			if ($this->request->data['Filemanager']['search']){

				$this->redirect('/main/index/search:'.$this->request->data['Filemanager']['search']);
			}

			//SEE #3 in DOCUMENTATION
			//set the data from the form (we need ot do this when we aren't saving it)
			
			$this->data = $this->data['que_create'];

			$this->Filemanager->set($this->data);

			$this->set('dataused', $this->data);
			//validate the data (run it through $validate in user.php) without saving it.
			if($this->Filemanager->validates()){

			}
			else{

				$this->Filemanager->validationErrors['quetitle']['0'] = "Your list title, within 5 to 25 characters, must be.";
			}
		}
	}
}  

?>