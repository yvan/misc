var fs = require('fs')

module.exports = function readByLine (inputfilepath, delimiter, callback) {

	var fileStream = fs.createReadStream(inputfilepath)
		,remaining = ''
		,rollover = ''

	fileStream.on('data', function (data) { 

		if(rollover !== ''){
			remaining = rollover + data.toString()
			rollover = ''
		} else {
			remaining = data.toString()
		}

		while(remaining !== '') {
			var indexOfDelimiter = remaining.indexOf(delimiter)
			if (indexOfDelimiter === -1) {
				rollover = remaining
				remaining = ''
				callback(new Error('The delimiter you were looking for did not appear!'), null)
			} else {
				var currentline = remaining.substring(0, indexOfDelimiter+1)
					,remaining = remaining.substring(remaining.indexOf(delimiter)+1)
				callback(null, currentline)
			}

		}
	})

	fileStream.on('end', function () {
		console.log('readbyline has reached the end of your file!')
	})
}