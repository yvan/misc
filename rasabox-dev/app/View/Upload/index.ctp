<?php 

echo $this->Html->css('upload'); 

?>
<div id="page-main">

	<?php
		foreach ($this->validationErrors['Upload'] as $validationError) {

			$error_count++;

			echo $this->Html->div('error-message-yvancustom', $validationError['0'], array('id'=>'error-message-yvancustom-'.$error_count));
		}
	?>

	<div id="node-field">
<?php

echo $this->Form->create('Upload', array('type' => 'file'));
echo $this->Form->input('Upload.title', array('label'=>false, 'placeholder' => 'Title', 'required'=>'false'));
echo $this->Form->input('Upload.description', array('label'=>false, 'placeholder' => 'Description', 'required'=>'false'));
echo $this->Form->input('Upload.submittedpicture.', 

		array('type' => 'file', 'multiple', 'required'=>'false', 'label'=>'Choose Pictures:  ',

			'div' => array(

        		'class' => 'input file submitpicture',
    		)
   		)
	);

echo $this->Form->input('Upload.submittedmodelfile.', 

		array('type' => 'file', 'multiple','required'=>'false', 'label'=>'Choose Stl or Obj Files:  ', 

			'div' => array(

        		'class' => 'input file submitmodel',
    		)
		)
	);
echo $this->Form->input('Upload.licensevalue',

	array(

		'label' => 'Choose your license: ',
		'options' => array(

			'Share-alike (SA)',
			'Attribution (BY)',
			'Non-commercial (NC)',
			'No Derivative Works (ND)'
		),
		'required' => 'false',
		'div' => array(

			'class' => 'input submitlicense'
		)
	)

);

echo $this->Form->end('');

echo $this->Html->div('upload-submits',


	$this->Html->image('profile-return.png', 

		array(
			
			'alt' => 'Profile Return Error' , 


			'url' => array(

		 		'controller' => 'profile',
				'action' => 'index',
				'id' => $userid,
				'username' => $username
			)
		)), 

	array('id'=> 'upload-return')
);

?>
	</div>
</div>