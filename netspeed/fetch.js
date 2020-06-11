var geographer = require('geographer')
var request = require('request')

module.exports = fetchNetSpeed

function fetchNetSpeed(latitudeorplacename, longitudeorcallback, callbackornull){
  var speed_data = {}
  if (typeof callbackornull === 'undefined') {
    callbackornull = longitudeorcallback
    var state = latitudeorplacename.split(', ')[1]
    var placename = latitudeorplacename.split(',')[0]
    var latitude, longitude
    geographer(placename, state, 1, function(results){
      for(var attributename in results['terraindata']){
        if(attributename != 'potentialresults'){
          latitude = results['terraindata'][attributename]['latitude']
          longitude = results['terraindata'][attributename]['longitude']
        }
      }
      request("http://data.fcc.gov/api/speedtest/find?latitude="
      +latitude+"&longitude="+longitude+"&format=json",
        function(error, response, json){
          if(error)throw error
          json = JSON.parse(json)
          speed_data[results['terraindata'][attributename]['county']] = json['SpeedTestCounty']
          callbackornull(  speed_data)
      })
    })
  }
  else{
    request("http://data.fcc.gov/api/speedtest/find?latitude="
    +latitudeorplacename+"&longitude="+longitudeorcallback+"&format=json",
      function(error, response, json){
        if(error)throw error
        json = JSON.parse(json)
        speed_data = json['SpeedTestCounty']
        speed_data['latitude'] = latitudeorplacename
        speed_data['longitude'] = longitudeorcallback
        callbackornull(speed_data)
    })
  }
}
