<?php 

class MainController extends AppController{


	function beforeFilter(){

		parent::beforeFilter();
	}

	public $helpers = array('Js');

	public function index(){

		/*
		this finds all of our upload objects from upload, this entire next part of the code
		sets an array with all the informaiton about each node, number likes and
		number dislikes are seperate for now, it then ranks them. based on the rank.
		the set functions at the end set the nodes for use in teh index.ctp view file.
		each node is indexed by its unique id.
		*/
		$images = $this->Main->Upload->find('all', 

			array(

				'limit' => 12,

				'order' => array( 'Upload.rank'=>'DESC' )
			)

		);

		$nodeparents = array();
		$numberlikes = array();
		$numberdislikes = array();

		foreach ($images as $image){

			//THIS SNIPPET will create a table for all models that have already been uploaded when the page is loaded once.
			/*$this->Main->query(

     			 "CREATE TABLE IF NOT EXISTS `".$image['Upload']['main_id']."liketable"."`
			      (`number` int(11) NOT NULL AUTO_INCREMENT,
			      `user_id` char(36) NOT NULL,
			      `like_flag` int(11) NOT NULL,
			      `created` datetime,
			      `modified` datetime,
			      PRIMARY KEY (`number`));"

      		);*/

			//This is a query which finds the table for the current model were looking at in $result
			//it sees if this user liked the thing in result at all.
			$liketable_result = $this->Main->query(

				"SELECT * FROM `".$image['Upload']['main_id']."liketable"."`
		      	WHERE( `user_id` = '".$this->Auth->user('id')."') limit 1;"

			);

			$file_types[$image['Upload']['main_id']] = ''.$image['Upload']['file_types'];

			$nodeparents[$image['Upload']['main_id'] ][ 'imagepath' ] = 'uploads' . DS . $image['Upload']['main_id'];
			$nodeparents[$image['Upload']['main_id'] ][ 'title' ] = str_replace("/", "&sect;", $image['Upload']['title']);
			$nodeparents[$image['Upload']['main_id'] ][ 'imageid' ] = $image['Upload']['main_id'];
			$nodeparents[$image['Upload']['main_id'] ][ 'search_value' ] = "@null";
			$nodeparents[$image['Upload']['main_id'] ][ 'username' ] = $image['Upload']['username'];
			$nodeparents[$image['Upload']['main_id'] ][ 'description' ] = str_replace("/", "&sect;", $image['Upload']['description']);
			$nodeparents[$image['Upload']['main_id'] ][ 'user_id' ] = $image['Upload']['user_id'];
			$nodeparents[$image['Upload']['main_id'] ][ 'likes' ] = $image['Upload']['likes'];
			$nodeparents[$image['Upload']['main_id'] ][ 'dislikes' ] = $image['Upload']['dislikes'];

			//we have a rank and a true rank.
			//basically the rank is the effective value of the product/thing its the rounded log3 of the true rank (yeah a little confusing)
			//the true rank is the float log10 value of likes-dislikes, we just round the true rank to get the effective rank.
			//in other words items with order(10) net upvotes are rank 1 and treated equally with difference determined by dates. order(100) net upvote objects are treated
			//equally as rank 2 so something with 100 votes and 130 votes is treated the same.
			//we cna change the precision on the float numbers in true_rank(the precsiion of hte rounding) to expand the spectrum of possible ranks in the future ,now well have 2.1 2.2 2.3 
			//type ranks if we do that.
			$datetimePast = date_create($mainObject['Main']['created']);
			$datetimeCurrent = date_create(date("Y-m-d H:i:s"));
			$timeAgo = date_diff($datetimeCurrent, $datetimePast);

			$numberlikes[$image['Upload']['main_id']] =  $nodeparents[$image['Upload']['main_id'] ][ 'likes' ];
			$numberdislikes[$image['Upload']['main_id']] = $nodeparents[$image['Upload']['main_id'] ][ 'dislikes' ];
			$nodeparents[$image['Upload']['main_id']]['true_rank'] = (log($nodeparents[$image['Upload']['main_id'] ][ 'likes' ] - $nodeparents[$image['Upload']['main_id'] ][ 'dislikes' ], 3)*0.95 - ($timeAgo)); 
			$nodeparents[$image['Upload']['main_id']]['rank'] = round($nodeparents[$image['Upload']['main_id']]['true_rank']);


			//this flag is based on a query for each object's id from the table whose name is object-id."liketable" it tells us whether the user has voted, liked or disliked
			// 0 for no votes, 1 for an upvote, 2 for a downvote, using this data passed to the view we will decide how to color each button.
			if ($liketable_result){

				$nodeparents[$image['Upload']['main_id']]['user_liketable_query'] = $liketable_result['0'][$image['Upload']['main_id']."liketable"]['like_flag'];
				
			}
			else{

				$nodeparents[$image['Upload']['main_id']]['user_liketable_query'] = 0;
			}
			
		}

		$this->set('file_types', $file_types);
		$this->set('numberlikes', $numberlikes);
		$this->set('numberdislikes', $numberdislikes);
		$this->set('nodeparents', $nodeparents);
		$this->set('search_value_tolayout', "@null");
		$this->set('userid', $this->Auth->user('id'));
		$this->set('current_username', $this->Auth->user('username'));
		$authUser = $this->Auth->user();
		$this->set('authUser', $authUser); // to check whether a user is logged in or not.

		//setup a temp username for the user to use (stop being lazy sounds good)
		//if the anonymous non logged in user tries to like, comment, wtvr, he gets the 
		//javascript redirect to create a new user.
		if (!$authUser){

			$this->set('temporary_username', "IamLazy");
			$this->set('userid', 0);
		}

		$results = array();
		$search = $this->params['named']['search'];

		$results=$this->simple_search($search, $results);

		if($search == "@null"){

			$this->set('searchflag', 0);
		}

		else if($search){

			if (!empty($results)){

				$searchnodes = array();
				
				foreach ($results as $result) {

					//This is a query which finds the table for the current model were looking at in $result
					//it sees if this user liked the thing in result at all.
					$liketable_result = $this->Main->query(

     				 "SELECT * FROM `".$result['Upload']['id']."liketable"."`
				      WHERE( `user_id` = '".$this->Auth->user('id')."') limit 1;"

      				);

					$file_types[$result['Upload']['id']] = ''.$result['Upload']['file_types'];

					//fix this. How can we only reference the first thing in the array?
					//because the first thing in teh array corresponds to the picture we're showing. 
					$searchnodes[$result['Upload']['id']]['imagepath'] = 'uploads' . DS . $result['Upload']['id'] /*. '.' . $file_ext[0]*/;
					$searchnodes[$result['Upload']['id']]['title'] = $result['Upload']['title'];
					$searchnodes[$result['Upload']['id']]['imageid'] = $result['Upload']['id'];
					$searchnodes[$result['Upload']['id']]['username'] = $result['Upload']['username'];
					$searchnodes[$result['Upload']['id']]['description'] = $result['Upload']['description'];
					$searchnodes[$result['Upload']['id']]['user_id'] = $result['Upload']['user_id'];
					$searchnodes[$result['Upload']['id']]['likes'] = $result['Upload']['likes'];
					$searchnodes[$result['Upload']['id']]['dislikes'] = $result['Upload']['dislikes'];
					$searchnodes[$result['Upload']['id']]['rank'] = $result['Upload']['rank'];
					$searchnodes[$result['Upload']['id']]['true_rank'] = $result['Upload']['true_rank'];

					//this flag is based on a query for each object's id from the table whose name is object-id."liketable" it tells us whether the user has voted, liked or disliked
					// 0 for no votes, 1 for an upvote, 2 for a downvote, using this data passed to the view we will decide how to color each button.
					if ($liketable_result){


						$searchnodes[$result['Upload']['id']]['user_liketable_query'] = $liketable_result['0'][$result['Upload']['id']."liketable"]['like_flag'];
					}
					else{

						$searchnodes[$result['Upload']['id']]['user_liketable_query'] = 0;
					}

					if ($search == null){

						$searchnodes[$result['Upload']['id']]['search_value'] = "@null";
					}
					else{

						$searchnodes[$result['Upload']['id']]['search_value'] = $search;
					}
					
				}

				$this->set('file_types', $file_types);
				$this->set('searchflag', 1);	
				$this->set('searchnodes', $searchnodes);
				$this->set('search_value_tolayout', $search);
			}

			else{

				$this->set('searchflag', 1);
				$this->set('search_failed_flag', 1);
				$this->set('search_value_tolayout', $search);
				$this->set('search_empty_error', "Your search yielded no results :(. you clearly did not find the page you were looking for. It's ok; stormtroopers couldn't find the broad side of a barn if they tried. If what you are looking for really does not exist request it at the bazar. Some person might just design it.");	
			}
		}

		/*
			The first part calls the search by redirecting with a new parameter to the main
			page. the "@null" parameter returns the default main page with no search.

			This part of the code tracks what's going on with users likes.
			
			Finds the first id where the main_id is the value of the node's
			unique id returned by the like button then also the user id matches
			the user id for that thing.

			For all if the user hasnt already liked or disliked something we proceed. 
			If they have already liked something nothing happens (!userlike returns false).

			If the user hasnt liked/disliked then we check is the $mainObject exists, we check
			if this particular node has has an entry on the main table.
			
			If it doesn't we make an entry into the main table and like table.

			At the begginning it also deals with search.

			That's it.
		*/

		if($this->request->is('post')){

			//we need to be careful now, because if we ask for certain data nad we dont redirect to a search
			//could cause the page to crash.
			//with submissions on the search bar we need to be careful that it does not conflict with other post
			//requests that are coming in.s
			if ($this->request->data['Main']['search']){

				$this->redirect('/main/index/search:'.$this->request->data['Main']['search']);
			}
		}
	}

	function simple_search($search_data, $results){

		$conditions = array();
		$or_conditions = array();
		$final_conditions = array();
		$search_fields = array('Upload.title','Upload.description','Upload.username'); //fields to search 'Video.tags','Video.desc'
		$value = $search_data;
		$value = str_replace("_", " ", $value); 
		$searches = explode(" ", $value);

		foreach($search_fields as $f){

			array_push($conditions, array("$f LIKE"=> "%$value%"));
			
			for($i=0; $i < sizeof($searches); $i++) {

				if($searches[$i] != ""){

					array_push($conditions, array("$f LIKE" => "%$searches[$i]%"));

				}
			}

			array_push($or_conditions,array('OR' => $conditions));	
			$conditions = array();
		}

		$final_conditions = array('OR'=>$or_conditions);		
		$results = $this->Main->Upload->find('all', 

			array(

				'limit' => 100, 

				'conditions' => $final_conditions
			)
		);

		return $results;
	}
}

?>