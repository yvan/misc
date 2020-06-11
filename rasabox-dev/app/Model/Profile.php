<?php 

class Profile extends AppModel{

	public $hasMany = array('Followtrack', 'Upload', 'User');
	
}

?>