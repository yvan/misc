<?php echo $this->Html->css('confirm'); ?>

<div id="page-main">

	<div id="logo-big">
		
	</div>

	<?php
		echo $this->Form->create();
		echo $this->Form->button('', 
                        
	        array('label'=>false, 

	            'type' => 'submit',
	            'name' => 'submit' 
	        )
    	);

		echo $this->Form->end();
	?>

	<div id="background-confirm"></div>

</div>