var statedata = require('../json/statedata.json')
var fs = require('fs')
var countrycode = ''
var JSONedData = {}
var counter = 0
var summay = {}
var temp = {}
var date = {}

var lowestDL = Infinity
var highestDL = 0
var lowestUP = Infinity
var highestUP = 0
var lowestDLYr = Infinity
var highestDLYr = 0
var lowestUPYr = Infinity
var highestUPYr = 0

temp['summary'] = {

	"lowestDL":lowestDL,
	"highestDL":highestDL,
	"lowestUP":lowestUP,
	"highestUP":highestUP,
	"00":{
		
		"lowestDL":Infinity,
		"highestDL":0,
		"lowestUP":Infinity,
		"highestUP":0
	},
	"08":{
		"lowestDL":lowestDL,
		"highestDL":highestDL,
		"lowestUP":lowestUP,
		"highestUP":highestUP,
	},
	"09":{
		"lowestDL":lowestDL,
		"highestDL":highestDL,
		"lowestUP":lowestUP,
		"highestUP":highestUP,
	},
	"10":{
		"lowestDL":lowestDL,
		"highestDL":highestDL,
		"lowestUP":lowestUP,
		"highestUP":highestUP,
	},
	"11":{
		"lowestDL":lowestDL,
		"highestDL":highestDL,
		"lowestUP":lowestUP,
		"highestUP":highestUP,
	},
	"12":{
		"lowestDL":lowestDL,
		"highestDL":highestDL,
		"lowestUP":lowestUP,
		"highestUP":highestUP,
	},
	"13":{
		"lowestDL":lowestDL,
		"highestDL":highestDL,
		"lowestUP":lowestUP,
		"highestUP":highestUP,
	},
	"14":{
		"lowestDL":lowestDL,
		"highestDL":highestDL,
		"lowestUP":lowestUP,
		"highestUP":highestUP,
	},
}

for (var index in statedata) {

	console.log(index)
	var date = index>0? getDate(statedata[index][4]): '00' 
	if(index>0 && statedata[index][2] !== statedata[index-1][2]){
		temp = {}
		temp['summary'] = {

			"lowestDL":Infinity,
			"highestDL":0,
			"lowestUP":Infinity,
			"highestUP":0,
			"00":{
				"lowestDL":Infinity,
				"highestDL":0,
				"lowestUP":Infinity,
				"highestUP":0
			},
			"08":{
				"lowestDL":Infinity,
				"highestDL":0,
				"lowestUP":Infinity,
				"highestUP":0
			},
			"09":{
				"lowestDL":Infinity,
				"highestDL":0,
				"lowestUP":Infinity,
				"highestUP":0
			},
			"10":{
				"lowestDL":Infinity,
				"highestDL":0,
				"lowestUP":Infinity,
				"highestUP":0
			},
			"11":{
				"lowestDL":Infinity,
				"highestDL":0,
				"lowestUP":Infinity,
				"highestUP":0
			},
			"12":{
				"lowestDL":Infinity,
				"highestDL":0,
				"lowestUP":Infinity,
				"highestUP":0
			},
			"13":{
				"lowestDL":Infinity,
				"highestDL":0,
				"lowestUP":Infinity,
				"highestUP":0
			},
			"14":{
				"lowestDL":Infinity,
				"highestDL":0,
				"lowestUP":Infinity,
				"highestUP":0
			}
		}
		counter = 0
	}

	if(index>0 && getDate(statedata[index][4]) !== getDate(statedata[index-1][4])){

		temp['summary'][getDate(statedata[index][4])] ={

			"lowestDL":Infinity,
			"highestDL":0,
			"lowestUP":Infinity,
			"highestUP":0
		}
			
	}

	temp[counter] = statedata[index]
	lowestDL = Math.min(temp['summary']['lowestDL'], statedata[index][5])
	highestDL = Math.max(temp['summary']['highestDL'], statedata[index][5])
	lowestUP = Math.min(temp['summary']['lowestUP'], statedata[index][6])
	highestUP = Math.max(temp['summary']['highestUP'], statedata[index][6])

	//console.log(date)
	//console.log(temp['summary'])
	lowestDLYr = Math.min(temp['summary'][date]['lowestDL'], statedata[index][5])
	highestDLYr = Math.max(temp['summary'][date]['highestDL'], statedata[index][5])
	lowestUPYr = Math.min(temp['summary'][date]['lowestUP'], statedata[index][6])
	highestUPYr = Math.max(temp['summary'][date]['highestUP'], statedata[index][6])
	
	temp['summary']['lowestDL'] = lowestDL
	temp['summary']['highestDL'] = highestDL
	temp['summary']['lowestUP'] = lowestUP
	temp['summary']['highestUP'] = highestUP
	
	temp['summary'][date]['lowestDL'] = lowestDLYr
	temp['summary'][date]['highestDL'] = highestDLYr
	temp['summary'][date]['lowestUP'] = lowestUPYr
	temp['summary'][date]['highestUP'] = highestUPYr

	JSONedData[statedata[index][2]] = temp
	counter++
}

fs.writeFile('statedatafinal.json',JSON.stringify(JSONedData, null, 4),function(err){
	if(err) throw err
	console.log('SAVE YOU SOME JSON')
})

function getDate(datestring){

	//really we should convert the datestring to a date object
	//then call getYear() on it, but hey we're pressed for time.
	return datestring.substring(2,4);
}

