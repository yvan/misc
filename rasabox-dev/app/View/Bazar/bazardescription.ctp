<?php
	
	echo $this->Html->css('bazardescription');

	//FOR THE LOVE OF GOD CHECK TO MAKE SURE YOU ARE REFERENCING THE RIGHT JQUERY. NOT JQUERY MIN THIS 'jquery.js' is the right one.

	echo $this->Html->script('jquery.js'); 

?>

<div id="page-main">

	<div id="node-field">

	<?php

		echo $this->Html->div('bazar-submits',


		$this->Html->image('bazar-return.png', array('alt' => 'Image Error' , 'url' => '/bazar')), 

		array('id'=> 'bazar-return')

		);

		echo $this->Html->div(null,

			$bazar_query['Bazar']['title'],
			array('id' => 'titletext')
		);
		
		echo $this->Html->div(null,

			$bazar_query['Bazar']['description'],
			array('id' => 'descriptext')
		);

		echo $this->Html->div(null,

				$this->Form->create('BazarQuery'.$bazar_query['Bazar']['bazar_id'].'pressed', array('default' => false))
				.
				$this->Form->button('', 

					array('label'=>false, 

						'type' => 'submit',
						'name' => 'submitlike' ,
						'value' => $bazar_query['Bazar']['bazar_id']
					)
				)
				.
				$this->Form->button('', 
						
					array('label'=>false, 

						'type' => 'submit',
						'name' => 'submitdislike' ,
						'value' => $bazar_query['Bazar']['bazar_id']
					)
				)
				.
				$this->Form->end()
				.
				$this->Html->div('Bazarlikes',

					''. $bazar_query['Bazar']['likes'],

					array('id'=>'BazarRlikes')
				)
				.
				$this->Html->div('Bazardislikes',

					''. $bazar_query['Bazar']['dislikes'],

					array('id'=>'BazarRdislikes')
				),

				array('id' => 'like-box')


			);

			echo '<script>';

		    echo '$(document).ready(function(){';

		    // find the comment form and add a submit event handler
		    //ProductIndexForm is the form for submitlike and submitdislike
		    echo '$(\'#BazarQuery'.$bazar_query['Bazar']['bazar_id'].'pressedBazardescriptionForm\').click(function (e) {';

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
		        data: {\'numberlikes\': \''.$bazar_query['Bazar']['likes'].'\', \'numberdislikes\': \''.$bazar_query['Bazar']['dislikes'].'\', \'bazar_id\': \''.$bazar_query['Bazar']['bazar_id'].'\', \'current_user_id\': \''.$userid.'\', \'liked_or_disliked\': clickedval, \'bazar_title\': \''.$bazar_query['Bazar']['title'].'\', \'description\': \''.$bazar_query['Bazar']['description'].'\', \'artist_username\': \''.$bazar_query['Bazar']['username'].'\', \'artistid\': \''.$bazar_query['Bazar']['user_id'].'\', \'rank\': \''.$bazar_query['Bazar']['rank'].'\', \'true_rank\': \''.$bazar_query['Bazar']['true_rank'].'\' },

		        }).done(function ( ) {
		            
		            
		           	
		        
		        }).fail(function ( jqXHR, textStatus, errorThrown ) {

		        	
		        
		        });';

		    echo '});';

		    echo  '});';

		    echo '</script>';

	?>

	</div>
</div>