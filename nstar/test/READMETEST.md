readbyline - a node.js module that reads files by a delimiter (line by line) very quickly

Installation:
=============

`npm install readbyline`

Usage: 
======

Abstract:

`readByLine(path_to_file, delimiter, callback)`

Practical: 

```javascript
var readByLine = require('readbyline')

readByLine('file1.txt', '\n', function (error, line) {
    
    console.log('readbyline processed your line : ' + line)
})
```

Contact:
========

<a href="https://twitter.com/yvanscher">@yvanscher</a>
<a href="https://twitter.com/sourabhtaletiya">@sourabhtaletiya</a>

Find readbyline on Node Package Manager (npm): <a href="https://www.npmjs.com/package/readbyline">https://www.npmjs.com/package/readbyline</a>