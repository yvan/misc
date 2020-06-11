#!/usr/bin/env node

var functions = require('./functionality')
var commander = require('commander')
var scrape = require('./scrape')
var clc = require('cli-color')
var open = require('open')
var fs = require('fs')

var msgcolor = clc.xterm(228).bgXterm(204)

//make sure to keep commander version up to date with
//version in package.json
commander.version('1.0.0')
.usage('[options] <keywords>')
.option('-wtfh, --wtfhelp', 'dun gets you some help fast')
.option('-t, --toppage', 'get the top page of hackernews')
.option('-p, --page [pagenumber]', 'gets a page given by number')
.option('-s, --sample [sizeofsample]', 'get sample of headlines')
.parse(process.argv)

//initial run of "hackerthought" or "ht"
//populates our data files
if(!process.argv[2]){

  scrape(function(err, result){
    if(err)throw err
    console.log(result)
  })
}else{//we received an arugment, user wants something

  var post_json
  fs.readFile(__dirname +'/scrapedata.json', 'utf8', function(err, data){

    if(err) throw err
    post_json = JSON.parse(data)
    if(commander.toppage){

      title_array=functions.toppage(post_json)
      fs.writeFile(__dirname +'/recentdata.json',
      JSON.stringify(title_array,null,4),
      function (err) {
        if(err) throw err
        for(i=0; i<title_array[0].length;i++){
          console.log(msgcolor.bold.underline(i+1)+msgcolor.bold(" "+title_array[0][i]))
        }
      })
    }else if(commander.sample){

      title_arrays=functions.sample(post_json, process.argv[3])
    }else if(commander.page){

      title_array=functions.page(post_json, process.argv[3])
      fs.writeFile(__dirname +'/recentdata.json',
      JSON.stringify(title_array,null,4),
      function (err) {
        if(err) throw err
        for(i=0; i<title_array[0].length;i++){
          console.log(msgcolor.bold.underline(i+1)+msgcolor.bold(" "+title_array[0][i]))
        }
      })
    }else{//our first input is a number so we want to load a page from recentdata
      fs.readFile(__dirname +'/recentdata.json', 'utf8', function(err, data){
        if(err)throw err
        recent_data = JSON.parse(data)
        open(recent_data[1][process.argv[2]-1])
      })
    }
  })
}
