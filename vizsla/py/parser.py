#parses json county information, and adds new columns 'conf' -- whether or not a state was in the confederacy:)
#return pandas dataframe -- pretty much the same as R data.frame

import pandas as pd
import json
import re

def coerced(num):
    if '.' in num:
        return float(num)
    else:
        return int(num)


#returns 0 for confederate states, 1 otherwise
def state(stateID):
    confederate_states = ['SC','MS','FL','AL','GA','LA','TX','VA','AR','NC','TN']
    if (stateID in confederate_states):
        return 0
    else:
        return 1

#returns a pd.DataFrame for given json string
def process_json(json_str):
    jsonobj = json.loads(json_str)

    poverty_rate = re.sub(',','',jsonobj["povertyrate"])
    median_income = re.sub(',','',jsonobj["medianincome"])

    if (median_income.isdigit()):
        data_row = {"population":0,
        "elevation":0,"povertyrate":coerced(poverty_rate),
        "medianincome":coerced(median_income),"bucket":jsonobj["bucket"]}
        keys = ["medianincome","povertyrate","bucket"]


        for key in jsonobj.keys():
            #key is county name
            if key not in keys:
                data_row["population"] = jsonobj[key]["population"]
                data_row["elevation"] = jsonobj[key]["elevation"]
                data_row["county_name"] = key
                data_row["latitude"] = float(jsonobj[key]["lat"])
                data_row["longitude"] = float(jsonobj[key]["lng"])
                data_row["state"] = jsonobj[key]["adminCode1"]
                data_row["conf"] = state(data_row["state"])


                if "internetspeed" in jsonobj[key].keys():
                    data_row_internet = jsonobj[key]["internetspeed"]
                    data_row = dict(data_row.items() + data_row_internet.items())
                    df = pd.DataFrame(data_row,index=[0])
                    return df
    return None
