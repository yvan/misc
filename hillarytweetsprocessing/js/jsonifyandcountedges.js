/* 
	1.This file takes that huge ass XML and turns it into a single json indexed by the id
	of the node.
	2.Then it counts the edges of each of those ids and adds them to the json.
	3.Then it splits each json into it's respective state files; a separate file for each
	state that contains (mostly, some little bugs/loopholes) only nodes located in a certain state.
	4.Once we've done that we should sort each of these files to be ordered in descending order.
	probably a merge sort using the indicies/ids of each json object and the node density.
	5.Once we've done that, we produce an ordered cube graph for each of these nodes. 
*/


//this file turns the original gexf into two JSON files
//one file for teh edges, one file for the nodes.
var statecodes = require('../json/statecodes.json'),
co = require('co'),
Q = require('q'),
fs = require('fs'),
path = require('path'),
xml2json = require('xml2json'),
lazy = require('lazy')

var lazeh = new lazy(fs.createReadStream(path.join(__dirname, '../gexf/hildawg.gexf'))),
timeslots = require('../json/timeslots.json')

var appendFile = Q.denodeify(fs.appendFile),
readFile = Q.denodeify(fs.readFile),
writeFile = Q.denodeify(fs.writeFile)

//extend the date object with a new method.
//this is for determining which date section
//a datetime is in.

Date.prototype.addDays = function (days) {

    this.setDate(this.getDate()+parseInt(days))
    return this
}

function * jsonifyAndRecordEdgeCounts (filepath) {

	//accumulators
	var cumulativeNodeString = '',
	accumulateflag = false,
	d2codespotted = ''

	//get the empty object that starts in the singlefile.json
	var currentFileJSON = {}, 
    currentEdgesJSON = {}

	//convert all the interesting tweets in different states
	//into a json file indexed by the unique id of the node
	lazeh.lines.forEach ( function ( line ) {
    	   
        //convert the lien to string
    	var lineString = line.toString()
    	
    	//if the line contains an open node tag.
    	//then start accuulating the data
    	if (lineString.includes('<node')) {
    		accumulateflag = true
    	} 
    	//if the line has a d2 value
    	if ( lineString.includes('<attvalue for="d2"') ) {

    		for (var i in statecodes) {
    			if ( lineString.toLowerCase().includes(i.toLowerCase()) )
    				d2codespotted = statecodes[i]
    			if ( lineString.toLowerCase().includes(', ' + statecodes[i].toLowerCase()) )
    				d2codespotted = statecodes[i]
    		}        		
    	}
    		
    	//if the line cotains a node closing tag
    	//then stop accumulating the data and
    	//get our json and add it to the big ass 
    	//json object then wipe the accumulator
    	if (lineString.includes('</node>')) {

    		accumulateflag = false
    		cumulativeNodeString += '\n'+lineString

    		if (d2codespotted != '') {
    			var jsondata = xml2json.toJson(cumulativeNodeString)
                json = JSON.parse(jsondata)
	    		// console.log(JSON.stringify(json, null, 4))
	    		if (json["nodes"] ) {
	    			currentFileJSON[json["nodes"]["node"]["id"]] = json
	    			currentFileJSON[json["nodes"]["node"]["id"]]["statecode"] = d2codespotted
	    			currentFileJSON[json["nodes"]["node"]["id"]]["source"] = 0
	    			currentFileJSON[json["nodes"]["node"]["id"]]["target"] = 0
                    // console.log("timeslots : "+timeslots)
                    // console.log("timeslots currently : "+currentFileJSON[json["node"]["id"]]["timeslots"])
                    currentFileJSON[json["nodes"]["node"]["id"]]["timeslots"] = timeslots
	    		} else {
	    			currentFileJSON[json["node"]["id"]] = json
	    			currentFileJSON[json["node"]["id"]]["statecode"] = d2codespotted
	    			currentFileJSON[json["node"]["id"]]["source"] = 0
	    			currentFileJSON[json["node"]["id"]]["target"] = 0
                    // console.log("timeslots : "+timeslots)
                    // console.log("timeslots currently : "+currentFileJSON[json["node"]["id"]]["timeslots"])
                    currentFileJSON[json["node"]["id"]]["timeslots"] = timeslots
	    		}	
    		}

    		cumulativeNodeString = ''
    		d2codespotted = ''
    	} 

    	if (lineString.includes('<edge')) {
    		accumulateflag = true 
    	}

    	if (lineString.includes('</edge>')) {

    		accumulateflag = false
    		cumulativeNodeString += '\n' + lineString

    		try {

    			var jsondata = xml2json.toJson(cumulativeNodeString),
                json = JSON.parse(jsondata),
                datestring = ''

		    	// console.log(JSON.stringify(json, null, 4))

		    	if (json["edges"]) {

                    //if the source node and target node for the edge are located in the
                    //json graph.
                    if(currentFileJSON[json['edges']['edge']['source']] && currentFileJSON[json['edges']['edge']['target']] ){

                        console.log(currentFileJSON[json['edges']['edge']['source']])
                        console.log(currentFileJSON[json['edges']['edge']['target']])

                        currentEdgesJSON[json['edges']['edge']['attvalues']['attvalue'][0]['value']] = json
                        console.log(currentEdgesJSON[json['edges']['edge']['attvalues']['attvalue'][0]['value']])
                    }

                    //if we have a value for d6 get the value
                    //this value is the timestamp on an edge.
                    if(json['edges']['edge']['attvalues']['attvalue'][2]['for'] == 'd6'){
                        datestring = json['edges']['edge']['attvalues']['attvalue'][2]['value']
                    }

                    //if the edge contains a "source" attribute, get the source value
                    //that value is actually the unqiue id of a node, increase that
                    //node's source count up by one.
		    		if(currentFileJSON [json["edges"]["edge"]["source"]]){
		    			currentFileJSON [json["edges"]["edge"]["source"]] ["source"] = currentFileJSON [json["edges"]["edge"]["source"]] ["source"] + 1
                        currentFileJSON [json["edges"]["edge"]["source"]] ["timeslots"] [determineTimeslotbyWeek(datestring)] = 1
		    		}

                    //if the edge contains a "target" attribute, get the target value
                    //that vlaue is aactually a unique id of a node, inceasre that
                    //node's target count up by one.
		    		if(currentFileJSON [json["edges"]["edge"]["target"]]){
		    			currentFileJSON [json["edges"]["edge"]["target"]] ["target"] = currentFileJSON [json["edges"]["edge"]["target"]] ["target"] + 1
                        currentFileJSON [json["edges"]["edge"]["target"]] ["timeslots"] [determineTimeslotbyWeek(datestring)] = 1
		    		}

		    	} else if(json["edge"]) {

                    //if the source node and target node for the edge are located in the
                    //json graph.
                    if(currentFileJSON[json['edge']['source']] && currentFileJSON[json['edge']['target']] ){

                        console.log(currentFileJSON[json['edge']['source']])
                        console.log(currentFileJSON[json['edge']['target']])

                        currentEdgesJSON[json['edge']['attvalues']['attvalue'][0]['value']] = json
                        console.log(currentEdgesJSON[json['edge']['attvalues']['attvalue'][0]['value']])
                    }

                    if(json['edge']['attvalues']['attvalue'][2]['for'] == 'd6'){
                        datestring = json['edge']['attvalues']['attvalue'][2]['value']
                    }

		    		if(currentFileJSON [json["edge"]["source"]]){
		    			currentFileJSON [json["edge"]["source"]] ["source"] = currentFileJSON [json["edge"]["source"]] ["source"] + 1
                        currentFileJSON [json["edge"]["source"]] ["timeslots"] [determineTimeslotbyWeek(datestring)] = 1
		    		}

		    		if(currentFileJSON [json["edge"]["target"]]){
		    			currentFileJSON [json["edge"]["target"]] ["target"] = currentFileJSON [json["edge"]["target"]] ["target"] + 1
                        currentFileJSON [json["edge"]["target"]] ["timeslots"] [determineTimeslotbyWeek(datestring)] = 1
		    		}
		    	}	
	    	} catch(e) {
    			console.log('THERE WAS ERROR : ' + e)
    			cumulativeNodeString = ''
    		}
    		cumulativeNodeString = ''
    	}

    	//if we're supposed to be accumulating stuff
    	//then accumulate stuff...
    	if (accumulateflag) {
    		cumulativeNodeString += '\n'+lineString 
    	} 

    	//when the xml file ends write the huge ass JSON object
    	//into the file.
    	if(lineString.includes('</gexf>')){

            //write the nodes into their own json file.
            //write the edges into their own json file.
            //i've split these up because they don't need
            //to be processed together and if the datasets
            //get large then well want them separate.
    		writeFile(path.join(__dirname,'../json/jsonifiednodes.json'), JSON.stringify(currentFileJSON, null, 4) + '\n')
            writeFile(path.join(__dirname,'../json/jsonifiededges.json'), JSON.stringify(currentEdgesJSON, null, 4) + '\n')
    	}
	})
}

// this function checks whether a date comes
// before a certain date and returns the 
// timeslot that this date is in.
// each node has a list of timeslots that
// it belongs to. These timeslots will
// determine how many graph files each
// node ends up on. In the first iteration
// there are only 16 timeslots (one for each)
// week, so before Jan 7 2015 is a time slot.
// before Jan 14 2015 but not before Jan 7 2015
// is the secodn timeslot, we can use if else
// statements in the right order ot create this
// exclusive logic w/o making excessive checks.

//only returns one time slot per edge.

function determineTimeslotbyWeek (datestring) {

    var dateobj = new Date(datestring),
    datebaseobj = new Date('2015-01-01 00:00:00'),
    numtimes = 0

    while(numtimes < 16) {

        if(dateobj < datebaseobj){ return numtimes }
        datebaseobj.addDays(1)
        numtimes++
    }
    return numtimes
}


//calls to generator functions

co(jsonifyAndRecordEdgeCounts)

// console.log(determineTimeslotbyWeek('2014-09-10 01:28:12'))
// console.log(determineTimeslotbyWeek('2015-02-17 00:00:00'))
