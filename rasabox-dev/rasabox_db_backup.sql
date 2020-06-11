-- phpMyAdmin SQL Dump
-- version 4.1.12
-- http://www.phpmyadmin.net
--
-- Host: localhost:8889
-- Generation Time: Jul 27, 2014 at 04:35 AM
-- Server version: 5.5.34
-- PHP Version: 5.5.10

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET time_zone = "+00:00";

--
-- Database: `cakeBasicTutorial`
--

-- --------------------------------------------------------

--
-- Table structure for table `53b1df549bc047d99a5a6fafa93f502d`
--

CREATE TABLE `53b1df549bc047d99a5a6fafa93f502d` (
  `number` int(11) NOT NULL AUTO_INCREMENT,
  `quetitle` char(50) DEFAULT NULL,
  `quesize` char(50) DEFAULT NULL,
  `que_follow_flag` int(1) DEFAULT NULL,
  `followed_user_id` char(36) DEFAULT NULL,
  `created` datetime DEFAULT NULL,
  `modified` datetime DEFAULT NULL,
  PRIMARY KEY (`number`)
) ENGINE=InnoDB  DEFAULT CHARSET=latin1 AUTO_INCREMENT=19 ;

--
-- Dumping data for table `53b1df549bc047d99a5a6fafa93f502d`
--

INSERT INTO `53b1df549bc047d99a5a6fafa93f502d` (`number`, `quetitle`, `quesize`, `que_follow_flag`, `followed_user_id`, `created`, `modified`) VALUES
(13, 'crazy ha test', '0', 0, '0', '2014-07-22 03:29:20', '2014-07-22 03:29:20'),
(16, 'kkkkkk', '0', 0, '0', '2014-07-22 03:36:42', '2014-07-22 03:36:42'),
(18, '53b197c2cd244d309e4a6878a93f502dself', '0', 1, '53b197c2-cd24-4d30-9e4a-6878a93f502d', '2014-07-22 03:50:31', '2014-07-22 03:50:31');

-- --------------------------------------------------------

--
-- Table structure for table `53b1df549bc047d99a5a6fafa93f502dcrazy ha test`
--

CREATE TABLE `53b1df549bc047d99a5a6fafa93f502dcrazy ha test` (
  `model_title` char(50) DEFAULT NULL,
  `model_size` char(50) DEFAULT NULL,
  `model_id` char(36) DEFAULT NULL,
  `user_id` char(36) DEFAULT NULL,
  `user_name` varchar(45) DEFAULT NULL,
  `file_exten` char(10) DEFAULT NULL,
  `model_description` text,
  `likes` int(11) DEFAULT NULL,
  `dislikes` int(11) DEFAULT NULL,
  `rank` int(11) DEFAULT NULL,
  `true_rank` float DEFAULT NULL,
  `num_pics` int(11) DEFAULT NULL,
  `num_mods` int(11) DEFAULT NULL,
  `file_types` int(11) DEFAULT NULL,
  `created` datetime DEFAULT NULL,
  `modified` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `53b1df549bc047d99a5a6fafa93f502dcrazy ha test`
--

INSERT INTO `53b1df549bc047d99a5a6fafa93f502dcrazy ha test` (`model_title`, `model_size`, `model_id`, `user_id`, `user_name`, `file_exten`, `model_description`, `likes`, `dislikes`, `rank`, `true_rank`, `num_pics`, `num_mods`, `file_types`, `created`, `modified`) VALUES
('selftest', '0', '53b19a8f-9d78-4ded-9d7f-66bfa93f502d', '53b197c2-cd24-4d30-9e4a-6878a93f502d', 'yvanscher', 'jpg', 'selftest', 12, 0, 1, 0, 1, 1, 1, '2014-07-22 03:30:07', '2014-07-22 03:30:07'),
('selftest', '0', '53b19a8f-9d78-4ded-9d7f-66bfa93f502d', '53b197c2-cd24-4d30-9e4a-6878a93f502d', 'yvanscher', 'jpg', 'selftest', 12, 0, 1, 0, 1, 1, 1, '2014-07-22 04:04:10', '2014-07-22 04:04:10');

-- --------------------------------------------------------

--
-- Table structure for table `53b1df549bc047d99a5a6fafa93f502dkkkkkk`
--

CREATE TABLE `53b1df549bc047d99a5a6fafa93f502dkkkkkk` (
  `model_title` char(50) DEFAULT NULL,
  `model_size` char(50) DEFAULT NULL,
  `model_id` char(36) DEFAULT NULL,
  `user_id` char(36) DEFAULT NULL,
  `user_name` varchar(45) DEFAULT NULL,
  `file_exten` char(10) DEFAULT NULL,
  `model_description` text,
  `likes` int(11) DEFAULT NULL,
  `dislikes` int(11) DEFAULT NULL,
  `rank` int(11) DEFAULT NULL,
  `true_rank` float DEFAULT NULL,
  `num_pics` int(11) DEFAULT NULL,
  `num_mods` int(11) DEFAULT NULL,
  `file_types` int(11) DEFAULT NULL,
  `created` datetime DEFAULT NULL,
  `modified` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `53b1df549bc047d99a5a6fafa93f502dkkkkkk`
--

INSERT INTO `53b1df549bc047d99a5a6fafa93f502dkkkkkk` (`model_title`, `model_size`, `model_id`, `user_id`, `user_name`, `file_exten`, `model_description`, `likes`, `dislikes`, `rank`, `true_rank`, `num_pics`, `num_mods`, `file_types`, `created`, `modified`) VALUES
('selftest', '0', '53b19a8f-9d78-4ded-9d7f-66bfa93f502d', '53b197c2-cd24-4d30-9e4a-6878a93f502d', 'yvanscher', 'jpg', 'selftest', 12, 0, 1, 0, 1, 1, 1, '2014-07-22 04:04:10', '2014-07-22 04:04:10');

-- --------------------------------------------------------

--
-- Table structure for table `53b1df549bc047d99a5a6fafa93f502dself`
--

CREATE TABLE `53b1df549bc047d99a5a6fafa93f502dself` (
  `model_title` char(50) DEFAULT NULL,
  `model_size` char(50) DEFAULT NULL,
  `model_id` char(36) DEFAULT NULL,
  `user_id` char(36) DEFAULT NULL,
  `user_name` varchar(45) DEFAULT NULL,
  `file_exten` char(10) DEFAULT NULL,
  `model_description` text,
  `likes` int(11) DEFAULT NULL,
  `dislikes` int(11) DEFAULT NULL,
  `rank` int(11) DEFAULT NULL,
  `true_rank` float DEFAULT NULL,
  `num_pics` int(11) DEFAULT NULL,
  `num_mods` int(11) DEFAULT NULL,
  `file_types` int(11) DEFAULT NULL,
  `created` datetime DEFAULT NULL,
  `modified` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `53b1df549bc047d99a5a6fafa93f502dself`
--

INSERT INTO `53b1df549bc047d99a5a6fafa93f502dself` (`model_title`, `model_size`, `model_id`, `user_id`, `user_name`, `file_exten`, `model_description`, `likes`, `dislikes`, `rank`, `true_rank`, `num_pics`, `num_mods`, `file_types`, `created`, `modified`) VALUES
('multiple color', '0', '53b2eb05-4408-4f40-8e5e-7d87a93f502d', '53b1df54-9bc0-47d9-9a5a-6fafa93f502d', 'crazyha', 'jpg', 'multi color', 0, 0, 0, 0, 1, 3, 1, '2014-07-01 19:08:22', '2014-07-01 19:08:22'),
('multicolor2', '0', '53b8673e-fd14-490e-ad1f-9c4ca93f502d', '53b1df54-9bc0-47d9-9a5a-6fafa93f502d', 'crazyha', 'jpg', 'multicolor2', 0, 0, 0, 0, 1, 3, 1, '2014-07-05 22:59:43', '2014-07-05 22:59:43');

-- --------------------------------------------------------

--
-- Table structure for table `53b197c2cd244d309e4a6878a93f502d`
--

CREATE TABLE `53b197c2cd244d309e4a6878a93f502d` (
  `number` int(11) NOT NULL AUTO_INCREMENT,
  `quetitle` char(50) DEFAULT NULL,
  `quesize` char(50) DEFAULT NULL,
  `que_follow_flag` int(1) DEFAULT NULL,
  `followed_user_id` char(36) DEFAULT NULL,
  `created` datetime NOT NULL,
  `modified` datetime NOT NULL,
  PRIMARY KEY (`number`)
) ENGINE=InnoDB  DEFAULT CHARSET=latin1 AUTO_INCREMENT=36 ;

--
-- Dumping data for table `53b197c2cd244d309e4a6878a93f502d`
--

INSERT INTO `53b197c2cd244d309e4a6878a93f502d` (`number`, `quetitle`, `quesize`, `que_follow_flag`, `followed_user_id`, `created`, `modified`) VALUES
(4, '53b1df549bc047d99a5a6fafa93f502dself', '0', 1, '53b1df54-9bc0-47d9-9a5a-6fafa93f502d', '2014-07-22 05:54:38', '2014-07-22 05:54:38'),
(35, 'Engineering_Stuff', '0', 0, '0', '2014-07-26 19:03:17', '2014-07-26 19:03:17');

-- --------------------------------------------------------

--
-- Table structure for table `53b197c2cd244d309e4a6878a93f502dEngineering_Stuff`
--

CREATE TABLE `53b197c2cd244d309e4a6878a93f502dEngineering_Stuff` (
  `model_title` char(50) DEFAULT NULL,
  `model_size` char(50) DEFAULT NULL,
  `model_id` char(36) DEFAULT NULL,
  `user_id` char(36) DEFAULT NULL,
  `user_name` varchar(45) DEFAULT NULL,
  `file_exten` char(10) DEFAULT NULL,
  `model_description` text,
  `likes` int(11) DEFAULT NULL,
  `dislikes` int(11) DEFAULT NULL,
  `rank` int(11) DEFAULT NULL,
  `true_rank` float DEFAULT NULL,
  `num_pics` int(11) DEFAULT NULL,
  `num_mods` int(11) DEFAULT NULL,
  `file_types` int(11) DEFAULT NULL,
  `created` datetime DEFAULT NULL,
  `modified` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Table structure for table `53b197c2cd244d309e4a6878a93f502dself`
--

CREATE TABLE `53b197c2cd244d309e4a6878a93f502dself` (
  `model_title` char(50) DEFAULT NULL,
  `model_size` char(50) DEFAULT NULL,
  `model_id` char(36) DEFAULT NULL,
  `user_id` char(36) DEFAULT NULL,
  `user_name` varchar(45) DEFAULT NULL,
  `file_exten` char(10) DEFAULT NULL,
  `model_description` text,
  `likes` int(11) DEFAULT NULL,
  `dislikes` int(11) DEFAULT NULL,
  `rank` int(11) DEFAULT NULL,
  `true_rank` float DEFAULT NULL,
  `num_pics` int(11) DEFAULT NULL,
  `num_mods` int(11) DEFAULT NULL,
  `file_types` int(11) DEFAULT NULL,
  `created` datetime DEFAULT NULL,
  `modified` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `53b197c2cd244d309e4a6878a93f502dself`
--

INSERT INTO `53b197c2cd244d309e4a6878a93f502dself` (`model_title`, `model_size`, `model_id`, `user_id`, `user_name`, `file_exten`, `model_description`, `likes`, `dislikes`, `rank`, `true_rank`, `num_pics`, `num_mods`, `file_types`, `created`, `modified`) VALUES
('yourmom', '0', '53b1e56f-0ed8-4b7a-ab4c-717ca93f502d', '53b197c2-cd24-4d30-9e4a-6878a93f502d', 'yvanscher', 'jpg', 'yourmomtestg5', 0, 0, 0, 0, 1, 1, 1, '2014-07-01 00:32:16', '2014-07-01 00:32:16'),
('seconfifle', '0', '53b1ec7d-4050-4dfe-b95d-7361a93f502d', '53b197c2-cd24-4d30-9e4a-6878a93f502d', 'yvanscher', 'jpg', 'file2', 0, 0, 0, 0, 1, 1, 1, '2014-07-01 01:02:21', '2014-07-01 01:02:21'),
('fourthfile', '0', '53b44a4b-843c-4ec8-97e6-8beca93f502d', '53b197c2-cd24-4d30-9e4a-6878a93f502d', 'yvanscher', 'jpg', 'fourth', 0, 0, 0, 0, 1, 1, 1, '2014-07-02 20:07:07', '2014-07-02 20:07:07'),
('crazy', '0', '53b44a56-ffc0-4618-bccf-8b04a93f502d', '53b197c2-cd24-4d30-9e4a-6878a93f502d', 'yvanscher', 'jpg', 'crayz', 0, 0, 0, 0, 1, 1, 1, '2014-07-02 20:07:19', '2014-07-02 20:07:19'),
('boredasshit', '0', '53b44ad4-86b8-444e-8e83-8a22a93f502d', '53b197c2-cd24-4d30-9e4a-6878a93f502d', 'yvanscher', 'jpg', 'asdkasdaskjdaskdasjdsa', 0, 0, 0, 0, 1, 1, 1, '2014-07-02 20:09:25', '2014-07-02 20:09:25'),
('Testregex', '0', '53ca0060-af70-466f-a992-6474a93f502d', '53b197c2-cd24-4d30-9e4a-6878a93f502d', 'yvanscher', 'jpg', 'http:&sect;&sect;localhost:8888&sect;cakephp-cakephp-0a6d85c&sect;upload', 0, 0, 0, 0, 1, 1, 1, '2014-07-19 07:21:36', '2014-07-19 07:21:36'),
('Testregex', '0', '53ca0154-ce50-4c90-86c0-65afa93f502d', '53b197c2-cd24-4d30-9e4a-6878a93f502d', 'yvanscher', 'jpg', 'Our example was printed with 0.20mm layer height (use lower resolution for quicker print), 20% infill. This took 5 hours and 48 minutes, and used 71g of filament. Attach to your wall using 4 screws and wall-plugs.\n', 0, 0, 0, 0, 1, 1, 1, '2014-07-19 07:25:41', '2014-07-19 07:25:41'),
('testingregex', '0', '53ca053e-4324-428c-b543-67e8a93f502d', '53b197c2-cd24-4d30-9e4a-6878a93f502d', 'yvanscher', 'jpg', 'abc123', 0, 0, 0, 0, 1, 1, 1, '2014-07-19 07:42:22', '2014-07-19 07:42:22'),
('Testregex', '0', '53ca0832-ebe4-413f-a18a-64dea93f502d', '53b197c2-cd24-4d30-9e4a-6878a93f502d', 'yvanscher', 'jpg', 'bvd4', 0, 0, 0, 0, 1, 1, 1, '2014-07-19 07:54:59', '2014-07-19 07:54:59'),
('REGEXTEXT', '0', '53ca8c09-a598-4ff1-9039-6900a93f502d', '53b197c2-cd24-4d30-9e4a-6878a93f502d', 'yvanscher', 'jpg', 'http:&sect;&sect;localhost:8888&sect;cakephp-cakephp-0a6d85c&sect;upload', 0, 0, 0, 0, 1, 1, 1, '2014-07-19 17:17:29', '2014-07-19 17:17:29'),
('REGEXTEXT', '0', '53ca8c36-c13c-4c16-8548-6825a93f502d', '53b197c2-cd24-4d30-9e4a-6878a93f502d', 'yvanscher', 'jpg', 'http:&sect;&sect;localhost:8888&sect;cakephp-cakephp-0a6d85c&sect;upload', 0, 0, 0, 0, 1, 1, 1, '2014-07-19 17:18:14', '2014-07-19 17:18:14'),
('REGEXTEST', '0', '53ca8c4a-9b1c-4373-8ecb-64f8a93f502d', '53b197c2-cd24-4d30-9e4a-6878a93f502d', 'yvanscher', 'jpg', 'http:&sect;&sect;localhost:8888&sect;cakephp-cakephp-0a6d85c&sect;upload', 0, 0, 0, 0, 1, 1, 1, '2014-07-19 17:18:34', '2014-07-19 17:18:34'),
('REGEXTEST', '0', '53ca8cae-a490-46ac-9444-6474a93f502d', '53b197c2-cd24-4d30-9e4a-6878a93f502d', 'yvanscher', 'jpg', 'http:&sect;&sect;localhost:8888&sect;cakephp-cakephp-0a6d85c&sect;upload', 0, 0, 0, 0, 1, 1, 1, '2014-07-19 17:20:14', '2014-07-19 17:20:14'),
('REGEXTEST', '0', '53ca91ea-e69c-4ffc-b3d3-6f59a93f502d', '53b197c2-cd24-4d30-9e4a-6878a93f502d', 'yvanscher', 'jpg', 'http:&sect;&sect;localhost:8888&sect;cakephp-cakephp-0a6d85c&sect;upload', 0, 0, 0, 0, 1, 1, 1, '2014-07-19 17:42:34', '2014-07-19 17:42:34'),
('REGEXNEW', '0', '53ca9766-1c68-42ba-879d-65afa93f502d', '53b197c2-cd24-4d30-9e4a-6878a93f502d', 'yvanscher', 'jpg', '$this->request->data[''Upload''][''description''] = str_replace("&sect;", "&sect;", $this->request->data[''Upload''][''description'']);http:&sect;&sect;localhost:8888&sect;cakephp-cakephp-0a6d85c&sect;upload', 0, 0, 0, 0, 1, 1, 1, '2014-07-19 18:05:58', '2014-07-19 18:05:58'),
('New REGEX again', '0', '53ca9b5b-9570-4501-8674-74aaa93f502d', '53b197c2-cd24-4d30-9e4a-6878a93f502d', 'yvanscher', 'jpg', ' $this->request->data[''Upload''][''id''] = $id; &sect;&sect;$id is a unique id created for the upload iteself\r\n          $this->request->data[''Upload''][''main_id''] = $id;http:&sect;&sect;localhost:8888&sect;cakephp-cakephp-0a6d85c&sect;upload', 0, 0, 0, 0, 1, 1, 1, '2014-07-19 18:22:52', '2014-07-19 18:22:52'),
('http://localhost:8888/cakephp-cakephp-0a6d85c', '0', '53ca9c3d-59c4-45f9-a127-74f9a93f502d', '53b197c2-cd24-4d30-9e4a-6878a93f502d', 'yvanscher', 'jpg', 'http:&sect;&sect;localhost:8888&sect;cakephp-cakephp-0a6d85c&sect;uploadhttp:&sect;&sect;localhost:8888&sect;cakephp-cakephp-0a6d85c&sect;upload', 0, 0, 0, 0, 1, 1, 1, '2014-07-19 18:26:38', '2014-07-19 18:26:38'),
('< > # % { } | \\ ^ ~ [ ]', '0', '53caa40c-f3b4-4ee9-9601-7813a93f502d', '53b197c2-cd24-4d30-9e4a-6878a93f502d', 'yvanscher', 'jpg', '< > # % { } | \\ ^ ~ [ ]', 0, 0, 0, 0, 1, 1, 1, '2014-07-19 18:59:56', '2014-07-19 18:59:56'),
('$ & + , / : ; = ? @', '0', '53caa468-5cec-4e54-8cef-74f9a93f502d', '53b197c2-cd24-4d30-9e4a-6878a93f502d', 'yvanscher', 'jpg', '$ & + , &sect; : ; = ? @', 0, 0, 0, 0, 1, 1, 1, '2014-07-19 19:01:29', '2014-07-19 19:01:29'),
('http://localhost:8888/cakephp-cakephp-0a6d85c', '0', '53caa7a4-70c0-490e-89ff-6e43a93f502d', '53b197c2-cd24-4d30-9e4a-6878a93f502d', 'yvanscher', 'jpg', '<a href="http:&sect;&sect;localhost:8888&sect;cakephp-cakephp-0a6d85c&sect;upload">CrazyBlah<&sect;a>', 0, 0, 0, 0, 1, 1, 1, '2014-07-19 19:15:17', '2014-07-19 19:15:17'),
(' Canon EW-73B Lens Hood', '0', '53cab055-f124-4583-9942-7ad0a93f502d', '53b197c2-cd24-4d30-9e4a-6878a93f502d', 'yvanscher', 'jpg', 'Printed at 0,15 mm layer height, with 50% infill. This took 156 minutes and used 20,4 g of filament', 0, 0, 0, 0, 1, 1, 1, '2014-07-19 19:52:21', '2014-07-19 19:52:21'),
(' Canon EW-73B Lens Hood', '0', '53cab0a8-6080-48aa-9c7c-7ccda93f502d', '53b197c2-cd24-4d30-9e4a-6878a93f502d', 'yvanscher', 'jpg', 'Printed at 0,15 mm layer height, with 50% infill. This took 156 minutes and used 20,4 g of filament', 0, 0, 0, 0, 1, 1, 1, '2014-07-19 19:53:45', '2014-07-19 19:53:45'),
('errortest', '0', '53d2d01f-0ca0-4249-a437-2c16a93f502d', '53b197c2-cd24-4d30-9e4a-6878a93f502d', 'yvanscher', 'jpg', 'Serrortest', 0, 0, 0, 0, 1, 1, 1, '2014-07-25 23:46:07', '2014-07-25 23:46:07'),
('errortest', '0', '53d2d029-5730-4f8d-91c3-2c6da93f502d', '53b197c2-cd24-4d30-9e4a-6878a93f502d', 'yvanscher', 'jpg', 'Serrortest', 0, 0, 0, 0, 1, 1, 1, '2014-07-25 23:46:17', '2014-07-25 23:46:17'),
('errortest', '0', '53d2d05f-1904-4262-94fb-2b36a93f502d', '53b197c2-cd24-4d30-9e4a-6878a93f502d', 'yvanscher', 'jpg', 'Serrortest', 0, 0, 0, 0, 1, 1, 1, '2014-07-25 23:47:12', '2014-07-25 23:47:12'),
('errortest', '0', '53d2d0cf-6c84-4be7-876a-2c6da93f502d', '53b197c2-cd24-4d30-9e4a-6878a93f502d', 'yvanscher', 'jpg', 'Serrortest', 0, 0, 0, 0, 1, 1, 1, '2014-07-25 23:49:04', '2014-07-25 23:49:04'),
('errortest', '0', '53d2d0d1-6c58-4837-93b0-2c16a93f502d', '53b197c2-cd24-4d30-9e4a-6878a93f502d', 'yvanscher', 'jpg', 'Serrortest', 0, 0, 0, 0, 1, 1, 1, '2014-07-25 23:49:06', '2014-07-25 23:49:06'),
('errortest', '0', '53d2d0e0-cec0-41b4-8529-2c76a93f502d', '53b197c2-cd24-4d30-9e4a-6878a93f502d', 'yvanscher', 'jpg', 'Serrortest', 0, 0, 0, 0, 1, 1, 1, '2014-07-25 23:49:21', '2014-07-25 23:49:21'),
('errortest', '0', '53d2d0e9-8e1c-4fc8-9942-2cd6a93f502d', '53b197c2-cd24-4d30-9e4a-6878a93f502d', 'yvanscher', 'jpg', 'Serrortest', 0, 0, 0, 0, 1, 1, 1, '2014-07-25 23:49:29', '2014-07-25 23:49:29'),
('errortest', '0', '53d2d0f7-6928-4ea1-adad-2c76a93f502d', '53b197c2-cd24-4d30-9e4a-6878a93f502d', 'yvanscher', 'jpg', 'Serrortest', 0, 0, 0, 0, 1, 1, 1, '2014-07-25 23:49:44', '2014-07-25 23:49:44'),
('errortest', '0', '53d2d104-0288-43ea-8bd3-1f08a93f502d', '53b197c2-cd24-4d30-9e4a-6878a93f502d', 'yvanscher', 'jpg', 'Serrortest', 0, 0, 0, 0, 1, 1, 1, '2014-07-25 23:49:57', '2014-07-25 23:49:57'),
('errortest', '0', '53d2d123-d660-45f3-8d5e-2c76a93f502d', '53b197c2-cd24-4d30-9e4a-6878a93f502d', 'yvanscher', 'jpg', 'Serrortest', 0, 0, 0, 0, 1, 1, 1, '2014-07-25 23:50:28', '2014-07-25 23:50:28'),
('errortest', '0', '53d2d12e-617c-4a12-b332-2c16a93f502d', '53b197c2-cd24-4d30-9e4a-6878a93f502d', 'yvanscher', 'jpg', 'Serrortest', 0, 0, 0, 0, 1, 1, 1, '2014-07-25 23:50:39', '2014-07-25 23:50:39'),
('errortest', '0', '53d2d136-627c-48e5-8715-2d0ea93f502d', '53b197c2-cd24-4d30-9e4a-6878a93f502d', 'yvanscher', 'jpg', 'Serrortest', 0, 0, 0, 0, 1, 1, 1, '2014-07-25 23:50:46', '2014-07-25 23:50:46'),
('errortest', '0', '53d2d13e-1904-4dcd-af4b-2c16a93f502d', '53b197c2-cd24-4d30-9e4a-6878a93f502d', 'yvanscher', 'jpg', 'Serrortest', 0, 0, 0, 0, 1, 1, 1, '2014-07-25 23:50:55', '2014-07-25 23:50:55'),
('errortest', '0', '53d2d14a-27ec-466a-badf-2cd6a93f502d', '53b197c2-cd24-4d30-9e4a-6878a93f502d', 'yvanscher', 'jpg', 'Serrortest', 0, 0, 0, 0, 1, 1, 1, '2014-07-25 23:51:06', '2014-07-25 23:51:06'),
('TESTERRO', '0', '53d2d161-1f44-459f-a5cc-2d0ea93f502d', '53b197c2-cd24-4d30-9e4a-6878a93f502d', 'yvanscher', 'jpg', 'TESTERRO', 0, 0, 0, 0, 1, 1, 1, '2014-07-25 23:51:30', '2014-07-25 23:51:30'),
('', '0', '53d2ec5b-7c94-45bc-8144-2cd6a93f502d', '53b197c2-cd24-4d30-9e4a-6878a93f502d', 'yvanscher', 'jpg', '', 0, 0, 0, 0, 1, 1, 1, '2014-07-26 01:46:35', '2014-07-26 01:46:35'),
('ewok', '0', '53d2fc34-d928-4b4b-a34f-2e57a93f502d', '53b197c2-cd24-4d30-9e4a-6878a93f502d', 'yvanscher', 'jpg', 'wertyuiopk', 0, 0, 0, 0, 1, 1, 1, '2014-07-26 02:54:13', '2014-07-26 02:54:13'),
('ewok', '0', '53d2fc8d-ef30-4ede-ac7a-3101a93f502d', '53b197c2-cd24-4d30-9e4a-6878a93f502d', 'yvanscher', 'jpg', 'lightsaber', 0, 0, 0, 0, 1, 1, 1, '2014-07-26 02:55:42', '2014-07-26 02:55:42'),
('ewok', '0', '53d2ff95-6540-4b02-aa9e-2e57a93f502d', '53b197c2-cd24-4d30-9e4a-6878a93f502d', 'yvanscher', 'jpg', 'lightsaber', 0, 0, 0, 0, 1, 1, 1, '2014-07-26 03:08:38', '2014-07-26 03:08:38'),
('ewok', '0', '53d2ffc0-df04-4e3a-b3a4-2fe0a93f502d', '53b197c2-cd24-4d30-9e4a-6878a93f502d', 'yvanscher', 'jpg', 'lightsaber', 0, 0, 0, 0, 1, 1, 1, '2014-07-26 03:09:21', '2014-07-26 03:09:21'),
('ewok', '0', '53d2ffc3-8d18-48b1-b38d-35d3a93f502d', '53b197c2-cd24-4d30-9e4a-6878a93f502d', 'yvanscher', 'jpg', 'lightsaber', 0, 0, 0, 0, 1, 1, 1, '2014-07-26 03:09:23', '2014-07-26 03:09:23'),
('ewok', '0', '53d2ffcf-44a8-4d2f-abf9-2d07a93f502d', '53b197c2-cd24-4d30-9e4a-6878a93f502d', 'yvanscher', 'jpg', 'lightsaber', 0, 0, 0, 0, 1, 1, 1, '2014-07-26 03:09:36', '2014-07-26 03:09:36'),
('ewok', '0', '53d2ffe4-e344-4e50-98f4-326fa93f502d', '53b197c2-cd24-4d30-9e4a-6878a93f502d', 'yvanscher', 'jpg', 'lightsaber', 0, 0, 0, 0, 1, 1, 1, '2014-07-26 03:09:57', '2014-07-26 03:09:57'),
('ewok', '0', '53d30007-c8c4-40fe-8fbd-2e57a93f502d', '53b197c2-cd24-4d30-9e4a-6878a93f502d', 'yvanscher', 'jpg', 'lightsaber', 0, 0, 0, 0, 1, 1, 1, '2014-07-26 03:10:32', '2014-07-26 03:10:32'),
('ewok', '0', '53d3002c-782c-42ef-ab49-34d8a93f502d', '53b197c2-cd24-4d30-9e4a-6878a93f502d', 'yvanscher', 'jpg', 'lightsaber', 0, 0, 0, 0, 1, 1, 1, '2014-07-26 03:11:09', '2014-07-26 03:11:09'),
('ewok', '0', '53d3004c-3e40-4575-aaec-2e57a93f502d', '53b197c2-cd24-4d30-9e4a-6878a93f502d', 'yvanscher', 'jpg', 'lightsaber', 0, 0, 0, 0, 1, 1, 1, '2014-07-26 03:11:41', '2014-07-26 03:11:41'),
('ewok', '0', '53d30077-bb64-4078-b931-34d8a93f502d', '53b197c2-cd24-4d30-9e4a-6878a93f502d', 'yvanscher', 'jpg', 'lightsaber', 0, 0, 0, 0, 1, 1, 1, '2014-07-26 03:12:24', '2014-07-26 03:12:24'),
('ewok', '0', '53d30081-805c-4c1d-9306-2d07a93f502d', '53b197c2-cd24-4d30-9e4a-6878a93f502d', 'yvanscher', 'jpg', 'lightsaber', 0, 0, 0, 0, 1, 1, 1, '2014-07-26 03:12:33', '2014-07-26 03:12:33'),
('ewok', '0', '53d3009f-a3fc-448e-83ca-35f8a93f502d', '53b197c2-cd24-4d30-9e4a-6878a93f502d', 'yvanscher', 'jpg', 'lightsaber1', 0, 0, 0, 0, 1, 1, 1, '2014-07-26 03:13:03', '2014-07-26 03:13:03'),
('ewok', '0', '53d300c9-d3b8-4e9f-8531-34d8a93f502d', '53b197c2-cd24-4d30-9e4a-6878a93f502d', 'yvanscher', 'jpg', 'lightsaber4', 0, 0, 0, 0, 1, 3, 1, '2014-07-26 03:13:46', '2014-07-26 03:13:46'),
('ewok', '0', '53d306b1-6e00-43a8-8129-35f8a93f502d', '53b197c2-cd24-4d30-9e4a-6878a93f502d', 'yvanscher', 'jpg', 'Sed ut perspiciatis unde omnis iste natus error sit voluptatem accusantium doloremque laudantium, totam rem aperiam, eaque ipsa quae ab illo inventore veritatis et quasi architecto beatae vitae dicta sunt explicabo. Nemo enim ipsam voluptatem quia voluptas sit aspernatur aut odit aut fugit, sed quia consequuntur magni dolores eos qui ratione voluptatem sequi nesciunt. Neque porro quisquam est, qui dolorem ipsum quia dolor sit amet, consectetur, adipisci velit, sed quia non numquam eius modi temp\r\nSed ut perspiciatis unde omnis iste natus error sit voluptatem accusantium doloremque laudantium, totam rem aperiam, eaque ipsa quae ab illo inventore veritatis et quasi architecto beatae vitae dicta sunt explicabo. Nemo enim ipsam voluptatem quia voluptas sit aspernatur aut odit aut fugit, sed quia consequuntur magni dolores eos qui ratione voluptatem sequi nesciunt. Neque porro quisquam est, qui dolorem ipsum quia dolor sit amet, consectetur, adipisci velit, sed quia non numquam eius modi temp\r\n\r\na', 0, 0, 0, 0, 1, 1, 1, '2014-07-26 03:38:58', '2014-07-26 03:38:58');

-- --------------------------------------------------------

--
-- Table structure for table `53cdd293282c48428ecef245a93f502d`
--

CREATE TABLE `53cdd293282c48428ecef245a93f502d` (
  `quetitle` char(50) DEFAULT NULL,
  `quesize` char(50) DEFAULT NULL,
  `que_follow_flag` int(1) DEFAULT NULL,
  `followed_user_id` char(36) DEFAULT NULL,
  `created` datetime DEFAULT NULL,
  `modified` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Table structure for table `53cdd293282c48428ecef245a93f502dnew`
--

CREATE TABLE `53cdd293282c48428ecef245a93f502dnew` (
  `model_title` char(50) DEFAULT NULL,
  `model_size` char(50) DEFAULT NULL,
  `model_id` char(36) DEFAULT NULL,
  `user_id` char(36) DEFAULT NULL,
  `user_name` varchar(45) DEFAULT NULL,
  `file_exten` char(10) DEFAULT NULL,
  `model_description` text,
  `likes` int(11) DEFAULT NULL,
  `dislikes` int(11) DEFAULT NULL,
  `rank` int(11) DEFAULT NULL,
  `true_rank` float DEFAULT NULL,
  `num_pics` int(11) DEFAULT NULL,
  `num_mods` int(11) DEFAULT NULL,
  `file_types` int(11) DEFAULT NULL,
  `created` datetime DEFAULT NULL,
  `modified` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Table structure for table `53cdd293282c48428ecef245a93f502dneww`
--

CREATE TABLE `53cdd293282c48428ecef245a93f502dneww` (
  `model_title` char(50) DEFAULT NULL,
  `model_size` char(50) DEFAULT NULL,
  `model_id` char(36) DEFAULT NULL,
  `user_id` char(36) DEFAULT NULL,
  `user_name` varchar(45) DEFAULT NULL,
  `file_exten` char(10) DEFAULT NULL,
  `model_description` text,
  `likes` int(11) DEFAULT NULL,
  `dislikes` int(11) DEFAULT NULL,
  `rank` int(11) DEFAULT NULL,
  `true_rank` float DEFAULT NULL,
  `num_pics` int(11) DEFAULT NULL,
  `num_mods` int(11) DEFAULT NULL,
  `file_types` int(11) DEFAULT NULL,
  `created` datetime DEFAULT NULL,
  `modified` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Table structure for table `53cdd293282c48428ecef245a93f502dself`
--

CREATE TABLE `53cdd293282c48428ecef245a93f502dself` (
  `model_title` char(50) DEFAULT NULL,
  `model_size` char(50) DEFAULT NULL,
  `model_id` char(36) DEFAULT NULL,
  `user_id` char(36) DEFAULT NULL,
  `user_name` varchar(45) DEFAULT NULL,
  `file_exten` char(10) DEFAULT NULL,
  `model_description` text,
  `likes` int(11) DEFAULT NULL,
  `dislikes` int(11) DEFAULT NULL,
  `rank` int(11) DEFAULT NULL,
  `true_rank` float DEFAULT NULL,
  `num_pics` int(11) DEFAULT NULL,
  `num_mods` int(11) DEFAULT NULL,
  `file_types` int(11) DEFAULT NULL,
  `created` datetime DEFAULT NULL,
  `modified` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Table structure for table `53cdea180a304fe9a9f9fb34a93f502dself`
--

CREATE TABLE `53cdea180a304fe9a9f9fb34a93f502dself` (
  `model_title` char(50) DEFAULT NULL,
  `model_size` char(50) DEFAULT NULL,
  `model_id` char(36) DEFAULT NULL,
  `user_id` char(36) DEFAULT NULL,
  `user_name` varchar(45) DEFAULT NULL,
  `file_exten` char(10) DEFAULT NULL,
  `model_description` text,
  `likes` int(11) DEFAULT NULL,
  `dislikes` int(11) DEFAULT NULL,
  `rank` int(11) DEFAULT NULL,
  `true_rank` float DEFAULT NULL,
  `num_pics` int(11) DEFAULT NULL,
  `num_mods` int(11) DEFAULT NULL,
  `file_types` int(11) DEFAULT NULL,
  `created` datetime DEFAULT NULL,
  `modified` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Table structure for table `53cefdc2f6c04b98add84247a93f502dself`
--

CREATE TABLE `53cefdc2f6c04b98add84247a93f502dself` (
  `model_title` char(50) DEFAULT NULL,
  `model_size` char(50) DEFAULT NULL,
  `model_id` char(36) DEFAULT NULL,
  `user_id` char(36) DEFAULT NULL,
  `user_name` varchar(45) DEFAULT NULL,
  `file_exten` char(10) DEFAULT NULL,
  `model_description` text,
  `likes` int(11) DEFAULT NULL,
  `dislikes` int(11) DEFAULT NULL,
  `rank` int(11) DEFAULT NULL,
  `true_rank` float DEFAULT NULL,
  `num_pics` int(11) DEFAULT NULL,
  `num_mods` int(11) DEFAULT NULL,
  `file_types` int(11) DEFAULT NULL,
  `created` datetime DEFAULT NULL,
  `modified` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Table structure for table `53d45169dfa04e85acd57547a93f502d`
--

CREATE TABLE `53d45169dfa04e85acd57547a93f502d` (
  `quetitle` char(50) DEFAULT NULL,
  `quesize` char(50) DEFAULT NULL,
  `que_follow_flag` int(1) DEFAULT NULL,
  `followed_user_id` char(36) DEFAULT NULL,
  `created` datetime DEFAULT NULL,
  `modified` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `53d45169dfa04e85acd57547a93f502d`
--

INSERT INTO `53d45169dfa04e85acd57547a93f502d` (`quetitle`, `quesize`, `que_follow_flag`, `followed_user_id`, `created`, `modified`) VALUES
('Que1', '0', 0, '0', NULL, NULL);

-- --------------------------------------------------------

--
-- Table structure for table `53d45169dfa04e85acd57547a93f502dQue1`
--

CREATE TABLE `53d45169dfa04e85acd57547a93f502dQue1` (
  `model_title` char(50) DEFAULT NULL,
  `model_size` char(50) DEFAULT NULL,
  `model_id` char(36) DEFAULT NULL,
  `user_id` char(36) DEFAULT NULL,
  `user_name` varchar(45) DEFAULT NULL,
  `file_exten` char(10) DEFAULT NULL,
  `model_description` text,
  `likes` int(11) DEFAULT NULL,
  `dislikes` int(11) DEFAULT NULL,
  `rank` int(11) DEFAULT NULL,
  `true_rank` float DEFAULT NULL,
  `num_pics` int(11) DEFAULT NULL,
  `num_mods` int(11) DEFAULT NULL,
  `file_types` int(11) DEFAULT NULL,
  `created` datetime DEFAULT NULL,
  `modified` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Table structure for table `53d45169dfa04e85acd57547a93f502dself`
--

CREATE TABLE `53d45169dfa04e85acd57547a93f502dself` (
  `model_title` char(50) DEFAULT NULL,
  `model_size` char(50) DEFAULT NULL,
  `model_id` char(36) DEFAULT NULL,
  `user_id` char(36) DEFAULT NULL,
  `user_name` varchar(45) DEFAULT NULL,
  `file_exten` char(10) DEFAULT NULL,
  `model_description` text,
  `likes` int(11) DEFAULT NULL,
  `dislikes` int(11) DEFAULT NULL,
  `rank` int(11) DEFAULT NULL,
  `true_rank` float DEFAULT NULL,
  `num_pics` int(11) DEFAULT NULL,
  `num_mods` int(11) DEFAULT NULL,
  `file_types` int(11) DEFAULT NULL,
  `created` datetime DEFAULT NULL,
  `modified` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Table structure for table `abouts`
--

CREATE TABLE `abouts` (
  `id` varchar(11) COLLATE utf8_unicode_ci NOT NULL,
  `test` varchar(45) COLLATE utf8_unicode_ci NOT NULL,
  `created` datetime NOT NULL,
  `modified` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `bazarliketracks`
--

CREATE TABLE `bazarliketracks` (
  `number` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` char(36) COLLATE utf8_unicode_ci NOT NULL,
  `bazar_id` char(36) COLLATE utf8_unicode_ci NOT NULL,
  `created` datetime NOT NULL,
  `modified` datetime NOT NULL,
  PRIMARY KEY (`number`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci AUTO_INCREMENT=7 ;

--
-- Dumping data for table `bazarliketracks`
--

INSERT INTO `bazarliketracks` (`number`, `user_id`, `bazar_id`, `created`, `modified`) VALUES
(1, '53b197c2-cd24-4d30-9e4a-6878a93f502d', '53cf581b-07d4-4199-9f10-41f2a93f502d', '2014-07-27 03:24:05', '2014-07-27 03:24:05'),
(2, '', '53cfefa6-be14-4abc-949c-474aa93f502d', '2014-07-27 03:24:30', '2014-07-27 03:24:30'),
(3, '', '53cf56cc-fd70-449a-a3ff-43a2a93f502d', '2014-07-27 03:24:31', '2014-07-27 03:24:31'),
(4, '53b197c2-cd24-4d30-9e4a-6878a93f502d', '53cf56e7-dee4-4443-a55b-4a65a93f502d', '2014-07-27 03:24:37', '2014-07-27 03:24:37'),
(5, '', '53cfef9f-2f60-4ee7-a8a4-4a9ba93f502d', '2014-07-27 03:32:52', '2014-07-27 03:32:52'),
(6, '', '53cf56e7-dee4-4443-a55b-4a65a93f502d', '2014-07-27 03:52:09', '2014-07-27 03:52:09');

-- --------------------------------------------------------

--
-- Table structure for table `bazars`
--

CREATE TABLE `bazars` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `likes` int(11) NOT NULL,
  `dislikes` int(11) NOT NULL,
  `rank` int(11) NOT NULL,
  `true_rank` float NOT NULL,
  `user_id` char(36) COLLATE utf8_unicode_ci NOT NULL,
  `username` varchar(45) COLLATE utf8_unicode_ci NOT NULL,
  `bazar_id` char(36) COLLATE utf8_unicode_ci NOT NULL,
  `rpflag` int(11) NOT NULL,
  `title` varchar(45) COLLATE utf8_unicode_ci NOT NULL,
  `description` text COLLATE utf8_unicode_ci NOT NULL,
  `created` datetime NOT NULL,
  `modified` datetime NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci AUTO_INCREMENT=6 ;

--
-- Dumping data for table `bazars`
--

INSERT INTO `bazars` (`id`, `likes`, `dislikes`, `rank`, `true_rank`, `user_id`, `username`, `bazar_id`, `rpflag`, `title`, `description`, `created`, `modified`) VALUES
(1, 1, 0, 0, 0, '53b197c2-cd24-4d30-9e4a-6878a93f502d', 'yvanscher', '53cf56cc-fd70-449a-a3ff-43a2a93f502d', 0, 'averf', 'avcfrertyoalwro', '2014-07-23 08:31:40', '2014-07-23 08:31:40'),
(2, 2, 0, 0, 0, '53b197c2-cd24-4d30-9e4a-6878a93f502d', 'yvanscher', '53cf56e7-dee4-4443-a55b-4a65a93f502d', 0, 'asdss', 'asdsadasdasdadas', '2014-07-23 08:32:07', '2014-07-23 08:32:07'),
(3, 0, 1, 0, 0, '53b197c2-cd24-4d30-9e4a-6878a93f502d', 'yvanscher', '53cf581b-07d4-4199-9f10-41f2a93f502d', 1, 'kklasdasd', 'asdsaasdasdasdasdas', '2014-07-23 08:37:15', '2014-07-23 08:37:15'),
(4, 0, 1, 0, 0, '53b197c2-cd24-4d30-9e4a-6878a93f502d', 'yvanscher', '53cfef9f-2f60-4ee7-a8a4-4a9ba93f502d', 0, 'sabc1235', 'asdasdasdasdasdasdasdasd', '2014-07-23 19:23:43', '2014-07-23 19:23:43'),
(5, 1, 0, 0, 0, '53b197c2-cd24-4d30-9e4a-6878a93f502d', 'yvanscher', '53cfefa6-be14-4abc-949c-474aa93f502d', 1, 'sadadas', 'asdasdasdasdasdasdasdd', '2014-07-23 19:23:50', '2014-07-23 19:23:50');

-- --------------------------------------------------------

--
-- Table structure for table `comments`
--

CREATE TABLE `comments` (
  `number` int(11) NOT NULL AUTO_INCREMENT,
  `comment_id` char(36) COLLATE utf8_unicode_ci NOT NULL,
  `product_id` char(36) COLLATE utf8_unicode_ci NOT NULL,
  `user_id` char(36) COLLATE utf8_unicode_ci NOT NULL,
  `username` varchar(45) COLLATE utf8_unicode_ci NOT NULL,
  `text` text COLLATE utf8_unicode_ci NOT NULL,
  `likes` int(11) NOT NULL,
  `dislikes` int(11) NOT NULL,
  `rank` int(11) NOT NULL,
  `true_rank` float NOT NULL,
  `created` datetime NOT NULL,
  `modified` datetime NOT NULL,
  PRIMARY KEY (`number`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci AUTO_INCREMENT=2 ;

--
-- Dumping data for table `comments`
--

INSERT INTO `comments` (`number`, `comment_id`, `product_id`, `user_id`, `username`, `text`, `likes`, `dislikes`, `rank`, `true_rank`, `created`, `modified`) VALUES
(1, 'f70d67b4-41cc-480f-8233-feed5b52f1e7', '53b44a56-ffc0-4618-bccf-8b04a93f502d', '53b197c2-cd24-4d30-9e4a-6878a93f502d', 'yvanscher', 'I post test', 0, 0, 0, 0, '2014-07-26 08:19:42', '2014-07-26 08:19:42');

-- --------------------------------------------------------

--
-- Table structure for table `filemanagers`
--

CREATE TABLE `filemanagers` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `filemanager_id` char(36) COLLATE utf8_unicode_ci NOT NULL,
  `user_id` char(36) COLLATE utf8_unicode_ci NOT NULL,
  `quetitle` char(50) COLLATE utf8_unicode_ci NOT NULL,
  `created` datetime NOT NULL,
  `modified` datetime NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci AUTO_INCREMENT=79 ;

--
-- Dumping data for table `filemanagers`
--

INSERT INTO `filemanagers` (`id`, `filemanager_id`, `user_id`, `quetitle`, `created`, `modified`) VALUES
(78, 'b6bfef60-6de5-4e01-8c98-98f359ddae16', '53b197c2-cd24-4d30-9e4a-6878a93f502d', 'Engineering_Stuff', '2014-07-26 19:03:17', '2014-07-26 19:03:17');

-- --------------------------------------------------------

--
-- Table structure for table `followtracks`
--

CREATE TABLE `followtracks` (
  `number` int(11) NOT NULL AUTO_INCREMENT,
  `id` int(11) NOT NULL,
  `followed_user_id` varchar(36) COLLATE utf8_unicode_ci NOT NULL,
  `follower_user_id` varchar(36) COLLATE utf8_unicode_ci NOT NULL,
  `product_id` char(36) COLLATE utf8_unicode_ci NOT NULL,
  `created` datetime NOT NULL,
  `modified` datetime NOT NULL,
  PRIMARY KEY (`number`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci AUTO_INCREMENT=25 ;

--
-- Dumping data for table `followtracks`
--

INSERT INTO `followtracks` (`number`, `id`, `followed_user_id`, `follower_user_id`, `product_id`, `created`, `modified`) VALUES
(20, 0, '53b197c2-cd24-4d30-9e4a-6878a93f502d', '53b1df54-9bc0-47d9-9a5a-6fafa93f502d', '', '2014-07-22 03:50:31', '2014-07-22 03:50:31'),
(24, 0, '53b1df54-9bc0-47d9-9a5a-6fafa93f502d', '53b197c2-cd24-4d30-9e4a-6878a93f502d', '', '2014-07-22 05:54:38', '2014-07-22 05:54:38');

-- --------------------------------------------------------

--
-- Table structure for table `homes`
--

CREATE TABLE `homes` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `email` varchar(50) COLLATE utf8_unicode_ci NOT NULL,
  `created` datetime NOT NULL,
  `modified` datetime NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci AUTO_INCREMENT=1 ;

-- --------------------------------------------------------

--
-- Table structure for table `liketracks`
--

CREATE TABLE `liketracks` (
  `number` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` char(36) COLLATE utf8_unicode_ci NOT NULL,
  `main_id` char(36) COLLATE utf8_unicode_ci NOT NULL,
  `product_id` char(36) COLLATE utf8_unicode_ci NOT NULL,
  `created` datetime NOT NULL,
  `modified` datetime NOT NULL,
  PRIMARY KEY (`number`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci AUTO_INCREMENT=61 ;

--
-- Dumping data for table `liketracks`
--

INSERT INTO `liketracks` (`number`, `user_id`, `main_id`, `product_id`, `created`, `modified`) VALUES
(58, '53b197c2-cd24-4d30-9e4a-6878a93f502d', '53b44a56-ffc0-4618-bccf-8b04a93f502d', '53b44a56-ffc0-4618-bccf-8b04a93f502d', '2014-07-26 08:19:30', '2014-07-26 08:19:30'),
(59, '', '53b44a56-ffc0-4618-bccf-8b04a93f502d', '53b44a56-ffc0-4618-bccf-8b04a93f502d', '2014-07-26 22:34:25', '2014-07-26 22:34:25'),
(60, '', '53b19842-e054-4662-b9fd-67d6a93f502d', '53b19842-e054-4662-b9fd-67d6a93f502d', '2014-07-27 03:33:13', '2014-07-27 03:33:13');

-- --------------------------------------------------------

--
-- Table structure for table `mains`
--

CREATE TABLE `mains` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` char(36) COLLATE utf8_unicode_ci NOT NULL,
  `main_id` char(36) COLLATE utf8_unicode_ci NOT NULL,
  `product_id` char(36) COLLATE utf8_unicode_ci NOT NULL,
  `title` varchar(45) COLLATE utf8_unicode_ci NOT NULL,
  `description` text COLLATE utf8_unicode_ci NOT NULL,
  `username` varchar(45) COLLATE utf8_unicode_ci NOT NULL,
  `likes` int(11) NOT NULL,
  `dislikes` int(11) NOT NULL,
  `rank` int(11) NOT NULL,
  `true_rank` float NOT NULL,
  `created` datetime NOT NULL,
  `modified` datetime NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci AUTO_INCREMENT=49 ;

--
-- Dumping data for table `mains`
--

INSERT INTO `mains` (`id`, `user_id`, `main_id`, `product_id`, `title`, `description`, `username`, `likes`, `dislikes`, `rank`, `true_rank`, `created`, `modified`) VALUES
(32, '53b197c2-cd24-4d30-9e4a-6878a93f502d', '53b2eb05-4408-4f40-8e5e-7d87a93f502d', '53b2eb05-4408-4f40-8e5e-7d87a93f502d', 'multiple color', 'multi color', 'crazyha', 4, 0, 1, 0, '2014-07-19 06:13:45', '2014-07-19 06:13:45'),
(33, '53b197c2-cd24-4d30-9e4a-6878a93f502d', '53b44ad4-86b8-444e-8e83-8a22a93f502d', '53b44ad4-86b8-444e-8e83-8a22a93f502d', 'boredasshit', 'asdkasdaskjdaskdasjdsa', 'yvanscher', 4, 0, 1, 0, '2014-07-19 06:13:46', '2014-07-19 06:13:46'),
(34, '53b197c2-cd24-4d30-9e4a-6878a93f502d', '53b8673e-fd14-490e-ad1f-9c4ca93f502d', '53b8673e-fd14-490e-ad1f-9c4ca93f502d', 'multicolor2', 'multicolor2', 'crazyha', 4, 0, 1, 0, '2014-07-19 06:13:46', '2014-07-19 06:13:46'),
(35, '53b197c2-cd24-4d30-9e4a-6878a93f502d', '53b1d5cb-7424-4200-bfb7-6878a93f502d', '53b1d5cb-7424-4200-bfb7-6878a93f502d', 'design1self', 'selftest', 'yvanscher', 2, 1, 0, 1, '2014-07-19 06:13:48', '2014-07-19 06:13:48'),
(36, '53b197c2-cd24-4d30-9e4a-6878a93f502d', '53b44a4b-843c-4ec8-97e6-8beca93f502d', '53b44a4b-843c-4ec8-97e6-8beca93f502d', 'fourthfile', 'fourth', 'yvanscher', 1, 2, 0, 1, '2014-07-19 06:13:50', '2014-07-19 06:13:50'),
(37, '53b197c2-cd24-4d30-9e4a-6878a93f502d', '53b44a31-e840-4c0b-94f2-8a22a93f502d', '53b44a31-e840-4c0b-94f2-8a22a93f502d', 'thridfile', 'thirdfile', 'yvanscher', 1, 2, 0, 1, '2014-07-19 06:13:51', '2014-07-19 06:13:51'),
(38, '53b197c2-cd24-4d30-9e4a-6878a93f502d', '53b1d5fa-e1b0-4d5a-857f-6860a93f502d', '53b1d5fa-e1b0-4d5a-857f-6860a93f502d', 'yourmom1self', 'asdasdasdas', 'yvanscher', 1, 2, 0, 1, '2014-07-19 06:13:53', '2014-07-19 06:13:53'),
(39, '53b197c2-cd24-4d30-9e4a-6878a93f502d', '53b19c59-dc2c-47f5-a507-66bfa93f502d', '53b19c59-dc2c-47f5-a507-66bfa93f502d', 'asdasdasdasdsa', 'asdasdasds', 'yvanscher', 3, 0, 1, 0, '2014-07-19 06:13:56', '2014-07-19 06:13:56'),
(40, '53b197c2-cd24-4d30-9e4a-6878a93f502d', '53b1dda8-d838-4ff4-a9e2-6daba93f502d', '53b1dda8-d838-4ff4-a9e2-6daba93f502d', 'self4', 'self4work', 'yvanscher', 6, 0, 2, 0, '2014-07-19 06:13:56', '2014-07-19 06:13:56'),
(41, '53b197c2-cd24-4d30-9e4a-6878a93f502d', '53b1e56f-0ed8-4b7a-ab4c-717ca93f502d', '53b1e56f-0ed8-4b7a-ab4c-717ca93f502d', 'yourmom', 'yourmomtestg5', 'yvanscher', 4, 1, 1, 0, '2014-07-19 06:13:57', '2014-07-19 06:13:57'),
(42, '53b197c2-cd24-4d30-9e4a-6878a93f502d', '53b1ec7d-4050-4dfe-b95d-7361a93f502d', '53b1ec7d-4050-4dfe-b95d-7361a93f502d', 'seconfifle', 'file2', 'yvanscher', 2, 1, 0, 1, '2014-07-19 06:13:58', '2014-07-19 06:13:58'),
(43, '53b197c2-cd24-4d30-9e4a-6878a93f502d', '53b19ae9-7340-4077-ad58-69fca93f502d', '53b19ae9-7340-4077-ad58-69fca93f502d', 'selftest2', 'selftest2', 'yvanscher', 2, 1, 0, 1, '2014-07-19 06:13:59', '2014-07-19 06:13:59'),
(44, '53b197c2-cd24-4d30-9e4a-6878a93f502d', '53b19842-e054-4662-b9fd-67d6a93f502d', '53b19842-e054-4662-b9fd-67d6a93f502d', 'testupload', 'testupload', 'yvanscher', 6, 1, 1, 1.39172, '2014-07-19 06:14:00', '2014-07-19 06:14:00'),
(45, '53b197c2-cd24-4d30-9e4a-6878a93f502d', '53b19a8f-9d78-4ded-9d7f-66bfa93f502d', '53b19a8f-9d78-4ded-9d7f-66bfa93f502d', 'selftest', 'selftest', 'yvanscher', 12, 0, 2, 0, '2014-07-19 06:14:01', '2014-07-19 06:14:01'),
(46, '53b197c2-cd24-4d30-9e4a-6878a93f502d', '53b44a56-ffc0-4618-bccf-8b04a93f502d', '53b44a56-ffc0-4618-bccf-8b04a93f502d', 'crazy', 'crayz', 'yvanscher', 24, 0, 3, 2.74815, '2014-07-19 06:14:02', '2014-07-19 06:14:02'),
(47, '53b197c2-cd24-4d30-9e4a-6878a93f502d', '53ca9766-1c68-42ba-879d-65afa93f502d', '53ca9766-1c68-42ba-879d-65afa93f502d', 'REGEXNEW', '$this-&gt;request-&gt;data[&#039;Upload&#039;][&#039;description&#039;] = str_replace(&quot;&amp;sect;&quot;, &quot;&amp;sect;&quot;, $this-&gt;request-&gt;data[&#039;Upload&#039;][&#039;description&#039;]);http:&amp;sect;&amp;sect;localhost:8888&amp;sect;cakephp-cakephp-0a6d85c&amp;sect;upload', 'yvanscher', 1, 0, 0, 1, '2014-07-19 18:07:38', '2014-07-19 18:07:38'),
(48, '53b197c2-cd24-4d30-9e4a-6878a93f502d', '53cab055-f124-4583-9942-7ad0a93f502d', '53cab055-f124-4583-9942-7ad0a93f502d', ' Canon EW-73B Lens Hood ', 'Printed at 0,15 mm layer height, with 50% infill. This took 156 minutes and used 204 g of filament', 'yvanscher', 0, 1, 0, 1, '2014-07-23 20:36:44', '2014-07-23 20:36:44');

-- --------------------------------------------------------

--
-- Table structure for table `products`
--

CREATE TABLE `products` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `product_id` char(36) COLLATE utf8_unicode_ci NOT NULL,
  `main_id` char(36) COLLATE utf8_unicode_ci NOT NULL,
  `number_downloads` int(11) NOT NULL,
  `likes` int(11) NOT NULL,
  `dislikes` int(11) NOT NULL,
  `rank` int(11) NOT NULL,
  `true_rank` float NOT NULL,
  `created` datetime NOT NULL,
  `modified` datetime NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `product_id` (`product_id`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci AUTO_INCREMENT=19 ;

--
-- Dumping data for table `products`
--

INSERT INTO `products` (`id`, `product_id`, `main_id`, `number_downloads`, `likes`, `dislikes`, `rank`, `true_rank`, `created`, `modified`) VALUES
(2, '53b19842-e054-4662-b9fd-67d6a93f502d', '53b19842-e054-4662-b9fd-67d6a93f502d', 0, 6, 1, 1, 1.39172, '2014-07-08 00:21:44', '2014-07-08 00:21:44'),
(3, '53b19a8f-9d78-4ded-9d7f-66bfa93f502d', '53b19a8f-9d78-4ded-9d7f-66bfa93f502d', 0, 12, 0, 2, 2.14877, '2014-07-08 00:21:51', '2014-07-08 00:21:51'),
(4, '53b19ae9-7340-4077-ad58-69fca93f502d', '53b19ae9-7340-4077-ad58-69fca93f502d', 0, 2, 1, 0, 0, '2014-07-08 00:22:09', '2014-07-08 00:22:09'),
(5, '53b19c59-dc2c-47f5-a507-66bfa93f502d', '53b19c59-dc2c-47f5-a507-66bfa93f502d', 0, 3, 0, 1, 0.95, '2014-07-08 00:22:10', '2014-07-08 00:22:10'),
(6, '53b1e56f-0ed8-4b7a-ab4c-717ca93f502d', '53b1e56f-0ed8-4b7a-ab4c-717ca93f502d', 0, 4, 1, 1, 0.95, '2014-07-08 00:22:11', '2014-07-08 00:22:11'),
(7, '53b1dda8-d838-4ff4-a9e2-6daba93f502d', '53b1dda8-d838-4ff4-a9e2-6daba93f502d', 0, 6, 0, 2, 1.54938, '2014-07-08 00:22:12', '2014-07-08 00:22:12'),
(8, '53b1d5fa-e1b0-4d5a-857f-6860a93f502d', '53b1d5fa-e1b0-4d5a-857f-6860a93f502d', 0, 1, 2, 0, 0, '2014-07-08 00:22:13', '2014-07-08 00:22:13'),
(9, '53b1d5cb-7424-4200-bfb7-6878a93f502d', '53b1d5cb-7424-4200-bfb7-6878a93f502d', 0, 2, 1, 0, 0, '2014-07-08 00:22:14', '2014-07-08 00:22:14'),
(10, '53b1ec7d-4050-4dfe-b95d-7361a93f502d', '53b1ec7d-4050-4dfe-b95d-7361a93f502d', 0, 2, 1, 0, 0, '2014-07-08 00:22:15', '2014-07-08 00:22:15'),
(11, '53b2eb05-4408-4f40-8e5e-7d87a93f502d', '53b2eb05-4408-4f40-8e5e-7d87a93f502d', 0, 4, 0, 1, 1.19877, '2014-07-08 00:22:16', '2014-07-08 00:22:16'),
(12, '53b44a31-e840-4c0b-94f2-8a22a93f502d', '53b44a31-e840-4c0b-94f2-8a22a93f502d', 0, 1, 2, 0, 0, '2014-07-08 00:22:17', '2014-07-08 00:22:17'),
(13, '53b44a4b-843c-4ec8-97e6-8beca93f502d', '53b44a4b-843c-4ec8-97e6-8beca93f502d', 0, 1, 2, 0, 0, '2014-07-08 00:22:18', '2014-07-08 00:22:18'),
(14, '53b44a56-ffc0-4618-bccf-8b04a93f502d', '53b44a56-ffc0-4618-bccf-8b04a93f502d', 0, 24, 0, 3, 2.74815, '2014-07-08 00:22:20', '2014-07-08 00:22:20'),
(15, '53b44ad4-86b8-444e-8e83-8a22a93f502d', '53b44ad4-86b8-444e-8e83-8a22a93f502d', 0, 4, 0, 1, 1.19877, '2014-07-08 00:22:20', '2014-07-08 00:22:20'),
(16, '53b8673e-fd14-490e-ad1f-9c4ca93f502d', '53b8673e-fd14-490e-ad1f-9c4ca93f502d', 0, 4, 0, 1, 1.19877, '2014-07-08 00:22:21', '2014-07-08 00:22:21'),
(17, '53ca9766-1c68-42ba-879d-65afa93f502d', '53ca9766-1c68-42ba-879d-65afa93f502d', 0, 1, 0, 0, 1, '2014-07-19 18:07:38', '2014-07-19 18:07:38'),
(18, '53cab055-f124-4583-9942-7ad0a93f502d', '53cab055-f124-4583-9942-7ad0a93f502d', 0, 0, 1, 0, 1, '2014-07-23 20:36:44', '2014-07-23 20:36:44');

-- --------------------------------------------------------

--
-- Table structure for table `profiles`
--

CREATE TABLE `profiles` (
  `id` int(11) NOT NULL,
  `created` datetime NOT NULL,
  `modified` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `self`
--

CREATE TABLE `self` (
  `model_title` char(50) DEFAULT NULL,
  `model_size` char(50) DEFAULT NULL,
  `model_id` char(36) DEFAULT NULL,
  `user_id` char(36) DEFAULT NULL,
  `user_name` varchar(45) DEFAULT NULL,
  `file_exten` char(10) DEFAULT NULL,
  `model_description` text,
  `likes` int(11) DEFAULT NULL,
  `dislikes` int(11) DEFAULT NULL,
  `rank` int(11) DEFAULT NULL,
  `true_rank` float DEFAULT NULL,
  `num_pics` int(11) DEFAULT NULL,
  `num_mods` int(11) DEFAULT NULL,
  `file_types` int(11) DEFAULT NULL,
  `created` datetime DEFAULT NULL,
  `modified` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Table structure for table `uploads`
--

CREATE TABLE `uploads` (
  `id` char(36) COLLATE utf8_unicode_ci NOT NULL,
  `user_id` char(36) COLLATE utf8_unicode_ci NOT NULL,
  `main_id` char(36) COLLATE utf8_unicode_ci NOT NULL,
  `product_id` char(36) COLLATE utf8_unicode_ci NOT NULL,
  `profile_id` char(36) COLLATE utf8_unicode_ci NOT NULL,
  `likes` int(11) NOT NULL,
  `dislikes` int(11) NOT NULL,
  `rank` int(11) NOT NULL,
  `true_rank` float NOT NULL,
  `filemanager_id` char(36) COLLATE utf8_unicode_ci NOT NULL,
  `username` varchar(45) COLLATE utf8_unicode_ci NOT NULL,
  `title` varchar(45) COLLATE utf8_unicode_ci NOT NULL,
  `description` text COLLATE utf8_unicode_ci NOT NULL,
  `filename` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `filesize` int(11) unsigned NOT NULL DEFAULT '0',
  `number_stls` int(11) NOT NULL,
  `file_types` int(11) NOT NULL,
  `filemime` varchar(45) COLLATE utf8_unicode_ci NOT NULL DEFAULT 'text/plain',
  `picturename` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `picturesize` int(11) NOT NULL,
  `picturemime` varchar(45) COLLATE utf8_unicode_ci NOT NULL,
  `created` datetime NOT NULL,
  `modified` datetime NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

--
-- Dumping data for table `uploads`
--

INSERT INTO `uploads` (`id`, `user_id`, `main_id`, `product_id`, `profile_id`, `likes`, `dislikes`, `rank`, `true_rank`, `filemanager_id`, `username`, `title`, `description`, `filename`, `filesize`, `number_stls`, `file_types`, `filemime`, `picturename`, `picturesize`, `picturemime`, `created`, `modified`) VALUES
('53b19842-e054-4662-b9fd-67d6a93f502d', '53b197c2-cd24-4d30-9e4a-6878a93f502d', '53b19842-e054-4662-b9fd-67d6a93f502d', '53b19842-e054-4662-b9fd-67d6a93f502d', '53b197c2-cd24-4d30-9e4a-6878a93f502d', 6, 1, 1, 1.39172, '53b197c2-cd24-4d30-9e4a-6878a93f502d', 'yvanscher', 'testupload', 'testupload', 'DefDist_Cuomo_AR15_30_Mag_Base_Plate.STL', 1256684, 1, 1, 'application/octet-stream', '1970 Chevelle Hot-Rod.jpg', 55642, 'image/jpeg', '2014-06-30 19:02:58', '2014-06-30 19:02:58'),
('53b19a8f-9d78-4ded-9d7f-66bfa93f502d', '53b197c2-cd24-4d30-9e4a-6878a93f502d', '53b19a8f-9d78-4ded-9d7f-66bfa93f502d', '53b19a8f-9d78-4ded-9d7f-66bfa93f502d', '53b197c2-cd24-4d30-9e4a-6878a93f502d', 12, 0, 2, 2.14877, '53b197c2-cd24-4d30-9e4a-6878a93f502d', 'yvanscher', 'selftest', 'selftest', 'DefDist_Cuomo_AR15_30_Mag_Base_Plate.STL', 1256684, 1, 1, 'application/octet-stream', '1970 Chevelle Hot-Rod.jpg', 55642, 'image/jpeg', '2014-06-30 19:12:47', '2014-06-30 19:12:47'),
('53b19ae9-7340-4077-ad58-69fca93f502d', '53b197c2-cd24-4d30-9e4a-6878a93f502d', '53b19ae9-7340-4077-ad58-69fca93f502d', '53b19ae9-7340-4077-ad58-69fca93f502d', '53b197c2-cd24-4d30-9e4a-6878a93f502d', 2, 1, 0, 0, '53b197c2-cd24-4d30-9e4a-6878a93f502d', 'yvanscher', 'selftest2', 'selftest2', 'DefDist_Cuomo_AR15_30_Mag_Base_Plate.STL', 1256684, 1, 1, 'application/octet-stream', '1970 Chevelle Hot-Rod.jpg', 55642, 'image/jpeg', '2014-06-30 19:14:18', '2014-06-30 19:14:18'),
('53b19c59-dc2c-47f5-a507-66bfa93f502d', '53b197c2-cd24-4d30-9e4a-6878a93f502d', '53b19c59-dc2c-47f5-a507-66bfa93f502d', '53b19c59-dc2c-47f5-a507-66bfa93f502d', '53b197c2-cd24-4d30-9e4a-6878a93f502d', 3, 0, 1, 0.95, '53b197c2-cd24-4d30-9e4a-6878a93f502d', 'yvanscher', 'asdasdasdasdsa', 'asdasdasds', 'dragon.stl', 136584, 1, 1, 'application/octet-stream', '1970 Chevelle Hot-Rod.jpg', 55642, 'image/jpeg', '2014-06-30 19:20:26', '2014-06-30 19:20:26'),
('53b1d5cb-7424-4200-bfb7-6878a93f502d', '53b197c2-cd24-4d30-9e4a-6878a93f502d', '53b1d5cb-7424-4200-bfb7-6878a93f502d', '53b1d5cb-7424-4200-bfb7-6878a93f502d', '53b197c2-cd24-4d30-9e4a-6878a93f502d', 2, 1, 0, 0, '53b197c2-cd24-4d30-9e4a-6878a93f502d', 'yvanscher', 'design1self', 'selftest', 'Catch.STL', 55884, 1, 1, 'application/octet-stream', '1970 Chevelle Hot-Rod.jpg', 55642, 'image/jpeg', '2014-06-30 23:25:31', '2014-06-30 23:25:31'),
('53b1d5fa-e1b0-4d5a-857f-6860a93f502d', '53b197c2-cd24-4d30-9e4a-6878a93f502d', '53b1d5fa-e1b0-4d5a-857f-6860a93f502d', '53b1d5fa-e1b0-4d5a-857f-6860a93f502d', '53b197c2-cd24-4d30-9e4a-6878a93f502d', 1, 2, 0, 0, '53b197c2-cd24-4d30-9e4a-6878a93f502d', 'yvanscher', 'yourmom1self', 'asdasdasdas', 'DefDist_Cuomo_AR15_30_Mag_Base_Plate.STL', 1256684, 1, 1, 'application/octet-stream', '1970 Chevelle Hot-Rod.jpg', 55642, 'image/jpeg', '2014-06-30 23:26:18', '2014-06-30 23:26:18'),
('53b1dda8-d838-4ff4-a9e2-6daba93f502d', '53b197c2-cd24-4d30-9e4a-6878a93f502d', '53b1dda8-d838-4ff4-a9e2-6daba93f502d', '53b1dda8-d838-4ff4-a9e2-6daba93f502d', '53b197c2-cd24-4d30-9e4a-6878a93f502d', 6, 0, 2, 1.54938, '53b197c2-cd24-4d30-9e4a-6878a93f502d', 'yvanscher', 'self4', 'self4work', 'DefDist_Cuomo_AR15_30_Mag_Coupler.STL', 3710584, 1, 1, 'application/octet-stream', '1970 Chevelle Hot-Rod.jpg', 55642, 'image/jpeg', '2014-06-30 23:59:05', '2014-06-30 23:59:05'),
('53b1e56f-0ed8-4b7a-ab4c-717ca93f502d', '53b197c2-cd24-4d30-9e4a-6878a93f502d', '53b1e56f-0ed8-4b7a-ab4c-717ca93f502d', '53b1e56f-0ed8-4b7a-ab4c-717ca93f502d', '53b197c2-cd24-4d30-9e4a-6878a93f502d', 4, 1, 1, 0.95, '53b197c2-cd24-4d30-9e4a-6878a93f502d', 'yvanscher', 'yourmom', 'yourmomtestg5', 'DefDist_Cuomo_AR15_30_Mag_Coupler.STL', 3710584, 1, 1, 'application/octet-stream', '1970 Chevelle Hot-Rod.jpg', 55642, 'image/jpeg', '2014-07-01 00:32:16', '2014-07-01 00:32:16'),
('53b1ec7d-4050-4dfe-b95d-7361a93f502d', '53b197c2-cd24-4d30-9e4a-6878a93f502d', '53b1ec7d-4050-4dfe-b95d-7361a93f502d', '53b1ec7d-4050-4dfe-b95d-7361a93f502d', '53b197c2-cd24-4d30-9e4a-6878a93f502d', 2, 1, 0, 0, '53b197c2-cd24-4d30-9e4a-6878a93f502d', 'yvanscher', 'seconfifle', 'file2', 'dragon.stl', 136584, 1, 1, 'application/octet-stream', '1970 Chevelle Hot-Rod.jpg', 55642, 'image/jpeg', '2014-07-01 01:02:21', '2014-07-01 01:02:21'),
('53b2eb05-4408-4f40-8e5e-7d87a93f502d', '53b1df54-9bc0-47d9-9a5a-6fafa93f502d', '53b2eb05-4408-4f40-8e5e-7d87a93f502d', '53b2eb05-4408-4f40-8e5e-7d87a93f502d', '53b1df54-9bc0-47d9-9a5a-6fafa93f502d', 4, 0, 1, 1.19877, '53b1df54-9bc0-47d9-9a5a-6fafa93f502d', 'crazyha', 'multiple color', 'multi color', 'DefDist_Cuomo_AR15_30_Mag_Coupler.STL', 3710584, 3, 1, 'application/octet-stream', '1970 Chevelle Hot-Rod.jpg', 55642, 'image/jpeg', '2014-07-01 19:08:22', '2014-07-01 19:08:22'),
('53b44a31-e840-4c0b-94f2-8a22a93f502d', '53b197c2-cd24-4d30-9e4a-6878a93f502d', '53b44a31-e840-4c0b-94f2-8a22a93f502d', '53b44a31-e840-4c0b-94f2-8a22a93f502d', '53b197c2-cd24-4d30-9e4a-6878a93f502d', 1, 2, 0, 0, '53b197c2-cd24-4d30-9e4a-6878a93f502d', 'yvanscher', 'thridfile', 'thirdfile', 'DefDist_Cuomo_AR15_30_Mag_Follower.stl', 4986484, 4, 1, 'application/octet-stream', '1970 Chevelle Hot-Rod.jpg', 55642, 'image/jpeg', '2014-07-02 20:06:42', '2014-07-02 20:06:42'),
('53b44a4b-843c-4ec8-97e6-8beca93f502d', '53b197c2-cd24-4d30-9e4a-6878a93f502d', '53b44a4b-843c-4ec8-97e6-8beca93f502d', '53b44a4b-843c-4ec8-97e6-8beca93f502d', '53b197c2-cd24-4d30-9e4a-6878a93f502d', 1, 2, 0, 0, '53b197c2-cd24-4d30-9e4a-6878a93f502d', 'yvanscher', 'fourthfile', 'fourth', 'DefDist_Cuomo_AR15_30_Mag_Base_Plate.STL', 1256684, 1, 1, 'application/octet-stream', '1970 Chevelle Hot-Rod.jpg', 55642, 'image/jpeg', '2014-07-02 20:07:07', '2014-07-02 20:07:07'),
('53b44a56-ffc0-4618-bccf-8b04a93f502d', '53b197c2-cd24-4d30-9e4a-6878a93f502d', '53b44a56-ffc0-4618-bccf-8b04a93f502d', '53b44a56-ffc0-4618-bccf-8b04a93f502d', '53b197c2-cd24-4d30-9e4a-6878a93f502d', 24, 0, 3, 2.74815, '53b197c2-cd24-4d30-9e4a-6878a93f502d', 'yvanscher', 'crazy', 'crayz', 'DefDist_Cuomo_AR15_30_Mag_Base_Plate.STL', 1256684, 1, 1, 'application/octet-stream', '1970 Chevelle Hot-Rod.jpg', 55642, 'image/jpeg', '2014-07-02 20:07:19', '2014-07-02 20:07:19'),
('53b44ad4-86b8-444e-8e83-8a22a93f502d', '53b197c2-cd24-4d30-9e4a-6878a93f502d', '53b44ad4-86b8-444e-8e83-8a22a93f502d', '53b44ad4-86b8-444e-8e83-8a22a93f502d', '53b197c2-cd24-4d30-9e4a-6878a93f502d', 4, 0, 1, 1.19877, '53b197c2-cd24-4d30-9e4a-6878a93f502d', 'yvanscher', 'boredasshit', 'asdkasdaskjdaskdasjdsa', 'DefDist_Cuomo_AR15_30_Mag_Body.STL', 4833184, 1, 1, 'application/octet-stream', '1970 Chevelle Hot-Rod.jpg', 55642, 'image/jpeg', '2014-07-02 20:09:25', '2014-07-02 20:09:25'),
('53b8673e-fd14-490e-ad1f-9c4ca93f502d', '53b1df54-9bc0-47d9-9a5a-6fafa93f502d', '53b8673e-fd14-490e-ad1f-9c4ca93f502d', '53b8673e-fd14-490e-ad1f-9c4ca93f502d', '53b1df54-9bc0-47d9-9a5a-6fafa93f502d', 4, 0, 1, 1.19877, '53b1df54-9bc0-47d9-9a5a-6fafa93f502d', 'crazyha', 'multicolor2', 'multicolor2', 'DefDist_Cuomo_AR15_30_Mag_Coupler.STL', 3710584, 3, 1, 'application/octet-stream', '1970 Chevelle Hot-Rod.jpg', 55642, 'image/jpeg', '2014-07-05 22:59:43', '2014-07-05 22:59:43'),
('53ca91ea-e69c-4ffc-b3d3-6f59a93f502d', '53b197c2-cd24-4d30-9e4a-6878a93f502d', '53ca91ea-e69c-4ffc-b3d3-6f59a93f502d', '53ca91ea-e69c-4ffc-b3d3-6f59a93f502d', '53b197c2-cd24-4d30-9e4a-6878a93f502d', 0, 0, 0, 0, '53b197c2-cd24-4d30-9e4a-6878a93f502d', 'yvanscher', 'REGEXTEST', 'http://localhost:8888/cakephp-cakephp-0a6d85c/upload', 'Catch.STL', 55884, 1, 1, 'application/octet-stream', '1970 Chevelle Hot-Rod.jpg', 55642, 'image/jpeg', '2014-07-19 17:42:34', '2014-07-19 17:42:34'),
('53ca9766-1c68-42ba-879d-65afa93f502d', '53b197c2-cd24-4d30-9e4a-6878a93f502d', '53ca9766-1c68-42ba-879d-65afa93f502d', '53ca9766-1c68-42ba-879d-65afa93f502d', '53b197c2-cd24-4d30-9e4a-6878a93f502d', 1, 0, 0, 0, '53b197c2-cd24-4d30-9e4a-6878a93f502d', 'yvanscher', 'REGEXNEW', '$this-&gt;request-&gt;data[&#039;Upload&#039;][&#039;description&#039;] = str_replace(&quot;&amp;sect;&quot;, &quot;&amp;sect;&quot;, $this-&gt;request-&gt;data[&#039;Upload&#039;][&#039;description&#039;]);http:&amp;sect;&amp;sect;localhost:8888&amp;sect;cakephp-cakephp-0a6d85c&amp;sect;upload', 'DefDist_Cuomo_AR15_30_Mag_Coupler.STL', 3710584, 1, 1, 'application/octet-stream', '1970 Chevelle Hot-Rod.jpg', 55642, 'image/jpeg', '2014-07-19 18:05:58', '2014-07-19 18:05:58'),
('53ca9b5b-9570-4501-8674-74aaa93f502d', '53b197c2-cd24-4d30-9e4a-6878a93f502d', '53ca9b5b-9570-4501-8674-74aaa93f502d', '53ca9b5b-9570-4501-8674-74aaa93f502d', '53b197c2-cd24-4d30-9e4a-6878a93f502d', 0, 0, 0, 0, '53b197c2-cd24-4d30-9e4a-6878a93f502d', 'yvanscher', 'New REGEX again', ' $this-&gt;request-&gt;data[&#039;Upload&#039;][&#039;id&#039;] = $id; //$id is a unique id created for the upload iteself\\n          $this-&gt;request-&gt;data[&#039;Upload&#039;][&#039;main_id&#039;] = $id;http://localhost:8888/cakephp-cakephp-0a6d85c/upload', 'DefDist_Cuomo_AR15_30_Mag_Follower.stl', 4986484, 1, 1, 'application/octet-stream', '1970 Chevelle Hot-Rod.jpg', 55642, 'image/jpeg', '2014-07-19 18:22:52', '2014-07-19 18:22:52'),
('53ca9c3d-59c4-45f9-a127-74f9a93f502d', '53b197c2-cd24-4d30-9e4a-6878a93f502d', '53ca9c3d-59c4-45f9-a127-74f9a93f502d', '53ca9c3d-59c4-45f9-a127-74f9a93f502d', '53b197c2-cd24-4d30-9e4a-6878a93f502d', 0, 0, 0, 0, '53b197c2-cd24-4d30-9e4a-6878a93f502d', 'yvanscher', 'http://localhost:8888/cakephp-cakephp-0a6d85c', 'http://localhost:8888/cakephp-cakephp-0a6d85c/uploadhttp://localhost:8888/cakephp-cakephp-0a6d85c/upload', 'DefDist_Cuomo_AR15_30_Mag_Body.STL', 4833184, 1, 1, 'application/octet-stream', '1970 Chevelle Hot-Rod.jpg', 55642, 'image/jpeg', '2014-07-19 18:26:38', '2014-07-19 18:26:38'),
('53caa40c-f3b4-4ee9-9601-7813a93f502d', '53b197c2-cd24-4d30-9e4a-6878a93f502d', '53caa40c-f3b4-4ee9-9601-7813a93f502d', '53caa40c-f3b4-4ee9-9601-7813a93f502d', '53b197c2-cd24-4d30-9e4a-6878a93f502d', 0, 0, 0, 0, '53b197c2-cd24-4d30-9e4a-6878a93f502d', 'yvanscher', '&lt; &gt; # % { } | \\\\\\\\ ^ ~ [ ]', '&lt; &gt; # % { } | \\\\\\\\ ^ ~ [ ]', 'DefDist_Cuomo_AR15_30_Mag_Body.STL', 4833184, 1, 1, 'application/octet-stream', '1970 Chevelle Hot-Rod.jpg', 55642, 'image/jpeg', '2014-07-19 18:59:56', '2014-07-19 18:59:56'),
('53caa468-5cec-4e54-8cef-74f9a93f502d', '53b197c2-cd24-4d30-9e4a-6878a93f502d', '53caa468-5cec-4e54-8cef-74f9a93f502d', '53caa468-5cec-4e54-8cef-74f9a93f502d', '53b197c2-cd24-4d30-9e4a-6878a93f502d', 0, 0, 0, 0, '53b197c2-cd24-4d30-9e4a-6878a93f502d', 'yvanscher', '$ &amp; + , / : ; = ? @', '$ &amp; + , / : ; = ? @', 'DefDist_Cuomo_AR15_30_Mag_Body.STL', 4833184, 1, 1, 'application/octet-stream', '1970 Chevelle Hot-Rod.jpg', 55642, 'image/jpeg', '2014-07-19 19:01:29', '2014-07-19 19:01:29'),
('53caa7a4-70c0-490e-89ff-6e43a93f502d', '53b197c2-cd24-4d30-9e4a-6878a93f502d', '53caa7a4-70c0-490e-89ff-6e43a93f502d', '53caa7a4-70c0-490e-89ff-6e43a93f502d', '53b197c2-cd24-4d30-9e4a-6878a93f502d', 0, 0, 0, 0, '53b197c2-cd24-4d30-9e4a-6878a93f502d', 'yvanscher', 'http://localhost:8888/cakephp-cakephp-0a6d85c', '&lt;a href=&quot;http://localhost:8888/cakephp-cakephp-0a6d85c/upload&quot;&gt;CrazyBlah&lt;/a&gt;', 'DefDist_Cuomo_AR15_30_Mag_Follower.stl', 4986484, 1, 1, 'application/octet-stream', '1970 Chevelle Hot-Rod.jpg', 55642, 'image/jpeg', '2014-07-19 19:15:17', '2014-07-19 19:15:17'),
('53cab055-f124-4583-9942-7ad0a93f502d', '53b197c2-cd24-4d30-9e4a-6878a93f502d', '53cab055-f124-4583-9942-7ad0a93f502d', '53cab055-f124-4583-9942-7ad0a93f502d', '53b197c2-cd24-4d30-9e4a-6878a93f502d', 0, 1, 0, 0, '53b197c2-cd24-4d30-9e4a-6878a93f502d', 'yvanscher', ' Canon EW-73B Lens Hood ', 'Printed at 0,15 mm layer height, with 50% infill. This took 156 minutes and used 204 g of filament', 'f4ea8ab76655dc50024cc70743926df20466d831.STL', 3019084, 1, 1, 'application/octet-stream', 'ced41b93273e60ed198e07fba1b29300b3e87f18.jpg', 322008, 'image/jpeg', '2014-07-19 19:52:21', '2014-07-19 19:52:21'),
('53cab0a8-6080-48aa-9c7c-7ccda93f502d', '53b197c2-cd24-4d30-9e4a-6878a93f502d', '53cab0a8-6080-48aa-9c7c-7ccda93f502d', '53cab0a8-6080-48aa-9c7c-7ccda93f502d', '53b197c2-cd24-4d30-9e4a-6878a93f502d', 0, 0, 0, 0, '53b197c2-cd24-4d30-9e4a-6878a93f502d', 'yvanscher', ' Canon EW-73B Lens Hood ', 'Printed at 0,15 mm layer height, with 50% infill. This took 156 minutes and used 20,4 g of filament', 'f4ea8ab76655dc50024cc70743926df20466d831.STL', 3019084, 1, 1, 'application/octet-stream', 'ced41b93273e60ed198e07fba1b29300b3e87f18.jpg', 322008, 'image/jpeg', '2014-07-19 19:53:45', '2014-07-19 19:53:45'),
('53d30077-bb64-4078-b931-34d8a93f502d', '53b197c2-cd24-4d30-9e4a-6878a93f502d', '53d30077-bb64-4078-b931-34d8a93f502d', '53d30077-bb64-4078-b931-34d8a93f502d', '53b197c2-cd24-4d30-9e4a-6878a93f502d', 0, 0, 0, 0, '53b197c2-cd24-4d30-9e4a-6878a93f502d', 'yvanscher', 'ewok', 'lightsaber', 'DefDist_Cuomo_AR15_30_Mag_Follower.stl', 4986484, 1, 1, 'application/octet-stream', '1970 Chevelle Hot-Rod.jpg', 55642, 'image/jpeg', '2014-07-26 03:12:24', '2014-07-26 03:12:24'),
('53d30081-805c-4c1d-9306-2d07a93f502d', '53b197c2-cd24-4d30-9e4a-6878a93f502d', '53d30081-805c-4c1d-9306-2d07a93f502d', '53d30081-805c-4c1d-9306-2d07a93f502d', '53b197c2-cd24-4d30-9e4a-6878a93f502d', 0, 0, 0, 0, '53b197c2-cd24-4d30-9e4a-6878a93f502d', 'yvanscher', 'ewok', 'lightsaber', 'DefDist_Cuomo_AR15_30_Mag_Follower.stl', 4986484, 1, 1, 'application/octet-stream', '1970 Chevelle Hot-Rod.jpg', 55642, 'image/jpeg', '2014-07-26 03:12:33', '2014-07-26 03:12:33'),
('53d3009f-a3fc-448e-83ca-35f8a93f502d', '53b197c2-cd24-4d30-9e4a-6878a93f502d', '53d3009f-a3fc-448e-83ca-35f8a93f502d', '53d3009f-a3fc-448e-83ca-35f8a93f502d', '53b197c2-cd24-4d30-9e4a-6878a93f502d', 0, 0, 0, 0, '53b197c2-cd24-4d30-9e4a-6878a93f502d', 'yvanscher', 'ewok', 'lightsaber1', 'DefDist_Cuomo_AR15_30_Mag_Body.STL', 4833184, 1, 1, 'application/octet-stream', '1970 Chevelle Hot-Rod.jpg', 55642, 'image/jpeg', '2014-07-26 03:13:03', '2014-07-26 03:13:03'),
('53d300c9-d3b8-4e9f-8531-34d8a93f502d', '53b197c2-cd24-4d30-9e4a-6878a93f502d', '53d300c9-d3b8-4e9f-8531-34d8a93f502d', '53d300c9-d3b8-4e9f-8531-34d8a93f502d', '53b197c2-cd24-4d30-9e4a-6878a93f502d', 0, 0, 0, 0, '53b197c2-cd24-4d30-9e4a-6878a93f502d', 'yvanscher', 'ewok', 'lightsaber4', 'DefDist_Cuomo_AR15_30_Mag_Coupler.STL', 3710584, 3, 1, 'application/octet-stream', '1970 Chevelle Hot-Rod.jpg', 55642, 'image/jpeg', '2014-07-26 03:13:46', '2014-07-26 03:13:46');

-- --------------------------------------------------------

--
-- Table structure for table `users`
--

CREATE TABLE `users` (
  `id` char(36) COLLATE utf8_unicode_ci NOT NULL,
  `username` varchar(45) COLLATE utf8_unicode_ci NOT NULL,
  `password` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `email` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `number_followers` int(50) NOT NULL,
  `number_downloads` int(50) NOT NULL,
  `created` datetime DEFAULT NULL,
  `modified` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

--
-- Dumping data for table `users`
--

INSERT INTO `users` (`id`, `username`, `password`, `email`, `number_followers`, `number_downloads`, `created`, `modified`) VALUES
('53b197c2-cd24-4d30-9e4a-6878a93f502d', 'yvanscher', '10b8e4723c578203e4d874e5918ec3aaf56ad86d', '', 9, 0, '2014-06-30 19:00:50', '2014-06-30 19:00:50'),
('53b1df54-9bc0-47d9-9a5a-6fafa93f502d', 'crazyha', '10b8e4723c578203e4d874e5918ec3aaf56ad86d', '', 1, 0, '2014-07-01 00:06:12', '2014-07-01 00:06:12'),
('53cdd293-282c-4842-8ece-f245a93f502d', 'Pinkman', '10b8e4723c578203e4d874e5918ec3aaf56ad86d', '', 0, 0, '2014-07-22 04:55:15', '2014-07-22 04:55:15'),
('53cdea18-0a30-4fe9-a9f9-fb34a93f502d', 'Newuser', '10b8e4723c578203e4d874e5918ec3aaf56ad86d', '', 0, 0, '2014-07-22 06:35:36', '2014-07-22 06:35:36'),
('53cdec27-8398-4713-8549-fb6da93f502d', 'Pinkman2', '47f04318f0a6f5de26fb2d7b3cfa0d77444d62e6', '', 0, 0, '2014-07-22 06:44:23', '2014-07-22 06:44:23'),
('53ceb9f2-1e48-4698-9814-fd7da93f502d', 'sdsd', '10b8e4723c578203e4d874e5918ec3aaf56ad86d', '', 0, 0, '2014-07-22 21:22:26', '2014-07-22 21:22:26'),
('53cefdc2-f6c0-4b98-add8-4247a93f502d', 'yv', '10b8e4723c578203e4d874e5918ec3aaf56ad86d', '', 0, 0, '2014-07-23 02:11:46', '2014-07-23 02:11:46'),
('53d45153-bd78-47a3-84ee-6ca1a93f502d', 'anakin', '2c1267cf7c6cc8b519750b4b421e371c2a793ccd', '', 0, 0, '2014-07-27 03:09:39', '2014-07-27 03:09:39'),
('53d45169-dfa0-4e85-acd5-7547a93f502d', 'skywalker', '10b8e4723c578203e4d874e5918ec3aaf56ad86d', '', 0, 0, '2014-07-27 03:10:01', '2014-07-27 03:10:01');