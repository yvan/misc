<?php 

class UploadController extends AppController{

  function beforeFilter(){

    parent::beforeFilter();
    $userid = $this->Auth->user('id');
    $username = $this->Auth->user('username');
    $strip_userid = str_replace("-", "", $userid);
    $this->set('userid', $userid);
    $this->set('username', $username);
    $this->set('current_username', $username);
  }

  //we only have 11 spaces in the int in our table so we should limit # of pictures to 10 or 11.
	public function index(){ 
    
    $this->set('accesserid', $this->Auth->user('id'));
    $filepictures = $this->request->data['Upload']['submittedpicture'];
    $filemodels = $this->request->data['Upload']['submittedmodelfile'];
    //print_r($filepictures);
    $index = 0;
    $count_filepictures = 0;
    $count_filemodels = 0;
    $picture_index = 0;
    $allFilesUploaded = false;
    $id = String::uuid();

    /*What I'm gonna do for the next section, and this is redundant and will increase uplaod times
    but fuck it, I'm tired and we need a working prototype.

    BAsically we cylce through all filemodels and if our file model index is higher than our picture count 
    (we have more models than pictures) we just dump all excess pictures into the picture file id-0 which
    is currently unused as the id sequencing goes id, id-1, id-2, etc.

    We then cycle through all the filepictures and fill in any missing model files into the id-0 dummy slot for models.
    we measure when the index of the pictures is in excess of the index of the models. This solution will probably double upload times.

    Eventually we should make 2 separate methods: 1 for uploading models, 1 for uploading images, and then just upload the models/images
    separately.

    */

    //here index is the index for mthe models
    //here picture_index is index for the uploaded pictures.
    foreach ($filemodels as $filemodel) {

      if ($index==0){

        $index = '';
      }

      $count_filemodels++;

      if ($this->uploadFiles($filemodel, $index, $count_filemodels, $id)){
    
        $allFilesUploaded = true; 

      }
      else{

        $allFilesUploaded = false;
        //$this->redirect('/dragon-ate.ctp')
      }

      if ($index == ''){

        $index = 0;
      }

      
      $index = '-'.$count_filemodels;
    }

    //here index is the index for the pictures.
    //here model_index is the index for the models
    $index = 0;

    foreach ($filepictures as $filepicture) {

      if ($index==0){

        $index = '';
      }

      if ($returnval = $this->uploadPictures($filepicture, $index, $id) ){
          
        //stores the first picture's extension.
        if ($count_filepictures  == 0){

          $file_exten_of_first_pic = $returnval;

        }

        $allFilesUploaded = true; 
        //resizes normal image to dimensions fo width 210 height 260 0 means not in thumbnail folder buti n uploads folder
        $this->resizeImage($this->request->data['Upload']['id'], 210, 260, 0, $index);
        //resizes for thumbnail width/height 100 1 means it goes in the thumnail folder
        $this->resizeImage($this->request->data['Upload']['id'], 100, 100, 1, $index);
      }
      else{

        $allFilesUploaded = false;
        //$this->redirect('/dragon-ate.ctp')
      }

      if ($index == ''){

        $index = 0;
      }

      $count_filepictures++;
      $index = '-'.$count_filepictures;
    }


    $dash = '';
    $zip = new ZipArchive();
    $zip->open(APP . 'webroot' . DS . 'img'. DS . 'models' . DS .$id.'-zip.zip', ZipArchive::CREATE);

    for ($i=0; $i<$count_filemodels; $i++){

      if ($i==0){

        $i = '';
        $dash = '';
      }

      //if our uploaded file is stl and exists, make a zip from that stl
      if(file_exists(APP .'webroot' . DS . 'img'. DS . 'models' . DS .$id.$dash.$i.'.stl')){

        $zip->addFile(APP . 'webroot' . DS . 'img'. DS . 'models' . DS .$id.$dash.$i.'.stl', 'model'.$dash.$i.'.stl');
      }
      //if our uploaded file is obj and exists make a zip from that obj
      else if(file_exists(APP .'webroot' . DS . 'img'. DS . 'models' . DS .$id.$dash.$i.'.obj') ){

        $zip->addFile(APP . 'webroot' . DS . 'img'. DS . 'models' . DS .$id.$dash.$i.'.obj', 'model'.$dash.$i.'.obj');
      }
      else{

        //INSERT ERROR MESSAGE HERE
      }

      if ($i == ''){

        $i = 0;
        $dash = '-';
      }
    }

    $zip->close();

    if($allFilesUploaded && $this->request->is('post')){
      
      //print_r(''.$this->Upload->save($this->request->data));
      //print_r($this->request->data);

      /*$var = $this->Upload->invalidFields();
      debug($var);
      die();*/

      //$id2 = String::uuid();

      //$strip_id2= str_replace("-", "", $id2);

      //THESE NEXT TWO QUERIES UPDATE AND / OR CREATE THE LIST WHICH EVERYONE LINKS TO WHEN THEY FOLLOW SOMEONE
      //AND EVERYONE WILL SEE ON THAT USER's PROFILE
      // IT IS A LIST OF ALL THEIR UPLOADS.
      $userid = $this->Auth->user('id');  
      $strip_userid = str_replace("-", "", $userid);

      //this is the list of al lthe stuff someone has uploaded.
      $this->Upload->query(

      "CREATE TABLE IF NOT EXISTS `". $strip_userid ."self"."`
      (`model_title` char(50), 
      `model_size` char(50),
      `model_id` char(36), 
      `user_id` char(36),
      `user_name` varchar(45),
      `file_exten` char(10),
      `model_description` text,
      `likes` int(11),
      `dislikes` int(11),
      `rank` int(11),
      `true_rank` float,
      `num_pics` int(11),
      `num_mods` int(11),
      `file_types` int(11),
      `created` datetime,
      `modified` datetime);"

      );

      //this is the table that we will use to track likes and see if a user has liked a thing already,
      //each uploaded model gets a table that does this.
      //the point being to color in a like or dislike button orange or blue depending on wether a user
      //has liked it.
      $this->Upload->query(

      "CREATE TABLE IF NOT EXISTS `".$id."liketable"."`
      (`number` int(11) NOT NULL AUTO_INCREMENT,
      `user_id` char(36) NOT NULL,
      `like_flag` int(11) NOT NULL,
      `created` datetime,
      `modified` datetime,
      PRIMARY KEY (`number`));"

      );

      //NOTE THE EXTENSION FIELD IS JSUT THE EXTENSION OF THE FIRST PICTURE A REMNANY OF WHEN WE COULD ONLY UPLOAD ONE IMAGE,
      //NOW we are using the file types array i think to print out all the extensions.
      //or it could the 0th one in which case it's still important, we will see. Will leave as ".jpg" for now
      //TURNS OUT IT"S IMPORTANT. 
      //i store the first exten now and keep it in the table
      $this->Upload->query(

        "INSERT INTO `".$strip_userid."self"."` (`model_title`, `model_size`, `model_id`, `user_id`, `user_name`, `file_exten`, `model_description`, `likes`, `dislikes`, `rank`, `true_rank`, `num_pics`, `num_mods`, `file_types`, `created`, `modified`)
        VALUES ('".str_replace("'", "''", $this->request->data['Upload']['title'])."', '0', '".$this->request->data['Upload']['id']."', '". $this->request->data['Upload']['user_id']."','".$this->request->data['Upload']['username']."','".$file_exten_of_first_pic."','".str_replace("/", "&sect;", str_replace("'", "''", $this->request->data['Upload']['description']))."','0','0','0','0','". $count_filepictures."','".$count_filemodels."','".$this->request->data['Upload']['file_types']."','".date("Y-m-d H:i:s")."','".date("Y-m-d H:i:s")."');"
      );
      
      $this->request->data = Sanitize::clean($this->request->data);

      if($this->Upload->save($this->request->data)){

        $this->redirect('/main/index/search:@null');
      } 
    }

    if ($this->request->is('post')){

      //with submissions on the search bar we need to be careful that it does not conflict with other post
      //requests that are coming in.
      if ($this->request->data['Upload']['search']){

        $this->redirect('/main/index/search:'.$this->request->data['Upload']['search']);
      }

      //SEE #2 in DOCUMENTATION
      //set the data from the form (we need ot do this when we aren't saving it)
      $this->Upload->set($this->data);
      //validate the data (run it through $validate in user.php) without saving it.
      $this->Upload->validates();
    }
	}


  function uploadPictures($filepicture, $picture_index, $id){

    $userid = $this->Auth->user('id');
    $username = $this->Auth->user('username');

    //printf($filepicture['error'] === UPLOAD_ERR_OK);
    //printf($filemodel['error'] === UPLOAD_ERR_OK);
    if ( ($filepicture['error'] === UPLOAD_ERR_OK) ) {

      $filenamePicture = $filepicture['name'];

      $file_ext_pic = substr($filenamePicture, strrpos($filenamePicture, ".") + 1);
      $file_ext_pic = strtolower($file_ext_pic);

      //under the 'file_types' table entry 1 is for jpg, 2 is for gif, 3 is for png, 4 is for jpeg
      if($file_ext_pic == 'jpg'){

        $ext = 1;
      }
      else if ($file_ext_pic == 'gif'){

        $ext = 2;
      }
      else if ($file_ext_pic == 'png'){

        $ext = 3;
      }
      else if ($file_ext_pic == 'jpeg'){

        $ext = 4; 
      }
      else{

        $ext=0;
      }
      //print_r($index);
      //print_r("FIRST: ".move_uploaded_file($filepicture['tmp_name'], APP . DS . 'webroot' . DS . 'img'. DS . 'uploads' . DS . $id . $index . '.' . $file_ext_pic));
      //print_r("SECODN: ". copy(APP . DS . 'webroot' . DS . 'img'. DS . 'uploads' . DS . $id . '.' . $file_ext_pic, APP . DS . 'webroot' . DS . 'img'. DS . 'thumbs' . DS . $id . 'thumb' .$index . '.' . $file_ext_pic));
      //print_r("THIRD: ". move_uploaded_file($filemodel['tmp_name'], APP . DS . 'webroot' . DS . 'img'. DS . 'models' . DS . $id . $index .'.' . $file_ext_mod));
       //path needs to be altered to fit the path on the server
        if (

        //path on the server.
        //move_uploaded_file($filepicture['tmp_name'], DS . 'home' . DS . 'rasabox' . DS . 'public_html' . DS . 'img'. DS . 'uploads' . DS . $id . '.' . $file_ext_pic)
        move_uploaded_file($filepicture['tmp_name'], APP . DS . 'webroot' . DS . 'img'. DS . 'uploads' . DS . $id . $picture_index . '.' . $file_ext_pic)

        && 

        //path on server
        //copy( DS . 'home' . DS . 'rasabox' . DS . 'public_html' . DS . 'img'. DS . 'uploads' . DS . $id . '.' . $file_ext_pic,  DS . 'home' . DS . 'rasabox' . DS . 'public_html' . DS . 'img'. DS . 'thumbs' . DS . $id . 'thumb' . '.' . $file_ext_pic)
        copy(APP . DS . 'webroot' . DS . 'img'. DS . 'uploads' . DS . $id . $picture_index . '.' . $file_ext_pic, APP . DS . 'webroot' . DS . 'img'. DS . 'thumbs' . DS . $id . 'thumb' . $picture_index .'.' . $file_ext_pic)

        //&&
        //path on the server
        //move_uploaded_file($filemodel['tmp_name'], DS . 'home' . DS . 'rasabox' . DS . 'public_html' . DS . 'img'. DS . 'models' . DS . $id . '.' . $file_ext_mod)
        //move_uploaded_file($filemodel['tmp_name'], APP . DS . 'webroot' . DS . 'img'. DS . 'models' . DS . $id . $index .'.' . $file_ext_mod)

        ) {

          $this->request->data['Upload']['id'] = $id; //$id is a unique id created for the upload iteself
          $this->request->data['Upload']['main_id'] = $id;
          $this->request->data['Upload']['product_id'] = $id;
          $this->request->data['Upload']['profile_id'] = $userid;
          $this->request->data['Upload']['likes'] = 0;
          $this->request->data['Upload']['dislikes'] = 0;
          $this->request->data['Upload']['rank'] = 0;
          $this->request->data['Upload']['true_rank'] = 0;
          $this->request->data['Upload']['user_id'] = $userid;//$userid the uploader's id
          $this->request->data['Upload']['filemanager_id'] = $userid;
          $this->request->data['Upload']['username'] = $username;
          //$this->request->data['Upload']['description'] = str_replace("/", "&sect;", $this->request->data['Upload']['description']);
          //a number that tells us which file is of which type.
          // 1242 would be 1 jpg where we see a 1
          // 1 png where we see 2 (second file)
          // 1 gif where we see 4 (3rd file)
          //1 png where we see 2 (4th file)
          $this->request->data['Upload']['file_types'] = $this->request->data['Upload']['file_types']*10 + $ext;
          $this->request->data['Upload']['picturename'] = $filepicture['name'];
          $this->request->data['Upload']['picturesize'] = $filepicture['size'];
          $this->request->data['Upload']['picturemime'] = $filepicture['type'];
          return $file_ext_pic;
        }
    }
    return false;
  }

	function uploadFiles($filemodel, $index, $count_filemodels, $id) {

    $userid = $this->Auth->user('id');
    $username = $this->Auth->user('username');

  	if ( ($filemodel['error'] === UPLOAD_ERR_OK) ) {

      $filenameModel = $filemodel['name'];

      $file_ext_mod = substr($filenameModel, strrpos($filenameModel, ".") + 1);
      $file_ext_mod = strtolower($file_ext_mod);

      if($file_ext_mod == 'stl'){

        $ext = 1;
      }
      else if ($file_ext_mod == 'obj'){

        $ext = 2;
      }
      else{

        $ext=0;
      }

       //path needs to be altered to fit the path on the server
    		if (

        move_uploaded_file($filemodel['tmp_name'], APP . DS . 'webroot' . DS . 'img'. DS . 'models' . DS . $id . $index .'.' . $file_ext_mod)

        ) {

      		$this->request->data['Upload']['id'] = $id; //$id is a unique id created for the upload iteself
          $this->request->data['Upload']['main_id'] = $id;
          $this->request->data['Upload']['product_id'] = $id;
          $this->request->data['Upload']['profile_id'] = $userid;
          $this->request->data['Upload']['likes'] = 0;
          $this->request->data['Upload']['dislikes'] = 0;
          $this->request->data['Upload']['rank'] = 0;
          $this->request->data['Upload']['true_rank'] = 0;
      		$this->request->data['Upload']['user_id'] = $userid;//$userid the uploader's id
          $this->request->data['Upload']['filemanager_id'] = $userid;
          $this->request->data['Upload']['username'] = $username;
          //$this->request->data['Upload']['description'] = str_replace("/", "&sect;", $this->request->data['Upload']['description']);
      		$this->request->data['Upload']['filename'] = $filemodel['name'];
      		$this->request->data['Upload']['filesize'] = $filemodel['size'];
          $this->request->data['Upload']['number_stls'] = $count_filemodels;
          $this->request->data['Upload']['model_types'] = $this->request->data['Upload']['model_types']*10 + $ext; //a string of 1s and 2 telling us which models are stl or obj
      		$this->request->data['Upload']['filemime'] = $filemodel['type'];
      		return true;
   			}
  	}
    return false;
  } 	

  //W262  H209
  function resizeImage($filename, $newHeight, $newWidth, $thumb_bool, $picture_index){

    $name_for_ext = $this->request->data['Upload']['picturename'];
    $file_ext = substr($name_for_ext, strrpos($name_for_ext, ".") + 1);
    $file_ext = strtolower($file_ext);
    //Server FP
    //$filepath =  DS . 'home' . DS . 'rasabox' . DS . 'public_html' . DS . 'img'. DS . 'uploads' . DS . $filename . '.' . $file_ext;
    $filepath = APP . DS . 'webroot' . DS . 'img'. DS . 'uploads' . DS . $filename . $picture_index . '.' . $file_ext;
    //$filepath =  DS . 'home' . DS . 'rasabox' . DS . 'public_html' . DS . 'img'. DS . 'thumbs' . DS . $filename .'thumb' . '.' . $file_ext;
    $filepath_thumb = APP . DS . 'webroot' . DS . 'img'. DS . 'thumbs' . DS . $filename . 'thumb' . $picture_index . '.' . $file_ext;
    $oldHeight= $this->getHeight($filepath);
    $oldWidth = $this->getWidth($filepath);

    //under the 'file_types' table entry 1 is for jpg, 
    //2 is for gif, 3 is for png, 4 is for jpeg
    //MAKE SURE EACH SAYS $file_ext 
    //and not $file_ext_pic
    if($file_ext == 'jpg'){

      $ext = 1;
    }
    else if ($file_ext == 'gif'){

      $ext = 2;
    }
    else if ($file_ext == 'png'){

      $ext = 3;
    }
    else if ($file_ext == 'jpeg'){

      $ext = 4; 
    }
    else{

      $ext=0;
    }

    switch ($ext){
      
      case 1;
        if ($thumb_bool){

          $source = imagecreatefromjpeg($filepath_thumb);
        }
        else{

          $source = imagecreatefromjpeg($filepath);
        }
        
        break;

      case 2;
        if ($thumb_bool){

          $source = imagecreatefromgif($filepath_thumb);
        }
        else{

          $source = imagecreatefromgif($filepath);
        }
        
        break;

      case 3;
        if ($thumb_bool){

          $source = imagecreatefrompng($filepath_thumb);
        }
        else{

          $source = imagecreatefrompng($filepath);
        }
        
        break;

      case 4;
        if ($thumb_bool){

          $source = imagecreatefromjpeg($filepath_thumb);
        }
        else{

          $source = imagecreatefromjpeg($filepath);
        }
        
        break;
    }

    $newImage = imagecreatetruecolor($newWidth, $newHeight);
    $bgcolor = imagecolorallocate($newImage, 255, 255, 255);
    imagefill($newImage, 0, 0, $bgcolor); //makes background white

    if($oldHeight<$oldWidth){

      $newImageHeight = $newHeight;/*210*/
      $newImageWidth = ceil(($newImageHeight*$oldWidth)/$oldHeight); /*210*/
      imagecopyresampled($newImage,$source,-ceil(($newImageWidth-$newWidth)/2),0,0,0,$newImageWidth,$newImageHeight,$oldWidth,$oldHeight);/*260*/
    }

    else{

      $newImageWidth = $newWidth; /*260*/
      $newImageHeight = ceil(($newImageWidth*$oldHeight)/$oldWidth);/*260*/
      imagecopyresampled($newImage,$source,0,-ceil(($newImageHeight-$newHeight)/2),0,0,$newImageWidth,$newImageHeight,$oldWidth,$oldHeight);/*210*/
    }

    //we save the image as wtvr extension the old image will be replaced
    //if its not a thumbnail save it into our standard path 
    if ($thumb_bool == 0){

      imagejpeg($newImage, $filepath, 90);
      return $filepath;
    }
    //if its a thumbnail save it into our special thumbnail folder
    else {

      imagejpeg($newImage, $filepath_thumb, 90);
      return $filepath_thumb;
    } 
  }

  function getHeight($image){

      $sizes = getimagesize($image);
      $height = $sizes[1];
      return $height;
  }

  function getWidth($image){

      $sizes = getimagesize($image);
      $width = $sizes[0];
      return $width;
  }
}

?>