var countrydata = require('../json/countrydatafinal.json')
var fs = require('fs')
var countrycode = ''
var JSONedData = {}
var temp = {}

var dateindicies = ["08", "09", "10", "11", "12", "13", "14"]
var lowestDL = Infinity
var highestDL = 0
var lowestUP = Infinity
var highestUP = 0

JSONedData = {
	
	"08":{
		"lowestDL":lowestDL,
		"highestDL":highestDL,
		"lowestUP":lowestUP,
		"highestUP":highestUP
	},
	"09":{
		"lowestDL":lowestDL,
		"highestDL":highestDL,
		"lowestUP":lowestUP,
		"highestUP":highestUP
	},
	"10":{
		"lowestDL":lowestDL,
		"highestDL":highestDL,
		"lowestUP":lowestUP,
		"highestUP":highestUP
	},
	"11":{
		"lowestDL":lowestDL,
		"highestDL":highestDL,
		"lowestUP":lowestUP,
		"highestUP":highestUP
	},
	"12":{
		"lowestDL":lowestDL,
		"highestDL":highestDL,
		"lowestUP":lowestUP,
		"highestUP":highestUP
	},
	"13":{
		"lowestDL":lowestDL,
		"highestDL":highestDL,
		"lowestUP":lowestUP,
		"highestUP":highestUP
	},
	"14":{
		"lowestDL":lowestDL,
		"highestDL":highestDL,
		"lowestUP":lowestUP,
		"highestUP":highestUP
	}
}

for (var index in countrydata) {
	//console.log(index)
	if(index !== 'country'){
		
		for(i=0; i<dateindicies.length; i++){
			lowestDL = Math.min(countrydata[index]['summary'][dateindicies[i]]["lowestDL"],JSONedData[dateindicies[i]]["lowestDL"])
			highestDL = Math.max(countrydata[index]['summary'][dateindicies[i]]["highestDL"],JSONedData[dateindicies[i]]["highestDL"])
			lowestUP = Math.min(countrydata[index]['summary'][dateindicies[i]]["lowestUP"],JSONedData[dateindicies[i]]["lowestUP"])
			highestUP = Math.max(countrydata[index]['summary'][dateindicies[i]]["highestUP"],JSONedData[dateindicies[i]]["highestUP"])
			console.log(JSONedData[dateindicies[i]]["lowestDL"])
			JSONedData[dateindicies[i]] = {
				"lowestDL":lowestDL,
				"highestDL":highestDL,
				"lowestUP":lowestUP,
				"highestUP":highestUP
			}
		}
	}	
}
console.log(JSONedData)
fs.writeFile('constantvals.json',JSON.stringify(JSONedData, null, 4),function(err){
	if(err) throw err
	console.log('SAVE YOU SOME JSON')
})

