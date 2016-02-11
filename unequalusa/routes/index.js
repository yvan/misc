var express = require('express');
var router = express.Router();

/* GET home page. */
router.get('/', function(req, res, next) {
  res.render('index', { title: 'What is the distribution of wealth in America? Scroll to find out.' });
});

module.exports = router;
