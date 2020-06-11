var config = require(__dirname + '/config.js')
,monk = require('monk')
,wrap = require('co-monk')
,db = monk(config.mongo.host)
,quotes = wrap(db.get(config.mongo.collection))

module.exports = {

	bebopGreeting: function * () {
		this.body = 'Hey bounty hunters! How ya\'ll doing?'
	},
	listQuotes: function * () {
		var res = yield quotes.find({}, {fields: {_id: 0}})
		var bodybuilder = ''
		console.log(res)
		res.forEach(function (docu) {
			bodybuilder += '</br>' + docu.quote + '</br>'
			console.log(bodybuilder)
		})
		this.body = bodybuilder
	},
	replaceQuotes: function * () {

	},
	addQuotes: function * () {

	},
	deleteQuotes: function * () {

	},
	listQuote: function * () {
		var res = yield quotes.find({})
		this.body = res
	},
	randomQuote: function * () {
		var count = yield quotes.count({})
		var res = yield quotes.find({}, {limit: -1, skip: Math.floor(Math.random() * count), next: {}, fields: {_id: 0}})
		this.body = res[0].quote
	},
	searchQuotes: function * () {

	}
}
