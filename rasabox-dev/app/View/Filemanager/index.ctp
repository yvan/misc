<?php 


	echo $this->Html->css('filemanager');
	echo $this->Html->script('jquery.js'); 

?>

<div id="page-main">

	<?php

	$count = 0;

	?>

	<div id="new-que">

	<?php

		echo $this->Form->create('que_create');
		echo $this->Form->input('quetitle', 

			array(

				'label'=>false, 
				'placeholder'=>'List Title', 
				'onfocus'=>'value=""'
			)
		);

		echo $this->Form->end(array('label'=>'', 'div' => array('id' => 'make_new_que')));

		echo $this->Html->div('filemanager-submits',


			$this->Html->image('profile-return.png', 

			array(

				'alt' => 'rasabox' , 


				'url' => array(

			 		'controller' => 'profile',
					'action' => 'index',
					'id' => $userid,
					'username' => $username
				)
			)), 

			array('id'=> 'filemanager-return')
		);
	?>

	</div>

	<?php

	    $error_count = 0;

		foreach ($this->validationErrors['Filemanager'] as $validationError) {

			$error_count++;
			echo $this->Html->div('error-message-yvancustom', $validationError['0'], array('id'=>'error-message-yvancustom-'.$error_count));
		}

	?>

	<div class="node-field">

		<?php

			foreach ($queinfos as $queinfo) {
				
				if (!$queinfo[$strip_userid]['que_follow_flag']){

					echo $this->Html->div('file_list_header',

					//reset all internally used underscores to spaces, for visual effect.
					str_replace("_", " ", $queinfo[$strip_userid]['quetitle'])
					.
					$this->Form->create('bigx'.$userid.$queinfo[$strip_userid]['quetitle'], array('default' => false))
					.
					$this->Form->button('', 

						array('label'=>false, 

							'type' => 'submit',
							'name' => 'bigx',
							'value' => $userid.$queinfo[$strip_userid]['quetitle']
						)
					)
					.
					$this->Form->end(),

					array('id' => $queinfo[$strip_userid]['quetitle'])
					);  

					//THIS IS GOING TO TBE THE ajax that deletes an entire list
	            	//user id i s the current user not the artist. We use this data for liketracks. 
	           		//the user who actually liked the thing.
		            echo '<script>';

		            echo '$(document).ready(function(){';

		            // find the comment form and add a submit event handler
		            //ProductIndexForm is the form for submitlike and submitdislike
		            echo '$(\'#'.'bigx'.$userid.$queinfo[$strip_userid]['quetitle'].'IndexForm\').click(function (e) {';

		            //get teh name from the button we clicked to know if user submitted a like or a dislike
		            echo  'clickedval = e.target.name;';

		            // stop the browser from submitting the form
		            echo  'e.preventDefault();';

		            //the request works, it spawns an error message.
		            //it get to success/failure because the url is working now.
		            //make a deleted list and all its models disappear after we click big x
		            echo '$.ajax({

		                url: \'http://localhost:8888/cakephp-cakephp-0a6d85c/ajaxrequests/filemanagerdeletelist.php\', 
		                type: \'POST\',
		                data: {\'quetitle\': \''.$queinfo[$strip_userid]['quetitle'].'\', \'filemanager_user_id\': \''.$userid.'\', \'strip_userid\': \''.$strip_userid.'\'},

		                }).done(function ( ) {

		                $(\'#'.$queinfo[$strip_userid]['quetitle'].'\').fadeOut(\'fast\');

		                $(\'.file_node_'.$queinfo[$strip_userid]['quetitle'].'\').fadeOut(\'fast\');

		                
		                }).fail(function ( jqXHR, textStatus, errorThrown ) {

		                
		                });';

		            echo '});';

		            echo  '});';

		            echo '</script>';
				}

				else{	

					echo $this->Html->div('file_list_header',

					//reset all internally used underscores to spaces, for visual effect.
					str_replace("_", " ", $queinfo[$strip_userid]['quetitle'])
					.
					$this->Form->create('unfollow'.$queinfo[$strip_userid]['followed_user_id'].$queinfo[$strip_userid]['quetitle'], array('default' => false))
					.
					$this->Form->button('', 

						array('label'=>false, 

							'type' => 'submit',
							'name' => 'unfollow-small',
							'value' => $queinfo[$strip_userid]['followed_user_id'].$queinfo[$strip_userid]['quetitle']
						)
					)
					.
					$this->Form->end(),

					array('id' => $queinfo[$strip_userid]['quetitle'])
					); 

					//THIS IS GOING TO TBE THE ajax that deletes an entire list
	            	//user id i s the current user not the artist. We use this data for liketracks. 
	           		//the user who actually liked the thing.
		            echo '<script>';

		            echo '$(document).ready(function(){';

		            // find the comment form and add a submit event handler
		            //ProductIndexForm is the form for submitlike and submitdislike
		            echo '$(\'#'.'unfollow'.$queinfo[$strip_userid]['followed_user_id'].$queinfo[$strip_userid]['quetitle'].'IndexForm\').click(function (e) {';

		            //get teh name from the button we clicked to know if user submitted a like or a dislike
		            echo  'clickedval = e.target.name;';

		            // stop the browser from submitting the form
		            echo  'e.preventDefault();';

		            //the request works, it spawns an error message.
		            //it get to success/failure because the url is working now.
		            //make an entire list that we had been following (and have now unfollowed, and 
		            //all it's models fadeout before a page reload once we're done with the ajax.

		            echo '$.ajax({

		                url: \'http://localhost:8888/cakephp-cakephp-0a6d85c/ajaxrequests/filemanagerunfollow.php\', 
		                type: \'POST\',
		                data: {\'quetitle\': \''.$queinfo[$strip_userid]['quetitle'].'\', \'filemanager_user_id\': \''.$userid.'\', \'strip_userid\': \''.$strip_userid.'\',\'followed_user_id\': \''.$queinfo[$strip_userid]['followed_user_id'].'\'},

		                }).done(function ( ) {

		        		$(\'#'.$queinfo[$strip_userid]['quetitle'].'\').fadeOut(\'fast\');

		                $(\'.file_node_'.$queinfo[$strip_userid]['followed_user_id'].'\').fadeOut(\'fast\');
		                    
		                }).fail(function ( jqXHR, textStatus, errorThrown ) {
		            
		                	
		                
		                });';

		            echo '});';

		            echo  '});';

		            echo '</script>';
				}


				//print_r($models_from_que);

				foreach ($models_from_que as $model) {

					//print_r($model[$strip_userid . $queinfo[$strip_userid]['quetitle']]['model_id']);

					if ($model[$strip_userid . $queinfo[$strip_userid]['quetitle']] OR $model[$queinfo[$strip_userid]['quetitle']] ){

						//if we're NOT trying to display a followed user's que
						if (substr($queinfo[$strip_userid]['quetitle'], strrpos($queinfo[$strip_userid]['quetitle'], "self")) != "self"){
						
							echo $this->Html->div('file_node '.'file_node_'.$queinfo[$strip_userid]['quetitle'],

							$this->Html->div('fieldtitle',

								$this->Html->link(

								$model[$strip_userid . $queinfo[$strip_userid]['quetitle']]['model_title'], 

								'/img/' . 'models' . DS . $model[$strip_userid . $queinfo[$strip_userid]['quetitle']]['model_id'] . '.stl', 

								array('class' => 'linkdl')

								)
							)
							.
							$this->Html->image('/img/thumbs' . DS . $model[$strip_userid . $queinfo[$strip_userid]['quetitle']]['model_id']. 'thumb'. '.'. $model[$strip_userid . $queinfo[$strip_userid]['quetitle']]['file_exten'], 

		 					array('alt' => 'Image Error', 

			 						'url' => array(

			 							'controller' => 'product',
		    							'action' => 'index',
		    							'id' => $model[$strip_userid . $queinfo[$strip_userid]['quetitle']]['model_id'],
		    							'search_value' => "@null"				

			 						),

		 						'id' => 'que-node-image'
		 						)
		 					) 
							.
							//little x button that is for delete in a non followed que passed_flag = 0
							$this->Form->create('deletemodel'.$queinfo[$strip_userid]['quetitle'].$model[$strip_userid . $queinfo[$strip_userid]['quetitle']]['model_id'], array('default' => false) )
							.
							$this->Form->button('',

								array('label'=>false,

									'type' => 'submit',
									'name' => 'smallx' ,
									'value' => 
									$model[$strip_userid . $queinfo[$strip_userid]['quetitle']]['model_id'].$queinfo[$strip_userid]['quetitle']
								)
							)
							.
							$this->Form->end(),

							array('id' => 'file_node_'.$model[$strip_userid . $queinfo[$strip_userid]['quetitle']]['model_id'])
						 	);

				            echo '<script>';

				            echo '$(document).ready(function(){';

				            // find the comment form and add a submit event handler
				            //ProductIndexForm is the form for submitlike and submitdislike
				            echo '$(\'#'.'deletemodel'.$queinfo[$strip_userid]['quetitle'].$model[$strip_userid . $queinfo[$strip_userid]['quetitle']]['model_id'].'IndexForm\').click(function (e) {';

				            //get teh name from the button we clicked to know if user submitted a like or a dislike
				            echo  'clickedval = e.target.name;';
				         	
				            // stop the browser from submitting the form
				            echo  'e.preventDefault();';

				            //the request works, it spawns an error message.
				            //it get to success/failure because the url is working now.
				            //once make the model we just deleted "fade out" or disappear before a page reload.
				            echo '$.ajax({

				                url: \'http://localhost:8888/cakephp-cakephp-0a6d85c/ajaxrequests/filemanagerdeletemodel.php\', 
				                type: \'POST\',
				                data: {\'quetitle\': \''.$queinfo[$strip_userid]['quetitle'].'\', \'filemanager_user_id\': \''.$userid.'\', \'strip_userid\': \''.$strip_userid.'\', \'model_id\': \''.$model[$strip_userid . $queinfo[$strip_userid]['quetitle']]['model_id'].'\'},

				                }).done(function ( ) {

				                	$(\'#file_node_'.$model[$strip_userid . $queinfo[$strip_userid]['quetitle']]['model_id'].'\').fadeOut(\'fast\');
				                	
				                    
				                }).fail(function ( jqXHR, textStatus, errorThrown ) {
				                
				                	
				                
				                });';

				            echo '});';

				            echo  '});';

				            echo '</script>';
						}

						//if we ARE trying to diplay a followed user's queue we change all the printout's to not include the appended id BEOFRE the "Self" queue name because it's already included in teh queue and name shows up as 2 ids +self which is not recognized by the filemanager controller.
						//GETS RID OF STRIP USERID FROM EVERYTHING except the queinfo index, this indexes into the queulist to get stuff.
						else{

						echo $this->Html->div('file_node '.'file_node_'.$queinfo[$strip_userid]['followed_user_id'],

						$this->Html->div('fieldtitle',

							$this->Html->link(

							$model[$queinfo[$strip_userid]['quetitle']]['model_title'], 

							'/img/' . 'models' . DS . $model[ $queinfo[$strip_userid]['quetitle']]['model_id'] . '.stl', 

							array('class' => 'linkdl')

							)
						)
						.
						$this->Html->image('/img/thumbs' . DS . $model[ $queinfo[$strip_userid]['quetitle']]['model_id']. 'thumb'. '.'. $model[$queinfo[$strip_userid]['quetitle']]['file_exten'], 

	 					array('alt' => 'Image Error', 

		 						'url' => array(

		 							'controller' => 'product',
	    							'action' => 'index',
	    							'id' => $model[$queinfo[$strip_userid]['quetitle']]['model_id'],
	    							'search_value' => "@null"
		 						),

	 						'id' => 'que-node-image'
	 						)
	 					)

	 					);

						}
					}
				}
			}

			//THIS IS GOING TO TBE THE FILEMANAGER AJAX TO MAKE A LIST
		    //user id i s the current user not the artist. We use this data for liketracks. 
		    //the user who actually liked the thing.
		    echo '<script>';

		    echo '$(document).ready(function(){';

		    // find the comment form and add a submit event handler
		    //ProductIndexForm is the form for submitlike and submitdislike
		    echo '$(\'#make_new_que\').click(function (e) {';

		    //get teh name from the button we clicked to know if user submitted a like or a dislike
		    echo  'clickedval = e.target.name;';
		    echo  'quetitle = document.getElementById("que_createQuetitle").value;';
		    
		    //SEE #3 in DOCUMENTATION
		    //if the data passes our cutom validation function below (length between 5 and 25)
			echo 'if(validatequetitle(quetitle)){

		    		// stop the browser from submitting the form
					// default is NOT set to false in the  que_create form above
		    		e.preventDefault();
		    		$(\'.error-message-yvancustom\').fadeOut(\'fast\');
		  	';
		  	//once finished prepend (tack on teh front of the containing div) the que/list we jsut made w/o a page reload.
		    //process and send the ajax request to url with data and type of request
		    echo '$.ajax({

		        url: \'http://localhost:8888/cakephp-cakephp-0a6d85c/ajaxrequests/make_que.php\', 
		        type: \'POST\',
		        data: {\'quetitle\': quetitle, \'filemanager_id\': createUUID(), \'filemanager_user_id\': \''.$userid.'\', \'strip_user_id\': \''.$strip_userid.'\'},

		        }).done(function ( ) {
		        	

		        $("div.node-field").prepend("<div id=\""+quetitle+"\" class=\"file_list_header\">"+quetitle+"</div>");

		        }).fail(function ( jqXHR, textStatus, errorThrown ) {
		        
		        
		        });';
	
			// end validation if 

		
			echo '

			}

			';

		    echo '});';

		    echo  '});';

		    echo '</script>';
		    //form displays properly I jsut can't get the javascript/ajax to print out right. it seems the final </script> disrupts and counts as closing the entire script 
		    //prematurely. Same issue will need ot be resolved on teh comment delete.
		    /*
				<form action=\"/cakephp-cakephp-0a6d85c/filemanager/index/id:'.$userid.'\" id=\"bigx'.$userid.'Que1IndexForm\" onsubmit=\"event.returnValue = false; return false;\" method=\"post\" accept-charset=\"utf-8\"><div style=\"display:none;\"><input type=\"hidden\" name=\"_method\" value=\"POST\"/></div><button type=\"submit\" name=\"bigx\" value=\"'.$userid.'Que1\"></button></form>
		        <script>$(document).ready(function(){

				$(\'#bigx'.$userid.'Que1IndexForm\').click(function (e) {

				clickedval = e.target.name;e.preventDefault();
				$.ajax({
				url: \'http://localhost:8888/cakephp-cakephp-0a6d85c/ajaxrequests/filemanagerdeletelist.php\',
				type: \'POST\',
				data: {\'quetitle\': quetitle, \'filemanager_user_id\': \''.$userid.'\', \'strip_userid\': \''.$strip_userid.'\'},}
				).done(function ( ) {$(\'#quetitle\').fadeOut(\'fast\');$(\'.file_node_'.$queinfo[$strip_userid]['quetitle'].'\').fadeOut(\'fast\');});});});</script>
		    */
	?>

	<script>

	function validatequetitle(quetitle){

		if ( (quetitle.length > 4) && (quetitle.length < 26) ){

			return true;
		}
		return false;
	}

	function createUUID() {
    // http://www.ietf.org/rfc/rfc4122.txt
    var s = [];
    var hexDigits = "0123456789abcdef";
    for (var i = 0; i < 36; i++) {
        s[i] = hexDigits.substr(Math.floor(Math.random() * 0x10), 1);
    }
    s[14] = "4";  // bits 12-15 of the time_hi_and_version field to 0010
    s[19] = hexDigits.substr((s[19] & 0x3) | 0x8, 1);  // bits 6-7 of the clock_seq_hi_and_reserved to 01
    s[8] = s[13] = s[18] = s[23] = "-";

    var uuid = s.join("");
    return uuid;
	}
	</script>
	</div>
</div>
