/***
Scraping script that gets data from hackernews.

Created by Yvan Scher on Oct 3 2014

***/

var format = require('util').format
var request = require('request')
var cheerio = require('cheerio')
var async = require('async')
var fs = require('fs')
var uniqueindex = 0
var metadata = {}

module.exports = scrapeFunc

function scrapeFunc(callback){

  console.log('Getting you some hackerthoughts...')
  async.times(100, function(n,next){

      setTimeout(null, 2000)
      url = format('https://news.ycombinator.com/news?p=%s',n+1)
      fetch(url, next, n)
    },
    function(err){
      console.log('Done processing!')
      fs.writeFile(__dirname +'/scrapedata.json',
      JSON.stringify(metadata,null,4),
      function (err) {
        if(err) callback(err, null)
        callback(null, "Success we have you some hackerthoughts!")
      })
    }
  )
}

function fetch(url, next, n) {

  //console.log('CAll#: '+(n+1))
  request(url, function (error, response, html) {

    if(!error && response.statusCode == 200){

      //console.log('Response from site for %s!',n+1)
      var $ = cheerio.load(html)
      $('span.comhead').each(function(i, element){

        var item = $(this).prev();
        var rank = item.parent().parent().text();
        var title = item.text();
        var url = item.attr('href');
        var subtext = item.parent().parent().next().children('.subtext').children();
        var points = $(subtext).eq(0).text();
        var author = $(subtext).eq(1).text();
        var comments = $(subtext).eq(2).text();
        metadata[uniqueindex] = {
          rank: parseInt(rank),
          title: title,
          url: url,
          points: parseInt(points),
          author: author,
          comments: parseInt(comments),
          page: n+1,
        }
        uniqueindex++
      })
      next(null)
    }else{
      //console.log('Request #:%s Failed!',n+1)
      next(error)
    }
  })
}
