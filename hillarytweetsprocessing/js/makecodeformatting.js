//geenral utility file for formatting
//code and indexing files, just a general
//prupose script that can be cahnged or edited or
//whatever

var co = require('co'),
Q = require('q'),
fs = require('fs'),
path = require('path'),
orderedstatejson = require('../json/statecodeobjects.json'),
timeslots = {}

var writeFile = Q.denodeify(fs.writeFile)

function * doTheFormattingStuff () {

	// code that created the json structure with nodes and edges and final graph offsets
	var XYoffset = 0

	for (var orderedstate in orderedstatejson) {

		orderedstatejson[orderedstate] = {"XYOffset": XYoffset, "nodes":[], "edges":[]}
		XYoffset=XYoffset+30000
		console.log(orderedstatejson)
	} 

	yield writeFile(path.join(__dirname, '../json/statecodeobjects.json'), JSON.stringify(orderedstatejson, null, 4))
}

function * createTimeSlots  () {

	var timeslotcounter = 0

	while(timeslotcounter < 16) {

		console.log(timeslotcounter)

		timeslots[timeslotcounter] = 0
		console.log(timeslots)
		timeslotcounter++
	}
	yield writeFile(path.join(__dirname, '../json/timeslots.json'), JSON.stringify(timeslots, null, 4))
}

// co(createTimeSlots)

co(doTheFormattingStuff)
