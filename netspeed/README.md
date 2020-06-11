Netspeed - Get US internet speeds
================================

[![NPM](https://nodei.co/npm/netspeed.png?downloads=true&downloadRank=true&stars=true)](https://nodei.co/npm/netspeed/)

Netspeed is a wrapper for the FCC broadband internet speed API. Broadband internet
speeds are only recorded at the county level by the FCC. You can plug in the name
of a county or coordinates and Netspeed will get you the internet speed for the
correpsonding county. If you're looking for something more granular it doesn't
exist (that I know of). If you do find something with more localized internet
speeds I would love to have a look, @yvanscher on twitter.

FCC data is only stored at the county level, so you can search for it by city, but
your results are going to come on on a per county basis.

In otherwords a call like so:
```
netspeed('Ithaca, NY', function(result){
  console.log(result)
})
```
gets internetspeed in Tompkins County, NY because Ithaca, NY is in Tompkins County.

Usage
====
```
var netspeed = require('netspeed')

netspeed('Tompkins County, NY', function(result){
  console.log(result)
}) // gets internetspeed in Tompkins County, NY

netspeed(42.45202,-76.47366, function(result){
  console.log(result)
}) // gets internetspeed at (latitude,longitude)
```

What do you need for this to work?
=================================

A Geonames username setup to work with the API key:

Go to http://www.geonames.org/manageaccount, create an account for free and then
click the button right underneath the signup form "enable for free web service."
It should take 1 hour for your key to activate for your chosen username.
Geonames doesn't give an exact number anywhere, I'd say anywhere around
2000 requests per hour should be fine.

Be sure to set your username locally with netspeed. It will not know to plug into
your globally installed 'geographer' module (if you have installed my geographer
module, that is).

To set Netspeed's 'geographer' dependency username use:
```
node_modules/netspeed/node_modules/.bin/geographer -u YOUR_GEONAMES_USERNAME
//or
node_modules/netspeed/node_modules/.bin/geo -u YOUR_GEONAMES_USERNAME
```

If it's too confusing to set up or you need moral support just hit me up on twitter  
handle @yvanscher, or if my module is a pile of donkey dung and you'd like
to tell me just how much better it could be tweet at me.

The Future
=========
Idk. Someone fork me.
