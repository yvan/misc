//this sript parses through the original XML
//to find the data range for the data set
var co = require('co'),
Q = require('q'),
fs = require('fs'),
path = require('path'),
lazy = require('lazy'),
xml2json = require('xml2json')

var lazeh = new lazy(fs.createReadStream(path.join(__dirname, '../gexf/hildawg.gexf')))

function * countdates () {

	var cumulativeNodeString = '',
	accumulateflag = false,
	datestring = '',
	lowestDate = null,
	highestDate = null

	lazeh.lines.forEach(function(line){

		var lineString = line.toString()

		if(lineString.includes('<edge')){
			accumulateflag = true
		}

		if(lineString.includes('</edge>')){

			accumulateflag = false
			cumulativeNodeString += '\n' + lineString

			try {

				// console.log(cumulativeNodeString)
				var jsondata = xml2json.toJson(cumulativeNodeString),
				json = JSON.parse(jsondata)

				// the index 2 is usually always teh timestamp object here
				// looks like { "for": "d6", "value": "2015-04-16 02:09:14"}
				if(json['edge']['attvalues']['attvalue'][2]['for'] == 'd6'){
					// console.log(json['edge']['attvalues']['attvalue'][2]['value'])

					tempDate = new Date(json['edge']['attvalues']['attvalue'][2]['value'])

					lowestDate = lowestDate === null ? tempDate : lowestDate
					highestDate === null ? tempDate : highestDate
					if(tempDate > highestDate){
						highestDate = tempDate
						console.log('new high! : ' + highestDate)
					}
					if(tempDate < lowestDate){
						lowestDate = tempDate
						console.log('new low! : ' + lowestDate)
					}

					cumulativeNodeString = ''
					// console.log(lowestDate)
					// console.log(highestDate)
				} else {
					throw new Error('There is an error')
				}

			} catch (e) {

				// console.log('Error :' + e)
				cumulativeNodeString = ''
			}
		}

		if(accumulateflag) {
			cumulativeNodeString += '\n' + lineString
		}

		if(lineString.includes('</gexf>')){

			console.log('Highest Date: ' + highestDate)
			console.log('Lowest Date: ' + lowestDate)
			console.log('Elapsed Time: ' + Math.abs(highestDate - lowestDate))
		}
	})
}

co(countdates)