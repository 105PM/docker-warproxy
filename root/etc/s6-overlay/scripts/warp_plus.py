import subprocess
import sys
import urllib.request
import json
import datetime
import random
import string
import time
import argparse
import toml
import logging
import re

#logger
################################
logger = logging.getLogger()
logger.setLevel(logging.ERROR)
formatter = logging.Formatter('%(asctime)s [WARP_PLUS] %(message)s', '[%Y/%m/%d %H:%M:%S]')
stream_handler = logging.StreamHandler()
stream_handler.setFormatter(formatter)
logger.addHandler(stream_handler)

#argparser
################################
parser = argparse.ArgumentParser()
subparsers = parser.add_subparsers(title='commands', dest='commands')
run_parser = subparsers.add_parser('run', help='Get WARP+ Quota')
update_parser = subparsers.add_parser('update', help='Update Private Key')
parser.add_argument("--config", dest="config", default="/config/wgcf-account.toml", help="Set wgcf-account.toml location")
parser.add_argument("-v", "--verbose", dest="verbose", action='store_true', help="Verbose")
args = parser.parse_args()

def genString(stringLength):
	try:
		letters = string.ascii_letters + string.digits
		return ''.join(random.choice(letters) for i in range(stringLength))
	except Exception as error:
		print(error)

def digitString(stringLength):
	try:
		digit = string.digits
		return ''.join((random.choice(digit) for i in range(stringLength)))    
	except Exception as error:
		print(error)

url = f'https://api.cloudflareclient.com/v0a{digitString(3)}/reg'

def run():
	with open(args.config) as f:
		data = toml.load(f)
		referrer = data['device_id']
	try:
		install_id = genString(22)
		body = {"key": "{}=".format(genString(43)),
				"install_id": install_id,
				"fcm_token": "{}:APA91b{}".format(install_id, genString(134)),
				"referrer": referrer,
				"warp_enabled": False,
				"tos": datetime.datetime.now().isoformat()[:-3] + "+02:00",
				"type": "Android",
				"locale": "es_ES"}
		data = json.dumps(body).encode('utf8')
		headers = {'Content-Type': 'application/json; charset=UTF-8',
					'Host': 'api.cloudflareclient.com',
					'Connection': 'Keep-Alive',
					'Accept-Encoding': 'gzip',
					'User-Agent': 'okhttp/3.12.1'
					}
		req         = urllib.request.Request(url, data, headers)
		response    = urllib.request.urlopen(req)
		status_code = response.getcode()	
		return status_code
	except Exception as error:
		logger.error(error)

def getquota():
	while True:
		result = run()
		if result == 200:
			logger.info(f'WARP+ 1GB added!')
			time.sleep(60)
		else:
			logger.error(f'WARP+ Fail!')

def updatekey():
	with open(args.config) as f:
		conf_data = toml.load(f)
		device_id = conf_data['device_id']
		access_token = conf_data['access_token']

	headers = {'Content-Type': 'application/json; charset=UTF-8',
				'Host': 'api.cloudflareclient.com',
				'User-Agent': 'okhttp/3.12.1',
				'authorization': f'Bearer {access_token}'
				}
	
	data = None
	req = urllib.request.Request(f'{url}/{device_id}', data, headers)
	req.get_method = lambda: 'PATCH'
	response = urllib.request.urlopen(req)
	if response.getcode() == 200:
		logger.info('Update Device Info...')
	else:
		logger.error(f'Update Failed: {response.getcode()}')

def checkmode():
	req = urllib.request.Request('https://www.cloudflare.com/cdn-cgi/trace')
	response = urllib.request.urlopen(req)
	warp_mode = re.search('warp=([\w]+)', response.read().decode('utf8')).group(1)
	return warp_mode

if __name__ == '__main__':
	if len(sys.argv)==1:
		parser.print_help(sys.stderr)
		sys.exit(1)
	if args.verbose:
		logger.setLevel(logging.INFO)
	if args.commands == 'run':
		getquota()
	elif args.commands == 'update':
		updatekey()