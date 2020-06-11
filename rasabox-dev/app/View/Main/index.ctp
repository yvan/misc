<?php 

echo $this->Html->css('main');

echo $this->Html->script('jquery');

?>
<div id="page-main">

<div id="return-to-main-from-search">

<?php
	
	if ( ($searchflag == 1) && $search_value_tolayout){

		echo $this->Html->image('return-to-main-from-search.png', array('alt' => 'Bazar', 'url' => '/main/index/search:@null')); 
	}

?>

</div>
	<div id="node-field">

	 <?php 

	 //to add multiple images or content just use a '.' concatenate
	 //this section prints the nodes on the main page
	 //searchflag == 1 prints the nodes resulting from a search
	 //searchflag == 0 prints the nodes resulting from normal display

	 	if ($searchflag == 1){//displays search nodes

	 		foreach ($searchnodes as $searchnode){

	 			$file_ext = array();
				//loop through the numbers in the $file_types string and determine which
				//file extensions to use for each file.
				for ($i=0 ; $i < strlen($file_types[$searchnode['imageid']]); $i++){

					switch($file_types[$searchnode['imageid']][$i]){


						case 1;

							$file_ext[$i] = 'jpg';

							break;

						case 2;

							$file_ext[$i] = 'gif';

						break;

						case 3;

							$file_ext[$i] = 'png';
						break;

						case 4;

							$file_ext[$i] = 'jpeg';
						break;

						default;
					}
				}

		 		echo $this->Html->div('node',

		 			$this->Html->div('description',

		 					'' . str_replace("&sect;", "/", $searchnode['description'])
		 				) 
		 				.
		 				$this->Html->div('username',

		 					$this->Html->link( $searchnode['username'], '/profile/index/id:'. $searchnode['user_id'].'/username:'.$searchnode['username'])
		 				) 
		 				.
		 				$this->Html->link(


		 					'<div class="filetitle">'.str_replace("&sect;", "/",$searchnode['title']).'</div>'
		 					,

		 					array(

	 							'controller' => 'product',
    							'action' => 'index',
    							'id' => $searchnode['imageid'],
    							'search_value' => $searchnode['search_value']
		 					),
		 					array(
	 							// escape just passes this option to the link to not escape
	 							// and mess up all the html chars in <div class="filetitle">
	 							'escape'=>false
	 						)
		 				)
		 				.
		 				//the reason we tack on teh file_ext here and not in the original image path in maincontroller
		 				//is because when we dynamically load data we need this file path again. 
		 				//to keep the dynaic loaded nodes code consistent with the ones loaded on page load, we tack it on the end.
		 				$this->Html->image($searchnode['imagepath'].'.'.$file_ext[0] , 

		 					array('alt' => 'Image Error', 

		 						'url' => array(

		 							'controller' => 'product',
	    							'action' => 'index',
	    							'id' => $searchnode['imageid'],
	    							'search_value' => $searchnode['search_value']
		 						),

		 						'id' => 'node-image'
		 					)
		 				) 
		 				. //user searchnode instead of nodeparent here for the form because searchflag is 0 search is null.
						$this->Form->create($searchnode['imageid'], array('default' => false))
						.
						$this->Form->button('', 

							array('label'=>false, 

								'type' => 'submit',
								'name' => 'submitlike' ,
								'value' => $searchnode['imageid'],
								'id' => $searchnode['imageid']."changetoorange"
							)
						)
						.
						$this->Form->button('', 
							
							array('label'=>false, 

								'type' => 'submit',
								'name' => 'submitdislike' ,
								'value' => $searchnode['imageid'],
								'id' => $searchnode['imageid']."changetoblue"
							)
						)
						.
						$this->Form->end()
						.
						$this->Html->div('numberdislikes' , 

		 					''.$numberdislikes[$searchnode['imageid']],
	 					array('id' => $searchnode['imageid'].'numberdislikes')
		 				)
						.
		 				$this->Html->div('numberlikes' , 

		 					''.$numberlikes[$searchnode['imageid']],
	 					array('id' => $searchnode['imageid'].'numberlikes')
		 				)
		 		);


								//unqiue id to ammend onto the front of our flag variables
				//so they don't interfere with other flags from
				//different models.
				$strip_imageid = str_replace("-", "", $searchnode['imageid']);
					
				//We concatenate F on the front of of our unique id because all javascript vars
				//must start with a letter or $ or wtvr, and cannot start iwth a number
				//our unique id without the F on the front starts with a number and
				// breaks everything.
				$strip_imageid = 'F'.$strip_imageid;

				
				//if the user has already upvoted something
				if($searchnode['user_liketable_query'] == 1){

					/********************* FIRST SCRIPT *********************/

					//likeflag has the node id tacked onto it just because i don't want to take a chance,
					// that several difference nodes like_flags interfere with each other, 
					// yeah they are declared separately but it's freaking like...3am again and i can't think about this right now.
					// FOR THIS TO WORK BOTH SCRIPTS  (FRIST, SECOND) MUST SHARE LOCK VARIABLES
					echo '<script type="text/javascript">'; 

					//duh the solution is to make 2 lock variables.
					//we concatenate amended stripped imageid because
					//we need a unique identifier on he variables or else
					//the buttons interfere with each other.
					//working query value is explained below above the javascript.
					//basically if there is no working_query_value you can only change your vote (sarcasm aside it needs a unqiue id tacked onto it)
					//once subsequent clicks on the same button will not be recorded, only the first.(or alternating clicks)
					//this happens because the DATABASE queries in main_page_like.php (called in the aajx below and passed the initial state)
					//of $searchnode['user_liketable_query'] for that indiviudal ID when the click was originally called only react to change
					//the DB tables once. Passing a working query reflects the new state of the thing to the ajax php script main_page_like.php.
					echo 'var '.$strip_imageid.'like_flag_sep = 1;';
					echo 'var '.$strip_imageid.'like_flag_b_sep = 0;';
					echo 'var '.$strip_imageid.'like_flag = 1;';
					echo 'var '.$strip_imageid.'like_flag_b = 0;';
					echo 'var '.$strip_imageid.'working_query_value_new = '.$searchnode['user_liketable_query'].';';
					echo 'var '.$strip_imageid.'working_query_value_old = '.$searchnode['user_liketable_query'].';';
					echo 'var '.$strip_imageid.'working_likes_new = '.$searchnode['likes'].';';
					echo 'var '.$strip_imageid.'working_likes_old = '.$searchnode['likes'].';';
					echo 'var '.$strip_imageid.'working_dislikes_new = '.$searchnode['dislikes'].';';
					echo 'var '.$strip_imageid.'working_dislikes_old = '.$searchnode['dislikes'].';';

					echo '</script>';

					echo '<script>';
					
				    echo '$(document).ready(function(){';
				    //if the flag is 1 set it to orange.
					echo '$(\'#'.$searchnode['imageid'].'changetoorange'.'\').css("background-color","#E5895B");';

					//if people click on that orange button again, reset it to gray. note the #393738 is rasabox grey.
					//if we load in initially with $searchnode['user_liketable_query'] == 1 and the user likes something
					echo '$(\'#'.$searchnode['imageid'].'IndexForm button[name="submitlike"]\').click(function (e) {';

					echo 'if('.$strip_imageid.'like_flag == 1){';

					echo '$(\'#'.$searchnode['imageid'].'changetoorange'.'\').css("background-color", "#393738");';
					echo ''.$strip_imageid.'working_query_value_new = 0;'; //current state set to "netural" equivalent
					echo ''.$strip_imageid.'like_flag = 0;';
					echo ''.$strip_imageid.'like_flag_b = 0;';
					echo '}';

					//make sure that the clicked thing turns orange
					//make sure that the minus (id = changetoblue) changes to grey.
					echo 'if('.$strip_imageid.'like_flag_b == 1){';

					echo '$(\'#'.$searchnode['imageid'].'changetoorange'.'\').css("background-color", "#E5895B");';
					echo '$(\'#'.$searchnode['imageid'].'changetoblue'.'\').css("background-color", "#393738");';
					echo ''.$strip_imageid.'working_query_value_new = 1;'; // current state set to "like" equivalent

					echo ''.$strip_imageid.'like_flag = 1;';
					echo ''.$strip_imageid.'like_flag_b = 1;';

					//RESET SCRIPT SECOND's locks
					echo ''.$strip_imageid.'like_flag_sep = 1;';
					echo ''.$strip_imageid.'like_flag_b_sep = 0;';
					echo '}';

					//if weve locked both
					echo 'if( ('.$strip_imageid.'like_flag_b == 0) && ('.$strip_imageid.'like_flag == 0) ){';

					//allow use to acces changing to orange
					echo ''.$strip_imageid.'like_flag_b = 1;';

					echo '}';

					//if we've unlocked both 
					echo 'if( ('.$strip_imageid.'like_flag_b == 1) && ('.$strip_imageid.'like_flag == 1) ){';

					//allow us to access changing to grey
					echo ''.$strip_imageid.'like_flag = 1;';
					echo ''.$strip_imageid.'like_flag_b = 0;';// we don't necessarily need this, but redundency is nice

					echo '}';
					
					echo  '});';

					echo  '});';

					echo '</script>';

					/********************* SECOND SCRIPT *********************/

					echo '<script>';

					//we haven't disliekd anything yet, but we are about to
				    echo '$(document).ready(function(){';

				    echo '$(\'#'.$searchnode['imageid'].'IndexForm button[name="submitdislike"]\').click(function (e) {';

				    //NOTE FOR this onewe swapped where we turn it grey to the second if,
				   	//this is because initially it is uncolored if it loads as 0 flag for $searchnode['user_liketable_query']
				    //also this one changes the opposite one to grey.
				    //In each SECOND SCRIPT under $searchnode['user_liketable_query'] =1 or =2,
				  	// the contents of the ifs should be the reverse of the FIrst script under teh respective $searchnode['user_liketable_query'] =1 or =2,
				    // Not just this but the color changing is also inverted.
				    echo 'if('.$strip_imageid.'like_flag_sep == 1){';
				    echo '$(\'#'.$searchnode['imageid'].'changetoblue'.'\').css("background-color", "#8485ED");';
					echo '$(\'#'.$searchnode['imageid'].'changetoorange'.'\').css("background-color", "#393738");';
					echo ''.$strip_imageid.'working_query_value_new = 2;'; //current state set to "dislike equivalent"
					echo ''.$strip_imageid.'like_flag_sep = 0;';
					echo ''.$strip_imageid.'like_flag_b_sep = 0;';

					//RESET FIRST SCRIPT's locks to the SECOND IF
					//here the second if will trigger and not the first.
					echo ''.$strip_imageid.'like_flag = 0;';
					echo ''.$strip_imageid.'like_flag_b = 1;';
					echo '}';

					echo 'if('.$strip_imageid.'like_flag_b_sep == 1){';
					echo '$(\'#'.$searchnode['imageid'].'changetoblue'.'\').css("background-color", "#393738");';
					echo ''.$strip_imageid.'working_query_value_new = 0;'; // neutral equivalent state set
					echo ''.$strip_imageid.'like_flag_sep = 1;';
					echo ''.$strip_imageid.'like_flag_b_sep = 1;';

					//RESET FIRST SCRIPT's locks to the SECOND IF
					//here the second if will trigger and not the first.
					echo ''.$strip_imageid.'like_flag = 0;';
					echo ''.$strip_imageid.'like_flag_b = 1;';
					echo '}';

					//if weve locked both
					echo 'if( ('.$strip_imageid.'like_flag_b_sep == 0) && ('.$strip_imageid.'like_flag_sep == 0) ){';

					//allow use to acces changing to blue
					echo ''.$strip_imageid.'like_flag_b_sep = 1;';

					echo '}';

					//if we've unlocked both 
					echo 'if( ('.$strip_imageid.'like_flag_b_sep == 1) && ('.$strip_imageid.'like_flag_sep  ==1) ){';

					//allow us to access changing to grey
					echo ''.$strip_imageid.'like_flag_sep = 1;';
					echo ''.$strip_imageid.'like_flag_b_sep = 0;';// we don't necessarily need this, but redundency is nice

					echo '}';

					echo  '});';

					echo  '});';

				    echo '</script>';
				}
				//if the user already downvoted
				if($searchnode['user_liketable_query'] == 2){

					/********************* FIRST SCRIPT *********************/

					echo '<script type="text/javascript">';

					//duh the solution is to make 2 variables.
					//i feel so dumb.
					echo 'var '.$strip_imageid.'like_flag_sep = 1;';
					echo 'var '.$strip_imageid.'like_flag_b_sep = 0;';
					echo 'var '.$strip_imageid.'like_flag = 1;';
					echo 'var '.$strip_imageid.'like_flag_b = 0;';
					echo 'var '.$strip_imageid.'working_query_value_new = '.$searchnode['user_liketable_query'].';';
					echo 'var '.$strip_imageid.'working_query_value_old = '.$searchnode['user_liketable_query'].';';
					echo 'var '.$strip_imageid.'working_likes_new = '.$searchnode['likes'].';';
					echo 'var '.$strip_imageid.'working_likes_old = '.$searchnode['likes'].';';
					echo 'var '.$strip_imageid.'working_dislikes_new = '.$searchnode['dislikes'].';';
					echo 'var '.$strip_imageid.'working_dislikes_old = '.$searchnode['dislikes'].';';

					echo '</script>';

					echo '<script>';

				    echo '$(document).ready(function(){';

				    //get the form that was clicked on
					echo '$(\'#'.$searchnode['imageid'].'changetoblue'.'\').css("background-color","#8485ED");';

					//if people click on that orange button again, reset it to gray. note the #393738 is rasabox grey.
					echo '$(\'#'.$searchnode['imageid'].'IndexForm button[name="submitdislike"]\').click(function (e) {';

					echo 'if('.$strip_imageid.'like_flag == 1){';
					echo '$(\'#'.$searchnode['imageid'].'changetoblue'.'\').css("background-color", "#393738");';
					echo ''.$strip_imageid.'working_query_value_new = 0;'; //neutral state of liking ( minus changed to greychanged to grey)
					echo ''.$strip_imageid.'like_flag = 0;';
					echo ''.$strip_imageid.'like_flag_b = 0;';
					echo '}';

					echo 'if('.$strip_imageid.'like_flag_b == 1){';
					echo '$(\'#'.$searchnode['imageid'].'changetoblue'.'\').css("background-color", "#8485ED");';
					echo '$(\'#'.$searchnode['imageid'].'changetoorange'.'\').css("background-color", "#393738");';
					echo ''.$strip_imageid.'working_query_value_new = 2;'; //dislike state of liking (minus changed to blue), plus changed to grey
					echo ''.$strip_imageid.'like_flag = 1;';
					echo ''.$strip_imageid.'like_flag_b = 1;';

					//RESET SCRIPT SECOND's locks
					echo ''.$strip_imageid.'like_flag_sep = 1;';
					echo ''.$strip_imageid.'like_flag_b_sep = 0;';

					echo '}';

					//if weve locked both
					echo 'if( ('.$strip_imageid.'like_flag_b == 0) && ('.$strip_imageid.'like_flag == 0) ){';

					//allow use to acces changing to blue
					echo ''.$strip_imageid.'like_flag_b = 1;';

					echo '}';

					//if we've unlocked both 
					echo 'if( ('.$strip_imageid.'like_flag_b == 1) && ('.$strip_imageid.'like_flag ==1) ){';

					//allow us to access changing to grey
					echo ''.$strip_imageid.'like_flag = 1;';
					echo ''.$strip_imageid.'like_flag_b = 0;';// we don't necessarily need this, but redundency is nice

					echo '}';
					
					echo  '});';

					echo  '});';

					echo '</script>';

					/********************* SECOND SCRIPT *********************/

					echo '<script>';

					//we haven't disliekd anything yet, but we are about to
				    echo '$(document).ready(function(){';

				    echo '$(\'#'.$searchnode['imageid'].'IndexForm button[name="submitlike"]\').click(function (e) {';

				    //NOTE FOR this onewe swapped where we turn it grey to the second if,
				   	//this is because initially it is uncolored if it loads as 0 flag for $searchnode['user_liketable_query']
				    //also this one changes the opposite one to grey.
				    //In each SECOND SCRIPT under $searchnode['user_liketable_query'] =1 or =2,
				  	// the contents of the ifs should be the reverse of the FIrst script under teh respective $searchnode['user_liketable_query'] =1 or =2,
				    // Not just this but the color changing is also inverted.
				    // HEre we changed changetoorange to orange, and changetoblue to grey
				   	// above we changed changetoorange to grey, and changetoblue to blue
				    echo 'if('.$strip_imageid.'like_flag_sep == 1){';
				    echo '$(\'#'.$searchnode['imageid'].'changetoorange'.'\').css("background-color", "#E5895B");';
					echo '$(\'#'.$searchnode['imageid'].'changetoblue'.'\').css("background-color", "#393738");';
					echo ''.$strip_imageid.'working_query_value_new = 1;'; //like state of liking (plus to orange, blue to grey)
					echo ''.$strip_imageid.'like_flag_sep = 0;';
					echo ''.$strip_imageid.'like_flag_b_sep = 0;';

					//RESET FIRST SCRIPT's locks to the SECOND IF
					//here the second if will trigger and not the first.
					echo ''.$strip_imageid.'like_flag = 0;';
					echo ''.$strip_imageid.'like_flag_b = 1;';
					echo '}';

					echo 'if('.$strip_imageid.'like_flag_b_sep == 1){';
					echo '$(\'#'.$searchnode['imageid'].'changetoorange'.'\').css("background-color", "#393738");';
					echo ''.$strip_imageid.'working_query_value_new = 0;'; //neutral state
					echo ''.$strip_imageid.'like_flag_sep = 1;';
					echo ''.$strip_imageid.'like_flag_b_sep = 1;';

					//RESET FIRST SCRIPT's locks to the SECOND IF
					//here the second if will trigger and not the first.
					echo ''.$strip_imageid.'like_flag = 0;';
					echo ''.$strip_imageid.'like_flag_b = 1;';
					echo '}';

					//if weve locked both
					echo 'if( ('.$strip_imageid.'like_flag_b_sep == 0) && ('.$strip_imageid.'like_flag_sep == 0) ){';

					//allow use to acces changing to blue
					echo ''.$strip_imageid.'like_flag_b_sep = 1;';

					echo '}';

					//if we've unlocked both 
					echo 'if( ('.$strip_imageid.'like_flag_b_sep == 1) && ('.$strip_imageid.'like_flag_sep == 1) ){';

					//allow us to access changing to grey
					echo ''.$strip_imageid.'like_flag_sep = 1;';

					echo '}';

					echo  '});';

					echo  '});';

				    echo '</script>';

				}
				// if the user has neither up or down voted, he has the ooprotunity to change the color.
				//NOTE the last if where the user is NEUTRAL on a certain model $searchnode['user_liketable_query'] == 0
				// uses a system where FIRST and SECOND SCRIPTs do not share the same locks.
				//the reason is that sharing the locks causes us to be awkward and haveot click a button 2x to switch to it.
				//separate locks are good here (unlike in the previous two cases where we have user_liketable_query =1 and =2)
				if($searchnode['user_liketable_query'] == 0){

					/********************* FIRST SCRIPT *********************/

					echo '<script type="text/javascript">';

					//duh the solution is to make 2 variables.
					//i feel so dumb.
					echo 'var '.$strip_imageid.'like_flag_sep = 1;';
					echo 'var '.$strip_imageid.'like_flag_b_sep = 0;';
					echo 'var '.$strip_imageid.'like_flag = 1;';
					echo 'var '.$strip_imageid.'like_flag_b = 0;';
					echo 'var '.$strip_imageid.'working_query_value_new = '.$searchnode['user_liketable_query'].';';
					echo 'var '.$strip_imageid.'working_query_value_old = '.$searchnode['user_liketable_query'].';';
					echo 'var '.$strip_imageid.'working_likes_new = '.$searchnode['likes'].';';
					echo 'var '.$strip_imageid.'working_likes_old = '.$searchnode['likes'].';';
					echo 'var '.$strip_imageid.'working_dislikes_new = '.$searchnode['dislikes'].';';
					echo 'var '.$strip_imageid.'working_dislikes_old = '.$searchnode['dislikes'].';';

					echo '</script>';

					echo '<script>';

				    echo '$(document).ready(function(){';

				    //get the form that was clicked on
				    echo '$(\'#'.$searchnode['imageid'].'IndexForm button[name="submitlike"]\').click(function (e) {';

				    //NOTE FOR this onewe swapped where we turn it grey to the second if,
				   	//this is because initially it is uncolored if it loads as 0 flag for $searchnode['user_liketable_query']
				   	//also this one changes the opposite one to grey.
				    echo 'if('.$strip_imageid.'like_flag == 1){';
					echo '$(\'#'.$searchnode['imageid'].'changetoorange'.'\').css("background-color", "#E5895B");';
					echo '$(\'#'.$searchnode['imageid'].'changetoblue'.'\').css("background-color", "#393738");';
					echo ''.$strip_imageid.'working_query_value_new = 1;'; //like state
					echo ''.$strip_imageid.'like_flag = 0;';
					echo ''.$strip_imageid.'like_flag_b = 0;';

					//RESET SCRIPT SECOND's locks
					echo ''.$strip_imageid.'like_flag_sep = 1;';
					echo ''.$strip_imageid.'like_flag_b_sep = 0;';
					echo '}';

					echo 'if('.$strip_imageid.'like_flag_b == 1){';
					echo '$(\'#'.$searchnode['imageid'].'changetoorange'.'\').css("background-color", "#393738");';
					echo ''.$strip_imageid.'working_query_value_new = 0;';//neutral state
					echo ''.$strip_imageid.'like_flag = 1;';
					echo ''.$strip_imageid.'like_flag_b = 1;';
					echo '}';

					//if weve locked both locks
					echo 'if( ('.$strip_imageid.'like_flag_b == 0) && ('.$strip_imageid.'like_flag == 0) ){';

					//allow use to acces changing to orange
					echo ''.$strip_imageid.'like_flag_b = 1;';

					echo '}';

					//if we've unlocked both lock
					echo 'if( ('.$strip_imageid.'like_flag_b == 1) && ('.$strip_imageid.'like_flag ==1) ){';

					//allow us to access changing to grey
					echo ''.$strip_imageid.'like_flag = 1;';
					echo ''.$strip_imageid.'like_flag_b = 0;'; // we don't necessarily need this, but redundency is nice

					echo '}';

					echo  '});';

					echo  '});';

					echo '</script>';

					/********************* SECOND SCRIPT *********************/

					echo '<script>';

					//we haven't disliekd anything yet, but we are about to
				    echo '$(document).ready(function(){';

				    echo '$(\'#'.$searchnode['imageid'].'IndexForm button[name="submitdislike"]\').click(function (e) {';

				    //NOTE FOR this onewe swapped where we turn it grey to the second if,
				   	//this is because initially it is uncolored if it loads as 0 flag for $searchnode['user_liketable_query']
				    //also this one changes the opposite one to grey.
				    echo 'if('.$strip_imageid.'like_flag_sep == 1){';
					echo '$(\'#'.$searchnode['imageid'].'changetoblue'.'\').css("background-color", "#8485ED");';
					echo '$(\'#'.$searchnode['imageid'].'changetoorange'.'\').css("background-color", "#393738");';
					echo ''.$strip_imageid.'working_query_value_new = 2;';
					echo ''.$strip_imageid.'like_flag_sep = 0;';
					echo ''.$strip_imageid.'like_flag_b_sep = 0;';

					//RESET FIRST SCRIPT's locks, in scenarios where we have clickedo n like, then dislike, then like again
					//this avoids the awkward first click that "does nothing", because we have to blow through the like
					// button's second lock before going back to the first again.
					echo ''.$strip_imageid.'like_flag = 1;';
					echo ''.$strip_imageid.'like_flag_b = 0;';
					echo '}';

					echo 'if('.$strip_imageid.'like_flag_b_sep == 1){';
					echo '$(\'#'.$searchnode['imageid'].'changetoblue'.'\').css("background-color", "#393738");';
					echo ''.$strip_imageid.'working_query_value_new = 0;';
					echo ''.$strip_imageid.'like_flag_sep = 1;';
					echo ''.$strip_imageid.'like_flag_b_sep = 1;';
					echo '}';

					//if weve locked both
					echo 'if( ('.$strip_imageid.'like_flag_b_sep == 0) && ('.$strip_imageid.'like_flag_sep == 0) ){';

					//allow use to acces changing to blue
					echo ''.$strip_imageid.'like_flag_b_sep = 1;';

					echo '}';

					//if we've unlocked both 
					echo 'if( ('.$strip_imageid.'like_flag_b_sep == 1) && ('.$strip_imageid.'like_flag_sep ==1) ){';

					//allow us to access changing to grey
					echo ''.$strip_imageid.'like_flag_sep = 1;';
					echo ''.$strip_imageid.'like_flag_b_sep = 0;';// we don't necessarily need this, but redundency is nice

					echo '}';

					echo  '});';

					echo  '});';

				    echo '</script>';
				}

					// what we're doing is printing out a script for each node. 
					// I know this seems insane but hear me out: 1. I'm really lazy and it's bedtime.
					// 2.We've gotta ship this website, running out of time and money.
					// 3. Otherwise we'd have to make a NEW array and dynamically load from this NEW
					// or newly indexed old array to load the appropriate data and send it to our 
					// php script. Arguably this is less bad, we're just printing a bunch of chars,
					// easy pickings comapred to array processing.
					//FOR SOME BLOODY REASON i made like buttons and dislike buttons have their own forms.
					//EACH BLOODY NODE NEEDS 2 scripts one is "likebuttonindexform" another dislikebuttonindexform
					//to go back and change it now would probably break all the styling and take all night
					//this will have to be a future fix.

					//THIS IS INSIDE THE FOREACHLOOP.
					//use searchnode instead of searchnode here for the form because searchflag is 0 search is null.

					echo '<script>';

				    echo '$(document).ready(function(){';

				    // find the comment form and add a submit event handler
				    //ProductIndexForm is the form for submitlike and submitdislike
				    echo '$(\'#'.$searchnode['imageid'].'IndexForm\').click(function (e) {';

				    //get teh name from the button we clicked to know if user submitted a like or a dislike
				    echo  'clickedval = e.target.name;';

				    // stop the browser from submitting the form
				    echo  'e.preventDefault();';

				    if (!$authUser){
	    			
	    				echo 'window.location.replace("http://localhost:8888/cakephp-cakephp-0a6d85c/users/login");';
					}

					echo 'triggered = 0;'; //prevents us from doing more than one of these things for each click.
					/***** START *****/
					//next couple sets of ifs set shit right., next 3 are for 2 empty buttons at the end.
				    echo 'if(('.$strip_imageid.'working_query_value_new == 0) && ('.$strip_imageid.'working_query_value_old == 2) && (triggered == 0)){';

				    echo ''.$strip_imageid.'working_dislikes_new = '.$searchnode['dislikes'].'-1;';
				    echo ''.$strip_imageid.'working_likes_new = '.$searchnode['likes'].';';

				    //if the original is 1 prevent it from setting likes back up to original as we went from 1 to 0.
				    echo 'if(('.$searchnode['user_liketable_query'].' == 1)){';

				    	echo ''.$strip_imageid.'working_likes_new = '.$searchnode['likes'].'-1;';

				    echo '}';
				   	echo 'triggered = true;';

				    echo '}';


				    echo 'if(('.$strip_imageid.'working_query_value_new == 0) && ('.$strip_imageid.'working_query_value_old == 1) && (triggered == 0)){';

				    echo ''.$strip_imageid.'working_likes_new = '.$searchnode['likes'].'-1;';
				    echo ''.$strip_imageid.'working_dislikes_new = '.$searchnode['dislikes'].';';

				   	//if the original == 2 prevent it from resettin the dislikes back to original (as we are now neutral at 0.)
				   	echo 'if(('.$searchnode['user_liketable_query'].' == 2)){';

				    	echo ''.$strip_imageid.'working_dislikes_new = '.$searchnode['dislikes'].'-1;';

				    echo '}';

				   	echo 'triggered = true;';

				    echo '}';


				    echo 'if(('.$strip_imageid.'working_query_value_new == 0) && ('.$strip_imageid.'working_query_value_old == 0) && (triggered == 0)){';

				    echo ''.$strip_imageid.'working_dislikes_new = '.$searchnode['dislikes'].';';
				    echo ''.$strip_imageid.'working_likes_new = '.$searchnode['likes'].';';
				   	echo 'triggered = true;';

				    echo '}';
				    /***** END *****/

				    /***** START *****/
				    //next couple are for ending on an upvote.
				    echo 'if(('.$strip_imageid.'working_query_value_new == 1) && ('.$strip_imageid.'working_query_value_old == 2) && (triggered == 0)){';

				    echo ''.$strip_imageid.'working_dislikes_new = '.$searchnode['dislikes'].'-1;';
				    echo ''.$strip_imageid.'working_likes_new = '.$searchnode['likes'].'+1;';
				   	echo 'triggered = true;';

				    echo '}';


				    echo 'if(('.$strip_imageid.'working_query_value_new == 1) && ('.$strip_imageid.'working_query_value_old == 1) && (triggered == 0)){';

				    echo ''.$strip_imageid.'working_dislikes_new = '.$searchnode['dislikes'].';';
				   	echo 'triggered = true;';

				    echo '}';


				    echo 'if(('.$strip_imageid.'working_query_value_new == 1) && ('.$strip_imageid.'working_query_value_old == 0) && (triggered == 0)){';

				    echo ''.$strip_imageid.'working_dislikes_new = '.$searchnode['dislikes'].';';
				    echo ''.$strip_imageid.'working_likes_new = '.$searchnode['likes'].'+1;';


				   	echo 'if(('.$searchnode['user_liketable_query'].' == 2)){';

				    	echo ''.$strip_imageid.'working_dislikes_new = '.$searchnode['dislikes'].'-1;';

				    echo '}';

				   	echo 'triggered = true;';

				    echo '}';
				    /***** END *****/


				    /***** START *****/
				    //next couple are for ending on an upvote.
				    echo 'if(('.$strip_imageid.'working_query_value_new == 2) && ('.$strip_imageid.'working_query_value_old == 2) && (triggered == 0)){';

				    echo ''.$strip_imageid.'working_dislikes_new = '.$searchnode['dislikes'].'-1;';
				   	echo 'triggered = true;';

				    echo '}';


				    echo 'if(('.$strip_imageid.'working_query_value_new == 2) && ('.$strip_imageid.'working_query_value_old == 1) && (triggered == 0)){';

				    echo ''.$strip_imageid.'working_dislikes_new = '.$searchnode['dislikes'].'+1;';
				    echo ''.$strip_imageid.'working_likes_new = '.$searchnode['likes'].'-1;';
				   	echo 'triggered = true;';

				    echo '}';


				    echo 'if(('.$strip_imageid.'working_query_value_new == 2) && ('.$strip_imageid.'working_query_value_old == 0) && (triggered == 0)){';

				    echo ''.$strip_imageid.'working_dislikes_new = '.$searchnode['dislikes'].'+1;';
				    echo ''.$strip_imageid.'working_likes_new = '.$searchnode['likes'].';';


				    echo 'if(('.$searchnode['user_liketable_query'].' == 1)){';

				    	echo ''.$strip_imageid.'working_likes_new = '.$searchnode['likes'].'-1;';

				    echo '}';
				   	
				   	echo 'triggered = true;';

				    echo '}';


				    /****** BEGIN *******/
				    echo 'if( (('.$searchnode['likes'].'-'.$strip_imageid.'working_likes_new) >= 1) && ('.$searchnode['user_liketable_query'].' == 1)){';

				    echo ''.$strip_imageid.'working_likes_new = '.$searchnode['likes'].'-1;';

				    echo '}';

				    echo 'if( (('.$searchnode['likes'].'-'.$strip_imageid.'working_likes_new) <= -1) && ('.$searchnode['user_liketable_query'].' == 1)){';

				    echo ''.$strip_imageid.'working_likes_new = '.$searchnode['likes'].';';

				    echo '}';


				    echo 'if( (('.$searchnode['likes'].'-'.$strip_imageid.'working_likes_new) >= 1) && ('.$searchnode['user_liketable_query'].' == 2)){';

				    echo ''.$strip_imageid.'working_likes_new = '.$searchnode['likes'].';';

				    echo '}';

				    echo 'if( (('.$searchnode['likes'].'-'.$strip_imageid.'working_likes_new) <= -1) && ('.$searchnode['user_liketable_query'].' == 2)){';

				    echo ''.$strip_imageid.'working_likes_new = '.$searchnode['likes'].'+1;';

				    echo '}';


				    echo 'if( (('.$searchnode['likes'].'-'.$strip_imageid.'working_likes_new) >= 1) && ('.$searchnode['user_liketable_query'].' == 0)){';

				    echo ''.$strip_imageid.'working_likes_new = '.$searchnode['likes'].';';

				    echo '}';

				    echo 'if( (('.$searchnode['likes'].'-'.$strip_imageid.'working_likes_new) <= -1) && ('.$searchnode['user_liketable_query'].' == 0)){';

				    echo ''.$strip_imageid.'working_likes_new = '.$searchnode['likes'].'+1;';

				    echo '}';
				    /****** END ******/

				    /****** BEGIN *******/
				    echo 'if( (('.$searchnode['dislikes'].'-'.$strip_imageid.'working_dislikes_new) >= 1)  && ('.$searchnode['user_liketable_query'].' == 2) ){';

				    echo ''.$strip_imageid.'working_dislikes_new = '.$searchnode['dislikes'].'-1;';

				    echo '}';

				    echo 'if( (('.$searchnode['dislikes'].'-'.$strip_imageid.'working_dislikes_new) <= -1) && ('.$searchnode['user_liketable_query'].' == 2)){';

				    echo ''.$strip_imageid.'working_dislikes_new = '.$searchnode['dislikes'].';';

				    echo '}';

				    echo 'if( (('.$searchnode['dislikes'].'-'.$strip_imageid.'working_dislikes_new) >= 1)  && ('.$searchnode['user_liketable_query'].' == 1) ){';

				    echo ''.$strip_imageid.'working_dislikes_new = '.$searchnode['dislikes'].';';

				    echo '}';

				    echo 'if( (('.$searchnode['dislikes'].'-'.$strip_imageid.'working_dislikes_new) <= -1) && ('.$searchnode['user_liketable_query'].' == 1)){';

				    echo ''.$strip_imageid.'working_dislikes_new = '.$searchnode['dislikes'].'+1;';

				    echo '}';

				    echo 'if( (('.$searchnode['dislikes'].'-'.$strip_imageid.'working_dislikes_new) >= 1)  && ('.$searchnode['user_liketable_query'].' == 0) ){';

				    echo ''.$strip_imageid.'working_dislikes_new = '.$searchnode['dislikes'].';';

				    echo '}';

				    echo 'if( (('.$searchnode['dislikes'].'-'.$strip_imageid.'working_dislikes_new) <= -1) && ('.$searchnode['user_liketable_query'].' == 0)){';

				    echo ''.$strip_imageid.'working_dislikes_new = '.$searchnode['dislikes'].'+1;';

				    echo '}';

				    //Puts the new number of likes/dislikes onto the page (like .prepend or .append)
				    echo '$("div#'.$searchnode['imageid'].'numberdislikes").html('.$strip_imageid.'working_dislikes_new);';
				   	echo '$("div#'.$searchnode['imageid'].'numberlikes").html('.$strip_imageid.'working_likes_new);';
				    /***** END *****/
				    

				    //the request works, it spawns an error message.
				    //it get to success/failure because the url is working now.
				    //user id i s the current user not the artist. We use this data for liketracks. 
				    //the user who actually liked the thing. "$userid" set as this-auth-id in MainController.
				    //We set the $_POST['user_liketable_query'] to be equal to a "working query value"+(unique id)
				    //this working query value reflects the new state of whatever originally was there,
				    //for each node. we actually need to send the OLD working query value to the mysel php main_page_like file
				    //but we need to update the old one to be the new one on successful ajax update,
				    //i just left it after the query entirely because i dont trust it to execture that done (success) function fast enough.
				    //also i want it to update the status EVEN if the query fails.
				    //The reason users could start NEUTRAL, then LIKE soemthing, then UNLIKE (by click on like so that it is grey again)
				    //is because the number of likes (passed to the main_page_like.php query file) is not updating.
				    //so say number likes starts off at 15. you LIKE it. query tells the database to put 15+1 in, 16.
				    //Now say you unlike it(not dislike, unlike by clicking orange button so it is grey again.)
				    //well not the query says put 15-1 in not 16-1 because the query pulls the ORIGINAL number of likes or dislikes as seen 
				    // below in "numberdislikes", "numberlikes", so we create "working_likes" and "working_dislikes"

				    //WE PASS working_likes_old and working_dislikes_old to the main_page_like.php via data but we do not use it in that php script.
				    //this is a vestige get rid of it eventually. \'numberlikes\': '.$strip_imageid.'working_likes_old, \'numberdislikes\': '.$strip_imageid.'working_dislikes_old,
				    echo '$.ajax({

				        url: \'http://localhost:8888/cakephp-cakephp-0a6d85c/ajaxrequests/main_page_like.php\', 
				        type: \'POST\',
				        data: {\'model_id\': \''.$searchnode['imageid'].'\', \'user_id\': \''.$userid.'\', \'liked_or_disliked\': clickedval,\'title\': \''.$searchnode['title'].'\', \'description\': \''.$searchnode['description'].'\', \'artist_username\': \''.$searchnode['username'].'\', \'artistid\': \''.$searchnode['user_id'].'\', \'rank\': \''.$searchnode['rank'].'\', \'true_rank\': \''.$searchnode['true_rank'].'\', \'user_liketable_query\': '.$strip_imageid.'working_query_value_old, \'original_liketable_query\': \''.$searchnode['user_liketable_query'].'\'},

				        }).done(function ( ) {
				           
				 
				        }).fail(function ( jqXHR, textStatus, errorThrown ) {

				        
				        });';

				    /******* END *******/

					echo ''.$strip_imageid.'working_query_value_old = '.$strip_imageid.'working_query_value_new;';

					echo ''.$strip_imageid.'working_likes_old = '.$strip_imageid.'working_likes_new;';

					echo ''.$strip_imageid.'working_dislikes_old = '.$strip_imageid.'working_dislikes_new;';

				    echo '});';

				    echo  '});';

				    echo '</script>';

	 		}

	 		if ($search_failed_flag == 1){

	 			//This is just a simple echo of our error message for search: styled in main.css with class below.
				echo $this->Html->div('error-message-yvancustom', $search_empty_error, array('id'=>'error-message-yvancustom-search'));
				
	 		}
	 	}

	 	//print_r($nodeparents);
	 	//displays non search nodes
	 	if ($searchflag == 0){//displays nodeparents

	 		foreach ($nodeparents as $nodeparent){

	 			$file_ext = array();
				//loop through the numbers in the $file_types string and determine which
				//file extensions to use for each file.
				for ($i=0 ; $i < strlen($file_types[$nodeparent['imageid']]); $i++){

					switch($file_types[$nodeparent['imageid']][$i]){


						case 1;

							$file_ext[$i] = 'jpg';

							break;

						case 2;

							$file_ext[$i] = 'gif';

						break;

						case 3;

							$file_ext[$i] = 'png';
						break;

						case 4;

							$file_ext[$i] = 'jpeg';
						break;

						default;
					}
				}


		 		echo $this->Html->div('node',

	 				$this->Html->div('description',

	 					'' . str_replace("&sect;", "/", $nodeparent['description'])
	 				) 
	 				.
	 				$this->Html->div('username',

	 					$this->Html->link( $nodeparent['username'], '/profile/index/id:'. $nodeparent['user_id']. '/username:'.$nodeparent['username'])
	 				) 
	 				.
	 				$this->Html->link(

	 					'<div class="filetitle">'.str_replace("&sect;", "/", $nodeparent['title']).'</div>'
		
		 				,

	 					array(

 							'controller' => 'product',
							'action' => 'index',
							'id' => $nodeparent['imageid'],
							'search_value' => $nodeparent['search_value']
	 					),

	 					array(

	 						// escape just passes this option to the link to not escape
	 						// and mess up all the html chars in <div class="filetitle">
	 						'escape'=>false
	 					)
	 				)
	 				.
	 				//the reason we tack on teh file_ext here and not in the original image path in maincontroller
		 			//is because when we dynamically load data we need this file path again. 
		 			//to keep the dynaic loaded nodes code consistent with the ones loaded on page load, we tack it on the end.
	 				$this->Html->image($nodeparent['imagepath'].'.'.$file_ext[0], 

	 					array('alt' => 'Image Error', 

	 						'url' => array(

	 							'controller' => 'product',
    							'action' => 'index',
    							'id' => $nodeparent['imageid'],
    							'search_value' => $nodeparent['search_value']
	 						),

	 						'id' => 'node-image'
	 					)
	 				) 
	 				. //use nodeparent here for the form because searchflag is 0 search is null.
					$this->Form->create($nodeparent['imageid'], array('default' => false))
					.
					$this->Form->button('', 

						array('label'=>false, 

							'type' => 'submit',
							'default' => false,
							'name' => 'submitlike' ,
							'value' => $nodeparent['imageid'],
							'id' => $nodeparent['imageid']."changetoorange"
						)
					)
					.
					$this->Form->button('', 
						
						array('label'=>false, 

							'type' => 'submit',
							'default' => false,
							'name' => 'submitdislike' ,
							'value' => $nodeparent['imageid'],
							'id' => $nodeparent['imageid']."changetoblue"
						)
					)
					.
					$this->Form->end()
					.
					$this->Html->div('numberdislikes' , 

	 					''.$numberdislikes[$nodeparent['imageid']],
	 					array('id' => $nodeparent['imageid'].'numberdislikes')
	 				)
					.
	 				$this->Html->div('numberlikes' , 

	 					''.$numberlikes[$nodeparent['imageid']],
	 					array('id' => $nodeparent['imageid'].'numberlikes')
	 				)
		 		);

				//unqiue id to ammend onto the front of our flag variables
				//so they don't interfere with other flags from
				//different models.
				$strip_imageid = str_replace("-", "", $nodeparent['imageid']);
					
				//We concatenate F on the front of of our unique id because all javascript vars
				//must start with a letter or $ or wtvr, and cannot start iwth a number
				//our unique id without the F on the front starts with a number and
				// breaks everything.
				$strip_imageid = 'F'.$strip_imageid;

				
				//if the user has already upvoted something
				if($nodeparent['user_liketable_query'] == 1){

					/********************* FIRST SCRIPT *********************/

					//likeflag has the node id tacked onto it just because i don't want to take a chance,
					// that several difference nodes like_flags interfere with each other, 
					// yeah they are declared separately but it's freaking like...3am again and i can't think about this right now.
					// FOR THIS TO WORK BOTH SCRIPTS  (FRIST, SECOND) MUST SHARE LOCK VARIABLES
					echo '<script type="text/javascript">'; 

					//duh the solution is to make 2 lock variables.
					//we concatenate amended stripped imageid because
					//we need a unique identifier on he variables or else
					//the buttons interfere with each other.
					//working query value is explained below above the javascript.
					//basically if there is no working_query_value you can only change your vote (sarcasm aside it needs a unqiue id tacked onto it)
					//once subsequent clicks on the same button will not be recorded, only the first.(or alternating clicks)
					//this happens because the DATABASE queries in main_page_like.php (called in the aajx below and passed the initial state)
					//of $nodeparent['user_liketable_query'] for that indiviudal ID when the click was originally called only react to change
					//the DB tables once. Passing a working query reflects the new state of the thing to the ajax php script main_page_like.php.
					echo 'var '.$strip_imageid.'like_flag_sep = 1;';
					echo 'var '.$strip_imageid.'like_flag_b_sep = 0;';
					echo 'var '.$strip_imageid.'like_flag = 1;';
					echo 'var '.$strip_imageid.'like_flag_b = 0;';
					echo 'var '.$strip_imageid.'working_query_value_new = '.$nodeparent['user_liketable_query'].';';
					echo 'var '.$strip_imageid.'working_query_value_old = '.$nodeparent['user_liketable_query'].';';
					echo 'var '.$strip_imageid.'working_likes_new = '.$nodeparent['likes'].';';
					echo 'var '.$strip_imageid.'working_likes_old = '.$nodeparent['likes'].';';
					echo 'var '.$strip_imageid.'working_dislikes_new = '.$nodeparent['dislikes'].';';
					echo 'var '.$strip_imageid.'working_dislikes_old = '.$nodeparent['dislikes'].';';

					echo '</script>';

					echo '<script>';
					
				    echo '$(document).ready(function(){';
				    //if the flag is 1 set it to orange.
					echo '$(\'#'.$nodeparent['imageid'].'changetoorange'.'\').css("background-color","#E5895B");';

					//if people click on that orange button again, reset it to gray. note the #393738 is rasabox grey.
					//if we load in initially with $nodeparent['user_liketable_query'] == 1 and the user likes something
					echo '$(\'#'.$nodeparent['imageid'].'IndexForm button[name="submitlike"]\').click(function (e) {';

					echo 'if('.$strip_imageid.'like_flag == 1){';

					echo '$(\'#'.$nodeparent['imageid'].'changetoorange'.'\').css("background-color", "#393738");';
					echo ''.$strip_imageid.'working_query_value_new = 0;'; //current state set to "netural" equivalent
					echo ''.$strip_imageid.'like_flag = 0;';
					echo ''.$strip_imageid.'like_flag_b = 0;';
					echo '}';

					//make sure that the clicked thing turns orange
					//make sure that the minus (id = changetoblue) changes to grey.
					echo 'if('.$strip_imageid.'like_flag_b == 1){';

					echo '$(\'#'.$nodeparent['imageid'].'changetoorange'.'\').css("background-color", "#E5895B");';
					echo '$(\'#'.$nodeparent['imageid'].'changetoblue'.'\').css("background-color", "#393738");';
					echo ''.$strip_imageid.'working_query_value_new = 1;'; // current state set to "like" equivalent

					echo ''.$strip_imageid.'like_flag = 1;';
					echo ''.$strip_imageid.'like_flag_b = 1;';

					//RESET SCRIPT SECOND's locks
					echo ''.$strip_imageid.'like_flag_sep = 1;';
					echo ''.$strip_imageid.'like_flag_b_sep = 0;';
					echo '}';

					//if weve locked both
					echo 'if( ('.$strip_imageid.'like_flag_b == 0) && ('.$strip_imageid.'like_flag == 0) ){';

					//allow use to acces changing to orange
					echo ''.$strip_imageid.'like_flag_b = 1;';

					echo '}';

					//if we've unlocked both 
					echo 'if( ('.$strip_imageid.'like_flag_b == 1) && ('.$strip_imageid.'like_flag == 1) ){';

					//allow us to access changing to grey
					echo ''.$strip_imageid.'like_flag = 1;';
					echo ''.$strip_imageid.'like_flag_b = 0;';// we don't necessarily need this, but redundency is nice

					echo '}';
					
					echo  '});';

					echo  '});';

					echo '</script>';

					/********************* SECOND SCRIPT *********************/

					echo '<script>';

					//we haven't disliekd anything yet, but we are about to
				    echo '$(document).ready(function(){';

				    echo '$(\'#'.$nodeparent['imageid'].'IndexForm button[name="submitdislike"]\').click(function (e) {';

				    //NOTE FOR this onewe swapped where we turn it grey to the second if,
				   	//this is because initially it is uncolored if it loads as 0 flag for $nodeparent['user_liketable_query']
				    //also this one changes the opposite one to grey.
				    //In each SECOND SCRIPT under $nodeparent['user_liketable_query'] =1 or =2,
				  	// the contents of the ifs should be the reverse of the FIrst script under teh respective $nodeparent['user_liketable_query'] =1 or =2,
				    // Not just this but the color changing is also inverted.
				    echo 'if('.$strip_imageid.'like_flag_sep == 1){';
				    echo '$(\'#'.$nodeparent['imageid'].'changetoblue'.'\').css("background-color", "#8485ED");';
					echo '$(\'#'.$nodeparent['imageid'].'changetoorange'.'\').css("background-color", "#393738");';
					echo ''.$strip_imageid.'working_query_value_new = 2;'; //current state set to "dislike equivalent"
					echo ''.$strip_imageid.'like_flag_sep = 0;';
					echo ''.$strip_imageid.'like_flag_b_sep = 0;';

					//RESET FIRST SCRIPT's locks to the SECOND IF
					//here the second if will trigger and not the first.
					echo ''.$strip_imageid.'like_flag = 0;';
					echo ''.$strip_imageid.'like_flag_b = 1;';
					echo '}';

					echo 'if('.$strip_imageid.'like_flag_b_sep == 1){';
					echo '$(\'#'.$nodeparent['imageid'].'changetoblue'.'\').css("background-color", "#393738");';
					//echo '$("div#'.$nodeparent['imageid'].'numberdislikes").html(parseInt($("div#'.$nodeparent['imageid'].'numberdislikes").html())-1);';
					echo ''.$strip_imageid.'working_query_value_new = 0;'; // neutral equivalent state set
					echo ''.$strip_imageid.'like_flag_sep = 1;';
					echo ''.$strip_imageid.'like_flag_b_sep = 1;';

					//RESET FIRST SCRIPT's locks to the SECOND IF
					//here the second if will trigger and not the first.
					echo ''.$strip_imageid.'like_flag = 0;';
					echo ''.$strip_imageid.'like_flag_b = 1;';
					echo '}';

					//if weve locked both
					echo 'if( ('.$strip_imageid.'like_flag_b_sep == 0) && ('.$strip_imageid.'like_flag_sep == 0) ){';

					//allow use to acces changing to blue
					echo ''.$strip_imageid.'like_flag_b_sep = 1;';

					echo '}';

					//if we've unlocked both 
					echo 'if( ('.$strip_imageid.'like_flag_b_sep == 1) && ('.$strip_imageid.'like_flag_sep  ==1) ){';

					//allow us to access changing to grey
					echo ''.$strip_imageid.'like_flag_sep = 1;';
					echo ''.$strip_imageid.'like_flag_b_sep = 0;';// we don't necessarily need this, but redundency is nice

					echo '}';

					echo  '});';

					echo  '});';

				    echo '</script>';
				}
				//if the user already downvoted
				if($nodeparent['user_liketable_query'] == 2){

					/********************* FIRST SCRIPT *********************/

					echo '<script type="text/javascript">';

					//duh the solution is to make 2 variables.
					//i feel so dumb.
					echo 'var '.$strip_imageid.'like_flag_sep = 1;';
					echo 'var '.$strip_imageid.'like_flag_b_sep = 0;';
					echo 'var '.$strip_imageid.'like_flag = 1;';
					echo 'var '.$strip_imageid.'like_flag_b = 0;';
					echo 'var '.$strip_imageid.'working_query_value_new = '.$nodeparent['user_liketable_query'].';';
					echo 'var '.$strip_imageid.'working_query_value_old = '.$nodeparent['user_liketable_query'].';';
					echo 'var '.$strip_imageid.'working_likes_new = '.$nodeparent['likes'].';';
					echo 'var '.$strip_imageid.'working_likes_old = '.$nodeparent['likes'].';';
					echo 'var '.$strip_imageid.'working_dislikes_new = '.$nodeparent['dislikes'].';';
					echo 'var '.$strip_imageid.'working_dislikes_old = '.$nodeparent['dislikes'].';';

					echo '</script>';

					echo '<script>';

				    echo '$(document).ready(function(){';

				    //get the form that was clicked on
					echo '$(\'#'.$nodeparent['imageid'].'changetoblue'.'\').css("background-color","#8485ED");';

					//if people click on that orange button again, reset it to gray. note the #393738 is rasabox grey.
					echo '$(\'#'.$nodeparent['imageid'].'IndexForm button[name="submitdislike"]\').click(function (e) {';

					echo 'if('.$strip_imageid.'like_flag == 1){';
					echo '$(\'#'.$nodeparent['imageid'].'changetoblue'.'\').css("background-color", "#393738");';
					echo ''.$strip_imageid.'working_query_value_new = 0;'; //neutral state of liking ( minus changed to greychanged to grey)
					echo ''.$strip_imageid.'like_flag = 0;';
					echo ''.$strip_imageid.'like_flag_b = 0;';
					echo '}';

					echo 'if('.$strip_imageid.'like_flag_b == 1){';
					echo '$(\'#'.$nodeparent['imageid'].'changetoblue'.'\').css("background-color", "#8485ED");';
					echo '$(\'#'.$nodeparent['imageid'].'changetoorange'.'\').css("background-color", "#393738");';
					echo ''.$strip_imageid.'working_query_value_new = 2;'; //dislike state of liking (minus changed to blue), plus changed to grey
					echo ''.$strip_imageid.'like_flag = 1;';
					echo ''.$strip_imageid.'like_flag_b = 1;';

					//RESET SCRIPT SECOND's locks
					echo ''.$strip_imageid.'like_flag_sep = 1;';
					echo ''.$strip_imageid.'like_flag_b_sep = 0;';

					echo '}';

					//if weve locked both
					echo 'if( ('.$strip_imageid.'like_flag_b == 0) && ('.$strip_imageid.'like_flag == 0) ){';

					//allow use to acces changing to blue
					echo ''.$strip_imageid.'like_flag_b = 1;';

					echo '}';

					//if we've unlocked both 
					echo 'if( ('.$strip_imageid.'like_flag_b == 1) && ('.$strip_imageid.'like_flag ==1) ){';

					//allow us to access changing to grey
					echo ''.$strip_imageid.'like_flag = 1;';
					echo ''.$strip_imageid.'like_flag_b = 0;';// we don't necessarily need this, but redundency is nice

					echo '}';
					
					echo  '});';

					echo  '});';

					echo '</script>';

					/********************* SECOND SCRIPT *********************/

					echo '<script>';

					//we haven't disliekd anything yet, but we are about to
				    echo '$(document).ready(function(){';

				    echo '$(\'#'.$nodeparent['imageid'].'IndexForm button[name="submitlike"]\').click(function (e) {';

				    //NOTE FOR this onewe swapped where we turn it grey to the second if,
				   	//this is because initially it is uncolored if it loads as 0 flag for $nodeparent['user_liketable_query']
				    //also this one changes the opposite one to grey.
				    //In each SECOND SCRIPT under $nodeparent['user_liketable_query'] =1 or =2,
				  	// the contents of the ifs should be the reverse of the FIrst script under teh respective $nodeparent['user_liketable_query'] =1 or =2,
				    // Not just this but the color changing is also inverted.
				    // HEre we changed changetoorange to orange, and changetoblue to grey
				   	// above we changed changetoorange to grey, and changetoblue to blue
				    echo 'if('.$strip_imageid.'like_flag_sep == 1){';
				    echo '$(\'#'.$nodeparent['imageid'].'changetoorange'.'\').css("background-color", "#E5895B");';
					echo '$(\'#'.$nodeparent['imageid'].'changetoblue'.'\').css("background-color", "#393738");';
					echo ''.$strip_imageid.'working_query_value_new = 1;'; //like state of liking (plus to orange, blue to grey)
					echo ''.$strip_imageid.'like_flag_sep = 0;';
					echo ''.$strip_imageid.'like_flag_b_sep = 0;';

					//RESET FIRST SCRIPT's locks to the SECOND IF
					//here the second if will trigger and not the first.
					echo ''.$strip_imageid.'like_flag = 0;';
					echo ''.$strip_imageid.'like_flag_b = 1;';
					echo '}';

					echo 'if('.$strip_imageid.'like_flag_b_sep == 1){';
					echo '$(\'#'.$nodeparent['imageid'].'changetoorange'.'\').css("background-color", "#393738");';
					echo ''.$strip_imageid.'working_query_value_new = 0;'; //neutral state
					echo ''.$strip_imageid.'like_flag_sep = 1;';
					echo ''.$strip_imageid.'like_flag_b_sep = 1;';

					//RESET FIRST SCRIPT's locks to the SECOND IF
					//here the second if will trigger and not the first.
					echo ''.$strip_imageid.'like_flag = 0;';
					echo ''.$strip_imageid.'like_flag_b = 1;';
					echo '}';

					//if weve locked both
					echo 'if( ('.$strip_imageid.'like_flag_b_sep == 0) && ('.$strip_imageid.'like_flag_sep == 0) ){';

					//allow use to acces changing to blue
					echo ''.$strip_imageid.'like_flag_b_sep = 1;';

					echo '}';

					//if we've unlocked both 
					echo 'if( ('.$strip_imageid.'like_flag_b_sep == 1) && ('.$strip_imageid.'like_flag_sep == 1) ){';

					//allow us to access changing to grey
					echo ''.$strip_imageid.'like_flag_sep = 1;';
					//echo ''.$strip_imageid.'like_flag_b_sep = 0;';// we don't necessarily need this, but redundency is nice

					echo '}';

					echo  '});';

					echo  '});';

				    echo '</script>';

				}
				// if the user has neither up or down voted, he has the ooprotunity to change the color.
				//NOTE the last if where the user is NEUTRAL on a certain model $nodeparent['user_liketable_query'] == 0
				// uses a system where FIRST and SECOND SCRIPTs do not share the same locks.
				//the reason is that sharing the locks causes us to be awkward and haveot click a button 2x to switch to it.
				//separate locks are good here (unlike in the previous two cases where we have user_liketable_query =1 and =2)
				if($nodeparent['user_liketable_query'] == 0){

					/********************* FIRST SCRIPT *********************/

					echo '<script type="text/javascript">';

					//duh the solution is to make 2 variables.
					//i feel so dumb.
					echo 'var '.$strip_imageid.'like_flag_sep = 1;';
					echo 'var '.$strip_imageid.'like_flag_b_sep = 0;';
					echo 'var '.$strip_imageid.'like_flag = 1;';
					echo 'var '.$strip_imageid.'like_flag_b = 0;';
					echo 'var '.$strip_imageid.'working_query_value_new = '.$nodeparent['user_liketable_query'].';';
					echo 'var '.$strip_imageid.'working_query_value_old = '.$nodeparent['user_liketable_query'].';';
					echo 'var '.$strip_imageid.'working_likes_new = '.$nodeparent['likes'].';';
					echo 'var '.$strip_imageid.'working_likes_old = '.$nodeparent['likes'].';';
					echo 'var '.$strip_imageid.'working_dislikes_new = '.$nodeparent['dislikes'].';';
					echo 'var '.$strip_imageid.'working_dislikes_old = '.$nodeparent['dislikes'].';';

					echo '</script>';

					echo '<script>';

				    echo '$(document).ready(function(){';

				    //get the form that was clicked on
				    echo '$(\'#'.$nodeparent['imageid'].'IndexForm button[name="submitlike"]\').click(function (e) {';

				    //NOTE FOR this onewe swapped where we turn it grey to the second if,
				   	//this is because initially it is uncolored if it loads as 0 flag for $nodeparent['user_liketable_query']
				   	//also this one changes the opposite one to grey.
				    echo 'if('.$strip_imageid.'like_flag == 1){';
					echo '$(\'#'.$nodeparent['imageid'].'changetoorange'.'\').css("background-color", "#E5895B");';
					echo '$(\'#'.$nodeparent['imageid'].'changetoblue'.'\').css("background-color", "#393738");';
					echo ''.$strip_imageid.'working_query_value_new = 1;'; //like state
					echo ''.$strip_imageid.'like_flag = 0;';
					echo ''.$strip_imageid.'like_flag_b = 0;';

					//RESET SCRIPT SECOND's locks
					echo ''.$strip_imageid.'like_flag_sep = 1;';
					echo ''.$strip_imageid.'like_flag_b_sep = 0;';
					echo '}';

					echo 'if('.$strip_imageid.'like_flag_b == 1){';
					echo '$(\'#'.$nodeparent['imageid'].'changetoorange'.'\').css("background-color", "#393738");';
					echo ''.$strip_imageid.'working_query_value_new = 0;';//neutral state
					//echo ''.$strip_imageid.'working_likes_new = '.$strip_imageid.'working_likes_old-'.'1'.';';
					echo ''.$strip_imageid.'like_flag = 1;';
					echo ''.$strip_imageid.'like_flag_b = 1;';
					echo '}';

					//if weve locked both locks
					echo 'if( ('.$strip_imageid.'like_flag_b == 0) && ('.$strip_imageid.'like_flag == 0) ){';

					//allow use to acces changing to orange
					echo ''.$strip_imageid.'like_flag_b = 1;';

					echo '}';

					//if we've unlocked both lock
					echo 'if( ('.$strip_imageid.'like_flag_b == 1) && ('.$strip_imageid.'like_flag ==1) ){';

					//allow us to access changing to grey
					echo ''.$strip_imageid.'like_flag = 1;';
					echo ''.$strip_imageid.'like_flag_b = 0;'; // we don't necessarily need this, but redundency is nice

					echo '}';

					echo  '});';

					echo  '});';

					echo '</script>';

					/********************* SECOND SCRIPT *********************/

					echo '<script>';

					//we haven't disliekd anything yet, but we are about to
				    echo '$(document).ready(function(){';

				    echo '$(\'#'.$nodeparent['imageid'].'IndexForm button[name="submitdislike"]\').click(function (e) {';

				    //NOTE FOR this onewe swapped where we turn it grey to the second if,
				   	//this is because initially it is uncolored if it loads as 0 flag for $nodeparent['user_liketable_query']
				    //also this one changes the opposite one to grey.
				    echo 'if('.$strip_imageid.'like_flag_sep == 1){';
					echo '$(\'#'.$nodeparent['imageid'].'changetoblue'.'\').css("background-color", "#8485ED");';
					echo '$(\'#'.$nodeparent['imageid'].'changetoorange'.'\').css("background-color", "#393738");';
					echo ''.$strip_imageid.'working_query_value_new = 2;';
					//echo ''.$strip_imageid.'working_dislikes_new = '.$strip_imageid.'working_dislikes_old+'.'1'.';';
					//echo ''.$strip_imageid.'working_likes_new = '.$strip_imageid.'working_likes_old-'.'1'.';';
					echo ''.$strip_imageid.'like_flag_sep = 0;';
					echo ''.$strip_imageid.'like_flag_b_sep = 0;';

					//RESET FIRST SCRIPT's locks, in scenarios where we have clickedo n like, then dislike, then like again
					//this avoids the awkward first click that "does nothing", because we have to blow through the like
					// button's second lock before going back to the first again.
					echo ''.$strip_imageid.'like_flag = 1;';
					echo ''.$strip_imageid.'like_flag_b = 0;';
					echo '}';

					echo 'if('.$strip_imageid.'like_flag_b_sep == 1){';
					echo '$(\'#'.$nodeparent['imageid'].'changetoblue'.'\').css("background-color", "#393738");';
					echo ''.$strip_imageid.'working_query_value_new = 0;';
					//echo ''.$strip_imageid.'working_dislikes_new = '.$strip_imageid.'working_dislikes_old-'.'1'.';';
					echo ''.$strip_imageid.'like_flag_sep = 1;';
					echo ''.$strip_imageid.'like_flag_b_sep = 1;';
					echo '}';

					//if weve locked both
					echo 'if( ('.$strip_imageid.'like_flag_b_sep == 0) && ('.$strip_imageid.'like_flag_sep == 0) ){';

					//allow use to acces changing to blue
					echo ''.$strip_imageid.'like_flag_b_sep = 1;';

					echo '}';

					//if we've unlocked both 
					echo 'if( ('.$strip_imageid.'like_flag_b_sep == 1) && ('.$strip_imageid.'like_flag_sep ==1) ){';

					//allow us to access changing to grey
					echo ''.$strip_imageid.'like_flag_sep = 1;';
					echo ''.$strip_imageid.'like_flag_b_sep = 0;';// we don't necessarily need this, but redundency is nice

					echo '}';

					echo  '});';

					echo  '});';

				    echo '</script>';
				}

					// what we're doing is printing out a script for each node. 
					// I know this seems insane but hear me out: 1. I'm really lazy and it's bedtime.
					// 2.We've gotta ship this website, running out of time and money.
					// 3. Otherwise we'd have to make a NEW array and dynamically load from this NEW
					// or newly indexed old array to load the appropriate data and send it to our 
					// php script. Arguably this is less bad, we're just printing a bunch of chars,
					// easy pickings comapred to array processing.
					//FOR SOME BLOODY REASON i made like buttons and dislike buttons have their own forms.
					//EACH BLOODY NODE NEEDS 2 scripts one is "likebuttonindexform" another dislikebuttonindexform
					//to go back and change it now would probably break all the styling and take all night
					//this will have to be a future fix.

					//THIS IS INSIDE THE FOREACHLOOP.
					//use nodeparent instead of searchnode here for the form because searchflag is 0 search is null.

					echo '<script>';

				    echo '$(document).ready(function(){';

				    // find the comment form and add a submit event handler
				    //ProductIndexForm is the form for submitlike and submitdislike
				    echo '$(\'#'.$nodeparent['imageid'].'IndexForm\').click(function (e) {';

				    //get teh name from the button we clicked to know if user submitted a like or a dislike
				    echo  'clickedval = e.target.name;';

				    // stop the browser from submitting the form
				    echo  'e.preventDefault();';

				    if (!$authUser){
	    			
	    				echo 'window.location.replace("http://localhost:8888/cakephp-cakephp-0a6d85c/users/login");';
					}

					 echo 'triggered = 0;'; //prevents us from doing more than one of these things for each click.
					/***** START *****/
					//next couple sets of ifs set shit right., next 3 are for 2 empty buttons at the end.
				    echo 'if(('.$strip_imageid.'working_query_value_new == 0) && ('.$strip_imageid.'working_query_value_old == 2) && (triggered == 0)){';

				    echo ''.$strip_imageid.'working_dislikes_new = '.$nodeparent['dislikes'].'-1;';
				    echo ''.$strip_imageid.'working_likes_new = '.$nodeparent['likes'].';';

				    //if the original is 1 prevent it from setting likes back up to original as we went from 1 to 0.
				    echo 'if(('.$nodeparent['user_liketable_query'].' == 1)){';

				    	echo ''.$strip_imageid.'working_likes_new = '.$nodeparent['likes'].'-1;';

				    echo '}';
				   	echo 'triggered = true;';

				    echo '}';


				    echo 'if(('.$strip_imageid.'working_query_value_new == 0) && ('.$strip_imageid.'working_query_value_old == 1) && (triggered == 0)){';

				    echo ''.$strip_imageid.'working_likes_new = '.$nodeparent['likes'].'-1;';
				    echo ''.$strip_imageid.'working_dislikes_new = '.$nodeparent['dislikes'].';';

				   	//if the original == 2 prevent it from resettin the dislikes back to original (as we are now neutral at 0.)
				   	echo 'if(('.$nodeparent['user_liketable_query'].' == 2)){';

				    	echo ''.$strip_imageid.'working_dislikes_new = '.$nodeparent['dislikes'].'-1;';

				    echo '}';

				   	echo 'triggered = true;';

				    echo '}';


				    echo 'if(('.$strip_imageid.'working_query_value_new == 0) && ('.$strip_imageid.'working_query_value_old == 0) && (triggered == 0)){';

				    echo ''.$strip_imageid.'working_dislikes_new = '.$nodeparent['dislikes'].';';
				    echo ''.$strip_imageid.'working_likes_new = '.$nodeparent['likes'].';';
				   	echo 'triggered = true;';

				    echo '}';
				    /***** END *****/

				    /***** START *****/
				    //next couple are for ending on an upvote.
				    echo 'if(('.$strip_imageid.'working_query_value_new == 1) && ('.$strip_imageid.'working_query_value_old == 2) && (triggered == 0)){';

				    echo ''.$strip_imageid.'working_dislikes_new = '.$nodeparent['dislikes'].'-1;';
				    echo ''.$strip_imageid.'working_likes_new = '.$nodeparent['likes'].'+1;';
				   	echo 'triggered = true;';

				    echo '}';


				    echo 'if(('.$strip_imageid.'working_query_value_new == 1) && ('.$strip_imageid.'working_query_value_old == 1) && (triggered == 0)){';

				    echo ''.$strip_imageid.'working_dislikes_new = '.$nodeparent['dislikes'].';';

				   	echo 'triggered = true;';

				    echo '}';


				    echo 'if(('.$strip_imageid.'working_query_value_new == 1) && ('.$strip_imageid.'working_query_value_old == 0) && (triggered == 0)){';

				    echo ''.$strip_imageid.'working_dislikes_new = '.$nodeparent['dislikes'].';';
				    echo ''.$strip_imageid.'working_likes_new = '.$nodeparent['likes'].'+1;';


				   	echo 'if(('.$nodeparent['user_liketable_query'].' == 2)){';

				    	echo ''.$strip_imageid.'working_dislikes_new = '.$nodeparent['dislikes'].'-1;';

				    echo '}';

				   	echo 'triggered = true;';

				    echo '}';
				    /***** END *****/


				    /***** START *****/
				    //next couple are for ending on an upvote.
				    echo 'if(('.$strip_imageid.'working_query_value_new == 2) && ('.$strip_imageid.'working_query_value_old == 2) && (triggered == 0)){';

				    echo ''.$strip_imageid.'working_dislikes_new = '.$nodeparent['dislikes'].'-1;';
				   	echo 'triggered = true;';

				    echo '}';


				    echo 'if(('.$strip_imageid.'working_query_value_new == 2) && ('.$strip_imageid.'working_query_value_old == 1) && (triggered == 0)){';

				    echo ''.$strip_imageid.'working_dislikes_new = '.$nodeparent['dislikes'].'+1;';
				    echo ''.$strip_imageid.'working_likes_new = '.$nodeparent['likes'].'-1;';
				   	echo 'triggered = true;';

				    echo '}';


				    echo 'if(('.$strip_imageid.'working_query_value_new == 2) && ('.$strip_imageid.'working_query_value_old == 0) && (triggered == 0)){';

				    echo ''.$strip_imageid.'working_dislikes_new = '.$nodeparent['dislikes'].'+1;';
				    echo ''.$strip_imageid.'working_likes_new = '.$nodeparent['likes'].';';


				    echo 'if(('.$nodeparent['user_liketable_query'].' == 1)){';

				    	echo ''.$strip_imageid.'working_likes_new = '.$nodeparent['likes'].'-1;';

				    echo '}';
				   	
				   	echo 'triggered = true;';

				    echo '}';


				    /****** BEGIN *******/
				    echo 'if( (('.$nodeparent['likes'].'-'.$strip_imageid.'working_likes_new) >= 1) && ('.$nodeparent['user_liketable_query'].' == 1)){';

				    echo ''.$strip_imageid.'working_likes_new = '.$nodeparent['likes'].'-1;';

				    echo '}';

				    echo 'if( (('.$nodeparent['likes'].'-'.$strip_imageid.'working_likes_new) <= -1) && ('.$nodeparent['user_liketable_query'].' == 1)){';

				    echo ''.$strip_imageid.'working_likes_new = '.$nodeparent['likes'].';';

				    echo '}';


				    echo 'if( (('.$nodeparent['likes'].'-'.$strip_imageid.'working_likes_new) >= 1) && ('.$nodeparent['user_liketable_query'].' == 2)){';

				    echo ''.$strip_imageid.'working_likes_new = '.$nodeparent['likes'].';';

				    echo '}';

				    echo 'if( (('.$nodeparent['likes'].'-'.$strip_imageid.'working_likes_new) <= -1) && ('.$nodeparent['user_liketable_query'].' == 2)){';

				    echo ''.$strip_imageid.'working_likes_new = '.$nodeparent['likes'].'+1;';

				    echo '}';


				    echo 'if( (('.$nodeparent['likes'].'-'.$strip_imageid.'working_likes_new) >= 1) && ('.$nodeparent['user_liketable_query'].' == 0)){';

				    echo ''.$strip_imageid.'working_likes_new = '.$nodeparent['likes'].';';

				    echo '}';

				    echo 'if( (('.$nodeparent['likes'].'-'.$strip_imageid.'working_likes_new) <= -1) && ('.$nodeparent['user_liketable_query'].' == 0)){';

				    echo ''.$strip_imageid.'working_likes_new = '.$nodeparent['likes'].'+1;';

				    echo '}';
				    /****** END ******/

				    /****** BEGIN *******/
				    echo 'if( (('.$nodeparent['dislikes'].'-'.$strip_imageid.'working_dislikes_new) >= 1)  && ('.$nodeparent['user_liketable_query'].' == 2) ){';

				    echo ''.$strip_imageid.'working_dislikes_new = '.$nodeparent['dislikes'].'-1;';

				    echo '}';

				    echo 'if( (('.$nodeparent['dislikes'].'-'.$strip_imageid.'working_dislikes_new) <= -1) && ('.$nodeparent['user_liketable_query'].' == 2)){';

				    echo ''.$strip_imageid.'working_dislikes_new = '.$nodeparent['dislikes'].';';

				    echo '}';

				    echo 'if( (('.$nodeparent['dislikes'].'-'.$strip_imageid.'working_dislikes_new) >= 1)  && ('.$nodeparent['user_liketable_query'].' == 1) ){';

				    echo ''.$strip_imageid.'working_dislikes_new = '.$nodeparent['dislikes'].';';

				    echo '}';

				    echo 'if( (('.$nodeparent['dislikes'].'-'.$strip_imageid.'working_dislikes_new) <= -1) && ('.$nodeparent['user_liketable_query'].' == 1)){';

				    echo ''.$strip_imageid.'working_dislikes_new = '.$nodeparent['dislikes'].'+1;';

				    echo '}';

				    echo 'if( (('.$nodeparent['dislikes'].'-'.$strip_imageid.'working_dislikes_new) >= 1)  && ('.$nodeparent['user_liketable_query'].' == 0) ){';

				    echo ''.$strip_imageid.'working_dislikes_new = '.$nodeparent['dislikes'].';';

				    echo '}';

				    echo 'if( (('.$nodeparent['dislikes'].'-'.$strip_imageid.'working_dislikes_new) <= -1) && ('.$nodeparent['user_liketable_query'].' == 0)){';

				    echo ''.$strip_imageid.'working_dislikes_new = '.$nodeparent['dislikes'].'+1;';

				    echo '}';

				    //Puts the new number of likes/dislikes onto the page (like .prepend or .append)
				    echo '$("div#'.$nodeparent['imageid'].'numberdislikes").html('.$strip_imageid.'working_dislikes_new);';
				   	echo '$("div#'.$nodeparent['imageid'].'numberlikes").html('.$strip_imageid.'working_likes_new);';
				    /***** END *****/
				    

				    //the request works, it spawns an error message.
				    //it get to success/failure because the url is working now.
				    //user id i s the current user not the artist. We use this data for liketracks. 
				    //the user who actually liked the thing. "$userid" set as this-auth-id in MainController.
				    //We set the $_POST['user_liketable_query'] to be equal to a "working query value"+(unique id)
				    //this working query value reflects the new state of whatever originally was there,
				    //for each node. we actually need to send the OLD working query value to the mysel php main_page_like file
				    //but we need to update the old one to be the new one on successful ajax update,
				    //i just left it after the query entirely because i dont trust it to execture that done (success) function fast enough.
				    //also i want it to update the status EVEN if the query fails.
				    //The reason users could start NEUTRAL, then LIKE soemthing, then UNLIKE (by click on like so that it is grey again)
				    //is because the number of likes (passed to the main_page_like.php query file) is not updating.
				    //so say number likes starts off at 15. you LIKE it. query tells the database to put 15+1 in, 16.
				    //Now say you unlike it(not dislike, unlike by clicking orange button so it is grey again.)
				    //well not the query says put 15-1 in not 16-1 because the query pulls the ORIGINAL number of likes or dislikes as seen 
				    // below in "numberdislikes", "numberlikes", so we create "working_likes" and "working_dislikes"

				    //WE PASS working_likes_old and working_dislikes_old to the main_page_like.php via data but we do not use it in that php script.
				    //this is a vestige get rid of it eventually. \'numberlikes\': '.$strip_imageid.'working_likes_old, \'numberdislikes\': '.$strip_imageid.'working_dislikes_old,
				    echo '$.ajax({

				        url: \'http://localhost:8888/cakephp-cakephp-0a6d85c/ajaxrequests/main_page_like.php\', 
				        type: \'POST\',
				        data: {\'model_id\': \''.$nodeparent['imageid'].'\', \'user_id\': \''.$userid.'\', \'liked_or_disliked\': clickedval,\'title\': \''.$nodeparent['title'].'\', \'description\': \''.$nodeparent['description'].'\', \'artist_username\': \''.$nodeparent['username'].'\', \'artistid\': \''.$nodeparent['user_id'].'\', \'rank\': \''.$nodeparent['rank'].'\', \'true_rank\': \''.$nodeparent['true_rank'].'\', \'user_liketable_query\': '.$strip_imageid.'working_query_value_old, \'original_liketable_query\': \''.$nodeparent['user_liketable_query'].'\'},

				        }).done(function ( ) {
				           
				 
				        }).fail(function ( jqXHR, textStatus, errorThrown ) {

				        
				        });';

				    /******* END *******/

					echo ''.$strip_imageid.'working_query_value_old = '.$strip_imageid.'working_query_value_new;';

					echo ''.$strip_imageid.'working_likes_old = '.$strip_imageid.'working_likes_new;';

					echo ''.$strip_imageid.'working_dislikes_old = '.$strip_imageid.'working_dislikes_new;';

				    echo '});';

				    echo  '});';

				    echo '</script>';
	 		}
		}
		
		?>

<script type="text/javascript">

//makes a 2d array
function Create2DArray(rows) {

  var arr = [];

  for (var i=0;i<rows;i++) {
     arr[i] = [];
  }

  return arr;
}

//Dynamically loads new nodes into the node-field
//basically we send a query to the server, we pull more stuff when the user scroll,
//below we reprint all that stuff as nodes with all the things we did for nodeparents/searchnodes

//decalred outside funx because we will increment it each time yHandler() is called.
var nodefield = document.getElementById('node-field');
var contentHeight = nodefield.offsetHeight;
// ****** NEEDS TO BE RESET TO 12 BEFORE WE UPLOAD TO MAIN SITE
var num_models_already_loaded = 12;
var path = window.location.pathname;
path = path.replace("main/index/search:@null","");

</script>
<script>
<?
echo 'var voterid = "'.$userid.'";';
?>
</script>
<script>

function yHandler(){

	var yOffset = window.pageYOffset; 
	var y = yOffset + window.innerHeight;
	if(y >= (contentHeight+130)){
		
		contentHeight = contentHeight+1080;
		//we used a time out because firefox,opera, and safari were having some weird
		//issues with loading more content via javascript dynamically, onscroll wasn't working
		if(timeOutEvent){

			//200 is the time out interval here
			clearTimeout(timeOutEvent);
			timeOutEvent = setTimeout(function(){dynamicAjaxPageLoad()}, 200);
		}
		//dynamicAjaxPageLoad();
		num_models_already_loaded = num_models_already_loaded+12;
	}	
}

function dynamicAjaxPageLoad(){

	$.ajax({
		url: path+'ajaxrequests/dynamicpageload.php',
		type: 'POST',
		dataType: 'json',
		data: {'voterid': voterid, 'num_models_already_loaded': num_models_already_loaded},

	}).done(function(dynamicresponsedata){

		for (var b = 0; b < dynamicresponsedata.length; b++){
		//JAVASCRIPT DOES NOT SUPPORT ASSOCIATIVE ARRAYS that's why if you feed this ajax script here an associative array with shit like
		//'description' => 'abc123' is just throws that weird object Object thing at you. 

			if(b==0){

			response_as_array_for_file_ext = Create2DArray(dynamicresponsedata.length);
			var file_ext = Create2DArray(dynamicresponsedata.length);	
			}
			//before we were just pointing to the array and this for loop with b was somehow altering it and messing up the second for loop.
			//now we are setting the new array value to the old array values. in other words if we don't set the ones were using to a new array (response as array)
			//it will totally mess up our original array (dynamic response data)
			response_as_array_for_file_ext[b][0] = dynamicresponsedata[b][0]; //imagid
			response_as_array_for_file_ext[b][1] = dynamicresponsedata[b][1]; //artist userid
			response_as_array_for_file_ext[b][5] = dynamicresponsedata[b][5]; //likes
			response_as_array_for_file_ext[b][6] = dynamicresponsedata[b][6]; //dislikes
			response_as_array_for_file_ext[b][7] = dynamicresponsedata[b][7]; //rank
			response_as_array_for_file_ext[b][8] = dynamicresponsedata[b][8]; //true_rank
			response_as_array_for_file_ext[b][10] = dynamicresponsedata[b][10]; //username
			response_as_array_for_file_ext[b][11] = dynamicresponsedata[b][11]; //title
			response_as_array_for_file_ext[b][12] = dynamicresponsedata[b][12]; //description
			response_as_array_for_file_ext[b][17] = dynamicresponsedata[b][17]; //file_types
			//index 18 for each object is the user_liketable_Query that tells us if they liked, disliked, or are neutral.
			response_as_array_for_file_ext[b][18] = dynamicresponsedata[b][18];
			response_length_var = response_as_array_for_file_ext[b][17];
			response_file_types_as_int = (response_as_array_for_file_ext[b][17]);

			for (var j=0; j < response_length_var.length; j++){

				switch(response_file_types_as_int[j]){

					case "1":
						file_ext[b][j] = "jpg";
						
						break;
					case "2":
						file_ext[b][j] = "gif";
						
						break;
					case "3":
						file_ext[b][j] = "png";
						
						break;
					case "4":
						file_ext[b][j] = "jpeg";
						
						break;
					default:
						
						break;
				}
				
			}
		}


		//since most of the likeclikcing code is just javascript, we just copy and get rid of the php echos
		for (var i = 0; i < dynamicresponsedata.length; i++){
		//JAVASCRIPT DOES NOT SUPPORT ASSOCIATIVE ARRAYS that's why if you feed this ajax script here an associative array with shit like
		// 'description' => 'abc123' is just throws that weird object Object thing at you. 


			if (i==0){

				response_as_array =  Create2DArray(dynamicresponsedata.length);
			}

			//before we were just pointing to the array and this for loop with b was somehow altering it and fucking up the second for loop.
			//now we are setting the new array value to the old array values.

			response_as_array[i][0] = dynamicresponsedata[i][0]; //imageid
			response_as_array[i][1] = dynamicresponsedata[i][1]; //artist userid
			response_as_array[i][5] = dynamicresponsedata[i][5]; //likes
			response_as_array[i][6] = dynamicresponsedata[i][6]; //dislikes
			response_as_array[i][7] = dynamicresponsedata[i][7]; //rank
			response_as_array[i][8] = dynamicresponsedata[i][8]; //true_rank
			response_as_array[i][10] = dynamicresponsedata[i][10]; // artist username
			response_as_array[i][11] = dynamicresponsedata[i][11]; //title
			response_as_array[i][12] = dynamicresponsedata[i][12]; //description
			response_as_array[i][17] = dynamicresponsedata[i][17]; //filetypes
			//index 18 for each object is the user_liketable_Query that tells us if they liked, disliked, or are neutral.
			response_as_array[i][18] = dynamicresponsedata[i][18];

			//this needs the /g after it because it's regex
			stripimageid = response_as_array[i][0].replace(/-/g, "");
			stripimageid = "F"+stripimageid;

		$('#node-field').append("<div class=\"node\"><div class=\"description\">"+response_as_array[i][12]+"</div><div class=\"username\"><a href=\"/cakephp-cakephp-0a6d85c/profile/index/id:"+response_as_array[i][1]+"/username:yvanscher\">yvanscher</a></div><a href=\"/cakephp-cakephp-0a6d85c/product/index/id:"+response_as_array[i][0]+"/search_value:%40null\"><div class=\"filetitle\">"+response_as_array[i][11]+"</div></a><a href=\"/cakephp-cakephp-0a6d85c/product/index/id:"+response_as_array[i][0]+"/search_value:%40null\"><img src=\"/cakephp-cakephp-0a6d85c/img/uploads/"+response_as_array[i][0]+"."+file_ext[i][0]+"\" alt=\"Image Error\" id=\"node-image\" /></a><form action=\"/cakephp-cakephp-0a6d85c/main/index/search:@null\" id=\""+response_as_array[i][0]+"IndexForm\" onsubmit=\"event.returnValue = false; return false;\" method=\"post\" accept-charset=\"utf-8\"><div style=\"display:none;\"><input type=\"hidden\" name=\"_method\" value=\"POST\"/></div><button type=\"submit\" name=\"submitlike\" value=\""+response_as_array[i][0]+"\" id=\""+response_as_array[i][0]+"changetoorange\"></button><button type=\"submit\" name=\"submitdislike\" value=\""+response_as_array[i][0]+"\" id=\""+response_as_array[i][0]+"changetoblue\"></button></form><div id=\""+response_as_array[i][0]+"numberdislikes\" class=\"numberdislikes\">"+response_as_array[i][6]+"</div><div id=\""+response_as_array[i][0]+"numberlikes\" class=\"numberlikes\">"+response_as_array[i][5]+"</div></div>");


		$('#node-field').append("<scri"+""+"pt>var "+stripimageid+"like_flag_sep = 1;var "+stripimageid+"like_flag_b_sep = 0;var "+stripimageid+"like_flag = 1;var "+stripimageid+"like_flag_b = 0;var "+stripimageid+"working_query_value_new = "+response_as_array[i][18]+";var "+stripimageid+"working_query_value_old = "+response_as_array[i][18]+";var "+stripimageid+"working_likes_new = "+response_as_array[i][5]+";var "+stripimageid+"working_likes_old = "+response_as_array[i][5]+";var "+stripimageid+"working_dislikes_new = "+response_as_array[i][6]+";var "+stripimageid+"working_dislikes_old = "+response_as_array[i][6]+";</scri"+""+"pt>");

		//The reason this says </scri" "pt> at the end is because this strign will print out string in the final result, but the code itself (what you see below)
		//will not prematurely break the containing script tag. before this ENTIRE javascript to print out these nodes was being cut off prematurely and ending
		//at that script tag, because .append ignores the script and anywhere you type that in here will prematurely end the whole script.
		if (response_as_array[i][18] == 1){

		//FIRST SCRIPT CHANGES BASED ON ORIGINAL LIKETRACKS, need to print 3 copies based on original liketrck
		$('#node-field').append("<scri"+""+"pt>$(document).ready(function(){$('#"+response_as_array[i][0]+"changetoorange').css(\"background-color\",\"#E5895B\");$('#"+response_as_array[i][0]+"IndexForm button[name=\"submitlike\"]').click(function (e) {if("+stripimageid+"like_flag == 1){$('#"+response_as_array[i][0]+"changetoorange').css(\"background-color\", \"#393738\");"+stripimageid+"working_query_value_new = 0;"+stripimageid+"like_flag = 0;"+stripimageid+"like_flag_b = 0;}if("+stripimageid+"like_flag_b == 1){$('#"+response_as_array[i][0]+"changetoorange').css(\"background-color\", \"#E5895B\");$('#"+response_as_array[i][0]+"changetoblue').css(\"background-color\", \"#393738\");"+stripimageid+"working_query_value_new = 1;"+stripimageid+"like_flag = 1;"+stripimageid+"like_flag_b = 1;"+stripimageid+"like_flag_sep = 1;"+stripimageid+"like_flag_b_sep = 0;}if( ("+stripimageid+"like_flag_b == 0) && ("+stripimageid+"like_flag == 0) ){"+stripimageid+"like_flag_b = 1;}if( ("+stripimageid+"like_flag_b == 1) && ("+stripimageid+"like_flag == 1) ){"+stripimageid+"like_flag = 1;"+stripimageid+"like_flag_b = 0;}});});</scri"+""+"pt>");

		//SECOND SCRIPT BASED ON ORIGINAL LIKETRACKS
		$('#node-field').append("<scri"+""+"pt>$(document).ready(function(){$('#"+response_as_array[i][0]+"IndexForm button[name=\"submitdislike\"]').click(function (e) {if("+stripimageid+"like_flag_sep == 1){$('#"+response_as_array[i][0]+"changetoblue').css(\"background-color\", \"#8485ED\");$('#"+response_as_array[i][0]+"changetoorange').css(\"background-color\", \"#393738\");"+stripimageid+"working_query_value_new = 2;"+stripimageid+"like_flag_sep = 0;"+stripimageid+"like_flag_b_sep = 0;"+stripimageid+"like_flag = 0;"+stripimageid+"like_flag_b = 1;}if("+stripimageid+"like_flag_b_sep == 1){$('#"+response_as_array[i][0]+"changetoblue').css(\"background-color\", \"#393738\");"+stripimageid+"working_query_value_new = 0;"+stripimageid+"like_flag_sep = 1;"+stripimageid+"like_flag_b_sep = 1;"+stripimageid+"like_flag = 0;"+stripimageid+"like_flag_b = 1;}if( ("+stripimageid+"like_flag_b_sep == 0) && ("+stripimageid+"like_flag_sep == 0) ){"+stripimageid+"like_flag_b_sep = 1;}if( ("+stripimageid+"like_flag_b_sep == 1) && ("+stripimageid+"like_flag_sep  ==1) ){"+stripimageid+"like_flag_sep = 1;"+stripimageid+"like_flag_b_sep = 0;}});});</scri"+""+"pt>");
		}
		if(response_as_array[i][18] == 2){

			$('#node-field').append("<scri"+""+"pt>$(document).ready(function(){$('#"+response_as_array[i][0]+"changetoblue').css(\"background-color\",\"#8485ED\");$('#"+response_as_array[i][0]+"IndexForm button[name=\"submitdislike\"]').click(function (e) {if("+stripimageid+"like_flag == 1){$('#"+response_as_array[i][0]+"changetoblue').css(\"background-color\", \"#393738\");"+stripimageid+"working_query_value_new = 0;"+stripimageid+"like_flag = 0;"+stripimageid+"like_flag_b = 0;}if("+stripimageid+"like_flag_b == 1){$('#"+response_as_array[i][0]+"changetoblue').css(\"background-color\", \"#8485ED\");$('#"+response_as_array[i][0]+"changetoorange').css(\"background-color\", \"#393738\");"+stripimageid+"working_query_value_new = 2;"+stripimageid+"like_flag = 1;"+stripimageid+"like_flag_b = 1;"+stripimageid+"like_flag_sep = 1;"+stripimageid+"like_flag_b_sep = 0;}if( ("+stripimageid+"like_flag_b == 0) && ("+stripimageid+"like_flag == 0) ){"+stripimageid+"like_flag_b = 1;}if( ("+stripimageid+"like_flag_b == 1) && ("+stripimageid+"like_flag ==1) ){"+stripimageid+"like_flag = 1;"+stripimageid+"like_flag_b = 0;}});});</scri"+""+"pt>");

			$('#node-field').append("<scri"+""+"pt>$(document).ready(function(){$('#"+response_as_array[i][0]+"IndexForm button[name=\"submitlike\"]').click(function (e) {if("+stripimageid+"like_flag_sep == 1){$('#"+response_as_array[i][0]+"changetoorange').css(\"background-color\", \"#E5895B\");$('#"+response_as_array[i][0]+"changetoblue').css(\"background-color\", \"#393738\");"+stripimageid+"working_query_value_new = 1;"+stripimageid+"like_flag_sep = 0;"+stripimageid+"like_flag_b_sep = 0;"+stripimageid+"like_flag = 0;"+stripimageid+"like_flag_b = 1;}if("+stripimageid+"like_flag_b_sep == 1){$('#"+response_as_array[i][0]+"changetoorange').css(\"background-color\", \"#393738\");"+stripimageid+"working_query_value_new = 0;"+stripimageid+"like_flag_sep = 1;"+stripimageid+"like_flag_b_sep = 1;"+stripimageid+"like_flag = 0;"+stripimageid+"like_flag_b = 1;}if( ("+stripimageid+"like_flag_b_sep == 0) && ("+stripimageid+"like_flag_sep == 0) ){"+stripimageid+"like_flag_b_sep = 1;}if( ("+stripimageid+"like_flag_b_sep == 1) && ("+stripimageid+"like_flag_sep == 1) ){"+stripimageid+"like_flag_sep = 1;}});});</scri"+""+"pt>");
		}
		if(response_as_array[i][18] == 0){

			$('#node-field').append("<scri"+""+"pt>$(document).ready(function(){$('#"+response_as_array[i][0]+"IndexForm button[name=\"submitlike\"]').click(function (e) {if("+stripimageid+"like_flag == 1){$('#"+response_as_array[i][0]+"changetoorange').css(\"background-color\", \"#E5895B\");$('#"+response_as_array[i][0]+"changetoblue').css(\"background-color\",\"#393738\");"+stripimageid+"working_query_value_new = 1;"+stripimageid+"like_flag = 0;"+stripimageid+"like_flag_b = 0;"+stripimageid+"like_flag_sep = 1;"+stripimageid+"like_flag_b_sep = 0;}if("+stripimageid+"like_flag_b == 1){$('#"+response_as_array[i][0]+"changetoorange').css(\"background-color\", \"#393738\");"+stripimageid+"working_query_value_new = 0;"+stripimageid+"like_flag = 1;"+stripimageid+"like_flag_b = 1;}if( ("+stripimageid+"like_flag_b == 0) && ("+stripimageid+"like_flag == 0) ){"+stripimageid+"like_flag_b = 1;}if( ("+stripimageid+"like_flag_b == 1) && ("+stripimageid+"like_flag ==1) ){"+stripimageid+"like_flag = 1;"+stripimageid+"like_flag_b = 0;}});});</scri"+""+"pt>");

			$('#node-field').append("<scri"+""+"pt>$(document).ready(function(){$('#"+response_as_array[i][0]+"IndexForm button[name=\"submitdislike\"]').click(function (e) {if("+stripimageid+"like_flag_sep == 1){$('#"+response_as_array[i][0]+"changetoblue').css(\"background-color\",\"#8485ED\");$('#"+response_as_array[i][0]+"changetoorange').css(\"background-color\", \"#393738\");"+stripimageid+"working_query_value_new = 2;"+stripimageid+"like_flag_sep = 0;"+stripimageid+"like_flag_b_sep = 0;"+stripimageid+"like_flag = 1;"+stripimageid+"like_flag_b = 0;}if("+stripimageid+"like_flag_b_sep == 1){$('#"+response_as_array[i][0]+"changetoblue').css(\"background-color\", \"#393738\");"+stripimageid+"working_query_value_new = 0;"+stripimageid+"like_flag_sep = 1;"+stripimageid+"like_flag_b_sep = 1;}if( ("+stripimageid+"like_flag_b_sep == 0) && ("+stripimageid+"like_flag_sep == 0) ){"+stripimageid+"like_flag_b_sep = 1;}if( ("+stripimageid+"like_flag_b_sep == 1) && ("+stripimageid+"like_flag_sep ==1) ){"+stripimageid+"like_flag_sep = 1;"+stripimageid+"like_flag_b_sep = 0;}});});</scri"+""+"pt>");
		}

		
		//AJAX STATIC DOES NOT DEPEND ON ORIGINAL LIKETRACKS need to print 3 copies based on original liketrack
		$('#node-field').append("<scri"+""+"pt>$(document).ready(function(){$('#"+response_as_array[i][0]+"IndexForm').click(function (e) {clickedval = e.target.name;e.preventDefault();triggered = 0;if(("+stripimageid+"working_query_value_new == 0) && ("+stripimageid+"working_query_value_old == 2) && (triggered == 0)){"+stripimageid+"working_dislikes_new ="+response_as_array[i][6]+"-1;"+stripimageid+"working_likes_new ="+response_as_array[i][5]+";if(("+response_as_array[i][18]+" == 1)){"+stripimageid+"working_likes_new ="+response_as_array[i][5]+"-1;}triggered = true;}if(("+stripimageid+"working_query_value_new == 0) && ("+stripimageid+"working_query_value_old == 1) && (triggered == 0)){"+stripimageid+"working_likes_new ="+response_as_array[i][5]+"-1;"+stripimageid+"working_dislikes_new ="+response_as_array[i][6]+";if(("+response_as_array[i][18]+" == 2)){"+stripimageid+"working_dislikes_new ="+response_as_array[i][6]+"-1;}triggered = true;}if(("+stripimageid+"working_query_value_new == 0) && ("+stripimageid+"working_query_value_old == 0) && (triggered == 0)){"+stripimageid+"working_dislikes_new ="+response_as_array[i][6]+";"+stripimageid+"working_likes_new ="+response_as_array[i][5]+";triggered = true;}if(("+stripimageid+"working_query_value_new == 1) && ("+stripimageid+"working_query_value_old == 2) && (triggered == 0)){"+stripimageid+"working_dislikes_new ="+response_as_array[i][6]+"-1;"+stripimageid+"working_likes_new ="+response_as_array[i][5]+"+1;triggered = true;}if(("+stripimageid+"working_query_value_new == 1) && ("+stripimageid+"working_query_value_old == 1) && (triggered == 0)){"+stripimageid+"working_dislikes_new ="+response_as_array[i][6]+";triggered = true;}if(("+stripimageid+"working_query_value_new == 1) && ("+stripimageid+"working_query_value_old == 0) && (triggered == 0)){"+stripimageid+"working_dislikes_new ="+response_as_array[i][6]+";"+stripimageid+"working_likes_new ="+response_as_array[i][5]+"+1;if(("+response_as_array[i][18]+" == 2)){"+stripimageid+"working_dislikes_new ="+response_as_array[i][6]+"-1;}triggered = true;}if(("+stripimageid+"working_query_value_new == 2) && ("+stripimageid+"working_query_value_old == 2) && (triggered == 0)){"+stripimageid+"working_dislikes_new ="+response_as_array[i][6]+"-1;triggered = true;}if(("+stripimageid+"working_query_value_new == 2) && ("+stripimageid+"working_query_value_old == 1) && (triggered == 0)){"+stripimageid+"working_dislikes_new ="+response_as_array[i][6]+"+1;"+stripimageid+"working_likes_new ="+response_as_array[i][5]+"-1;triggered = true;}if(("+stripimageid+"working_query_value_new == 2) && ("+stripimageid+"working_query_value_old == 0) && (triggered == 0)){"+stripimageid+"working_dislikes_new ="+response_as_array[i][6]+"+1;"+stripimageid+"working_likes_new ="+response_as_array[i][5]+";if(("+response_as_array[i][18]+"== 1)){"+stripimageid+"working_likes_new ="+response_as_array[i][5]+"-1;}triggered = true;}if( (("+response_as_array[i][5]+"-"+stripimageid+"working_likes_new) >= 1) && ("+response_as_array[i][18]+" == 1)){"+stripimageid+"working_likes_new ="+response_as_array[i][5]+"-1;}if( (("+response_as_array[i][5]+"-"+stripimageid+"working_likes_new) <= -1) && ("+response_as_array[i][18]+" == 1)){"+stripimageid+"working_likes_new ="+response_as_array[i][5]+";}if( (("+response_as_array[i][5]+"-"+stripimageid+"working_likes_new) >= 1) && ("+response_as_array[i][18]+" == 2)){"+stripimageid+"working_likes_new ="+response_as_array[i][5]+";}if( (("+response_as_array[i][5]+"-"+stripimageid+"working_likes_new) <= -1) && ("+response_as_array[i][18]+"== 2)){"+stripimageid+"working_likes_new ="+response_as_array[i][5]+"+1;}if( (("+response_as_array[i][5]+"-"+stripimageid+"working_likes_new) >= 1) && ("+response_as_array[i][18]+" == 0)){"+stripimageid+"working_likes_new ="+response_as_array[i][5]+";}if( (("+response_as_array[i][5]+"-"+stripimageid+"working_likes_new) <= -1) && ("+response_as_array[i][18]+"== 0)){"+stripimageid+"working_likes_new ="+response_as_array[i][5]+"+1;}if( (("+response_as_array[i][6]+"-"+stripimageid+"working_dislikes_new) >= 1)  && ("+response_as_array[i][18]+" == 2) ){"+stripimageid+"working_dislikes_new ="+response_as_array[i][6]+"-1;}if( (("+response_as_array[i][6]+"-"+stripimageid+"working_dislikes_new) <= -1) && ("+response_as_array[i][18]+" == 2)){"+stripimageid+"working_dislikes_new ="+response_as_array[i][6]+";}if( (("+response_as_array[i][6]+"-"+stripimageid+"working_dislikes_new) >= 1)  && ("+response_as_array[i][18]+" == 1) ){"+stripimageid+"working_dislikes_new ="+response_as_array[i][6]+";}if( (("+response_as_array[i][6]+"-"+stripimageid+"working_dislikes_new) <= -1) && ("+response_as_array[i][18]+" == 1)){"+stripimageid+"working_dislikes_new ="+response_as_array[i][6]+"+1;}if( (("+response_as_array[i][6]+"-"+stripimageid+"working_dislikes_new) >= 1)  && ("+response_as_array[i][18]+"== 0) ){"+stripimageid+"working_dislikes_new ="+response_as_array[i][6]+";}if( (("+response_as_array[i][6]+"-"+stripimageid+"working_dislikes_new) <= -1) && ("+response_as_array[i][18]+" == 0)){"+stripimageid+"working_dislikes_new ="+response_as_array[i][6]+"+1;}$('div#"+response_as_array[i][0]+"numberdislikes').html("+stripimageid+"working_dislikes_new);$('div#"+response_as_array[i][0]+"numberlikes').html("+stripimageid+"working_likes_new);$.ajax({url: 'http://localhost:8888/cakephp-cakephp-0a6d85c/ajaxrequests/main_page_like.php',type: 'POST',data: {'model_id': '"+response_as_array[i][0]+"', 'user_id': '"+voterid+"', 'liked_or_disliked': clickedval,'title': '"+response_as_array[i][11]+"', 'description': '"+response_as_array[i][12]+"', 'artist_username': '"+response_as_array[i][10]+"', 'artistid': '"+response_as_array[i][1]+"', 'rank': '"+response_as_array[i][7]+"', 'true_rank': '"+response_as_array[i][8]+"', 'user_liketable_query': "+stripimageid+"working_query_value_old,'original_liketable_query': '"+response_as_array[i][18]+"'}}).done(function ( ) {}).fail(function ( jqXHR, textStatus, errorThrown ) {});"+stripimageid+"working_query_value_old = "+stripimageid+"working_query_value_new;"+stripimageid+"working_likes_old = "+stripimageid+"working_likes_new;"+stripimageid+"working_dislikes_old = "+stripimageid+"working_dislikes_new;});});</scri"+""+"pt>");
	}

	}).fail(function ( jqXHR, textStatus, errorThrown ){ 

	});

}
window.onscroll = yHandler;
</script>

	</div>
</div>



