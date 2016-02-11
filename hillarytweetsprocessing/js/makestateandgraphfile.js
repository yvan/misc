//this file makes many state files and 
//also a single graph file containing all nodes
//the primary reason we need this file is that
//it makes assigning edges and time zones to nodes
//super ast because each node is indexed by its ID 
//in the singlefile.json

var co = require('co'),
statejson = require('../json/jsonifiednodes.json'),
Q = require('q'),
fs = require('fs'),
path = require('path'),
orderedstatejson = require('../json/statecodeobjects.json')

var appendFile = Q.denodeify(fs.appendFile),
writeFile = Q.denodeify(fs.writeFile),
graphfilejson = {'nodes':[], 'edges':[]}

function * makeJSONifiedIntoStateFiles () {

	//first index is the state's code
	//second index for the object is the
	//unique id of the node
	for (var state in statejson){

		var newNodeObj = {
			'id' : ''+statejson[state]['node']['id'],
			'label' : statejson[state]['node']['label'],
			'size' : statejson[state]['node']['viz:size']['value'],
			'statecode' : statejson[state]['statecode'],
			'source' : statejson[state]['source'],
			'target' : statejson[state]['target'],
			'x' :  statejson[state]['node']['viz:position']['x'],
			'y' :  statejson[state]['node']['viz:position']['y'],
			'color' : 'brown',
			'XYOffset' : orderedstatejson[statejson[state]['statecode']]['XYOffset'],
			'size' : 0, // nodes of size zero display and automatically re-scale WOOOOO
			'label' : '',
			'originalColor' : 'brown'
		}

		if(newNodeObj.source > 40) {
			newNodeObj.color = '#800080'
			newNodeObj.originalColor = '#800080'
		} else if(newNodeObj.source > 30) {
			newNodeObj.color = '#0000FF'
			newNodeObj.originalColor = '#0000FF'
		} else if(newNodeObj.source > 20) {
		 	newNodeObj.color = '#00FF00'
		 	newNodeObj.originalColor = '#00FF00'
		} else if(newNodeObj.source > 10) {
			newNodeObj.color = '#FF0000'
			newNodeObj.originalColor = '#FF0000'
		} else {
			newNodeObj.color = '#F4A460'
			newNodeObj.originalColor = '#F4A460'
		}

		// console.log(newNodeObj)
		orderedstatejson[statejson[state]['statecode']]['nodes'].push(newNodeObj)
	}

	try {

		//for each state code create a json file that
		//contains the node entries from the jsonifiednodegraph.json
		//file, breaks up the entries into their own state 
		//files, also sort each state before hand.
		for (var orderedstate in orderedstatejson) {

			var nodecounter = 0, columncounter = 0, linecounter = 0

			orderedstatejson[orderedstate]['nodes'].sort(
				function (a, b) {
					return b.source - a.source
				} 
			) 

			orderedstatejson[orderedstate]['nodes'] = orderedstatejson[orderedstate]['nodes'].map(
				function(obj){
					nodecounter++
					columncounter++
					obj.x = (columncounter * 1000) + obj.XYOffset
					obj.y = (linecounter * 1000) //+ obj.XYOffset
					if(columncounter === 15){
						columncounter = 0
						linecounter++
					} else {
						columncounter
					}
					return obj
				}
			)

			graphfilejson['nodes'] = graphfilejson['nodes'].concat(orderedstatejson[orderedstate]['nodes'])
			graphfilejson['edges'] = graphfilejson['edges'].concat(orderedstatejson[orderedstate]['edges'])

			yield writeFile(path.join(__dirname, '../states/' , orderedstate + '.json'), JSON.stringify(orderedstatejson[orderedstate], null, 4))
		}

		yield writeFile(path.join(__dirname, '../json/graphfile.json'), JSON.stringify(graphfilejson, null, 4))

	} catch (error) {

		console.log(error)
	}
}

co(makeJSONifiedIntoStateFiles)
