<?php
/**
 *
 * PHP 5
 *
 * CakePHP(tm) : Rapid Development Framework (http://cakephp.org)
 * Copyright 2005-2012, Cake Software Foundation, Inc. (http://cakefoundation.org)
 *
 * Licensed under The MIT License
 * Redistributions of files must retain the above copyright notice.
 *
 * @copyright     Copyright 2005-2012, Cake Software Foundation, Inc. (http://cakefoundation.org)
 * @link          http://cakephp.org CakePHP(tm) Project
 * @package       Cake.View.Layouts
 * @since         CakePHP(tm) v 0.10.0.1076
 * @license       MIT License (http://www.opensource.org/licenses/mit-license.php)
 */

$siteDescription = ('Art, Content, Creators, Innovation, Design, Creativity');
$siteMotto = ('rasabox');
//start out session for this user (whether logged in or not)
//will this conflcit with php login stuff? hopefully not.
session_start();

//record the url if we're no logged in to pass to usercontroller
if (!$authUser){

	//DO NOT COMMENT OUT THE LINE BELOW. IT DECLARES CURRENT_URL if you delete
	//it breaks the whole redirect system.
	$current_url = str_replace("/cakephp-cakephp-0a6d85c/", "", $this->here);

	if ( !(( $current_url == 'users/login') || ($current_url == 'users/add')) ){

		$_SESSION['Login']['redirect_url'] = $this->here;
		//print_r($current_url."\n");
		//print_r($this->here);
	}
}
?>

<!DOCTYPE html>

<html>
<head>

	<?php echo $this->Html->charset(); 
		  echo $this->Html->meta(
    				
    			'description',
    			$siteDescription
    	  );
    ?>
    
	<title>
		<?php echo $siteMotto;?>

	</title>

	<?php
		echo $this->Html->meta('icon');
		echo $this->fetch('meta');
		echo $this->fetch('css');
		echo $this->fetch('script');
	?>
	<?php 

	echo $this->Html->css('default-page');

	echo $this->Html->css('font'); 
?>

</head>
<body>
	<div id="container">
		<div id="header-main">

	<div id="logo">

  		<?php 

  		echo $this->Html->image('lobsterlogo.png', array('alt' => 'rasabox' , 'url' => '/main/index/search:@null'));

		?> 

	</div>



	<div id="logout" class="link">

		<?php 

		if ($authUser){

			echo $this->Html->image(
  			
  				'Lobster-logout.png', 

  				array('alt' => 'rasabox', 'url' => '/users/logout')
  			);
		}
		else{

			echo $this->Html->image(
  			
  				'Lobster-login.png', 

  				array('alt' => 'rasabox', 'url' => '/users/login')
  			);

		}

		?> 
	
	</div>

	<div id="profile" class="link">

		<?php 

		//if the user is logged in send them to their own profile
		if ($authUser){

			echo $this->Html->image(
  			
  				'LobsterProfile.png', 

  				array('alt' => 'Profile', 'url' => '/profile/index/id:'. $userid .'/username:'. $current_username)
  			);
		}
		else{
			
			echo $this->Html->image(
  			
  				'LobsterProfile.png', 

  				array('alt' => 'Profile', 'url' => '/users/login')
  			);
		}

		?> 
	
	</div>

	<div id="about" class="link">

		<?php 

  		echo $this->Html->image(
  			
  			'LobsterAbout.png', 

  			array('alt' => 'About', 'url' => '/about')
  		);

		?> 
	
	</div>
	
	
	<div id="ideabox" class="link">
		
		<?php 

  		echo $this->Html->image('LobsterBazar.png', array('alt' => 'Bazar', 'url' => '/bazar'));

		?> 
	</div>	

	<div id="search-main">
	<?php

		if($search_value_tolayout == "@null"){

			$search_replace_value = "";
		}
		else{

			$search_replace_value = $search_value_tolayout;
		}

		echo $this->Form->create();
		echo $this->Form->input('search',

			array(	'label'=>false, 
					'placeholder'=>'Search for 3D files to print!',
					'value' => $search_replace_value
					//'onfocus'=>'value=""'
			)
			);
		echo $this->Form->end();
	?>
	</div>
</div>

		<div id="content">

			<?php echo $this->Session->flash(); ?>
			<?php echo $this->fetch('content'); ?>
		</div>
		<div id="footer"></div>
	</div>
	
	<?php echo $this->element('sql_dump'); ?>
</body>
</html>
