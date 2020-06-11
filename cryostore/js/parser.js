var lexerclass = require('./lexer')  
var path = require('path')
var fs = require('fs')

module.exports = {
	freeze:freeze,
	unfreeze:unstore
}

/*	- freeze uses a lexer to break down a javascript file
	- it then sotres it as JSON in the icebox/frozen folder
	- */

function freeze(scriptname, callback){

	// - create a lexer, stores the final JSONified script, line stores current JSON line - //
	var lexer = new lexerclass(), JSONifiedScript = {}, line = []

	/* 	- reader just reads in a file. scriptnae is a variable
		- passed by the user via the command line or in the .cryoconfig file
		- returns true or false depending on whether or not the tree was su
		- -ccessfully created and saved. Probably needs more error checking.
		*/
	reader(scriptname, function(codestring){
		
		var reduce = false
		var line_count = 0
		var paren_count = 0
		var brace_count = 0
		lexer.datain(codestring)
		var obj = JSON.stringify(lexer.nextToken())
		
		// - while there is a next Token get that token. - //
		while (obj){

			// - determines what part of code were looking at - //
			if(obj.name === 'L_PAREN'){
				paren_count++
			}else if(obj.name === 'R_PAREN'){
				paren_count--
				if(paren_count === 0){reduce = true}
			}else if(obj.name === 'L_BRACE'){
				brace_count++
				if(paren_count > 0 && brace_count === 1){reduce = true}
			}else if(obj.name === 'R_BRACE'){
				brace_count--
			}else if(obj.name === 'COMMENT'){
				reduce = true
			}else if(obj.name === 'NEWLINE'){
				obj.value = ''
				reduce = true
			}else if(obj.name === 'SEMICOLON'){
				obj.value = ';\n'
				reduce = true
			}

			// - push an object into the current JSON line - //
			line.push(obj.value) 
			// - only triggers when it's time to reduce the current line array - //
			if(reduce){	
				var finalcode = line.join('')
				JSONifiedScript[line_count] = finalcode
				reduce = false
				line_count++
				line = []
			}
			obj = lexer.nextToken() // - gets the next token - //
		}

		// - freezes the JSONified code and saves it to the icebox folder - //
		store(scriptname, JSONifiedScript, function(filesaved){ 
			filesaved ? callback(true):callback(false)
		})
	})
}

function unstore(filename, callback){

	if(path.extname(filename) === '.json'){
	
		var wholeScript = ''
		fs.readFile(__dirname+'/../icebox/frozen/'+filename, function(err, data){

			if(err){callback(false); throw err}
			var JSONscript = JSON.parse(data)
			for (var key in JSONscript){
				if(JSONscript[key] === ""){wholeScript+=JSONscript[key]}
				else{wholeScript+=JSONscript[key]+'\n'}
			}

			filename = path.basename(filename, '.json')
			filename += '.js'

			fs.writeFile(path.join(__dirname,'../icebox/unfrozen/',filename), wholeScript, function(err){
				if(err){callback(false); throw err}
				callback(true)
			})
		})
	}
}

/*	- reads stuff from the unfrozen directory
	- */
function reader(filename, callback){

	// - redundant, but I'm putting it in each one - //
	// - to avoid bugs in the future. - //
	if(path.extname(filename) === '.js'){

		fs.readFile(path.join(__dirname,'../icebox/unfrozen/',filename), function(err, data){

			if(err){throw err}
			callback(data.toString())
		})
	}
}

/* 	- stores stuff in the frozen directory 
	- */
function store(scriptname, parsetree, callback){

	if(path.extname(scriptname) === '.js'){

		scriptname = path.basename(scriptname, '.js')
		scriptname += '.json'

		fs.writeFile(path.join(__dirname,'../icebox/frozen/',scriptname), JSON.stringify(parsetree,null,4), function(err){

			if(err){callback(false); throw err}
			callback(true)
		})
	}
}
