import json
import pandas as pd
import re
import parser
from vincent import *
import json
#import os

county_geo = r'us_counties.geo.json'
county_topo = r'us_counties.topo.json'
state_topo = r'us_states.topo.json'


#load json data into pandas dataframes (predictors, to_predict)
with open('json/terraindata.json') as f:
    jsonstr = f.read()
jsonstr_spcd = re.sub('}{','}____{',jsonstr)
jsonarr = jsonstr_spcd.split( '____' )

dataframes = [parser.process_json(json_str) for json_str in jsonarr]
data = pd.concat(dataframes)
data['FIPS'] = ""

#create dataframe with county names and fips codes
datatypes = {'State':object,'State ANSI':object,'County ANSI':object,
'County Name':object,'ANSI Cl':object}
fipsdf = pd.read_table('fips.txt',sep=',',header=0,dtype=datatypes)

fipsdf['FIPS'] = ""
fipsdf['Name'] = ""
for index, row in fipsdf.iterrows():
    statefips = row['State ANSI']
    countyfips = row['County ANSI']
    fips = statefips + countyfips
    #row['FIPS'] = fips

    county_name = row['County Name']
    state_name = row['State']
    combined_name = county_name + state_name
    data.ix[data['county_name']==combined_name,'FIPS'] = fips

df = data[data['FIPS']!=""]

#do map stuff
with open('us_counties.topo.json', 'r') as f:
    get_id = json.load(f)



#MUNGE!
new_geoms = []
for geom in get_id['objects']['us_counties.geo']['geometries']:
    geom['properties']['FIPS'] = int(geom['properties']['FIPS'])
    new_geoms.append(geom)
get_id['objects']['us_counties.geo']['geometries'] = new_geoms

#update that shit
with open('us_counties.topo.json', 'w') as f:
    json.dump(get_id, f)


geometries = get_id['objects']['us_counties.geo']['geometries']
county_codes = [x['properties']['FIPS'] for x in geometries]
county_df = pd.DataFrame({'FIPS': county_codes}, dtype=int)
county_df = county_df.astype(int)


#update our dataframe with county info
df['FIPS'] = df['FIPS'].astype(int)

#merge the two databases together so that only
#counties represented on the map can display info:)
merged = pd.merge(df, county_df, on='FIPS', how='inner')
merged = merged.fillna(method='pad')

geo_data = [{'name': 'counties',
             'url': county_topo,
             'feature': 'us_counties.geo'}]

vis = Map(data=merged, geo_data=geo_data, scale=1100, projection='albersUsa',
          data_bind='povertyrate', data_key='FIPS',
          map_key={'counties': 'properties.FIPS'})

vis.marks[0].properties.enter.stroke_opacity = ValueRef(value=0.5)
#Change our domain for an even inteager
vis.scales['color'].domain = [0, 189000]
vis.legend(title='Poverty Rate by County?')
vis.rebind(column='povertyrate', brew='YlGnBu')

vis.to_json('poverty_map.json', html_out=True, html_path='poverty_map.html')
