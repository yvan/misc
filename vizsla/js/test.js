var csv = require('fast-csv')
var fs = require('fs')
var uniqueindex = 0
var dataJSON = {}

var csvStream = csv() // - uses the fast-csv module to create a csv parser
  .on('data',function(data){ // - when we get data perform function(data) 
    dataJSON[uniqueindex] = data; // - store our data in a JSON object dataJSON
    uniqueindex++ // - the index of the data item in our array
  })
  .on('end', function(){ // - when the data stream ends perform function()
    console.log(dataJSON) // - log our whole object on console
    fs.writeFile('../json/test.json', // - use fs module to write a file
    JSON.stringify(dataJSON,null,4), // - turn our JSON object into string that can be written
    function(err){ // function(err) only gets performed once were done and err will be nil if there is no error
      if(err)throw err //if there's an error throw it
      console.log('data saved as JSON yay!')
    //uniqueindex = 0 // reset our index.
    })
  })

var stream = fs.createReadStream('../csv/test.csv')
stream.pipe(csvStream)