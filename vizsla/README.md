vizsla
======

## CSV Folder
All csv data file are original data sets downloaded offline and are in teh csv folder. Country quality talks about latency and 
packet loss on a daily time scale from 2008-14 for world countries. Country speeds is daily time scale internet upload and 
download speeds for the same years. Country value is the daily time scale cost of internet in various countries over the same 
years, data is spottier here. All of the 'region' csv files with quality, speeds, and value are the exact same data s for the 
countries except for US states and provinces of Canada (which didn't really use because so few people actually live in canada 
that it's basically the equivalent of one large U.S. state).

## JS Folder

All javascript data conversion from csv to JSON, data preprocessing/formatting, and data processing scripts are in the js 
folder. Convertdata.js converts from csv to JSON for all data sets, just swap out the appropriate file names in the script to 
get it working. processcountrydata.js processes daily speed data and summarizes it on a yearly basis for each political 
division The summary is accessible underneath the JSON attribute "COUNTRY_NAME" in the structure of the json file. 
processcountryquality does the same thing for quality data. processcountryvalue does the same thing for internet costs. The
scripts that say "state" instead of "country" process the same data in the same way but for US states. We also REPLACE the U.S. 
country level data with this U.S. state level data (so as not to confuse our data visualized map in the <a href="https://github.com/yvanscher/datamap">datamap repo</a> with state level and country level U.S. data). Statsmachine.js does some data 
processing averaging, displays, and stores that data. terraindata.js was our original data collection from multiple APIs on our 
first attempt to combine multiple API data scources to create a predictive model for internet speed. You will notice that the 
call to the mapquest API is totally unecessary and redundant, because Geonames API before it gives elevation data. We didn't 
know that, and the option you send to Geonames to get that elevation data is not really in their documentation (which is 
convoluted at best) anywhere.

##JSON Folder

This stores all our processed data. bucket1.json contains the bucket for our original predictive model. "constantvals" are the result of js folder scripts with similar names to find the highest and lowest values in certain data measurements to we can create the color scale on our webapp. Terraindata.json is the data collected from the three APIs (Geonames, FCC, and mapQuest) for our original predictive model. the other's all follow a format XXXdata XXXdatafinal, data is the converted from CSV file. datafinal is the final file with the formatting and data summaries we need for the data to actually be useful. The structure is quite different; in the final file each country and state's data and summaries are indexed by it's name.

##PY Folder

All the python scripts. map.py creates those beautiful maps that were in our presentation slides, poverty, internet speeds (wireless and wireline). parser.py is a mini library that parses json properly, we use it in map.py.


Notes
=====
Ended up not using JShint in node_modules folder. Tacked it on there just in case I want to use it for this in the future.