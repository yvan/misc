#!/usr/bin/env node

var commander = require('commander')
var config = require('./config.json')
var fs = require('fs')

commander.version('0.0.3')
.usage('-options [KEYWORDS]')
.option('-u, --username [YOUR_USERNAME]', 'username you used to sign up for geonames')
.option('-l, --language [LANGUAGE_CODE] ', 'your language, default is english(en)')
.option('-c, --country [YOUR_COUNTRY]', 'set your country')
.parse(process.argv)

if(!process.argv[2]){
  commander.help()
}else{
  if(commander.username){
    config['geonames']['username'] = process.argv[3]
    fs.writeFile(__dirname+'/config.json', JSON.stringify(config, null, 4), function(err){
      if(err)throw err
      console.log('Added your username!')
    })
  }else if(commander.language){
    config['geonames']['language'] = process.argv[3]
    fs.writeFile(__dirname+'/config.json', JSON.stringify(config, null, 4), function(err){
      if(err)throw err
      console.log('Added your language!')
    })
  }else if(commander.country){
    config['geonames']['country'] = process.argv[3]
    fs.writeFile(__dirname+'/config.json', JSON.stringify(config, null, 4), function(err){
      if(err)throw err
      console.log('Added your country!')
    })
  }
}
