#!/usr/bin/env python
# Encoding: utf-8
# -----------------------------------------------------------------------------
# Project : 
# -----------------------------------------------------------------------------
# Author : Edouard Richard                                  <edou4rd@gmail.com>
# -----------------------------------------------------------------------------
# License : GNU Lesser General Public License
# -----------------------------------------------------------------------------
# Creation : 
# Last mod : 
# -----------------------------------------------------------------------------

from flask import Flask, render_template, request, send_file, Response, abort, session, redirect, url_for
import os, json, uuid, pymongo
import preprocessing.preprocessing as preprocessing
from embedly import Embedly
from pymongo import MongoClient
from bson.json_util import dumps
from httplib2 import Http

app       = Flask(__name__)
app.config.from_pyfile("settings.cfg")

def get_collection(collection):
	client = MongoClient()
	db     = client['platinium']
	return db[collection]

def get_contribution(referer):
	contributions = get_collection('contributions')
	contrib       =  contributions.find_one(referer=referer)
	if not contrib:
		contributions.insert({"referer":referer, "medias":list()})
		contrib =  get_contribution(referer)
	return contrib

def get_referer():
	if 'referer' in session:
		referer = session['referer']
	else:
		referer = str(uuid.uuid4())
		session['referer'] = referer
	return referer

# -----------------------------------------------------------------------------
#
# API
#
# -----------------------------------------------------------------------------
@app.route('/api/upload/sound', methods=['post'])
def upload_sound():
	f     = request.files.get('sound')
	media = upload_file(f, type='audio', referer=get_referer())
	return dumps(media)

@app.route('/api/upload/picture', methods=['post'])
def upload_picture():
	f     = request.files.get('picture')
	media = upload_file(f, type='picture', referer=get_referer())
	return dumps(media)

@app.route('/api/upload/avatar', methods=['post'])
def upload_avatar():
	f     = request.files.get('avatar')
	media = upload_file(f, type='avatar', referer=get_referer())
	return dumps(media)

@app.route('/api/userInfos', methods=['post'])
def user_infos():
	user_info            = request.form.to_dict()
	# add ip
	print request.remote_addr
	user_info['ip']      = request.remote_addr
	# add coord
	response, content    = Http().request("http://freegeoip.net/json/%s" % user_info['ip'])
	content = json.loads(content)
	user_info['lat']     = content['latitude']
	user_info['lng']     = content['longitude']
	contribution         = get_contribution(get_referer())
	contribution['user'] = user_info
	get_collection('contributions').save(contribution)
	return dumps(contribution)

@app.route('/api/map', methods=['get'])
def map():
	contributions = get_collection('contributions')
	return dumps(contributions.find())

def upload_file(f, referer, type):
	filename = f.filename
	# save file
	save_as = os.path.join('uploaded', filename)
	f.save(save_as)
	# keep the reference
	client = Embedly('a54233f91473419f9a947e1300f27f9b')
	obj    = client.oembed('http://instagr.am/p/BL7ti/')
	meta   = obj.__dict__
	media  = {
		'type'    : type,
		'url'     : save_as,
		'meta'    : meta
	}
	contrib = get_contribution(referer)
	contrib['medias'].append(media)
	get_collection('contributions').save(contrib)
	return contrib

# -----------------------------------------------------------------------------
#
# Site pages
#
# -----------------------------------------------------------------------------

@app.route('/')
def index():
	return render_template('home.html')

# -----------------------------------------------------------------------------
#
# Utils
#
# -----------------------------------------------------------------------------

# -----------------------------------------------------------------------------
#
# Main
#
# -----------------------------------------------------------------------------

if __name__ == '__main__':
	import sys
	if len(sys.argv) > 1 and sys.argv[1] == "collectstatic":
		preprocessing._collect_static(app)
	else:
		# render ccss, coffeescript and shpaml in 'templates' and 'static' dirs
		preprocessing.preprocess(app, request) 
		# set FileSystemCache instead of Memcache for development
		# cache = werkzeug.contrib.cache.FileSystemCache(os.path.join(app.root_path, "cache"))
		# run application
		app.run()
# EOF
