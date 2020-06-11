<?php 

App::uses('CakeEmail', 'Network/Email');

//$validate is the array that gets used by cakePHP to validate teh data
//the user has entered.  What im doing here is im saying for the field 
//'email' in Home.php and thus the homes table of my directory
//check if that email is formated properly and 'true', check if 
//it returns a real host value(the email is real), then check
//if the email is unique.
class Home extends AppModel{

	public $validate = array(

        'email' => array(

        	'rule1' => array(
            	'rule' => array('email', true),
            	'message' => 'Please enter a valid email address.',
            	'last' => true,
        	),

        	'rule2' => array(
            	'rule' => 'isUnique',
            	'message' => 'Email address already registered.'
        	)
    	),
	);

//this method sends an email to the user before saving their data 
// in homes but after havign validated it with $validate.
	public function beforeSave($options = array()){
	
		$email = new CakeEmail();
		$email->config('default');
		$email->template('default');
		$email->emailFormat('both');
		$email->from(array('rasabox@rasabox.com' => 'rasabox Team'));
		$email->to($this->data['Home']['email']);
		$email->subject('rasabox Signup');
		$email->send('You are now signed up for updates from the rasabox team! Rasabox is a place for you to explore, innovate, and connect with the creators of the world. Be on the lookout for updates!');

		return true;
	}
}

?>