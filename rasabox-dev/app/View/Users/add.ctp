<?php

	echo $this->Html->css('users');

	echo $this->Form->create();
	echo $this->Form->input('username' , array('label'=>false , 'placeholder'=>'Username', 'required'=>'false'));
	echo $this->Form->input('password' , array('label'=>false , 'placeholder'=>'Password', 'required'=>'false'));
	echo $this->Form->end('');
?>

<div id="return-to-login" class="link">

<?php 

  		echo $this->Html->image(
  			
  			'return-to-login.png', 

  			array('alt' => 'rasabox', 'url' => '/users/login')
  		);

?>

</div>

<?php
	echo $this->Html->div( null, 

        'Enter your new account username and password and then press "Ok" to make an account. We\'ll take you back to the login page.',

		array('id' => 'login-dialogue-2')
	);

	//SEE #2 in DOCUMENTATION
	$error_count = 0;

	foreach ($this->validationErrors['User'] as $validationError) {

		$error_count++;

		echo $this->Html->div('error-message-yvancustom', $validationError['0'], array('id'=>'error-message-yvancustom-'.$error_count));
	}
	
?>