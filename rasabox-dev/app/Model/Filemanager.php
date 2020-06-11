<?php

class Filemanager extends AppModel{

	public $hasMany = array('Upload');


	public $validate = array(
	
		'quetitle' => array(

			'rule5to25' =>array(

	    		'rule' => array('between', 5, 25),
	    		'message' => 'Your password, within 5 to 15 characters, must be.',
	    		'last' => true,
	    	)
		)
	);
}

?>