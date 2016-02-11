var countrydata = require('../json/countryqualityfinal.json')
var fs = require('fs')
var countrycode = ''
var JSONedData = {}
var temp = {}

var dateindicies = ["08", "09", "10", "11", "12", "13", "14"]
var lowestPL = Infinity
var highestPL = 0
var lowestLAT = Infinity
var highestLAT = 0

JSONedData = {
	
	"08":{
		"lowestPL":lowestPL,
		"highestPL":highestPL,
		"lowestLAT":lowestLAT,
		"highestLAT":highestLAT
	},
	"09":{
		"lowestPL":lowestPL,
		"highestPL":highestPL,
		"lowestLAT":lowestLAT,
		"highestLAT":highestLAT
	},
	"10":{
		"lowestPL":lowestPL,
		"highestPL":highestPL,
		"lowestLAT":lowestLAT,
		"highestLAT":highestLAT
	},
	"11":{
		"lowestPL":lowestPL,
		"highestPL":highestPL,
		"lowestLAT":lowestLAT,
		"highestLAT":highestLAT
	},
	"12":{
		"lowestPL":lowestPL,
		"highestPL":highestPL,
		"lowestLAT":lowestLAT,
		"highestLAT":highestLAT
	},
	"13":{
		"lowestPL":lowestPL,
		"highestPL":highestPL,
		"lowestLAT":lowestLAT,
		"highestLAT":highestLAT
	},
	"14":{
		"lowestPL":lowestPL,
		"highestPL":highestPL,
		"lowestLAT":lowestLAT,
		"highestLAT":highestLAT
	}
}

for (var index in countrydata) {
	//console.log(index)
	if(index !== 'country'){
		
		for(i=0; i<dateindicies.length; i++){
			lowestPL = Math.min(countrydata[index]['summary'][dateindicies[i]]["lowestPL"],JSONedData[dateindicies[i]]["lowestPL"])
			highestPL = Math.max(countrydata[index]['summary'][dateindicies[i]]["highestPL"],JSONedData[dateindicies[i]]["highestPL"])
			lowestLAT = Math.min(countrydata[index]['summary'][dateindicies[i]]["lowestLAT"],JSONedData[dateindicies[i]]["lowestLAT"])
			highestLAT = Math.max(countrydata[index]['summary'][dateindicies[i]]["highestLAT"],JSONedData[dateindicies[i]]["highestLAT"])
			console.log(JSONedData[dateindicies[i]]["lowestPL"])
			JSONedData[dateindicies[i]] = {
				"lowestPL":lowestPL,
				"highestPL":highestPL,
				"lowestLAT":lowestLAT,
				"highestLAT":highestLAT
			}
		}
	}	
}
console.log(JSONedData)
fs.writeFile('json/constantqualityvals.json',JSON.stringify(JSONedData, null, 4),function(err){
	if(err) throw err
	console.log('SAVE YOU SOME JSON')
})

