<?php echo $this->Html->css('home'); ?>

<div id="page-main">

	<div id="logo-big">

  		<?php echo $this->Html->image('rasaboxlogo-signup.png', array('alt' => 'rasabox', 'url' => 'http://rasabox.com'));

		?> 
		
	</div>

	<?php
		echo $this->Form->create();
		echo $this->Form->input('email', array('label'=>false, 'placeholder'=>'Email'));
		echo $this->Form->end('');
	?>

	<div id="background"></div>

	<div id="about-image"></div>

	<div id="splash"></div>

</div>

