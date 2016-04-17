# uses twitter app called SMaPP ID to Username
from smappPy import tweepy_pool

import argparse
import logging
import tweepy
import json
import csv
import os

#setup the logger
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger('ids_to_usernames')
hdlr = logging.FileHandler(os.path.dirname(os.path.abspath(__file__))+'/logs/log.log')
logger.addHandler(hdlr)

# tests whether a file is JSON
def is_json(jsonfilename):
  try:
    json_object = json.loads(jsonfilename)
  except ValueError, e:
    return False
  return True

def is_csv(csvfilename):
    filehandle = open(csvfilename)
    filecontents = csv.reader(filehandle)
    for row in filecontents:
        if len(row)==0:
            return False
    return True

#setup the main function
if __name__ == '__main__':
	##these file path defaults redicrect to the directory from which the script is run
	parser = argparse.ArgumentParser()
	parser.add_argument('-i', '--input', dest='input', default=os.path.dirname(os.path.abspath(__file__))+'/input/input.json', help='This is a path to your input.json, a [] list of twitter ids.')
	parser.add_argument('-o', '--output', dest='output', default=os.path.dirname(os.path.abspath(__file__))+'/output/output.json', help='This will be your output file, a {} json object showing original ids and twitter screen names.')
	parser.add_argument('-a', '--auth', dest='auth', default=os.path.dirname(os.path.abspath(__file__))+'/oauth/oauthpool.json', help='This is the path to your oauth.json file for twitter')
	args = parser.parse_args()

	id_list = []

	filename, file_extension = os.path.splitext(args.input)

	if file_extension == '.json':
		print 'trying json...'
		id_data = open(args.input).read()
		id_list = json.loads(id_data)
		print 'id_list is json'
		print id_list
	elif file_extension == '.csv':
		print 'is not json, trying csv'
		csvhandle = open(args.input)
		csvreader = csv.reader(csvhandle)
		#don't record column names
		count = 0
		for row in csvreader:
			if count > 0:
				id_list.append(row[0])
			count = count + 1

	# create an API pool
	json_data = open(args.auth).read()
	oauth = json.loads(json_data)
	api = tweepy_pool.APIPool(oauth)

	names_json = {}

	# tweepy docs here : https://github.com/tweepy/tweepy/blob/master/tweepy/api.py#L146
	# there's a way to get a bunch of users in one go
	# not supported by tweepy though...
	for a_user_id in id_list:
		try:
			res = api.get_user(user_id=a_user_id)
			names_json[str(a_user_id)] = res.screen_name
			logger.info("{} , {}".format(a_user_id, res.screen_name))
		except:
			print 'excepted a tweepy error'

	write_fd = open(args.output, 'w')
	write_fd.write(json.dumps(names_json, indent=4))
	write_fd.close()
