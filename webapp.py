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

from flask import Flask, render_template, request, send_file, \
	send_from_directory, Response, abort, session, redirect, url_for, make_response
import os, json, uuid, pymongo
from embedly        import Embedly
from pymongo        import MongoClient
from bson.json_util import dumps
from httplib2       import Http
from werkzeug       import secure_filename
from base64         import b64decode
import flask_s3

app       = Flask(__name__)
app.config.from_pyfile("settings.cfg")

def get_collection(collection):
	client = MongoClient(app.config['MONGO_HOST'])
	db     = client[app.config['MONGO_DB']]
	return db[collection]

def get_contribution(referer):
	contributions = get_collection('contributions')
	contrib       =  contributions.find_one({"referer":referer})
	if not contrib:
		contributions.insert({"referer":referer, "medias":list()})
		contrib =  get_contribution(referer)
	return contrib

def update_media(media, referer):
	type = media['type']
	contribution = get_contribution(referer)
	done = False
	for i, _media in enumerate(contribution['medias']):
		if _media['type'] == type:
			contribution['medias'][i] = media
			done = True
			break
	if not done:
		contribution['medias'].append(media)
	get_collection('contributions').save(contribution)
	return contribution

def get_referer():
	if 'referer' in session:
		referer = session['referer']
	else:
		referer = str(uuid.uuid4())
		session['referer'] = referer
	return referer

def allowed_file(filename):
	return '.' in filename and \
		   filename.rsplit('.', 1)[1].lower() in app.config['ALLOWED_EXTENSIONS']

# -----------------------------------------------------------------------------
#
# API
#
# -----------------------------------------------------------------------------
@app.route('/api/upload/audio', methods=['post'])
def upload_sound():
	f     = request.files.get('audio')
	media = upload_file(f, type='audio', referer=get_referer())
	return dumps(media)

@app.route('/api/upload/picture', methods=['post'])
def upload_picture():
	f     = request.files.get('picture')
	media = upload_file(f, type='picture', referer=get_referer())
	return dumps(media)
	
@app.route('/api/upload/avatar', methods=['post'])
def upload_avatar():
	encoded  = request.form.get('avatar').split('base64,')[1]
	filename = os.path.join(app.config['UPLOAD_FOLDER'], str(uuid.uuid4()))
	with open(filename,"wb") as f:
		f.write(b64decode(encoded))
	media  = {
		'type': 'avatar',
		'url' : filename
	}
	contribution = update_media(media, get_referer())
	return dumps(contribution)

@app.route('/api/media', methods=['post'])
def set_media():
	link = request.form.get('value')
	contribution = get_contribution(get_referer())
	client = Embedly('a54233f91473419f9a947e1300f27f9b')
	obj    = client.oembed(link)
	meta   = obj.__dict__
	media  = {
		'type'    : request.form.get('type'),
		'url'     : meta.get('url'),
		'meta'    : meta
	}
	contrib = update_media(media, get_referer())
	return dumps(contrib)

@app.route('/api/userInfos', methods=['post'])
def user_infos():
	user_info            = request.form.to_dict()
	# add ip
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

@app.route('/api/pictures', methods=['get'])
def pictures():
	res = []
	contributions = get_collection('contributions')
	for c in contributions.find():
		for media in c['medias']:
			if media['type'] == 'picture':
				res.append(media['url'])
	return dumps(res)

def upload_file(file, referer, type):
	if file and allowed_file(file.filename):
		filename = secure_filename(file.filename)
		save_as = os.path.join(app.config['UPLOAD_FOLDER'], filename)
		file.save(save_as)
		media  = {
			'type'    : type,
			'url'     : save_as,
		}
		contrib = update_media(media, referer)
		return dumps(contrib)
	return 'error, file unsupported'

@app.route('/uploaded/<media_type>/')
def uploaded_file_on_s3(media_type):
	print request.args
	filename = request.args.get('key')
	media    = {
		'type': media_type,
		'url' : filename
	}
	contrib  = update_media(media, get_referer())
	response = make_response( dumps(contrib))
	response.headers['Access-Control-Allow-Origin'] = '*'
	return response
	# return 'ok'
# -----------------------------------------------------------------------------
#
# Site pages
#
# -----------------------------------------------------------------------------

@app.route('/')
def index():
	response = make_response(render_template('home.html'))
	# response.headers['Access-Control-Allow-Origin'] = '*'
	return response

# -----------------------------------------------------------------------------
#
# Utils
#
# -----------------------------------------------------------------------------
# @app.route('/uploaded/<filename>')
# def uploaded_file(filename):
# 	return send_from_directory(app.config['UPLOAD_FOLDER'], filename)
# -----------------------------------------------------------------------------
#
# Main
#
# -----------------------------------------------------------------------------

if __name__ == '__main__':
	import preprocessing.preprocessing as preprocessing
	import sys
	if len(sys.argv) > 1 and sys.argv[1] == "collectstatic":
		preprocessing._collect_static(app)
		if app.config['USE_S3']:
			flask_s3.create_all(app)
	else:
		# render ccss, coffeescript and shpaml in 'templates' and 'static' dirs
		preprocessing.preprocess(app, request) 
		# set FileSystemCache instead of Memcache for development
		# cache = werkzeug.contrib.cache.FileSystemCache(os.path.join(app.root_path, "cache"))
		# run application
		app.run()
# EOF
