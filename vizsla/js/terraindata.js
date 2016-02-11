/**Buckets:
 Bucket 1 is 50% of population (146 from Bucket1.json)
 Bucket 2 is the other 50% of population (the rest of the counties)
**/
var request = require('request')
var ratelimiter = require('limiter').RateLimiter
var geode = require('geode')
var async = require('async')
var sys = require('util')
var fs = require('fs')
var bucketlist = {}
var i = 0

var geo = new geode('yvanscher', {language: 'en', country : 'US'})

function getData(key, json_data, next){
  var tmp_data = {}
  async.waterfall([

    //use our list of counties in countydata.json
    //to get geoNames data (lat/lng) and terrain type
    function(cb){
      geo.search({name:json_data[key][3], adminCode1:json_data[key][2], maxRows:1},
      function(err, results){
          if(err)throw err
          try{
            if(results['geonames'][0]){
              tmp_data[results['geonames'][0]['name']+results['geonames'][0]['adminCode1']] = results['geonames'][0]
              tmp_data["bucket"] = ~bucketlist[0].indexOf(json_data[key][3]+json_data[key][2]) ? 1 : 0
              tmp_data["medianincome"] = json_data[key][22]
              tmp_data["povertyrate"] = json_data[key][7]
              cb(null, tmp_data, results['geonames'][0]['name']+results['geonames'][0]['adminCode1'])
            }
          }catch(e){
            cb(e)
          }
      })
    },

    //gets elevation for latitutde and longitude
    //from google elevation api
    function(results, index, cb){
      request('http://open.mapquestapi.com/elevation/v1/profile?key=Fmjtd%7Cluurn9u22u%2Cb2%3Do5-9wzngy&latLngCollection='+results[index]['lat']+','+results[index]['lng'],
      function(error, response, json){
        if(error)throw error
        try{
          json = JSON.parse(json.replace(/\s/g,""))
        }catch(e){

          json = {"Could not load info for county": index}
        }
        tmp_data[index]['elevation'] = json['elevationProfile'][0]['height']
        cb(null, tmp_data, index)
      })
    },

    //gets consumer broadband speed from
    //FCC api
    function(results, index, cb){
      request("http://data.fcc.gov/api/speedtest/find?latitude="+results[index]['lat']+"&longitude="+results[index]['lng']+"&format=json",
      function(error, response, json){
        if(error)throw error
        json = JSON.parse(json)
        tmp_data[index]['internetspeed'] = json['SpeedTestCounty']
        cb(null,tmp_data, index)
      })
    }

    ],function(err, finalresult, index){
      if(err)fs.appendFile('json/terraindata.json', {"void":json_data[key][3]+json_data[key][2]+" had an error or is missing"})
      console.log('saving new entry!')
      console.log(finalresult)
      fs.appendFile('json/terraindata.json', JSON.stringify(finalresult,null,4))
      next(null)
  })
}

var limiter = new ratelimiter(2, 'second')

fs.readFile('json/bucket1.json', function(err, data){
  if(err)throw err
  bucketlist=JSON.parse(data)
  fs.readFile('countydata.json', function(err, data){
    if(err) throw err
    var json_data = JSON.parse(data)
    async.times(3197, function(n ,next){
      limiter.removeTokens(1, function(err, remainingRequests) {
        if(err) throw err
        getData(n, json_data, next)
      })
    })
  })
})
