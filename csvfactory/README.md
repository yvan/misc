csvfactory - convert csv files to json
======================================

This package converts csv into json and json into csv. It was made for specific SMaPP lab applications so it's not generally applicable.


First - Intall Node.js appropriate for your OS
==========================
<a href="https://nodejs.org/download/">https://nodejs.org/download/</a>

Second - Install csvfactory
==========================
```
npm i -g csvfactory
```

Third - Run csv factory
=======================
Use:
```
csvfactory csvtojson -i /path/to/inputfile.csv -o /path/to/put/outputfile.json
```
```
-i should be set to the relative or absolute path of your input file
-o should be set to the relative or absolute path of your of your output json file
```

Use:

```
csvfactory maketwittercsv -o /path/to/put/outputfile.csv -t 5 -u username -p password -n name_of_app -d description -w website_url -y true -s sign_in_url -l log_out_url
```
```
-o should be set to the relative or absolute path of your of your output csv file
-t the number of twitter apps
-u the username you'd like to use.
-p the password you'd like to use.
-n the basename of your app
-d description of your app.
-w your app's website url
-y should be set to true
-s your sign in url
-l your log out url
```

To update your package:
```
npm update -g csvfactory
```

Note on npm:
```
If you get an EACCESS error use `sudo` like so `sudo npm blah blah blah`
```