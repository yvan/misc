<?php

	echo $this->Html->css('users');

	echo $this->Form->create();
	echo $this->Form->input('username', array('label'=>false , 'placeholder'=>'Username', 'required'=>'false'));
	echo $this->Form->input('password', array('label'=>false , 'placeholder'=>'Password', 'required'=>'false'));
	echo $this->Form->end('');
?>
<div id="add-user" class="link">

<?php 

  		echo $this->Html->image(
  			
  			'new-account.png', 

  			array('alt' => 'rasabox', 'url' => '/users/add')
  		);

?>

</div>

<?php 

	echo $this->Html->div( null, 

            'Enter your login info here and press "Ok" to login or press "New Account" to go make a new account.',

			array('id' => 'login-dialogue-1')
	);

	//SEE #2 in DOCUMENTATION
	$error_count = 0;
	//print_r($this->validationErrors);
	foreach ($this->validationErrors['User'] as $validationError) {

		$error_count++;
		echo $this->Html->div('error-message-yvancustom', $validationError['0'], array('id'=>'error-message-yvancustom-'.$error_count));
	}

?>

