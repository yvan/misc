<?php

class BazarController extends AppController {


	function beforeFilter(){

		parent::beforeFilter();
		$userid = $this->Auth->user('id');
		$this->set('userid', $userid);
		$this->set('current_username', $this->Auth->user('username'));
	}

	/*
	custom sorting function that sorts the array nodes by 
	number of likes - dislikes or rank which is entered as $key.
	*/
	function yvansort (&$array, $key){

    $sorter = array();
    $ret = array();
    reset($array);

    foreach ($array as $ii => $va) {

        $sorter[$ii]=$va[$key];
    }
    arsort($sorter);

    foreach ($sorter as $ii => $va) {

        $ret[$ii]=$array[$ii];
    }

    	$array=$ret;
	}

	public function index(){


		$BazarObjects = $this->Bazar->find('all', 

			array(

			'limit' => 100,
			'order' => array('Bazar.rank'=>'DESC'))
		);

		$BazarRequests = array();
		$BazarProposals = array();
		$index = 0;

		foreach ($BazarObjects as $Bazar) {
			
			if($Bazar['Bazar']['rpflag'] == 1){

				$BazarProposals[$index]['Bazar'] = $Bazar['Bazar'];
			}

			else{

				$BazarRequests[$index]['Bazar'] = $Bazar['Bazar'];
			}

			$index++;
		}

		$this->set('BazarRequests', $BazarRequests);
		$this->set('BazarProposals', $BazarProposals);

		if($this->request->is('post')){

			//with submissions on the search bar we need to be careful 
			//that it does not conflict with other post
			//requests that are coming in.
			if ($this->request->data['Bazar']['search']){

				$this->redirect('/main/index/search:'.$this->request->data['Bazar']['search']);
			}
		}
	}

	public function proposestl(){

		//MASSIVE FUCKING NOTE TO SELF:
		//IF THE DATA IS NOT SAVING OR JUST SAVING AS BLANKS
		//TURN ON DEBUG IN CORE.PHP and then turn it off set from 0 to 3
		//then run save, then set back to 0 and all the data will save fine
		//in the future...weidest shit ever. 
		//rpflag of 1 is  proposal.
		if($this->request->is('post')){

			$this->request->data['Bazar']['rpflag'] = 1;
			$this->request->data['Bazar']['bazar_id'] = String::uuid();
			$this->request->data['Bazar']['user_id'] = $this->Auth->user('id');
			$this->request->data['Bazar']['username'] = $this->Auth->user('username');

			//SEE #2 in DOCUMENTATION: set the data from the form (we need ot do this when we aren't saving it)
			$this->Bazar->set($this->data);

			//validate the data (run it through $validate in user.php) without saving it.
			if($this->Bazar->validates()){

				$this->request->data = Sanitize::clean($this->request->data);
				if($this->Bazar->save($this->request->data)){

	        		$this->redirect('/bazar');
	      		}
	      	}
		}
	}

	public function requeststl(){

		if($this->request->is('post')){

			// rpflag of 0 is a request
			// maybe rpflag of 2 should be a request/proposal pair that
			// has been fulfilled? 0-1-2.
			$this->request->data['Bazar']['rpflag'] = 0;
			$this->request->data['Bazar']['bazar_id'] = String::uuid();
			$this->request->data['Bazar']['user_id'] = $this->Auth->user('id');
			$this->request->data['Bazar']['username'] = $this->Auth->user('username');

			// SEE #2 in DOCUMENTATION: set the data from the form 
			// (we need ot do this when we aren't saving it)
			$this->Bazar->set($this->data);
			
			// validate the data (run it through $validate in user.php) 
			// without saving it.
			if($this->Bazar->validates()){

				$this->request->data = Sanitize::clean($this->request->data);

				if($this->Bazar->save($this->request->data)){

        			$this->redirect('/bazar');
      			}
			}
		}
	}

	public function bazardescription(){

		$bazar_id = $this->params['named']['bazar_id'];

		$bazar_query = $this->Bazar->find('first',

			array(
				
				//what goes here is the id itself, this returns $_POST['name'] => XXXX									
				'conditions' => array( 'Bazar.bazar_id' => $bazar_id) 
			)
		);

		//print_r($bazar_query);
		$this->set('bazar_id', $bazar_id);
		$this->set('bazar_query', $bazar_query);
	}
}

?>