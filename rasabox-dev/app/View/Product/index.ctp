<?php 
	
	echo $this->Html->css('product'); 

	echo $this->Html->script('jquery.js'); 
?>

<div id="page-main">

	<div id="node-field">

		<?php

            if ($search_value != "@null"){

                echo $this->Html->image('return-to-search.png', 

                    array('alt' => 'Image Error', 

                        'url' => array(

                            'controller' => 'main',
                            'action' => 'index',
                            'search' => $search_value
                                    
                        ),

                        'id' => 'return-to-search'
                    )
                ); 
            }

            if($number_pics > 1){


                echo $this->Html->div('picture-nav',

                    '',

                    array('alt' => 'Picture Nav Error', 'id' => 'picture-nav-right')
                );
            }

            if($number_models > 1){

                echo $this->Html->div('viewer-nav',

                    '',

                    array('alt' => 'Viewer Nav Error', 'id' => 'viewer-nav-right')
                 );
            }

            //zoomin button
            echo $this->Html->div('',

                '<button id = "zoomin-button" onclick="zoomIn();">In</button>',

                array('id' => 'zoomin')
            );
            //zoomout button
            echo $this->Html->div('',

                '<button id = "zoomout-button" onclick="zoomOut();">Out</button>',

                array('id' => 'zoomout')
            );

            //licensing area
            echo $this->Html->div('',

                'License',

                array('id' => 'license-box')
            );

			$index = 0;
            $dash = '-';

            foreach ($file_ext as $ext){

                if ($index == 0){

                    $index = '';
                    $dash = '';
                }

                echo $this->Html->div('product-image',

                    $this->Html->image('uploads' . DS . $model_id . $dash . $index . '.' . $ext, 

                        array('alt' => 'Image Error', 'id' => 'index' . $index)
                    )
                ); 
                if ($index == ''){

                    $index = 0;
                    $dash = '-';
                }

                $index++;
            }

            echo '<div id="product-viewerdiv">';
            
            for ($i=0; $i < $number_models; $i++){

                if ($i == 0){

                    $i = '';
                }

                echo '<canvas class="product-viewer" id="canvas'.$i.'" ></canvas>';

                echo '<canvas class="product-viewer-complete" id="canvas-completeurl'.$i.'" ></canvas>';

                if($i == ''){

                    $i = 0;
                }
            }

            echo '</div>';

            //swaps the viewer out with a working one
            echo $this->Html->div('',

                'Viewer not working? Click here to reset.',    

                array('id' => 'viewer-reset')
            );

            //resets the perspective on teh current viewer
            echo $this->Html->div('',

                '<button id = "viewer-perspective-reset-button" onclick="resetPerspective();">Reset Perspective</button>',    

                array('id' => 'viewer-perspective-reset')
            );

            //set of coor changers for 3dviewcompleteurl.js
            echo $this->Html->div('color-changer-2',

                '<button onclick="changeBodyColor1(0xe84948);"></button>',    

                array('id' => 'color-set-red')
            );

            echo $this->Html->div('color-changer-2',

                '<button onclick="changeBodyColor1(0xE3D664);"></button>',    

                array('id' => 'color-set-yellow')
            );

            echo $this->Html->div('color-changer-2',

                '<button onclick="changeBodyColor1(0x00C78C);"></button>',    

                array('id' => 'color-set-teal')
            );

            echo $this->Html->div('color-changer-2',

                '<button onclick="changeBodyColor1(0x7DB3DC);"></button>',    

                array('id' => 'color-set-blue')
            );


            echo $this->Html->div('color-changer-2',

                '<button onclick="changeBodyColor1(0x2E2EFE);"></button>',    

                array('id' => 'color-set-darkblue')
            );

            echo $this->Html->div('color-changer-2',

                '<button onclick="changeBodyColor1(0x000000);"></button>',    

                array('id' => 'color-set-black')
            );

            echo $this->Html->div('color-changer-1',

                '<button onclick="changeBodyColor2(0xe84948);"></button>',    

                array('id' => 'color-set-red')
            );

            echo $this->Html->div('color-changer-1',

                '<button onclick="changeBodyColor2(0xE3D664);"></button>',    

                array('id' => 'color-set-yellow')
            );

            echo $this->Html->div('color-changer-1',

                '<button onclick="changeBodyColor2(0x00C78C);"></button>',    

                array('id' => 'color-set-teal')
            );

            echo $this->Html->div('color-changer-1',

                '<button onclick="changeBodyColor2(0x7DB3DC);"></button>',    

                array('id' => 'color-set-blue')
            );

            echo $this->Html->div('color-changer-1',

                '<button onclick="changeBodyColor2(0x2E2EFE);"></button>',    

                array('id' => 'color-set-darkblue')
            );

            echo $this->Html->div('color-changer-1',

                '<button onclick="changeBodyColor2(0x000000);"></button>',    

                array('id' => 'color-set-black')
            );

            //"$index" is just for picture navigation.
            //we will use "$model_index" for navigating the viewer.
            //This next group of echos is a jquery script that cycles through the images
            echo '<script>';

            echo 'var lock1 = -1;';

            echo '$(\'#picture-nav-right\').click(function(e){';  

            echo 'lock1 = lock1 + 1;';

            echo 'if(lock1 =='.$index.'){lock1 = 0;}';

            for ($i=0; $i < $index; $i++){

                echo 'if(lock1 == '.$i.'){';

                if ($i == 0){//there is no 0 index it goes empty 1 then 2.

                    $i='';
                }

                echo '$(\'#index'. $i . '\').fadeIn(\'fast\', function(e){';

                for($z=0; $z < $index; $z++){

                    if ($z == 0){//there is no 0 index it goes empty 1 then 2.

                        $z='';
                    }

                    if ($z != $i){

                        echo    '$(\'#index'. $z . '\').fadeOut(\'fast\');'; 
                    }

                    if ($z == ''){

                        $z = 0;
                    }
                }

                if ($i == ''){

                    $i = 0;
                }
    
                echo    '});';
                echo '}';
            }
            
            echo    '});';
            echo '</script>';


            //this resets model_index to be equal to the number of models because now we use index to cycle through the 
            $model_index = $number_models;
            //This next group of echos is a jquery script that cycles through the the stls
            //cycles between models of one type of canvas grey or white, (complete url canvas or non complete url canvas)
            //this one uses the arrow nav to navigate the complete urls or grey background models.
            echo '<script>';

            echo '$(document).ready(function() {';

            echo 'var lock = -1;';

            echo '$(\'#viewer-nav-right\').click(function(e){';  

            echo 'lock = lock + 1;';

            echo 'if(lock =='.$model_index.'){lock = 0;}';

            for ($i=0; $i < $model_index; $i++){

                echo 'if(lock == '.$i.'){';

                if ($i == 0){//there is no 0 index it goes empty 1 then 2.

                    $i='';
                }
                
                echo '$(\'#canvas'. $i . '\').fadeIn(\'fast\', function(e){';
                
                for($z=0; $z < $model_index; $z++){

                    if ($z == 0){//there is no 0 index it goes empty 1 then 2.

                        $z='';
                    }

                    if ($z != $i){

                        echo    '$(\'#canvas'. $z . '\').fadeOut(\'fast\');'; 
                    }

                    if ($z == ''){

                        $z = 0;
                    }
                }

                if ($i == ''){

                    $i = 0;
                }
    
                echo    '});';
                echo '}';
            }
            
            echo    '});';
            echo '});';

            echo '</script>';

            //cycles between models of one type of canvas grey or white, (complete url canvas or non complete url canvas)
            //this one uses the arrow nav to navigate the complete urls or grey background models.
            echo '<script>';

            echo '$(document).ready(function() {';

            echo 'var lock = -1;';

            echo '$(\'#viewer-nav-right\').click(function(e){';  



            echo 'lock = lock + 1;';

            echo 'if(lock =='.$model_index.'){lock = 0;}';

            for ($i=0; $i < $model_index; $i++){

                echo 'if(lock == '.$i.'){';

                if ($i == 0){//there is no 0 index it goes empty 1 then 2.

                    $i='';
                }
                
                echo '$(\'#canvas-completeurl'. $i . '\').fadeIn(\'fast\', function(e){';
                
                for($z=0; $z < $model_index; $z++){

                    if ($z == 0){//there is no 0 index it goes empty 1 then 2.

                        $z='';
                    }

                    if ($z != $i){

                        echo    '$(\'#canvas-completeurl'. $z . '\').fadeOut(\'fast\');'; 
                    }

                    if ($z == ''){

                        $z = 0;
                    }
                }

                if ($i == ''){

                    $i = 0;
                }
    
                echo    '});';
                echo '}';
            }
            
            echo    '});';
            echo '});';

            echo '</script>';

            echo '<script>';
            // when you click on one set of buttons the other fades out
            // click on 1 and 2 fades out
            // click on 2 and 1 fades out
            echo '$(document).ready(function() {';

            echo '$(\'.color-changer-1\').click(function(e){';  

            echo '$(\'.color-changer-2\').fadeOut(\'fast\');';

            echo '});';

            echo '$(\'.color-changer-2\').click(function(e){';  

            echo '$(\'.color-changer-1\').fadeOut(\'fast\');';

            echo '});';

            echo '});';

            echo '</script>';

            //this next script switches the opacity of the 2 canvas types, complete url and non complete url 
            //when the user presses the viewer reset text.
            //resets the canvases/viewers
            echo '<script>';

            echo '$(document).ready(function() {';
            
            //VARIABLES CANNOT HAVE "-" cahracters it crashes the whole script.

            echo 'var opacityflag = 0;';

            echo '$(\'#viewer-reset\').click(function(e){';


            echo 'if(opacityflag == 0){';

            for ($i=0; $i < $number_models; $i++){

                if ($i == 0){//there is no 0 index it goes empty 1 then 2.

                    $i='';
                }

                echo '$(\'#canvas-completeurl'.$i.'\').css("opacity","0");';
                echo '$(\'#canvas-completeurl'.$i.'\').css("z-index","-1");';
                echo '$(\'#canvas'.$i.'\').css("opacity","1");';
                echo '$(\'#canvas'.$i.'\').css("z-index","1");';

                echo '$(\'.color-changer-1\').fadeOut(\'fast\');';

                echo '$(\'.color-changer-2\').fadeIn(\'fast\');';

                if ($i == ''){

                    $i = 0;
                }

            }

            echo '}';

            echo 'if(opacityflag == 1){';

            for ($i=0; $i < $number_models; $i++){

                if ($i == 0){//there is no 0 index it goes empty 1 then 2.

                    $i='';
                }

                echo '$(\'#canvas-completeurl'.$i.'\').css("opacity","1");';
                echo '$(\'#canvas-completeurl'.$i.'\').css("z-index","1");';

                echo '$(\'#canvas'.$i.'\').css("opacity","0");';
                echo '$(\'#canvas'.$i.'\').css("z-index","-1");';

                echo '$(\'.color-changer-1\').fadeIn(\'fast\');';

                echo '$(\'.color-changer-2\').fadeOut(\'fast\');';

                if ($i == ''){

                    $i = 0;
                }

            }
            
            echo '}';

            echo 'if(opacityflag == 0){';
            echo 'opacityflag = 1;';
            echo '}';
            echo 'else{opacityflag = 0;}';

            //echo 'alert("yourmom");';  

            echo '});';
            echo '});';

            echo '</script>';
    
			echo $this->Html->div( null, 

                $description,

				array('id' => 'product-description')
			);

            //this next script control when the download buttons are shown and closed
            echo '<script>';

            //never omit the document ready, Ik this seems fucking basic but it happens 
            //then this shit wont work for like 8hrs and yours just sitting there with
            //your appendage in your hand looking like a total boob. Do not look like a total
            //boob. You may also ignore the blatantly retarded fact that the previous scripts 
            //work WITHOUT $(document).ready(function() this is either yoru lack of knowledge 
            //or jquery being just plain stupid. It may be (and this is widl speculation) that
            // the first scripts work and then you need to reset the document to run mroe scripts.
            echo '$(document).ready(function() {';

            echo '$(\'#dlsidebar-mainbutton\').click(function(e){';  

            echo '$(\'#download-buttons\').fadeIn(\'fast\');';

            echo '$(\'#list_of_ques\').fadeOut(\'fast\');';

            echo '});';

            echo '$(\'#dlsidebar-unit-close\').click(function(e){';  

            echo '$(\'#download-buttons\').fadeOut(\'fast\');';

            echo '});';

            echo '});';

            echo '</script>';

			?>   

			<div id="product-sidebar">

            <?php
                                
                    echo $this->Form->create('like_submit', array('default' => false));
                    
                    echo $this->Form->button('', 
                        
                        array('label'=>false, 

                            'type' => 'submit',
                            'name' => 'submitlike' ,
                            'value' => $model_id,
                            'id' => $model_id.'changetoorange' //need model id because that's how the identifier script works
                        )
                    );
                    
                    echo $this->Form->button('', 

                        array('label'=>false, 

                            'type' => 'submit',
                            'name' => 'submitdislike' ,
                            'value' => $model_id,
                            'id' => $model_id.'changetoblue' //need model id because that's how the identifier script works
                        )
                    );
                    
                    echo $this->Form->end();

            ?>

            <div id="download-sidebar">

                <div id="download-reveal">

            <?php
            echo $this->Html->image('/img/download.png' ,

                array('alt' => 'Download Link Error', 

                    'url' => '/img/' . 'models' . DS . $model_id. '-zip.zip',

                    'id'=>'dlsidebar-mainbutton'
                )
            );

            ?>
                </div>
            </div>
            <?php

			echo $this->Html->div( null,

                $this->Html->div(null, 

                    $numberlikes,

                    array('id' => 'product-likes')
                )
                .
                $this->Html->div(null, 


                    $numberdislikes,

                    array('id' => 'product-dislikes')
                )
                ,

				array('id' => 'likes-sidebar')

			);

            ?>

			</div>

			<?php

            echo $this->Html->div('',

                $this->Html->link( 

                            'Uploaded by: '. $artist_username , 
                            '/profile/index/id:'. $artistid.'/username:'.$artist_username 
                        ),

                array('id' => 'artist-username')

            );


            echo $this->Html->div('' , 

                '',

                array('alt' => 'Download Link Error', 

                    'id'=>'add_que_button'
                )
            );

			?>


			<div id="list_of_ques">

			<?php
                echo $this->Form->create('Que_List', array('default' => false));

				foreach ($table_que_list as $que) {

					if (substr($que[$strip_userid]['quetitle'], strrpos($que[$strip_userid]['quetitle'], "self")) != "self"){

                        echo $this->Form->button(str_replace("_", " ", $que[$strip_userid]['quetitle']), 

                            array('label'=>false, 

                                'type' => 'submit',
                                'name ' => 'list_que' ,
                                'value' => $que[$strip_userid]['quetitle'],
                            )
                        );
                    }

                    
				}
                echo $this->Form->end();

            echo $this->Html->div('closebutton', 

                '',

                array( 

                    'id'=>'que-unit-close'
                )
            );

            echo '<script>';

            echo '$(document).ready(function() {';

            echo '$(\'#add_que_button\').click(function(e){';  

            echo '$(\'#list_of_ques\').fadeIn(\'fast\');';

            echo '$(\'#download-buttons\').fadeOut(\'fast\');';

            echo '});';

            echo '$(\'#que-unit-close\').click(function(e){';  

            echo '$(\'#list_of_ques\').fadeOut(\'fast\');';

            echo '});';

            echo  '});';

            echo '</script>';

            //While here we do not strictly NEED to tack a unique identifier 
            //onto each button (via tacking it in front of the id)
            //I still do it because it's too much work to go back and untype all of them (also i like code consistency/portability)
            //from teh script below. The script was copeid directly from index.ctp - Main
            //do not forget to change "working_query_value_new" and "working_Query_value_old"
            //after the ajax gets called.
            //"$nodeparent['user_liketable_query'] == 1" changed to "$like_flag == 1."
            //There are not nodeparents on the product page (all occurences of nodeparent replaced with appropriate variables)
            //like_flag in the php has NOTHING to do with the like_flag in the javascript/jquery, they are never ser to each other
            //the javascript like_flags are just a series of locks to make the color changer work.
            //unqiue id to ammend onto the front of our flag variables
            //so they don't interfere with other flags from
            //different models.
            $strip_imageid = str_replace("-", "", $model_id);
                
            //We concatenate F on the front of of our unique id because all javascript vars
            //must start with a letter or $ or wtvr, and cannot start iwth a number
            //our unique id without the F on the front starts with a number and
            // breaks everything.
            $strip_imageid = 'F'.$strip_imageid;
            
            //if the user has already upvoted something
            if($like_flag == 1){

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
                echo 'var '.$strip_imageid.'working_query_value_new = '.$like_flag.';';
                echo 'var '.$strip_imageid.'working_query_value_old = '.$like_flag.';';
                echo 'var '.$strip_imageid.'working_likes_new = '.$numberlikes.';';
                echo 'var '.$strip_imageid.'working_likes_old = '.$numberlikes.';';
                echo 'var '.$strip_imageid.'working_dislikes_new = '.$numberdislikes.';';
                echo 'var '.$strip_imageid.'working_dislikes_old = '.$numberdislikes.';';

                echo '</script>';

                echo '<script>';
                
                echo '$(document).ready(function(){';
                //if the flag is 1 set it to orange.
                echo '$(\'#'.$model_id.'changetoorange'.'\').css("background-color","#E5895B");';

                //if people click on that orange button again, reset it to gray. note the #393738 is rasabox grey.
                //if we load in initially with $nodeparent['user_liketable_query'] == 1 and the user likes something
                echo '$(\'#like_submitIndexForm button[name="submitlike"]\').click(function (e) {';

                echo 'if('.$strip_imageid.'like_flag == 1){';

                echo '$(\'#'.$model_id.'changetoorange'.'\').css("background-color", "#393738");';
                echo ''.$strip_imageid.'working_query_value_new = 0;'; //current state set to "netural" equivalent
              //  echo ''.$strip_imageid.'working_likes_new = '.$strip_imageid.'working_likes_old-'.'1'.';';
                echo ''.$strip_imageid.'like_flag = 0;';
                echo ''.$strip_imageid.'like_flag_b = 0;';
                echo '}';

                //make sure that the clicked thing turns orange
                //make sure that the minus (id = changetoblue) changes to grey.
                echo 'if('.$strip_imageid.'like_flag_b == 1){';

                echo '$(\'#'.$model_id.'changetoorange'.'\').css("background-color", "#E5895B");';
                echo '$(\'#'.$model_id.'changetoblue'.'\').css("background-color", "#393738");';
                echo ''.$strip_imageid.'working_query_value_new = 1;'; // current state set to "like" equivalent
              //  echo ''.$strip_imageid.'working_likes_new = '.$strip_imageid.'working_likes_old+'.'1'.';';

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

                echo '$(\'#like_submitIndexForm button[name="submitdislike"]\').click(function (e) {';

                //NOTE FOR this onewe swapped where we turn it grey to the second if,
                //this is because initially it is uncolored if it loads as 0 flag for $nodeparent['user_liketable_query']
                //also this one changes the opposite one to grey.
                //In each SECOND SCRIPT under $nodeparent['user_liketable_query'] =1 or =2,
                // the contents of the ifs should be the reverse of the FIrst script under teh respective $nodeparent['user_liketable_query'] =1 or =2,
                // Not just this but the color changing is also inverted.
                echo 'if('.$strip_imageid.'like_flag_sep == 1){';
                echo '$(\'#'.$model_id.'changetoblue'.'\').css("background-color", "#8485ED");';
                echo '$(\'#'.$model_id.'changetoorange'.'\').css("background-color", "#393738");';
                echo ''.$strip_imageid.'working_query_value_new = 2;'; //current state set to "dislike equivalent"
             //   echo ''.$strip_imageid.'working_dislikes_new = '.$strip_imageid.'working_dislikes_old+'.'1'.';';
                echo ''.$strip_imageid.'like_flag_sep = 0;';
                echo ''.$strip_imageid.'like_flag_b_sep = 0;';

                //RESET FIRST SCRIPT's locks to the SECOND IF
                //here the second if will trigger and not the first.
                echo ''.$strip_imageid.'like_flag = 0;';
                echo ''.$strip_imageid.'like_flag_b = 1;';
                echo '}';

                echo 'if('.$strip_imageid.'like_flag_b_sep == 1){';
                echo '$(\'#'.$model_id.'changetoblue'.'\').css("background-color", "#393738");';
                echo ''.$strip_imageid.'working_query_value_new = 0;'; // neutral equivalent state set
             //   echo ''.$strip_imageid.'working_dislikes_new = '.$strip_imageid.'working_dislikes_old-'.'1'.';';
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
            if($like_flag == 2){

                /********************* FIRST SCRIPT *********************/

                echo '<script type="text/javascript">';

                //duh the solution is to make 2 variables.
                //i feel so dumb.
                echo 'var '.$strip_imageid.'like_flag_sep = 1;';
                echo 'var '.$strip_imageid.'like_flag_b_sep = 0;';
                echo 'var '.$strip_imageid.'like_flag = 1;';
                echo 'var '.$strip_imageid.'like_flag_b = 0;';
                echo 'var '.$strip_imageid.'working_query_value_new = '.$like_flag.';';
                echo 'var '.$strip_imageid.'working_query_value_old = '.$like_flag.';';
                echo 'var '.$strip_imageid.'working_likes_new = '.$numberlikes.';';
                echo 'var '.$strip_imageid.'working_likes_old = '.$numberlikes.';';
                echo 'var '.$strip_imageid.'working_dislikes_new = '.$numberdislikes.';';
                echo 'var '.$strip_imageid.'working_dislikes_old = '.$numberdislikes.';';

                echo '</script>';

                echo '<script>';

                echo '$(document).ready(function(){';

                //get the form that was clicked on
                echo '$(\'#'.$model_id.'changetoblue'.'\').css("background-color","#8485ED");';

                //if people click on that orange button again, reset it to gray. note the #393738 is rasabox grey.
                echo '$(\'#like_submitIndexForm button[name="submitdislike"]\').click(function (e) {';

                echo 'if('.$strip_imageid.'like_flag == 1){';
                echo '$(\'#'.$model_id.'changetoblue'.'\').css("background-color", "#393738");';
                echo ''.$strip_imageid.'working_query_value_new = 0;'; //neutral state of liking ( minus changed to greychanged to grey)
              //  echo ''.$strip_imageid.'working_dislikes_new = '.$strip_imageid.'working_dislikes_old-'.'1'.';';
                echo ''.$strip_imageid.'like_flag = 0;';
                echo ''.$strip_imageid.'like_flag_b = 0;';
                echo '}';

                echo 'if('.$strip_imageid.'like_flag_b == 1){';
                echo '$(\'#'.$model_id.'changetoblue'.'\').css("background-color", "#8485ED");';
                echo '$(\'#'.$model_id.'changetoorange'.'\').css("background-color", "#393738");';
                echo ''.$strip_imageid.'working_query_value_new = 2;'; //dislike state of liking (minus changed to blue), plus changed to grey
               // echo ''.$strip_imageid.'working_dislikes_new = '.$strip_imageid.'working_dislikes_old+'.'1'.';';
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

                echo '$(\'#like_submitIndexForm button[name="submitlike"]\').click(function (e) {';

                //NOTE FOR this onewe swapped where we turn it grey to the second if,
                //this is because initially it is uncolored if it loads as 0 flag for $nodeparent['user_liketable_query']
                //also this one changes the opposite one to grey.
                //In each SECOND SCRIPT under $nodeparent['user_liketable_query'] =1 or =2,
                // the contents of the ifs should be the reverse of the FIrst script under teh respective $nodeparent['user_liketable_query'] =1 or =2,
                // Not just this but the color changing is also inverted.
                // HEre we changed changetoorange to orange, and changetoblue to grey
                // above we changed changetoorange to grey, and changetoblue to blue
                echo 'if('.$strip_imageid.'like_flag_sep == 1){';
                echo '$(\'#'.$model_id.'changetoorange'.'\').css("background-color", "#E5895B");';
                echo '$(\'#'.$model_id.'changetoblue'.'\').css("background-color", "#393738");';
                echo ''.$strip_imageid.'working_query_value_new = 1;'; //like state of liking (plus to orange, blue to grey)
              //  echo ''.$strip_imageid.'working_likes_new = '.$strip_imageid.'working_likes_old+'.'1'.';';
                echo ''.$strip_imageid.'like_flag_sep = 0;';
                echo ''.$strip_imageid.'like_flag_b_sep = 0;';

                //RESET FIRST SCRIPT's locks to the SECOND IF
                //here the second if will trigger and not the first.
                echo ''.$strip_imageid.'like_flag = 0;';
                echo ''.$strip_imageid.'like_flag_b = 1;';
                echo '}';

                echo 'if('.$strip_imageid.'like_flag_b_sep == 1){';
                echo '$(\'#'.$model_id.'changetoorange'.'\').css("background-color", "#393738");';
                echo ''.$strip_imageid.'working_query_value_new = 0;'; //neutral state
              //  echo ''.$strip_imageid.'working_likes_new = '.$strip_imageid.'working_likes_old-'.'1'.';';
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
            if($like_flag == 0){

                /********************* FIRST SCRIPT *********************/

                echo '<script type="text/javascript">';

                //duh the solution is to make 2 variables.
                //i feel so dumb.
                echo 'var '.$strip_imageid.'like_flag_sep = 1;';
                echo 'var '.$strip_imageid.'like_flag_b_sep = 0;';
                echo 'var '.$strip_imageid.'like_flag = 1;';
                echo 'var '.$strip_imageid.'like_flag_b = 0;';
                echo 'var '.$strip_imageid.'working_query_value_new = '.$like_flag.';';
                echo 'var '.$strip_imageid.'working_query_value_old = '.$like_flag.';';
                echo 'var '.$strip_imageid.'working_likes_new = '.$numberlikes.';';
                echo 'var '.$strip_imageid.'working_likes_old = '.$numberlikes.';';
                echo 'var '.$strip_imageid.'working_dislikes_new = '.$numberdislikes.';';
                echo 'var '.$strip_imageid.'working_dislikes_old = '.$numberdislikes.';';

                echo '</script>';

                echo '<script>';

                echo '$(document).ready(function(){';

                //get the form that was clicked on
                echo '$(\'#like_submitIndexForm button[name="submitlike"]\').click(function (e) {';

                //NOTE FOR this onewe swapped where we turn it grey to the second if,
                //this is because initially it is uncolored if it loads as 0 flag for $nodeparent['user_liketable_query']
                //also this one changes the opposite one to grey.
                echo 'if('.$strip_imageid.'like_flag == 1){';
                echo '$(\'#'.$model_id.'changetoorange'.'\').css("background-color", "#E5895B");';
                echo '$(\'#'.$model_id.'changetoblue'.'\').css("background-color", "#393738");';
                echo ''.$strip_imageid.'working_query_value_new = 1;'; //like state
               // echo ''.$strip_imageid.'working_likes_new = '.$strip_imageid.'working_likes_old+'.'1'.';';
                echo ''.$strip_imageid.'like_flag = 0;';
                echo ''.$strip_imageid.'like_flag_b = 0;';

                //RESET SCRIPT SECOND's locks
                echo ''.$strip_imageid.'like_flag_sep = 1;';
                echo ''.$strip_imageid.'like_flag_b_sep = 0;';
                echo '}';

                echo 'if('.$strip_imageid.'like_flag_b == 1){';
                echo '$(\'#'.$model_id.'changetoorange'.'\').css("background-color", "#393738");';
                echo ''.$strip_imageid.'working_query_value_new = 0;';//neutral state
               // echo ''.$strip_imageid.'working_likes_new = '.$strip_imageid.'working_likes_old-'.'1'.';';
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

                echo '$(\'#like_submitIndexForm button[name="submitdislike"]\').click(function (e) {';

                //NOTE FOR this onewe swapped where we turn it grey to the second if,
                //this is because initially it is uncolored if it loads as 0 flag for $nodeparent['user_liketable_query']
                //also this one changes the opposite one to grey.
                echo 'if('.$strip_imageid.'like_flag_sep == 1){';
                echo '$(\'#'.$model_id.'changetoblue'.'\').css("background-color", "#8485ED");';
                echo '$(\'#'.$model_id.'changetoorange'.'\').css("background-color", "#393738");';
                echo ''.$strip_imageid.'working_query_value_new = 2;';
               // echo ''.$strip_imageid.'working_dislikes_new = '.$strip_imageid.'working_dislikes_old+'.'1'.';';
                echo ''.$strip_imageid.'like_flag_sep = 0;';
                echo ''.$strip_imageid.'like_flag_b_sep = 0;';

                //RESET FIRST SCRIPT's locks, in scenarios where we have clickedo n like, then dislike, then like again
                //this avoids the awkward first click that "does nothing", because we have to blow through the like
                // button's second lock before going back to the first again.
                echo ''.$strip_imageid.'like_flag = 1;';
                echo ''.$strip_imageid.'like_flag_b = 0;';
                echo '}';

                echo 'if('.$strip_imageid.'like_flag_b_sep == 1){';
                echo '$(\'#'.$model_id.'changetoblue'.'\').css("background-color", "#393738");';
                echo ''.$strip_imageid.'working_query_value_new = 0;';
               // echo ''.$strip_imageid.'working_dislikes_new = '.$strip_imageid.'working_dislikes_old-'.'1'.';';
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



            echo '<script>';

            //THIS IS THE ADD QUE BUTTON AJAX

            echo '$(document).ready(function(){';

            // find the comment form and add a submit event handler
            echo '$(\'#Que_ListIndexForm\').click(function (e) {';

                // stop the browser from submitting the form
            echo  'clickedval = e.target.value;';

            echo  'e.preventDefault();';

            //if the user is not logged in and attempts to like stuff, we will redirect him to the login page.
            if (!$authUser){
                
                echo 'window.location.replace("http://localhost:8888/cakephp-cakephp-0a6d85c/users/login");';
            }

            //the request works, it spawns an error message.
            //it get to success/failure because the url is working now.
            //also ".update()" is not valid jquery


            echo '$.ajax({

                url: \'http://localhost:8888/cakephp-cakephp-0a6d85c/ajaxrequests/add_to_que.php\', 
                type: \'POST\',
                data: {\'model_title\': \''.$title.'\', \'model_id\': \''.$model_id.'\', \'artist_id\': \''.$artistid.'\', \'artist_username\': \''.$artist_username.'\', \'extension\': \''.$extension.'\', \'description\': \''.$description.'\', \'numberlikes\': \''.$numberlikes.'\', \'numberdislikes\': \''.$numberdislikes.'\', \'number_pics\': \''.$number_pics.'\', \'number_models\': \''.$number_models.'\', \'file_types\': \''.$file_types.'\', \'strip_userid\': \''.$strip_userid.'\', \'list_que\': clickedval, \'rank\': \''.$rank.'\'},

                }).done(function ( ) {

                   
                
                }).fail(function ( jqXHR, textStatus, errorThrown ) {
                        
                    

                });';

            echo '});';

            echo  '});';

            echo '</script>';


            //THIS IS THE PRODUCT LIKE BUTTON AJAX
            //user id i s the current user not the artist. We use this data for liketracks. 
            //the user who actually liked the thing.
            echo '<script>';

            echo '$(document).ready(function(){';

            // find the comment form and add a submit event handler
            //ProductIndexForm is the form for submitlike and submitdislike
            echo '$(\'#like_submitIndexForm\').click(function (e) {';

            //get teh name from the button we clicked to know if user submitted a like or a dislike
            echo  'clickedval = e.target.name;';

            // stop the browser from submitting the form
            echo  'e.preventDefault();';

            //if the user is not logged in and attempts to like stuff, we will redirect him to the login page.
            if (!$authUser){
                
                echo 'window.location.replace("http://localhost:8888/cakephp-cakephp-0a6d85c/users/login");';
            }

            echo 'triggered = 0;'; //prevents us from doing more than one of these things for each click.
            /***** START *****/
            //next couple sets of ifs set shit right., next 3 are for 2 empty buttons at the end.
            echo 'if(('.$strip_imageid.'working_query_value_new == 0) && ('.$strip_imageid.'working_query_value_old == 2) && (triggered == 0)){';

            echo ''.$strip_imageid.'working_dislikes_new = '.$numberdislikes.'-1;';
            echo ''.$strip_imageid.'working_likes_new = '.$numberlikes.';';

            //if the original is 1 prevent it from setting likes back up to original as we went from 1 to 0.
            echo 'if(('.$like_flag.' == 1)){';

                echo ''.$strip_imageid.'working_likes_new = '.$numberlikes.'-1;';

            echo '}';
            //echo '$("div#'.$searchnode['imageid'].'numberdislikes").html('.$strip_imageid.'working_dislikes_new);';
            //echo '$("div#'.$searchnode['imageid'].'numberlikes").html('.$strip_imageid.'working_likes_new);';
            echo 'triggered = true;';

            echo '}';


            echo 'if(('.$strip_imageid.'working_query_value_new == 0) && ('.$strip_imageid.'working_query_value_old == 1) && (triggered == 0)){';

            echo ''.$strip_imageid.'working_likes_new = '.$numberlikes.'-1;';
            echo ''.$strip_imageid.'working_dislikes_new = '.$numberdislikes.';';
            //echo '$("div#'.$searchnode['imageid'].'numberdislikes").html('.$strip_imageid.'working_dislikes_new);';
            //echo '$("div#'.$searchnode['imageid'].'numberlikes").html('.$strip_imageid.'working_likes_new);';

            //if the original == 2 prevent it from resettin the dislikes back to original (as we are now neutral at 0.)
            echo 'if(('.$like_flag.' == 2)){';

                echo ''.$strip_imageid.'working_dislikes_new = '.$numberdislikes.'-1;';

            echo '}';

            echo 'triggered = true;';

            echo '}';


            echo 'if(('.$strip_imageid.'working_query_value_new == 0) && ('.$strip_imageid.'working_query_value_old == 0) && (triggered == 0)){';

            echo ''.$strip_imageid.'working_dislikes_new = '.$numberdislikes.';';
            echo ''.$strip_imageid.'working_likes_new = '.$numberlikes.';';
            //echo '$("div#'.$searchnode['imageid'].'numberdislikes").html('.$strip_imageid.'working_dislikes_new);';
            //echo '$("div#'.$searchnode['imageid'].'numberlikes").html('.$strip_imageid.'working_likes_new);';
            echo 'triggered = true;';

            echo '}';
            /***** END *****/

            /***** START *****/
            //next couple are for ending on an upvote.
            echo 'if(('.$strip_imageid.'working_query_value_new == 1) && ('.$strip_imageid.'working_query_value_old == 2) && (triggered == 0)){';

            echo ''.$strip_imageid.'working_dislikes_new = '.$numberdislikes.'-1;';
            echo ''.$strip_imageid.'working_likes_new = '.$numberlikes.'+1;';
            //echo '$("div#'.$searchnode['imageid'].'numberdislikes").html('.$strip_imageid.'working_dislikes_new);';
            //echo '$("div#'.$searchnode['imageid'].'numberlikes").html('.$strip_imageid.'working_likes_new);';
            echo 'triggered = true;';

            echo '}';


            echo 'if(('.$strip_imageid.'working_query_value_new == 1) && ('.$strip_imageid.'working_query_value_old == 1) && (triggered == 0)){';

            echo ''.$strip_imageid.'working_dislikes_new = '.$numberdislikes.';';
            //echo ''.$strip_imageid.'working_likes_new = '.$numberlikes.'-1;';
           //   echo '$("div#'.$searchnode['imageid'].'numberdislikes").html('.$strip_imageid.'working_dislikes_new);';
            //echo '$("div#'.$searchnode['imageid'].'numberlikes").html('.$strip_imageid.'working_likes_new);';
            echo 'triggered = true;';

            echo '}';


            echo 'if(('.$strip_imageid.'working_query_value_new == 1) && ('.$strip_imageid.'working_query_value_old == 0) && (triggered == 0)){';

            echo ''.$strip_imageid.'working_dislikes_new = '.$numberdislikes.';';
            echo ''.$strip_imageid.'working_likes_new = '.$numberlikes.'+1;';
            //echo '$("div#'.$searchnode['imageid'].'numberdislikes").html('.$strip_imageid.'working_dislikes_new);';
            //echo '$("div#'.$searchnode['imageid'].'numberlikes").html('.$strip_imageid.'working_likes_new);';


            echo 'if(('.$like_flag.' == 2)){';

                echo ''.$strip_imageid.'working_dislikes_new = '.$numberdislikes.'-1;';

            echo '}';

            echo 'triggered = true;';

            echo '}';
            /***** END *****/


            /***** START *****/
            //next couple are for ending on an upvote.
            echo 'if(('.$strip_imageid.'working_query_value_new == 2) && ('.$strip_imageid.'working_query_value_old == 2) && (triggered == 0)){';

            echo ''.$strip_imageid.'working_dislikes_new = '.$numberdislikes.'-1;';
            //echo ''.$strip_imageid.'working_likes_new = '.$numberlikes.';';
            //echo '$("div#'.$searchnode['imageid'].'numberdislikes").html('.$strip_imageid.'working_dislikes_new);';
            //echo '$("div#'.$searchnode['imageid'].'numberlikes").html('.$strip_imageid.'working_likes_new);';
            echo 'triggered = true;';

            echo '}';


            echo 'if(('.$strip_imageid.'working_query_value_new == 2) && ('.$strip_imageid.'working_query_value_old == 1) && (triggered == 0)){';

            echo ''.$strip_imageid.'working_dislikes_new = '.$numberdislikes.'+1;';
            echo ''.$strip_imageid.'working_likes_new = '.$numberlikes.'-1;';
            //echo '$("div#'.$searchnode['imageid'].'numberdislikes").html('.$strip_imageid.'working_dislikes_new);';
            //echo '$("div#'.$searchnode['imageid'].'numberlikes").html('.$strip_imageid.'working_likes_new);';
            echo 'triggered = true;';

            echo '}';


            echo 'if(('.$strip_imageid.'working_query_value_new == 2) && ('.$strip_imageid.'working_query_value_old == 0) && (triggered == 0)){';

            echo ''.$strip_imageid.'working_dislikes_new = '.$numberdislikes.'+1;';
            echo ''.$strip_imageid.'working_likes_new = '.$numberlikes.';';


            echo 'if(('.$like_flag.' == 1)){';

                echo ''.$strip_imageid.'working_likes_new = '.$numberlikes.'-1;';

            echo '}';
            
            echo 'triggered = true;';

            echo '}';


            /****** BEGIN *******/
            echo 'if( (('.$numberlikes.'-'.$strip_imageid.'working_likes_new) >= 1) && ('.$like_flag.' == 1)){';

            //echo ''.$strip_imageid.'working_dislikes_new = '.$numberdislikes.'+1;';
            echo ''.$strip_imageid.'working_likes_new = '.$numberlikes.'-1;';

            echo '}';

            echo 'if( (('.$numberlikes.'-'.$strip_imageid.'working_likes_new) <= -1) && ('.$like_flag.' == 1)){';

            //echo ''.$strip_imageid.'working_dislikes_new = '.$numberdislikes.'+1;';
            echo ''.$strip_imageid.'working_likes_new = '.$numberlikes.';';

            echo '}';


            echo 'if( (('.$numberlikes.'-'.$strip_imageid.'working_likes_new) >= 1) && ('.$like_flag.' == 2)){';

            //echo ''.$strip_imageid.'working_dislikes_new = '.$numberdislikes.'+1;';
            echo ''.$strip_imageid.'working_likes_new = '.$numberlikes.';';

            echo '}';

            echo 'if( (('.$numberlikes.'-'.$strip_imageid.'working_likes_new) <= -1) && ('.$like_flag.' == 2)){';

            //echo ''.$strip_imageid.'working_dislikes_new = '.$numberdislikes.'+1;';
            echo ''.$strip_imageid.'working_likes_new = '.$numberlikes.'+1;';

            echo '}';


            echo 'if( (('.$numberlikes.'-'.$strip_imageid.'working_likes_new) >= 1) && ('.$like_flag.' == 0)){';

            //echo ''.$strip_imageid.'working_dislikes_new = '.$numberdislikes.'+1;';
            echo ''.$strip_imageid.'working_likes_new = '.$numberlikes.';';

            echo '}';

            echo 'if( (('.$numberlikes.'-'.$strip_imageid.'working_likes_new) <= -1) && ('.$like_flag.' == 0)){';

            //echo ''.$strip_imageid.'working_dislikes_new = '.$numberdislikes.'+1;';
            echo ''.$strip_imageid.'working_likes_new = '.$numberlikes.'+1;';

            echo '}';
            /****** END ******/

            /****** BEGIN *******/
            echo 'if( (('.$numberdislikes.'-'.$strip_imageid.'working_dislikes_new) >= 1)  && ('.$like_flag.' == 2) ){';

            //echo ''.$strip_imageid.'working_dislikes_new = '.$numberdislikes.'+1;';
            echo ''.$strip_imageid.'working_dislikes_new = '.$numberdislikes.'-1;';

            echo '}';

            echo 'if( (('.$numberdislikes.'-'.$strip_imageid.'working_dislikes_new) <= -1) && ('.$like_flag.' == 2)){';

            //echo ''.$strip_imageid.'working_dislikes_new = '.$numberdislikes.'+1;';
            echo ''.$strip_imageid.'working_dislikes_new = '.$numberdislikes.';';

            echo '}';

            echo 'if( (('.$numberdislikes.'-'.$strip_imageid.'working_dislikes_new) >= 1)  && ('.$like_flag.' == 1) ){';

            //echo ''.$strip_imageid.'working_dislikes_new = '.$numberdislikes.'+1;';
            echo ''.$strip_imageid.'working_dislikes_new = '.$numberdislikes.';';

            echo '}';

            echo 'if( (('.$numberdislikes.'-'.$strip_imageid.'working_dislikes_new) <= -1) && ('.$like_flag.' == 1)){';

            //echo ''.$strip_imageid.'working_dislikes_new = '.$numberdislikes.'+1;';
            echo ''.$strip_imageid.'working_dislikes_new = '.$numberdislikes.'+1;';

            echo '}';

            echo 'if( (('.$numberdislikes.'-'.$strip_imageid.'working_dislikes_new) >= 1)  && ('.$like_flag.' == 0) ){';

            //echo ''.$strip_imageid.'working_dislikes_new = '.$numberdislikes.'+1;';
            echo ''.$strip_imageid.'working_dislikes_new = '.$numberdislikes.';';

            echo '}';

            echo 'if( (('.$numberdislikes.'-'.$strip_imageid.'working_dislikes_new) <= -1) && ('.$like_flag.' == 0)){';

            //echo ''.$strip_imageid.'working_dislikes_new = '.$numberdislikes.'+1;';
            echo ''.$strip_imageid.'working_dislikes_new = '.$numberdislikes.'+1;';

            echo '}';

            echo '$("div#product-dislikes").html('.$strip_imageid.'working_dislikes_new);';
            echo '$("div#product-likes").html('.$strip_imageid.'working_likes_new);';
            /***** END *****/

            //the request works, it spawns an error message.
            //it get to success/failure because the url is working now.

            echo '$.ajax({

                url: \'http://localhost:8888/cakephp-cakephp-0a6d85c/ajaxrequests/product_page_like.php\', 
                type: \'POST\',
                data: {\'numberlikes\': '.$strip_imageid.'working_likes_old, \'numberdislikes\': '.$strip_imageid.'working_dislikes_old, \'model_id\': \''.$model_id.'\', \'user_id\': \''.$userid.'\', 
                        \'liked_or_disliked\': clickedval,\'model_title\': \''.$title.'\', \'description\': \''.$description.'\', \'artist_username\': \''.$artist_username.'\', \'artistid\': \''.$artistid.'\', \'rank\': \''.$rank.'\', \'true_rank\': \''.$true_rank.'\', \'user_liketable_query\': '.$strip_imageid.'working_query_value_old, \'original_liketable_query\': \''.$like_flag.'\' },

                }).done(function ( ) {
                    
                    
                
                }).fail(function ( jqXHR, textStatus, errorThrown ) {

                    
                });';

            echo ''.$strip_imageid.'working_query_value_old = '.$strip_imageid.'working_query_value_new;';

            echo ''.$strip_imageid.'working_likes_old = '.$strip_imageid.'working_likes_new;';

            echo ''.$strip_imageid.'working_dislikes_old = '.$strip_imageid.'working_dislikes_new;';

            echo '});';

            echo  '});';

            echo '</script>';


            //comment ajax script
            echo '<script>';

            echo '$(document).ready(function(){';

            // find the comment form and add a submit event handler
            //ProductIndexForm is the form for comment_submit
            echo '$(\'#comment_submit\').click(function (e) {';

            //get teh name from the button we clicked to know if user submitted a like or a dislike
            echo  'textval = document.getElementById("new_comment").value;';

            // stop the browser from submitting the form
            echo  'e.preventDefault();';

            //if the user is not logged in and attempts to like stuff, we will redirect him to the login page.
            if (!$authUser){
                
                echo 'window.location.replace("http://localhost:8888/cakephp-cakephp-0a6d85c/users/login");';
            }

            echo 'if(!textval){exit();}';


            echo  'uuidval = createUUID();';

            //the request works, it spawns an error message.
            //it get to success/failure because the url is working now.
            //here numberlikes, numberdislikes, rank are the likes/dislikes/rank of that comment and not it's parent product/object.
            //so they all start as zero from this ajax request.
            //if you want yo use variables fro mjava script like clickedval and text val get rid of the " \' " symbols, duh these make them into string literals.
            //add the comment w/o a page reload once we're done (use jquery .prepend)
             echo '$.ajax({

                url: \'http://localhost:8888/cakephp-cakephp-0a6d85c/ajaxrequests/product_page_comment.php\', 
                type: \'POST\',
                data: {\'comment_id\': uuidval, \'model_id\': \''.$model_id.'\', \'user_id\': \''.$userid.'\', \'username\': \''.$current_username.'\', \'text\': textval, \'numberlikes\': \'0\', \'numberdislikes\': \'0\', \'rank\': \'0\', \'true_rank\': \'0\'},

                }).done(function ( ) {
                    
                $("div#comment-field").prepend( "<div class=\"comment\" id=\""+uuidval+"\"><div class=\"username\"><a href=\"/cakephp-cakephp-0a6d85c/profile/index/id:'.$userid.'/username:'.$current_username.'\">'.$current_username.'</a> just now</div>"+textval+"</div>");
                
                }).fail(function ( jqXHR, textStatus, errorThrown ) {
                
                });';

            echo '});';

            echo  '});';

            echo '</script>';

            /*

            <form action=\"/cakephp-cakephp-0a6d85c/product/index/id:53d60b53-a058-420b-bffd-d56ca93f502d/search_value:%40null\" id="comment_delete83998495-4cd5-445a-864e-73d0724e520aIndexForm" onsubmit="event.returnValue = false; return false;" method="post" accept-charset="utf-8"><div style="display:none;"><input type="hidden" name="_method" value="POST"/></div><button type="submit" name="smallx" value="83998495-4cd5-445a-864e-73d0724e520a"></button></form>

            */

            ?>

            </div>

            <?php
            /*textarea for inputting comments*/
            echo $this->Form->create('comment',array('default' => false));
            echo $this->Form->textarea('new_comment',

                array(  'label'=>false, 
                        'onfocus'=>'value=""', 
                        'id' => 'new_comment',
                        'placeholder'=>'Write your comment, then press post comment.',
                    )
            );
            echo $this->Form->end(array('label' => '',  'div' => array('id' => 'comment_submit') ));

            ?>

        <div id="comment-field">
            <?php
            foreach($comments as $comment){

                //if the viewing user is the poster of the comment we printthe little x so a user can delete their comments
                if ($comment['Comment']['user_id'] == $userid){

                    echo $this->Html->div('comment',


                        $this->Html->div('username',

                            $this->Html->link( 
                                $comment['Comment']['username'] , 
                                '/profile/index/id:'. $comment['Comment']['user_id'].'/username:'.$comment['Comment']['username'] 
                            )
                            .
                            ' '
                            .
                            //see cakephp timehelper
                            $this->Time->timeAgoInWords($comment['Comment']['created'], 

                                array('accuracy' => array('month' => 'month', 'hour'=> 'hour', 'day'=>'day', 'week' => 'week')
                                )
                            )
                            .
                            $this->Form->create('comment_delete'.$comment['Comment']['comment_id'], array('default' => false))
                            .
                            $this->Form->button('', 

                                array('label'=>false, 

                                    'type' => 'submit',
                                    'name' => 'smallx' ,
                                    'value' => $comment['Comment']['comment_id']
                                )
                            )
                            .
                            $this->Form->end()

                        )
                        .

                        '' . $comment['Comment']['text'],

                        array('id' => $comment['Comment']['comment_id'])
                    );

                    //comment delete ajax script
                    //There is one for each comment because of a similar issue to the one we had on the main page, 
                    //if you have the same #name in the script it will only recognize clicks on the FIRST button,
                    //by having a script for EACH button with it's own unique ID  #name to search for we remove this problem.
                    echo '<script>';

                    echo '$(document).ready(function(){';

                    // find the comment form and add a submit event handler
                    //ProductIndexForm is the form for comment_submit
                    echo '$(\'#comment_delete'.$comment['Comment']['comment_id'].'IndexForm\').click(function (e) {';

                    //get teh name from the button we clicked to know if user submitted a like or a dislike
                    echo  'clickedval = e.target.value;';

                    // stop the browser from submitting the form
                    echo  'e.preventDefault();';

                    //if the user is not logged in and attempts to like stuff, we will redirect him to the login page.
                    if (!$authUser){
                        
                        echo 'window.location.replace("http://localhost:8888/cakephp-cakephp-0a6d85c/users/login");';
                    }

                    //the request works, it spawns an error message.
                    //it get to success/failure because the url is working now.
                    //here numberlikes, numberdislikes, rank are the likes/dislikes/rank of that comment and not it's parent product/object.
                    //so they all start as zero from this ajax request.
                    //if you want yo use variables fro mjava script like clickedval and text val get rid of the " \' " symbols, duh these make them into string literals.
                    //disappear comments without page reload.
                     echo '$.ajax({

                        url: \'http://localhost:8888/cakephp-cakephp-0a6d85c/ajaxrequests/deletecomment.php\', 
                        type: \'POST\',
                        data: {\'comment_id\': clickedval},

                        }).done(function ( ) {
                            
                        $(\'#'.$comment['Comment']['comment_id'].'\').fadeOut(\'fast\');
                        
                        }).fail(function ( jqXHR, textStatus, errorThrown ) {
                            
                          
                        });';

                    echo '});';

                    echo  '});';

                    echo '</script>';
                }
                //if the comment is not posted by the current viewer then we don't print the smallx for them to delete the comment.
                else{


                    echo $this->Html->div('comment',


                        $this->Html->div('username',

                            $this->Html->link( 
                                $comment['Comment']['username'] , 
                                '/profile/index/id:'. $comment['Comment']['user_id'].'/username:'.$comment['Comment']['username'] 
                            )
                            .
                            ' '
                            .
                            //see cakephp timehelper
                            $this->Time->timeAgoInWords($comment['Comment']['created'], 

                                array('accuracy' => array('month' => 'month', 'hour'=> 'hour', 'day'=>'day', 'week' => 'week')
                                )
                            )

                        )
                        .

                        '' . $comment['Comment']['text']
                    );

                }

            }
		?>
            </div>
	</div>
</div>

<?php 
    
    //be sure to make sure we have the correct jsc3d version number. Check the file in the webroot/js directory 
	echo $this->Html->script('dir3D/3dlifter.js');

	//echo $this->Html->script('jsc3d-full-0.9.8/jsc3d.console.js'); 

	echo '<script type="text/javascript">';
	echo 'var id = "' . $model_id .'";';
	//echo 'var www = "' . $www .'";'; 
    echo 'var number_models = "' . $number_models .'";'; 
    echo 'var model_ext = [];';

    //populate a javascript array with the 
    //extensions for stls and obj
    //print_r($model_ext);
    for ($i=0; $i < $number_models; $i++){

        echo 'model_ext['.$i.'] = "' . $model_ext[$i].'";'; 
    }
    
	echo '</script>';

	echo $this->Html->script('3dview.js'); 
    echo $this->Html->script('3dviewcompleteurl.js'); 

?>


<!--
            <a href="https://twitter.com/rasabox" class="twitter-follow-button" data-show-count="false" data-size="large" data-dnt="true">

    Follow @rasabox
</a>

<script>!function(d,s,id){var js,fjs=d.getElementsByTagName(s)[0],p=/^http:/.test(d.location)?'http':'https';if(!d.getElementById(id)){js=d.createElement(s);js.id=id;js.src=p+'://platform.twitter.com/widgets.js';fjs.parentNode.insertBefore(js,fjs);}}(document, 'script', 'twitter-wjs');
</script>

<div id="fb-root"></div>
<script>(function(d, s, id) {
  var js, fjs = d.getElementsByTagName(s)[0];
  if (d.getElementById(id)) return;
  js = d.createElement(s); js.id = id;
  js.src = "//connect.facebook.net/en_US/all.js#xfbml=1";
  fjs.parentNode.insertBefore(js, fjs);
}(document, 'script', 'facebook-jssdk'));
</script>

<div class="fb-like" data-href="http://www.rasabox.com/" data-width="150" data-layout="standard" data-action="like" data-show-faces="true" data-share="true"></div>

<script src="http://platform.tumblr.com/v1/share.js"></script>


<a href="http://www.tumblr.com/share" class="tumblr-share" title="Share on Tumblr">Share on Tumblr</a>-->