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
 * @package       Cake.View.Emails.html
 * @since         CakePHP(tm) v 0.10.0.1076
 * @license       MIT License (http://www.opensource.org/licenses/mit-license.php)
 */
?>

<div style="width:900px; height: 200px; background-color: #000000;">

<div style="height:20px;">

</div>

<div style="margin-left: 20px; ">
<?php 
	echo $this->Html->image('http://rasabox.com/one/rasaboxlogo-signup.png', array('alt' => 'rasabox', 'url' => 'http://rasabox.com')); 
?>
</div>
<?php

$content = explode("\n", $content);
?>
<div style="font-family: Helvetica; color: white; margin-left: 20px;">

<?php
foreach ($content as $line):
	echo '<p> ' . $line . "</p>\n";
endforeach;

?>

Thanks,

Rasabox Team

</div>