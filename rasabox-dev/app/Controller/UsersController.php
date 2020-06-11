<?php

class UsersController extends AppController{

	function beforeFilter(){

		parent::beforeFilter();
		$this->Auth->allow('add', 'logout', 'login');
		$this->Auth->fields = array('username' => 'username', 'password' => 'password');
		$this->Auth->loginAction = array('controller' => 'users', 'action' => 'login');
		$this->Auth->loginRedirect = array('controller' => 'main', 'action' => 'index');
		$this->Auth->logoutRedirect = '/users/login';
	}

	public function login() {

		if($this->request->is('post')){

			if ($this->request->data['User']['search']){

				$this->redirect('/main/index/search:'.$this->request->data['User']['search']);
			}

			$url_to_direct_back_to = "/";

			if (isset($_SESSION['Login']['redirect_url'])){


				$_SESSION['Login']['redirect_url'] = str_replace("/cakephp-cakephp-0a6d85c/", "", $_SESSION['Login']['redirect_url']);

				$url_to_direct_back_to .= $_SESSION['Login']['redirect_url'];
			}
			else{

				$url_to_direct_back_to .= "main/index/search:@null";
			}

			if( $this->Auth->login( $this->Auth->user('id') ) ){
				
				$this->redirect($url_to_direct_back_to);
			}
			else{

				//SEE #2 in DOCUMENTATION
				//set the data from the form (we need ot do this when we aren't saving it)
				$this->User->set($this->data);
				//unset the rules that don't make sense for login like username taken error.
				unset($this->User->validate['username']['ruleIsUnique']);
				//validate the data (run it through $validate in user.php) without saving it.
				$this->User->validates();

				if( (!$this->User->find('first', array('conditions' => array('User.username' => $this->data['User']['username']))) || !$this->User->find('first', array('conditions' => array('User.password' => $this->data['User']['password'])))) && $this->data['User']['password'] && $this->data['User']['username']){

					$this->User->validationErrors['username']['0'] = "Invalid username or password.";
				}
			}

		}
	}

	public function index() {

	}

	public function add(){

		if($this->request->is('post')){

			if ($this->request->data['User']['search']){

				$this->redirect('/main/index/search:'.$this->request->data['User']['search']);
			}

			$this->request->data = Sanitize::clean($this->request->data);
			if ($this->User->save($this->request->data)){
				//print_r("ROMANS FAULTS");
				$this->redirect('/users/login');
			}

			else{

				//$this->redirect('/users/add');
			}
		}
	}


	public function logout() {

		//$this->Auth->user() instead of $this->Auth->user('id');
    	$this->redirect($this->Auth->logout($this->Auth->user('id')));
	}
}
?>