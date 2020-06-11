var path = require('path')
var fs = require('fs')

module.exports = {
	remove: remove,
	removeall: removeall
}


function remove(filename, callback){

	if(path.extname(filename) === '.js'){
		//take a secondary input for std.in, a confirmation "Do you really want to delete all...blah blah"
		removeFile(path.join(__dirname,'../icebox/unfrozen/', filename),callback)
	}else if (path.extname(filename) === '.json'){
		removeFile(path.join(__dirname,'../icebox/frozen/', filename), callback)
	}
}

function removeall(callback, filetype){

	if(filetype === 'js'){
			//take a secondary input for std.in, a confirmation "Do you really want to delete all...blah blah"
		fs.readdir(path.join(__dirname,'../icebox/unfrozen/'), function(err, files){
			
			if(err){throw err}
			files.splice(0, 1) // remove the first element which is  hiddren file	

			for (var i = 0; i < files.length; i++) {

				removeFile(path.join(__dirname,'../icebox/unfrozen/', files[i]),callback)	
			}
		})
	}else if (filetype === 'json'){
		fs.readdir(path.join(__dirname,'../icebox/frozen/'), function(err, files){
			
			if(err){throw err}
			files.splice(0, 1) // remove the first element which is  hiddren file	

			for (var i = 0; i < files.length; i++) {

				removeFile(path.join(__dirname,'../icebox/frozen/', files[i]),callback)	
			}
		})

	}else{//neither is set remove all files from frozen and unfrozen
			//take a secondary input for std.in, a confirmation "Do you really want to delete all...blah blah"
		fs.readdir(path.join(__dirname,'../icebox/unfrozen/'), function(err, files){
			
			if(err){throw err}
			files.splice(0, 1) // remove the first element which is  hiddren file	

			for (var i = 0; i < files.length; i++) {

				removeFile(path.join(__dirname,'../icebox/unfrozen/', files[i]),callback)
			}
		})
		fs.readdir(path.join(__dirname,'../icebox/frozen/'), function(err, files){
			
			if(err){throw err}
			files.splice(0, 1) // remove the first element which is  hiddren file	

			for (var i = 0; i < files.length; i++) {

				removeFile(path.join(__dirname,'../icebox/frozen/', files[i]),callback)
			}
		})
	}
}

function removeFile(filetodelete, callback){

	fs.unlink(filetodelete, function (err) {
		if (err){callback(false);throw err}
		callback(true)
	})	
}
