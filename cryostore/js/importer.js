var path = require('path')
var fs = require('fs')

module.exports = {
	importFile:importFile,
	importCommandLine:importCommandLine
}

/*	- reads data from an unfrozen Javascript
	- and returns that data 
	- */
function importFile(filepath, callback){

	var filename = path.basename(filepath)

	if(path.extname(filepath) === '.js'){

		fs.readFile(path.join(__dirname,'../../',filepath), function(err, data){

			if(err){callback(false); throw err}
			fs.writeFile(path.join(__dirname,'../icebox/unfrozen/',filename), data, function(err, data){
				if(err){callback(false); throw err}
				callback(true)
			})
		})
	}else if(path.extname(filepath) === '.json'){			

		var filename = path.basename(filepath)

		fs.readFile(path.join(__dirname,'../../',filepath), function(err, data){

			if(err){callback(false); throw err}
			fs.writeFile(path.join(__dirname,'../icebox/frozen/',filename), data, function(err, data){
				if(err){callback(false); throw err}
				callback(true)
			})
		})
	}
}


// - These next two are exactly the same as the above except we've changed process.cwd() 
// - in fs.readFile to __dirname, these methods are for calling in code, whereas process.cwd() 
// - is for calling from the command line

/*	- reads data from an unfrozen Javascript
	- and returns that data 
	- */
function importCommandLine(scriptpath, callback){

	if(path.extname(scriptpath)==='.js'){

		var scriptname = path.basename(scriptpath)

		fs.readFile(path.join(process.cwd(),scriptpath), function(err, data){

			if(err){callback(false); throw err}
			fs.writeFile(path.join(__dirname,'../icebox/unfrozen/',scriptname), data, function(err, data){
				if(err){callback(false); throw err}
				callback(true)
			})
		})
	}else if(path.extname(scriptpath) === '.json'){

		var filename = path.basename(scriptpath)


		fs.readFile(path.join(process.cwd(),scriptpath), function(err, data){

			if(err){callback(false); throw err}
			fs.writeFile(path.join(__dirname,'../icebox/frozen/',filename), data, function(err, data){
				if(err){callback(false); throw err}
				callback(true)
			})
		})
	}
}


