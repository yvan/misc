var path = require('path')
var fs = require('fs')

module.exports = {
	excavate:excavate
}

/*	- reads data from an unfrozen Javascript
	- and returns that data 
	- */
function excavate(scriptname, callback){

	if(path.extname(scriptname) === '.js'){
		fs.readFile(path.join(__dirname,'../icebox/unfrozen/',scriptname), function(err, data){

			if(err){callback(false); throw err}
			callback(data)
		})

	}else if(path.extname(scriptname) === '.json'){
		fs.readFile(path.join(__dirname,'../icebox/frozen/',scriptname), function(err, data){

			if(err){callback(false); throw err}
			var JSONscript = JSON.parse(data)
			callback(JSONscript)
		})
	}
}