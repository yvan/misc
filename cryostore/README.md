Cryostore - Converts Javascript into Frozen JSON scripts :snowflake:
====================================

[![NPM](https://nodei.co/npm/cryostore.png?downloads=true&downloadRank=true&stars=true)](https://nodei.co/npm/cryostore/)

This module takes your Javascript code and turns it into a JSON object. Insecure? Probably. Fun? Yes.

Installation:
============ 
```
npm install cryostore 	 // - your project directory, this is just for using javascript functions in your code - // 
npm install -g cryostore // - to use the global utility on the command line - //
```

It's very important to note that any time you use the command line, you are using the globally installed module and any frozen or unfrozen files will be located inside `/usr/local/lib/node_modules/cryostore/icebox/frozen` or `/usr/local/lib/node_modules/cryostore/icebox/unfrozen` on a mac or unix based system (On windows idk, good luck you're on your own).

Anytime you use the in-code methods like cryo.importJS(......) this will affect the locally installed copy in your current project. And you should be able to find the files in `./node_modules/cryostore/icebox/frozen` or `./node_modules/cryostore/icebox/frozen`

Usage (code): 
===========
```javascript

var cryo = require('cryostore')

// - imports a file from an arbitrary path into cryostore - //
// - imported JSON files should be files produced by cryostore - //

cryo.import('../arbitrary/path/to/jsorjson/file', function(trueorfalse){
 	if(trueorfalse === true){console.log('successful import!')}
	else{console.log('unsuccessful import :(')}
})

// - takes a .js file and turns into JSON - //
cryo.freeze('jsfile', function(success){
	console.log(success)
})

// - takes a .json file and turns into .js - //
cryo.unfreeze('jsonfile', function(success){
	console.log(success)
}) 

// - pulls out and returns data from a js (unfrozen) or json (frozen) file  - //
cryo.excavate('file', function(jsondata){
	for (var key in jsondata){
		console.log(jsondata[key])
	}
})

// - removes a file by name from frozen or unfrozen - //
cryo.remove('file',function(trueorfalse){

	if(trueorfalse === true){console.log('successful remove!')}
	else{console.log('unsuccessful remove :(')}
})

//- removes all files from the unfrozen (js) folder - //
cryo.removeall(function(trueorfalse){

},'js')//can replace 'js' with 'json' or leave the parameter empty entirely to clear all folders. 

``` 

Note that all paths in cryostore are relative paths from the current working directory.

Usage (terminal): 
================
```

cryostore ls           	      // lists frozen and unfrozen files
cryostore list 

cryostore f test.js          // freezes that file, js -> json
cryostore freeze test.js

cryostore u test.js          // unfreezes that json file, json -> js
cryostore unfreeze test.js

cryostore x test.json        // prints file data in the console
cryostore x test.js 
cryostore excavate test.json
cryostore excavate test.js 

cryostore i path/to/from/current/to/test.json // imports an existing file from somewhere into frozen/unfrozen 
cryostore i path/to/from/current/to/test.js
cryostore import path/to/from/current/to/test.js

cryostore r test.js 
cryostore r test.json
cryostore remove test.js     // removes a single file, test.js, from unfrozen
cryostore remove test.json   // removes a singel file, test.json, from frozen

cryostore removeall          // clears your icebox (frozen and unfrozen folders)
cryostore removeall js       // clears only your unfrozen (the one with the js files) folder
cryostore removeall json     // clears only your frozen (the one with the json files)folder

NOTE: All uses of 'cryostore' can be replaced with shorthand 'cryo'.


```

Icebox:
======
Contains frozen and unfrozen folders. Frozen is the place where JS gets stored as JSON. Contains .frozen.json file, don't overwrite it. Unfrozen is the place where your frozen JSON gets stored as JS. Contains .unfrozen.json file, don't overwrite it.

Example using async:
=======
Since node is asynchronous we can't just call:
```javascript

var cryo = require('cryostore')

cryo.import('../dummycontainer/jsfile', function(trueorfalse){

 	if(trueorfalse === true){callback(null, 'successful import')}
	else{callback(null, 'failed import')}
})

// - takes a .js file and turns into JSON - //
cryo.freeze('jsfile', function(success){

	console.log(success)
})

```

in succession. We could put the cryo.freeze call inside cryo.importJS callback, but this puts us in dangerous territory and can land us in
<a href="http://callbackhell.com/">callback hell</a>.

Using async we can combine asynchronous funtions to only execute after the predecessors are done. Like so:

```javascript
var cryo = require('cryostore')
var async = require('async')

async.series([

	function(callback){
		
		cryo.import('arbitrary/path/to/jsfile', function(trueorfalse){

 			if(trueorfalse === true){callback(null, 'successful import')}
			else{callback(null, 'failed import')}
		})
	},

	function(callback){

		cryo.freeze('jsfile', function(success){
			
			callback(null, success)
		})
	}
], function(err, results){
	
	// results is an array that where the first element is 'sucessful import'
	// or failed import depending on the first function in series, and whether
	// the import was successful
	// the second element will be true or false depending on whether the freezing was successful
	console.log(results)
})

```
you should `npm install async` as well as add it to your package.json under dependencies to use the package, it's not included with standard node.js.


Todo:
====
Could eventually also work with mongoDB, could be cool.

Check to make sure we're not over writing files, add - number indexes onto repeat files. 

Support Javascript objects.

Add the ability to create modular divisions within frozen or unfrozen code.

Hit me up on twitter at <a href="https://twitter.com/yvanscher">@yvanscher</a>.

It would be nice to have pretty printing on the cryo excavate functions. In other words
print something that looks like JSON or Javascript in the command line. It would be nice if they were distinguishable in the cmd line. 
