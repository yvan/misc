//adds a starting bracket to make state files have the
//proper json format, just added ending bracket manually...

var co = require('co'),
prepend = require('prepend-file'),
Q = require('q'),
statecodes = require('../json/statecodes.json')

var prependFile = Q.denodeify(prepend)

function * prependTheStuff () {

	for(var i in statecodes){

		yield prependFile('../states/' + statecodes[i] + '.json', '[')
	}	
}

co(prependTheStuff)
