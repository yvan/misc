<?php echo $this->Html->css('profile');

?>

<div id="page-main">

	
<?php


echo $this->Html->div(null,

	"Number of People who think ".$profile_username." has good taste: ".$number_followers,

	array(

		'id' => 'number_followers'
	)
);

if ($userid == $passed_id){

	echo ' <br />';

	if($authUser){

		echo $this->Html->div(null,

			$this->Html->image('/img/filemanager.png' , 

				array('alt' => 'Image Error', 

					'url' => '/filemanager/index/id:'. $userid
				)
			),

			array('id' => 'filemanager-link')
		);

		echo $this->Html->div(null,

			$this->Html->image('/img/upload-design.png' , 

				array('alt' => 'Image Error', 

					'url' => '/upload'
				)
			),

			array('id' => 'upload-link')
		);
	}
	else{

		echo $this->Html->div(null,

			$this->Html->image('/img/filemanager.png' , 

				array('alt' => 'Image Error', 

					'url' => '/users/login'
				)
			),

			array('id' => 'filemanager-link')
		);

		echo $this->Html->div(null,

			$this->Html->image('/img/upload-design.png' , 

				array('alt' => 'Image Error', 

					'url' => '/users/login'
				)
			),

			array('id' => 'upload-link')
		);
	}
}

elseif(!$userFollowedAlready){

	//follow someone
	echo $this->Form->create();
	echo $this->Form->button('', 

		array('label'=>false, 

			'type' => 'submit',
			'name ' => 'follow' ,
			'value' => $passed_id
		)
	);
	$this->Form->end();
}

elseif($userFollowedAlready){

	//unfollow someone
	echo $this->Form->create();
	echo $this->Form->button('', 

		array('label'=>false, 

			'type' => 'submit',
			'name ' => 'unfollow' ,
			'value' => $passed_id
		)
	);
	$this->Form->end();

}
?>

<div id="node-field">
<?
foreach ($models_from_que as $model){


	echo $this->Html->div('file_node',

		$this->Html->div('fieldtitle',

		$this->Html->link(

		$model[$quetitle]['model_title'], 

		'/img/' . 'models' . DS . $model[$quetitle]['model_id'] . '.stl', 

		array('class' => 'linkdl')

		)
	)
	.
	$this->Html->image('/img/thumbs' . DS . $model[$quetitle]['model_id']. 'thumb'. '.'. $model[$quetitle]['file_exten'], 

		array('alt' => 'Image Error', 

				'url' => array(

					'controller' => 'product',
				'action' => 'index',
				'id' => $model[$quetitle]['model_id'],
				'exten' => $model[$quetitle]['file_exten'],
				'title' => $model[$quetitle]['model_title'],
				'descrip' => $model[$quetitle]['model_description'],
				'artistid' => $model[$quetitle]['user_id'],
				'likes' => $model[$quetitle]['likes'],
				'dislikes' => $model[$quetitle]['dislikes'],
				'rank' =>	$model[$quetitle]['rank'],
				'true_rank' => $model[$quetitle]['true_rank'],
				'num_pics' => $model[$quetitle]['num_pics'],
				'num_mods' => $model[$quetitle]['num_mods'],
				'file_types' => $model[$quetitle]['file_types'],
				'username' => $model[$quetitle]['user_name'],
				'search_value' => "@null"

				),

			'id' => 'que-node-image'
			)
		) 
	.
	$this->Form->create()
	.
	$this->Form->button('', 

		array('label'=>false, 

			'type' => 'submit',
			'name' => 'smallx' ,
			'value' => 
			$model[$quetitle]['model_id'].$quetitle
		)
	)
	.
	$this->Form->end()
 	);
	
}

?>

	</div>
</div>