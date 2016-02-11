#!/usr/bin/env node

//script that contains various
//functionality for working
//with csv at SMaPP

var csv = require('fast-csv')
,argv 	= require('minimist')(process.argv.slice(2))
,fs 	= require('fs')

var jsonObj = [], fistpass = false,
uniques = ['abcd', 'abdc', 'acbd', 'acdb', 'adbc', 'adcb', 'bacd', 'badc', 'bcad', 'bcda', 'bdac', 'bdca', 'cabd', 'cadb', 'cbad', 'cbda', 'cdab', 'cdba', 'dabc', 'dacb', 'dbac', 'dbca', 'dcab', 'dcba']

//converts a particular format of CSV
//where the twitter info is in those
//indicies/slots for each row. (8, 9, 10, 11)

function csvToJSON (inputpath, outputpath) {
	var csvStream = csv()
	.on('data', function (data) {
		if(!firstpass) {
			jsonObj.push({
				"consumer_key": data[8]
				,"consumer_secret": data[9]
				,"access_token": data[10]
				,"access_token_secret": data[11]
			})
			firstpass = false
		}
	})
	.on('end', function () {
		console.log(jsonObj)
		fs.writeFile(outputpath, JSON.stringify(jsonObj, null, 4), function (err) {
			if (err) throw err
			console.log('Your csv has been converted and saved as JSON!')
		})
	})
	var stream = fs.createReadStream(inputpath)
	stream.pipe(csvStream)
}

function produceTwitterCSV (outputpath, numtimes, username, password, appname, description, website, yia, siurl, lourl) {
	var csvStream = csv.createWriteStream({headers: true})
		,writeableStream = fs.createWriteStream(outputpath)

	writeableStream.on('finish', function () {
		console.log('Done creating your sexy csv!')
	})

	csvStream.pipe(writeableStream)
	for (var i = 0; i < numtimes; i++) {
		csvStream.write({
			"Phone email or username": username
			,"Password": password
			, "Name": appname +'_'+ Date.now()+'_'+uniques[i]
			,"Description": description
			,"Website": website
			,"Yes I agree": yia
			,"Sign IN URL": siurl
			,"Log Out URL": lourl
		})	
	}
	csvStream.end()
}

//Phone email or username;Password;Name;Description;Website;Yes I agree;Sign IN URL;Log Out URL
switch(true){
	case (argv._[0] === 'csvtojson' ):
		csvToJSON(argv.i, argv.o)
	break;
	case (argv._[0] === 'maketwittercsv'):
		produceTwitterCSV(argv.o, argv.t, argv.u, argv.p, argv.n, argv.d, argv.w, argv.y, argv.s, argv.l)
	break;
	default:
		console.log('Use csvfactory csvtojson -i /path/to/inputfile.csv -o /path/to/put/outputfile.json')
		console.log('Use csvfactory maketwittercsv -o /path/to/put/outputfile.csv -t number_of_apps -u username -p password -n name_of_app -d description -w website_url -y true -s sign_in_url -l log_out_url')
}
