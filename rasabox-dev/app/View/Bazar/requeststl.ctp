<?php
	
	echo $this->Html->css('requeststl');

?>

<div id="page-main">

	<div id="node-field">

	<?php

	echo $this->Html->div('bazar-submits',


		$this->Html->image('bazar-return.png', array('alt' => 'Image Error' , 'url' => '/bazar')), 

		array('id'=> 'bazar-return')
	);


    echo $this->Form->create();
    echo $this->Form->textarea('description',

        array(  'label'=>false, 
                'onfocus'=>'value=""', 
                'placeholder'=>'Request a model from the community...',
            )
    );
    echo $this->Form->input('title', array('label'=>false, 'placeholder' => 'Title'));
    echo $this->Form->end('');

    //SEE #2 in DOCUMENTATION
	$error_count = 0;

	foreach ($this->validationErrors['Bazar'] as $validationError) {

		$error_count++;

		echo $this->Html->div('error-message-yvancustom', $validationError['0'], array('id'=>'error-message-yvancustom-'.$error_count));
	}

	?>

	</div>
</div>