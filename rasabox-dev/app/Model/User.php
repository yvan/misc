<?php

App::uses('Security', 'Utility');

class User extends AppModel{

	public function beforeSave($options = array()){

		if (isset($this->data['User']['password'])){

			$this->data['User']['password'] = Security::hash($this->data['User']['password'], 'sha1', true);

		}
		
		return true;
	}

	//SEE #2 in DOCUMENTATION
	public $validate = array(
		
		'password' => array(

			'ruleNotEmpty' => array(

				'rule' => 'notEmpty',
				'message' => 'Be empty your password cannot.',
				'last' => true,
        	),
        	'ruleAplaNumeric'=>array(

        		'rule' => 'alphaNumeric',
        		'message' => 'Your password, made of alphanumeric characters, must be.',
        		'last' => true,
        	),
        	'rule5to15' =>array(

        		'rule' => array('between', 5, 15),
        		'message' => 'Your password, within 5 to 15 characters, must be.',
        		'last' => true,
        	)
		),
		'username' => array(

			'ruleNotEmpty' => array(

				'rule' => 'notEmpty',
				'message' => 'Have a blank username, you cannot.  Much to learn young padawan, you have.',
				'last' => true,
        	),
        	'ruleIsUnique' => array(
            	'rule' => 'isUnique',
            	'message' => 'Username taken, try another one earthling.',
            	'last' => true,
        	)
		)
	);
}
?>