#does "stats" -- whatever that means
#loads json data and calls parser function to form pandas dataframe

import json
import pandas as pd
import numpy as np
import re
import parser


#load json data into pandas dataframes (predictors, to_predict)
jsonstr = open('terraindata.json').read()
jsonstr_spcd = re.sub('}{','}____{',jsonstr)
jsonarr = jsonstr_spcd.split( '____' )

dataframes = [parser.process_json(json_str) for json_str in jsonarr]
data = pd.concat(dataframes)

print data.dtypes

#dataframe of just the predictors as columns
predictors = data[['elevation','medianincome','population','povertyrate']]
#since column dataframe with one target, change to any internet test if neccessary
target = data['wirelessTests']

#do stats

                              ###see statsmachine.js insteads##