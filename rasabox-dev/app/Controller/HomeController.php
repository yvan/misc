<?php 

class HomeController extends AppController{

	

	//logic for the main signup page, checks if the entered data
	//can be validated, if it can it redirects to confirm
	//if not it redirects to noconfirm. This avoids duplicate
	//user email entries in our DB.
	public function index(){

		$this->set('userid', $this->Auth->user('id'));
		$this->set('current_username', $this->Auth->user('username'));
		
		if($this->request->is('post')){

			//with submissions on the search bar we need to be careful that it does not conflict with other post
			//requests that are coming in.
			if ($this->request->data['Home']['search']){

				$this->redirect('/main/index/search:'.$this->request->data['Home']['search']);
			}

			//if the search bar is empty and the submitlike or submitdislike posts are empty 
			elseif(!isset($_POST['data[Home][search]']) && ($this->request->data['Home']['email']=='')  ){

				$this->redirect('/');
			}
			
			$this->request->data = Sanitize::clean($this->request->data);
			if ($this->Home->save($this->request->data) )  {

    			$this->redirect('/home/confirm');	
			} 

			else {

				$this->redirect('/home/noconfirm');	
			}
		}			
	}
	//ogic for the confrimation pages, both just redirect
	//to the main page where the user was initially.
	//dong things this way avoids form resubmission
	public function confirm(){

		if($this->request->is('post')){

			if ($this->request->data['Home']['search']){

				$this->redirect('/main/index/search:'.$this->request->data['Home']['search']);
			}


			if(isset($_POST['submit'])){

				$this->redirect('/main/index/search:@null');
			}
		}	
	}

	public function noconfirm(){


		if($this->request->is('post')){

			//print_r($_POST);

			if ($this->request->data['Home']['search']){

				$this->redirect('/main/index/search:'.$this->request->data['Home']['search']);
			}

			if(isset($_POST['submit'])){

				$this->redirect('/');
			}
		}	
	}

	function beforeFilter(){

		$this->Auth->allow('index', 'confirm', 'noconfirm');

	}
}

?>