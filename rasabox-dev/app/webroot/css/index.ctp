<?php 
	
	echo $this->Html->css('product'); 

	echo $this->Html->script('jquery-1.7.2.min.js'); 
?>

<div id="page-main">

	<div id="node-field">

		<?php

			//echo 'This is the product page for ' . $model_id . ' this is the product called ' . $title; 

			echo $this->Html->div('product-image',

				$this->Html->image('uploads' . DS . $model_id . '.' . $extension, 

					array('alt' => 'rasabox', 'id' => 'product-image')
				)
			); 
			?>
			<div id="product-viwerdiv">

			<canvas id="product-viewer" ></canvas>
			</div>

			<?php
			
			echo $this->Html->div( null, $description,

					array('id' => 'product-description')

			);

			?>

			<div id="product-sidebar">

			<?php
			echo $this->Html->div( null,

				//$this->Html->link('' , '/img/' . 'models' . DS . $model_id . '.stl'
				//)
				$this->Html->image('/img/download.png' , 

	 					array('alt' => 'rasabox', 

	 						'url' => '/img/' . 'models' . DS . $model_id . '.stl'
	 					)
	 			),

				array('id' => 'download-sidebar')

			);?>

			</div>

			<?php

			if ( ($artistid != $userid) && !$userFollowedAlready ){

			echo $this->Form->create();
			echo $this->Form->button('', 

				array('label'=>false, 

					'type' => 'submit',
					'name ' => 'follow' ,
					'value' => $artistid
				)
			);

			$this->Form->end();
			}

			echo $this->Form->create();
			echo $this->Form->button('', 

				array('label'=>false, 

					'type' => 'submit',
					'name ' => 'add_que' ,
					'value' => $model_id
				)
			);

			$this->Form->end();
			?>

			<div id="list_of_ques">

			<?php
			if ($queflag == 1){

				foreach ($table_que_list as $que) {

					echo $this->Form->create();
					echo $this->Form->button($que[$strip_userid]['quetitle'], 

						array('label'=>false, 

							'type' => 'submit',
							'name ' => 'list_que' ,
							'value' => $que[$strip_userid]['quetitle']
						)
					);
					echo $this->Form->end();
				}
			}

            echo $this->Form->create();
            echo $this->Form->textarea('new_comment',

                array(  'label'=>false, 
                        'onfocus'=>'value=""', 
                        'id' => 'new_comment',
                        'placeholder'=>'Share your thoughts...',
                    )
            );
            echo $this->Form->end('');

            foreach($comments as $comment){

                echo $this->Html->div('comment',


                    $this->Html->div('username',

                        $this->Html->link( $comment['Comment']['username'] , '/profile/index/id:'. $comment['Comment']['user_id'])

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
		?>
		</div>
	</div>
</div>

<?php 

//Here's what's up with this section: it looks simple but it's not.
//USE ABSOLUTE URLS
//Tony Lukasavage

    $u_agent = $_SERVER['HTTP_USER_AGENT']; 
    $bname = 'Unknown';
    $platform = 'Unknown';
    $version= "";

    //First get the platform?
    if (preg_match('/linux/i', $u_agent)) {
        $platform = 'linux';
    }
    elseif (preg_match('/macintosh|mac os x/i', $u_agent)) {
        $platform = 'mac';
    }
    elseif (preg_match('/windows|win32/i', $u_agent)) {
        $platform = 'windows';
    }
    
    // Next get the name of the useragent yes seperately and for good reason
    if(preg_match('/MSIE/i',$u_agent) && !preg_match('/Opera/i',$u_agent)) 
    { 
        $bname = 'Internet Explorer'; 
        $ub = "MSIE"; 
        $www = 'www.'; //FOR MICROSOFT INTERNET EXPLORER (AKA THE SPAWN OF SATAN) NO WWW.
    } 
    elseif(preg_match('/Firefox/i',$u_agent)) 
    { 
        $bname = 'Mozilla Firefox'; 
        $ub = "Firefox";
        $www = ''; 
    } 
    elseif(preg_match('/Chrome/i',$u_agent)) 
    { 
        $bname = 'Google Chrome'; 
        $ub = "Chrome"; 
        $www = ''; //FOR CHROME NO 'WWW.'
    } 
    elseif(preg_match('/Safari/i',$u_agent)) 
    { 
        $bname = 'Apple Safari'; 
        $ub = "Safari"; 
        $www = ''; //FOR SAFARI NO 'WWW.'
    } 
    elseif(preg_match('/Opera/i',$u_agent)) 
    { 
        $bname = 'Opera'; 
        $ub = "Opera"; 
        $www = ''; //FOR OPERA NO WWW.
    } 
    elseif(preg_match('/Netscape/i',$u_agent)) 
    { 
        $bname = 'Netscape'; 
        $ub = "Netscape"; 
        $www = 'www.'; 
    } 
    
    // finally get the correct version number
    $known = array('Version', $ub, 'other');
    $pattern = '#(?<browser>' . join('|', $known) .
    ')[/ ]+(?<version>[0-9.|a-zA-Z.]*)#';
    if (!preg_match_all($pattern, $u_agent, $matches)) {
        // we have no matching number just continue
    }
    
    // see how many we have
    $i = count($matches['browser']);
    if ($i != 1) {
        //we will have two since we are not using 'other' argument yet
        //see if version is before or after the name
        if (strripos($u_agent,"Version") < strripos($u_agent,$ub)){
            $version= $matches['version'][0];
        }
        else {
            $version= $matches['version'][1];
        }
    }
    else {
        $version= $matches['version'][0];
    }
    
    // check if we have a number
    if ($version==null || $version=="") {$version="?";}
    
    //be sure to make sure we have the correct jsc3d version number. Check the file in the webroot/js directory 
	echo $this->Html->script('jsc3d-full-1.4.2/jsc3d.js');

	//echo $this->Html->script('jsc3d-full-0.9.8/jsc3d.console.js'); 

	echo '<script type="text/javascript">';
	echo 'var id = "' . $model_id .'";';
	echo 'var www = "' . $www .'";'; 
	echo '</script>';

	echo $this->Html->script('3dview.js'); 
?>

