// this lets heroku use the proper mongodb uri for mongo
// as well as letting heroku pick the port for our server
// if we don't do this the app will not work.
var mongouri = process.env.MONGOLAB_URI || 'localhost/bebop'
var appport = process.env.PORT || 3000

module.exports = {
	mongo: {
		host: mongouri,
		collection: 'quotes'
	},
	koa: {
		port: appport
	}
}
