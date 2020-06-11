<?php

class AboutController extends AppController {


	public function index(){
		
		$this->set('userid', $this->Auth->user('id'));
		$this->set('current_username', $this->Auth->user('username'));

		if($this->request->is('post')){

			//with submissions on the search bar we need to be careful that it does not conflict with other post
			//requests that are coming in.
			if ($this->request->data['About']['search']){

				$this->redirect('/main/index/search:'.$this->request->data['About']['search']);
			}
 

		}
	}
}


?>