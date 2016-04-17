twitterids_to_usernames
=========================================================================
convert ids to usernames or usernames to ids

Usage:
======

`python path/to/ids_to_usernames.py -i path/to/input.json -o path/to/output.json -a path/to/oauthpool.json`

`python path/to/usernames_to_ids.py -i path/to/input.json -o path/to/output.json -a path/to/oauthpool.json`

Get twitter Oauth authorization :
===============================

(default is `oauth/oauthpool.json`)

Create a twitter app if you haven't and get the keys and auth tokens.

You will need to put your twitter keys in a file called oauthpool.json formatted like so:

```
[
	{
		"cKey": "YOUR_CONSUMER_KEY_HERE",
		"cSecret": "YOUR_CONSUMER_SECRET_HERE",
		"aToken": "YOUR_AUTHORIZATION_TOKEN_HERE",
		"aTokenSecret": "YOUR_TOKEN_SECRET_HERE"
	},
	{
		"cKey": "YOUR_CONSUMER_KEY_HERE",
		"cSecret": "YOUR_CONSUMER_SECRET_HERE",
		"aToken": "YOUR_AUTHORIZATION_TOKEN_HERE",
		"aTokenSecret": "YOUR_TOKEN_SECRET_HERE"
	}
	.
	.
	.
	{
		"cKey": "YOUR_CONSUMER_KEY_HERE",
		"cSecret": "YOUR_CONSUMER_SECRET_HERE",
		"aToken": "YOUR_AUTHORIZATION_TOKEN_HERE",
		"aTokenSecret": "YOUR_TOKEN_SECRET_HERE"
	}

]
```

Input Files:
============

(default is `input/input.json`)

The input file is specified by an input parameter '-i' when you run the script.

Input files of id lists should just be a file containing a hard bracket array:

```
[22997097, 14281853, 20686582, 19977542, 15529670, 14291684, 5680622, 14411725, 
2304746754, 77821953, 22628924, 21796893, 358204197, 2289811698, 103065157, 219976700, 
275799277, 16596200, 61781260, 15010349, 14450739, 15484198, 160952087, 245320407, 
92248166, 19017675]
```

and should be '.json' formatted. The default input file name is input.json and if you 
place a file called input.json in the input folder the script will read that file as the
input.

The input file can also be a CSV with one column like so:
```csv
screen_name
mcdonald4avalon
jeannie4avalon
lbarnettavalon
ScottAndrewsNL
Jenn_McCreath
judyfootemp
teejohnny
Scott_Simms
ClaudetteNDP
YvonneJJones
EdwardNDP
PeterPenashue
Gudie
DevBabstockNDP
.
.
.
joebyrnepei
beckaviau
ronmacmillanpei
MorrisseyEgmont
Drhdickieson
```

Output Files:
=============

(default is `output/output.json`)

The output file is specified by an output parameter '-o' when you run the script.

Output files are json files where the index/key is the original user id and the values
are the twitter screen names.

Output files should be '.json' formatted. The default output file name is output.json. Output will appear in the output folder by default.

There is also a log.log file that gets output in the logs folder with a format that looks like so:
```
22997097 , allianceparty
14281853 , Conservatives
20686582 , CoopParty
.
.
.
.
19017675 , Nigel_Farage
```

Log files :
==========

(default is `logs/log.log`)

Logs get output to a folder called logs and a file called log.log inside that file. They give a simpler non-json list of the twitter screen names.

Note: All these default folders input, output, logs are located within the downloaded 
repository folder. If you don't want to use these 
defaults then specify your own via command line arguments as demonstrated above. To be even more clear, none of these folders contain anything, you just have the option of putting your input.json, oauth.json files there or specifying some other location. If you use the folders and you put your files there the script can be run as:

`python path/to/ids_to_usernames.py`

TODO:
=====

There should be a way to submit up to 100 twitter user_ids and get 100 user screen names back at once. It doesn't seem like it's supported by tweepy though. lookup_users theoretically has this functionality but it doesn't really work.


