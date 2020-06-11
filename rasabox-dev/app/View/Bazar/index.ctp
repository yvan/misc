<?php 
	
	echo $this->Html->css('bazar'); 

	//FOR THE LOVE OF GOD CHECK TO MAKE SURE YOU ARE REFERENCING THE RIGHT JQUERY. NOT JQUERY MIN THIS 'jquery.js' is the right one.

	echo $this->Html->script('jquery.js'); 

?>
<div id="page-main">

	<div id="node-field">
<?php


	echo $this->Html->div('bazar-submits',

		//constructed these as links because I don't want the controller to have to handle more than necessary.
		//less processing server side. 
		$this->Html->image('bazar-request-stl.png', array('alt' => 'Image Error' , 'url' => '/bazar/requeststl')), 

		array('id'=> 'request-stl')
	);

	echo $this->Html->div('bazar-submits',


		$this->Html->image('bazar-propose-stl.png', array('alt' => 'Image Error' , 'url' => '/bazar/proposestl')), 

		array('id'=> 'propose-stl')
	);


	echo $this->Html->div('',

		'',
		array('id'=>'separator-line')
	);


	?>

	<div id="Requests">

	<?php


		echo $this->Html->div('',

			'',
			array('id'=>'separator-line')
		);

		foreach ($BazarRequests as $BazarR) {

			echo $this->Html->div('BazarRPost',

				$this->Html->div('BazarRtitle',

					$this->Html->link( $BazarR['Bazar']['title'], '/bazar/bazardescription/bazar_id:'. $BazarR['Bazar']['bazar_id']),

					array('id'=>'BazarR')
				)
				.
				$this->Form->create("BazarR".$BazarR['Bazar']['bazar_id']."pressed", array('default' => false))
				.
				$this->Form->button('', 

					array('label'=>false, 

						'type' => 'submit',
						'name' => 'submitlike' ,
						'value' => $BazarR['Bazar']['bazar_id']
					)
				)
				.
				$this->Form->button('', 
						
					array('label'=>false, 

						'type' => 'submit',
						'name' => 'submitdislike' ,
						'value' => $BazarR['Bazar']['bazar_id']

					)
				)
				.
				$this->Form->end()
				.
				$this->Html->div('BazarRlikes',

					''. $BazarR['Bazar']['likes'],

					array('id'=>'BazarRlikes')
				)
				.
				$this->Html->div('BazarRdislikes',

					''. $BazarR['Bazar']['dislikes'],

					array('id'=>'BazarRdislikes')
				)
			);

			echo '<script>';

		    echo '$(document).ready(function(){';

		    // find the comment form and add a submit event handler
		    //ProductIndexForm is the form for submitlike and submitdislike
		    echo '$(\'#BazarR'.$BazarR['Bazar']['bazar_id'].'pressedIndexForm\').click(function (e) {';

		    //get teh name from the button we clicked to know if user submitted a like or a dislike
		    echo  'clickedval = e.target.name;';
		    //gets the id of the clicked thing, we're gonna try to do this in one script.
		    //WE CANNOT DO IT IN ONE SCRIPT (Well we can but it's way more work)WE NEED A SCRIP for each one or else the update
		    //functions in the external script won't have any old numbers to update.
		    //echo  'clickedid = e.target.value;';

		    // stop the browser from submitting the form
		    // sometimes to prevent the default submit/reload action of the webpage you need to add array('default' => false) 
		    // to the form create statement, this prevents the default submit action for sure.
		    echo  'e.preventDefault();';

		    //if the user is not logged in and attempts to like stuff, we will redirect him to the login page.
            if (!$authUser){
                
                echo 'window.location.replace("http://localhost:8888/cakephp-cakephp-0a6d85c/users/login");';
            }

		    //the request works, it spawns an error message.
		    //it get to success/failure because the url is working now.
		    //user id i s the current user not the artist. We use this data for liketracks. 
		    //the user who actually liked the thing. "$userid" set as this-auth-id in MainController.
		    //you can check the current userid is set to this-Auth(id) in the controller.
		    //$BazarP['Bazar']['user_id'] is the original poster's id pulled from database.

		    //FOR THE LOVE OF ALL THAT IS SACRED TO CODERS MAKE SURE YOU REFERENCED THE PROPER JQUERY SCRIPT
		    // NOT JQUERY MIN just jquery.js, that's why the ajax (And subsequently dialgoue alerts) would just not proc at all.
		    echo '$.ajax({

		        url: \'http://localhost:8888/cakephp-cakephp-0a6d85c/ajaxrequests/bazar_page_like.php\', 
		        type: \'POST\',
		        data: {\'numberlikes\': \''.$BazarR['Bazar']['likes'].'\', \'numberdislikes\': \''.$BazarR['Bazar']['dislikes'].'\', \'bazar_id\': \''.$BazarR['Bazar']['bazar_id'].'\', \'current_user_id\': \''.$userid.'\', \'liked_or_disliked\': clickedval, \'bazar_title\': \''.$BazarR['Bazar']['title'].'\', \'description\': \''.$BazarR['Bazar']['description'].'\', \'artist_username\': \''.$BazarR['Bazar']['username'].'\', \'artistid\': \''.$BazarR['Bazar']['user_id'].'\', \'rank\': \''.$BazarR['Bazar']['rank'].'\', \'true_rank\': \''.$BazarR['Bazar']['true_rank'].'\' },

		        }).done(function ( ) {
		            
		           	
		        
		        }).fail(function ( jqXHR, textStatus, errorThrown ) {

		        	
		        
		        });';

		    echo '});';

		    echo  '});';

		    echo '</script>';
		}
	?>

	</div>

	<div id="Proposals">
		
	<?php

		foreach ($BazarProposals as $BazarP) {

			echo $this->Html->div('BazarPPost',

				$this->Html->div('BazarPtitle',

					$this->Html->link( $BazarP['Bazar']['title'], '/bazar/bazardescription/bazar_id:'. $BazarP['Bazar']['bazar_id']),

					array('id'=>'BazarP')
				)
				.
				$this->Form->create("BazarP".$BazarP['Bazar']['bazar_id']."pressed", array('default' => false))
				.
				$this->Form->button('', 

					array('label'=>false, 

						'type' => 'submit',
						'name' => 'submitlike' ,
						'value' => $BazarP['Bazar']['bazar_id']

					)
				)
				.
				$this->Form->button('', 
						
					array('label'=>false, 

						'type' => 'submit',
						'name' => 'submitdislike' ,
						'value' => $BazarP['Bazar']['bazar_id']

					)
				)
				.
				$this->Form->end()
				.
				$this->Html->div('BazarPlikes',

					''. $BazarP['Bazar']['likes'],

					array('id'=>'BazarPlikes')
				)
				.
				$this->Html->div('BazarPdislikes',

					''. $BazarP['Bazar']['dislikes'],

					array('id'=>'BazarPdislikes')
				)
			);


			echo '<script>';

		    echo '$(document).ready(function(){';
		    // find the comment form and add a submit event handler
		    //ProductIndexForm is the form for submitlike and submitdislike
		    echo '$(\'#BazarP'.$BazarP['Bazar']['bazar_id'].'pressedIndexForm\').click(function (e) {';

		    //get teh name from the button we clicked to know if user submitted a like or a dislike
		    echo  'clickedval = e.target.name;';

		    //gets the id of the clicked thing, we're gonna try to do this in one script.
		    //WE CANNOT DO IT IN ONE SCRIPT (Well we can but it's way more work)WE NEED A SCRIP for each one or else the update
		    //functions in the external script won't have any old numbers to update.
		    //echo  'clickedid = e.target.value;';

		    // stop the browser from submitting the form
		    echo  'e.preventDefault();';

		    //if the user is not logged in and attempts to like stuff, we will redirect him to the login page.
            if (!$authUser){
                
                echo 'window.location.replace("http://localhost:8888/cakephp-cakephp-0a6d85c/users/login");';
            }

		    //the request works, it spawns an error message.
		    //it get to success/failure because the url is working now.
		    //user id i s the current user not the artist. We use this data for liketracks. 
		    //the user who actually liked the thing. "$userid" set as this-auth-id in MainController.
		    //you can check the current userid is set to this-Auth(id) in the controller.
		    //$BazarP['Bazar']['user_id'] is the original poster's id pulled from database.
		    echo '$.ajax({

		        url: \'http://localhost:8888/cakephp-cakephp-0a6d85c/ajaxrequests/bazar_page_like.php\', 
		        type: \'POST\',
		        data: {\'numberlikes\': \''.$BazarP['Bazar']['likes'].'\', \'numberdislikes\': \''.$BazarP['Bazar']['dislikes'].'\', \'bazar_id\': \''.$BazarP['Bazar']['bazar_id'].'\', \'current_user_id\': \''.$userid.'\', \'liked_or_disliked\': clickedval,\'bazar_title\': \''.$BazarP['Bazar']['title'].'\', \'description\': \''.$BazarP['Bazar']['description'].'\', \'artist_username\': \''.$BazarP['Bazar']['username'].'\', \'artistid\': \''.$BazarP['Bazar']['user_id'].'\', \'rank\': \''.$BazarP['Bazar']['rank'].'\', \'true_rank\': \''.$BazarP['Bazar']['true_rank'].'\' },

		        }).done(function ( ) {
		            
		            
		        
		        }).fail(function ( jqXHR, textStatus, errorThrown ) {

		            
		        
		        });';

		    echo '});';

		    echo  '});';

		    echo '</script>';
		}

	?>

	</div>


	</div>
</div>