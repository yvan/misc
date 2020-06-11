/* Great video for API design: https://vimeo.com/23861183 */
var koa = require('koa')
,router = require('koa-router')
,logger = require('koa-logger')
,config = require('./config.js')
,routes = require('./routes.js')

var app = koa()

app.use(logger())

app.use(router(app))
app.get('/', routes.bebopGreeting)
app.get('/quotes', routes.listQuotes)
app.get('/quotes/random', routes.randomQuote)
// app.put('/quotes', routes.replaceQuotes)
// app.post('/quotes', routes.addQuotes)
// app.delete('/quotes', routes.deleteQuotes)
// app.get('/quotes/:id', routes.listQuote)
// app.put('/quotes/:id', routes.replaceQuote)
// app.post('/quotes/:id', routes.addQuote)
// app.delete('/quotes/:id', routes.deleteQuote)
// app.get('/quotes/search/:searchparam', routes.searchQuotes)

app.listen(config.koa.port)

console.log('This api can now service ALL 300,000 bounty hunters in the system!')
