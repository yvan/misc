#!/usr/bin/env node

var argv = require('minimist')(process.argv.slice(2))
var exterminator = require('./js/exterminator')
var importer = require('./js/importer')
var parser = require('./js/parser')
var digger = require('./js/digger')
var path = require('path')
var fs = require('fs')

module.exports = {

	unfreeze: function(filename, callback){
		parser.unfreeze(filename, callback)
	},

	freeze: function(scriptname, callback){
		parser.freeze(scriptname, callback)
	},

	excavate: function(filename, callback){
		digger.excavate(filename, callback)
	},

	import: function(scriptpath, callback){
		importer.importFile(scriptpath, callback)
	},

	remove: function(scriptname, callback){
		exterminator.remove(scriptname, callback)
	},

	// second parameter, optionalparam, is optional
	removeall: function(callback, optionalparam){
		exterminator.removeall(callback, optionalparam)
	}
}

// - experimented with templating a bit on this switch statement - //
// - in the freeze and unfreeze sections - //
var freezetemplate = '{sucessorfailure} processing of {jsfilename}!'
			        .replace('{jsfilename}', argv._[1])
var freezetxtsuccess = freezetemplate.replace('{sucessorfailure}', 'Success')
var freezetxtfailure = freezetemplate.replace('{sucessorfailure}', 'Failure')

switch(true){

	case (argv._[0] === "list") || (argv._[0] === "ls"):

		fs.readdir(path.join(__dirname,'icebox/frozen/'), function(err, files){
			console.log("Frozen files:")
			files.splice(0, 1) // remove the first element which is  hiddren file	
			console.log(files)
		})
		fs.readdir(path.join(__dirname,'icebox/unfrozen/'), function(err, files){
			console.log("Unfrozen files:")
			files.splice(0, 1) // remove the first element which is  hiddren file	
			console.log(files)
		})
	break;

	case (argv._[0] === "freeze") || (argv._[0] === "f"):

		module.exports.freeze(argv._[1], function(trueorfalse){
			if(trueorfalse === true){console.log(freezetxtsuccess)}
			else{console.log(freezetxtfailure)}
		})
	break;

	case (argv._[0] === "unfreeze") || (argv._[0] === "u"):

		module.exports.unfreeze(argv._[1], function(trueorfalse){
			if(trueorfalse === true){console.log(freezetxtsuccess)}
			else{console.log(freezetxtfailure)}
		})
	break;

	case (argv._[0] === "excavate") || (argv._[0] === "x"):

		if(path.extname(argv._[1]) === '.js'){

			module.exports.excavate(argv._[1], function(codedata){
 				process.stdout.write(codedata.toString())
			})
		}else if(path.extname(argv._[1]) === '.json'){
			module.exports.excavate(argv._[1], function(jsondata){

				for (var key in jsondata){
					if (jsondata.hasOwnProperty(key)) {
						process.stdout.write(jsondata[key]+'\n')
					}
				}
			})
		}
	break;

	case (argv._[0] === "import") || (argv._[0] === "i"):

		if(path.extname(argv._[1]) === '.js'){
			importer.importCommandLine(argv._[1], function(trueorfalse){

 				if(trueorfalse === true){console.log('successful import!')}
				else{console.log('unsuccessful import :(')}
			})
		}else if(path.extname(argv._[1]) === '.json'){
			importer.importCommandLine(argv._[1], function(trueorfalse){

	 			if(trueorfalse === true){console.log('successful import!')}
	 			else{console.log('unsuccessful import :(')}
			})
		}
	break;

	case (argv._[0] === "remove") || (argv._[0] === "r"):

		if(path.extname(argv._[1]) === '.js'){
			module.exports.remove(argv._[1],function(trueorfalse){

				if(trueorfalse === true){console.log('successful remove!')}
	 			else{console.log('unsuccessful remove :(')}
			})
		}else if (path.extname(argv._[1]) === '.json'){
			module.exports.remove(argv._[1], function(trueorfalse){

				if(trueorfalse === true){console.log('successful remove!')}
	 			else{console.log('unsuccessful remove :(')}
			})
		}
	break;

	case (argv._[0] === "removeall"):
		if(argv._[1] === 'js' || argv._[1] === 'json'){
			module.exports.removeall(function(trueorfalse){

			},argv._[1])
		}else{
			module.exports.removeall(function(trueorfalse){

			})
		}
	break;


	default:
		//default does nothing
}