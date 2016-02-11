var statedata = require('../json/statequality.json') //7 and 8 for packet loss and latency
var fs = require('fs')
var countrycode = ''
var JSONedData = {}
var counter = 0
var summay = {}
var temp = {}
var date = {}

var lowestPL = Infinity
var highestPL = 0
var lowestLAT = Infinity
var highestLAT = 0
var lowestPLYr = Infinity
var highestPLYr = 0
var lowestLATYr = Infinity
var highestLATYr = 0

temp['summary'] = {

	"lowestPL":lowestPL,
	"highestPL":highestPL,
	"lowestLAT":lowestLAT,
	"highestLAT":highestLAT,
	"00":{
		
		"lowestPL":Infinity,
		"highestPL":0,
		"lowestLAT":Infinity,
		"highestLAT":0
	},
	"08":{
		"lowestPL":lowestPL,
		"highestPL":highestPL,
		"lowestLAT":lowestLAT,
		"highestLAT":highestLAT,
	},
	"09":{
		"lowestPL":lowestPL,
		"highestPL":highestPL,
		"lowestLAT":lowestLAT,
		"highestLAT":highestLAT,
	},
	"10":{
		"lowestPL":lowestPL,
		"highestPL":highestPL,
		"lowestLAT":lowestLAT,
		"highestLAT":highestLAT,
	},
	"11":{
		"lowestPL":lowestPL,
		"highestPL":highestPL,
		"lowestLAT":lowestLAT,
		"highestLAT":highestLAT,
	},
	"12":{
		"lowestPL":lowestPL,
		"highestPL":highestPL,
		"lowestLAT":lowestLAT,
		"highestLAT":highestLAT,
	},
	"13":{
		"lowestPL":lowestPL,
		"highestPL":highestPL,
		"lowestLAT":lowestLAT,
		"highestLAT":highestLAT,
	},
	"14":{
		"lowestPL":lowestPL,
		"highestPL":highestPL,
		"lowestLAT":lowestLAT,
		"highestLAT":highestLAT,
	},
}

for (var index in statedata) {

	console.log(index)
	var date = index>0? getDate(statedata[index][4]): '00' 
	if(index>0 && statedata[index][2] !== statedata[index-1][2]){
		temp = {}
		temp['summary'] = {

			"lowestPL":Infinity,
			"highestPL":0,
			"lowestLAT":Infinity,
			"highestLAT":0,
			"00":{
				"lowestPL":Infinity,
				"highestPL":0,
				"lowestLAT":Infinity,
				"highestLAT":0
			},
			"08":{
				"lowestPL":Infinity,
				"highestPL":0,
				"lowestLAT":Infinity,
				"highestLAT":0
			},
			"09":{
				"lowestPL":Infinity,
				"highestPL":0,
				"lowestLAT":Infinity,
				"highestLAT":0
			},
			"10":{
				"lowestPL":Infinity,
				"highestPL":0,
				"lowestLAT":Infinity,
				"highestLAT":0
			},
			"11":{
				"lowestPL":Infinity,
				"highestPL":0,
				"lowestLAT":Infinity,
				"highestLAT":0
			},
			"12":{
				"lowestPL":Infinity,
				"highestPL":0,
				"lowestLAT":Infinity,
				"highestLAT":0
			},
			"13":{
				"lowestPL":Infinity,
				"highestPL":0,
				"lowestLAT":Infinity,
				"highestLAT":0
			},
			"14":{
				"lowestPL":Infinity,
				"highestPL":0,
				"lowestLAT":Infinity,
				"highestLAT":0
			}
		}
		counter = 0
	}

	if(index>0 && getDate(statedata[index][4]) !== getDate(statedata[index-1][4])){

		temp['summary'][getDate(statedata[index][4])] ={

			"lowestPL":Infinity,
			"highestPL":0,
			"lowestLAT":Infinity,
			"highestLAT":0
		}
			
	}

	temp[counter] = statedata[index]
	lowestPL = Math.min(temp['summary']['lowestPL'], statedata[index][7])
	highestPL = Math.max(temp['summary']['highestPL'], statedata[index][7])
	lowestLAT = Math.min(temp['summary']['lowestLAT'], statedata[index][8])
	highestLAT = Math.max(temp['summary']['highestLAT'], statedata[index][8])

	//console.log(date)
	//console.log(temp['summary'])
	lowestPLYr = Math.min(temp['summary'][date]['lowestPL'], statedata[index][7])
	highestPLYr = Math.max(temp['summary'][date]['highestPL'], statedata[index][7])
	lowestLATYr = Math.min(temp['summary'][date]['lowestLAT'], statedata[index][8])
	highestLATYr = Math.max(temp['summary'][date]['highestLAT'], statedata[index][8])
	
	temp['summary']['lowestPL'] = lowestPL
	temp['summary']['highestPL'] = highestPL
	temp['summary']['lowestLAT'] = lowestLAT
	temp['summary']['highestLAT'] = highestLAT
	
	temp['summary'][date]['lowestPL'] = lowestPLYr
	temp['summary'][date]['highestPL'] = highestPLYr
	temp['summary'][date]['lowestLAT'] = lowestLATYr
	temp['summary'][date]['highestLAT'] = highestLATYr

	JSONedData[statedata[index][2]] = temp
	counter++
}

fs.writeFile('json/statequalityfinal.json',JSON.stringify(JSONedData, null, 4),function(err){
	if(err) throw err
	console.log('SAVE YOU SOME JSON')
})

function getDate(datestring){

	//really we should convert the datestring to a date object
	//then call getYear() on it, but hey we're pressed for time.
	return datestring.substring(2,4);
}

