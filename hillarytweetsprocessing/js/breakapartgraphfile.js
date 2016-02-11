var co = require('co'),
Q = require('q'),
graph = require('../json/graphfile.json'),
fs = require('fs'),
path = require('path')

var writeFile = Q.denodeify(fs.writeFile)
var temporaryobj = {'nodes':[], 'edges':[]},
prevbreak = 0

function * breakTheGraph (numberofbreaks) {

	var nodecounter = 0

	for(var node in graph.nodes){

		numberofnodesinbreak = graph.nodes.length / numberofbreaks
		var currentbreak = Math.round(nodecounter / numberofnodesinbreak)
		if(currentbreak != prevbreak){
			yield writeFile(path.join(__dirname, '../json/break' + currentbreak + '.json'), JSON.stringify(temporaryobj, null, 4) + '\n')
			temporaryobj = {'nodes':[], 'edges':[]}
		}
		prevbreak = currentbreak
		temporaryobj.nodes.push(graph.nodes[node])
		nodecounter++
	}
}

//inserts the appropriate edges for a cut into a temporary object
function getEdgesForTempObj () {

}

co(breakTheGraph(5))
