var countries = require('./info/country_codes.json')
var language = require('./info/language_codes.json')
var states = require('./info/usstates.json')
var config = require('./config.json')
var request = require('request')
var async = require('async')
var fs = require('fs')


module.exports = fetchGeoData

//gets the geographic information for the requested
//thing from the user
function fetchGeoData(placename, statename, maxrows, callback){

  if (typeof callback === 'undefined') {
    callback = maxrows
    maxrows = undefined
  }
  var terraindata = {}
  var returnstruct = {}
  maxrows = maxrows ? maxrows : ''
  countrycode = countries[config['geonames']['country'].toLowerCase()]
  statecode = statename.length == 2 ? statename : states[statename.toLowerCase()]

  request('http://api.geonames.org/searchJSON?formatted=true&q='+placename+
  '&maxRows='+maxrows+'&lang='+config['geonames']['language']+
  '&username='+config['geonames']['username']+
  '&adminCode1='+statecode+'&countryCode='+countrycode+'&style=full',
  function(error, response, json){
    if(error)throw error
    try{
      json = JSON.parse(json)
      terraindata['potentialresults'] = json['totalResultsCount']
      json['geonames'].forEach(function(location){
        terraindata[location['name']] = {
          "country":location['countryName'],
          "region":location['adminName1'],
          "county":location['adminName2'],
          "locationtype":location['fcodeName'],
          "terraintype":location['fclName'],
          "elevation":location['elevation'],
          "latitude":location['lat'],
          "longitude":location['lng'],
          "boundingbox":location['bbox'],
          "timezone":location['timezone'],
          "population":location['population']
        }
      })
      emptyfields = cleanData(terraindata)
      returnstruct['emptyfields'] = emptyfields
      returnstruct['terraindata'] = terraindata
      callback(returnstruct)
    }catch(err){throw err}
  })
}

//Cleans empty data from the array
//tells you what couldn't be found
//in a new/separate array
function cleanData(data_to_clean){
  var empty_fields = {}
  for(var location in data_to_clean){
    for(var location_detail in data_to_clean[location] ){
      detail = data_to_clean[location][location_detail]
      if(detail == '' || detail == undefined){
        if(!empty_fields[location]){empty_fields[location]={"0":[]}}
        empty_fields[location][0].push(location_detail)
        delete data_to_clean[location][location_detail]
      }
    }
  }
  return empty_fields
}
