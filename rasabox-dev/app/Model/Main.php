<?php 

//this just says taht the Main page or main object has many Uploads and liketracks,
//it allows us to access the data in those tables in this model. analogous 'belongsTo' in upload.php
class Main extends AppModel{

	public $hasMany = array('Upload', 'Liketrack', 'Product');

	public $belongsTo = array('Product');

	public $validate = array(

		'Main.search' => array(
			'rule' => array('between', 4, 60),
			'message' => 'Your search should be between 4 and 50 characters',
		),

	);
}

?>