<?php 

class Upload extends AppModel{
	
	public $belongsTo= array('Main', 'Filemanager', 'Product', 'Profile');
	//for some fucking reason 5-50 characters just doesnt work.
	
	// SEE DOCUMENTATION #2.
	public $validate = array(

		'search' => array(

			'rulebetween4and60' => array(

				'rule'=>array('between', 4, 60),
				'message' => 'Your search should be between 4 and 50 characters, you can\'t jump to hyperspace without proper coordinates.',
			)
		),
		'title' => array(

			'ruleAcceptedChars' => array(

				'rule' => '/[0-9a-zA-Z\\/\\$_\\. \\+\\!\\*\'\\(\\),\\?:\t\r\n-]*/',
				'message' => 'Your title must contain only valid url cahracters, letters, numbers. Pew. Pew.'
				
			),
			'ruleMinLength' => array(

				'rule' => array('minLength', 4),
				'message' => 'Your title has gotta be at least 4 letters. Come on; even an ewok can spell "ewok."'
			),
			'ruleMaxLength' => array(

				'rule' => array('maxLength', 50),
				'message' => 'Your title can\'t be more than 50 letters. Don\'t be greedy. Greed is the path to the dark side.'
			)
		),
		'description' => array(

			'ruleAcceptedChars' => array(

				'rule' => '/[0-9a-zA-Z\\/\\$_\\. \\+\\!\\*\'\\(\\),\\?:\t\r\n-]*/',
				'message' => 'Your description must contain only valid url cahracters, letters, numbers. Pew. Pew.'
			),
			'ruleMinLength' => array(

				'rule' => array('minLength', 10),
				'message' => 'Your description has gotta be at least 10 letters. Can you spell "lightsaber?"'
			),
			'ruleMaxLength' => array(

				'rule' => array('maxLength', 1000),
				'message' => 'Your description can\'t be over 1000 characters. Our slave army...errr "ewok volunteer force," cannot read more than that.'
			),
		),
		'submittedmodelfile' => array( 

			'ruleExtensionModel' => array(

				'rule'    => 'checkExtensionsModels',
				'message' => 'Submit at least one model file with .stl or .obj file ending. Any other endings you give us are fed to the Sarlacc.'
            )
		),
		'submittedpicture' => array(

			'ruleExtensionPic' => array(

				'rule' => 'checkExtensionsPics',
				'message' => 'Submit at least one picture file with .gif, .jpeg, .png, or .jpg file endings. Other endings make Chewie mad.'
			)
		)
	);


    public function checkExtensionsPics($check) {

    	//print_r($check['submittedpicture']);
	    foreach($check['submittedpicture'] as $file_to_check){

	    	$ext_to_check = substr($file_to_check['name'], strrpos($file_to_check['name'], ".") + 1);

	    	$ext_to_check = strtolower($ext_to_check);

	    	if( !(($ext_to_check == 'jpg') || ($ext_to_check == 'gif') || ($ext_to_check == 'png') || ($ext_to_check == 'jpeg')) ){

        		return false;
      		}
	    }
        return true;
	}
	public function checkExtensionsModels($check) {

	    foreach($check['submittedmodelfile'] as $file_to_check){

	    	$ext_to_check = substr($file_to_check['name'], strrpos($file_to_check['name'], ".") + 1);

	    	$ext_to_check = strtolower($ext_to_check);

	    	if( !($ext_to_check == 'stl') && !($ext_to_check == 'obj') ){

        		return false;
      		}
	    }

        return true;
	}
}
?>