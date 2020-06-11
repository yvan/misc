//census API key  ae16a32fd72538332bd68ca11eb21c6bba02f5a6
//script takes a csv and turns it into JSON
//csv data from http://www.census.gov/did/www/saipe/index.html
/*mulitline comment test 
test should include all the reserved words and all types of javascript syntax*/
var csv = require('fast-csv')
var fs = require('fs')
var countrycode = ''
var uniqueindex = 0
var countydata = {}
var csvStream = csv()
.on('data',function(data){
  countydata[uniqueindex] = data
  uniqueindex++
})
.on('end', function(){
  console.log(countydata)
  fs.writeFile('json/statedailyvalue.json',
  JSON.stringify(countydata,null,4),
  function(err){
    if(err)throw err
    console.log('data saved as JSON yay!')
	  uniqueindex = 0
  })
})
var stream = fs.createReadStream('csv/region_daily_value.csv')
stream.pipe(csvStream)
