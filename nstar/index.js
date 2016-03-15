var fs = require('fs')
var co = require('co')
var Promise = require('bluebird')

var readFile = Promise.promisify(fs.readFile)

co(function * () {
    var nstardata = yield readFile('test/nstar.json')
    var nstarjson = JSON.parse(nstardata)
    for (key in nstarjson) {
        
    }
    console.log(nstarjson)
}).catch(function(e){
    console.log(e)
})