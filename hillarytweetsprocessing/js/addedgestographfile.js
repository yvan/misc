//this file takes an edgefile.json produced by the
//jsonifyandcountedges.js script. 
//the reason the labels are empty
//is that we don't put them on th graph.
//this is too processing intensive and
//causes slow rendering and whatnot.
//basically each node will get an ID
//then when a user hovers on that edge
//we get its id and do a lookup for the edge value
//this will make the graph faster

var co = require('co'),
Q = require('q'),
fs = require('fs'),
path = require('path'),
edgefile = require('../json/jsonifiededges.json'),
graphfilejson = require('../json/graphfile.json')
edges = {'edges':[]}

var writeFile = Q.denodeify(fs.writeFile)

function * addEdges () {

	for (var edgeid in edgefile) {

		//the edge source and target MUST
		// be strings hence the ''+
		var newEdgeObj = {
			'id' : edgeid,
			'source' : ''+edgefile[edgeid]['edge']['source'],
			'target' : ''+edgefile[edgeid]['edge']['target'],
			'label' : edgefile[edgeid]['edge']['label'],
			'originalColor' : 'brown'
		edges['edges'].push(newEdgeObj)
	}

	console.log(edges)

	//adds edges
	// graphfilejson['edges'] = graphfilejson['edges'].concat(edges['edges'])

	//replaces edges
	graphfilejson['edges'] = edges['edges']
	
	console.log(graphfilejson['edges'])

	yield writeFile(path.join(__dirname, '../json/graphfile.json'), JSON.stringify(graphfilejson, null, 4))
}

co(addEdges)