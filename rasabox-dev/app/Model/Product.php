<?php

class Product extends AppModel{

 	public $hasMany = array('Followtrack', 'Comment', 'Liketrack', 'Upload', 'Main');
	
	public $belongsTo = array('Main');



	public $validate = array(


		'new_comment' => array(
			'rule1' => array(

				'rule'=>array('between', 4, 300),
				'message' => 'Your search should be between 4 and 300 characters',
			)
		),
	);
}

?>