<?php 

class Bazar extends AppModel{

	public $hasMany = array('Bazarliketrack');


	public $validate = array(

		'title' => array(

			'ruleBewteen5and29' => array(

				'rule' => array('between', 5, 29),
				'message' => 'This is not the title you are looking for. The title you want should be between 5 and 29 characters.',
				'last' => true,
        	)
		),
		'description' => array(

			'ruleBetween15and50' => array(

				'rule' => array('between', 15, 400),
				'message' => 'This is not the description you are looking for. The description you want should be between 15 and 400 characters.',
				'last' => true,
        	)
		)
	);


}

?>