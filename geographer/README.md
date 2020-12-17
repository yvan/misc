Geographer - Geographic information from place names
===================================================
[![NPM](https://nodei.co/npm/geographer.png?downloads=true&downloadRank=true&stars=true)](https://nodei.co/npm/geographer/)

Download with:
```
npm install -g geographer //installing globally means you set API username once
//or
npm install geographer    //each project gets its own geographer installation
```

This module lets you get geographic inforamtion about cities and places in the
USA easily and conveniently.

There's a command line component which allows you to set your username (tied to
your Geonames API key). You can also just add it to the 'config.json' file
manually if that's your jam.

Full List of Setup Commands:
```
geographer -u YOUR_GEONAMES_USERNAME
geographer -l LANGUAGE_CODE             //default set to 'en' for english
geographer -c YOUR_COUNTRY_CODE_OR_NAME //default set to 'US' or united states
//or
geo -u YOUR_USERNAME
geo -l LANGUAGE_CODE
geo -c YOUR_COUNTRY_CODE_OR_NAME
```

Instead of setting your username this way you can always just edit teh config.json file
directly. Your username is how the API links to your API key for the geonames API.

config.json is loccated in node_modules/geographer/config.json

To work with these commands on only the current directory's copy of geographer use:
```
node_modules/.bin/geographer -u YOUR_GEONAMES_USERNAME
//or
node_modules/.bin/geo -u YOUR_GEONAMES_USERNAME
```

If you country is more than one word set it like so:
```
geo -c 'united states'
```
What do you need for this to work?
=================================

A Geonames username setup to work with the API key:

Go to http://www.geonames.org/manageaccount, create an account for free and then
click the button right underneath the signup form "enable for free web service."
It should take 1 hour for your key to activate for your chosen username.
Geonames doesn't give an exact number anywhere, I'd say anywhere around
2000 requests per hour should be fine.

If it's too confusing to set up or you need moral support just hit me up on twitter  
handle @yvanscher, or if my module is a pile of donkey dung and you'd like
to tell me just how much better it could be tweet at me.

Usage
====
Setup:
```
geo -u YOUR_USERNAME
```
Call format:
```
//maxresults is optional
geographer('placename', 'statename/statecode', [maxresults], function(results){
  console.log(results)
})
```
Example:
```
var geographer = require('geographer')

geographer('Ithaca', 'NY', 2, function(results){
  console.log(results)
})
//or
geographer('Ithaca', 'new york', 2 , function(results){ //new york not case sensitive
  console.log(results)
})  

//returns

{ emptyfields: { 'Ithaca Tompkins Regional Airport': { '0': [Object] } },
  terraindata:
   { potentialresults: 62,
     Ithaca:
      { country: 'United States',
        region: 'New York',
        county: 'Tompkins County',
        locationtype: 'seat of a second-order administrative division',
        terraintype: 'city, village,...',
        elevation: 125,
        latitude: '42.44063',
        longitude: '-76.49661',
        boundingbox: [Object],
        timezone: [Object],
        population: 30014 },
     'Ithaca Tompkins Regional Airport':
      { country: 'United States',
        region: 'New York',
        locationtype: 'airport',
        terraintype: 'spot, building, farm',
        elevation: 335,
        latitude: '42.49083',
        longitude: '-76.45833',
        timezone: [Object]
      }
    }
}
```
Why does it get an airport as the second result? Clearly we asked for the city.
Since we set the finalparameter in our call to geographer('Ithaca', 'NY', 2)
to 2, geographer tries to get more places that might fit the description in
addition to the most likely result. This final parameter is optional and if left
blank or omitted all possible results will be returned. To just get the city of
Ithaca set the final parameter to 1.

Any fields that could not be found a location gets cleaned out of the terraindata
object and put into the emptyfields object with the location name as an index.
If you don't want that info just discard it.

Calling:
```
geographer('Ithaca', 'NY', function(results){})
```
Returns 62 results for locations that potentially match the name Ithaca. From most
likely desired to least likely desired.

In the Future
============
In the world of tommorrow I'm hoping to add the ability to create geonames API keys
and usernames directly from your code or command line. For now we have to use
Geonames functional website for signing up.I'm working on the ability to
exclude certain keywords forall queries or just from queries that
search for placename "ithaca." IT IS NOT IMPLEMENTED YET.

What is in the 'info' folder?
============================
Magical country codes, language codes, US states. Some are used
others are there for any future work on the project.
