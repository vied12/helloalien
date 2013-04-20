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
import os, json
import preprocessing.preprocessing as preprocessing

app       = Flask(__name__)
app.config.from_pyfile("settings.cfg")

# -----------------------------------------------------------------------------
#
# API
#
# -----------------------------------------------------------------------------


# -----------------------------------------------------------------------------
#
# Site pages
#
# -----------------------------------------------------------------------------

@app.route('/')
def index():
	return render_template('home.html')

@app.route('/cdiscount')
def cdiscount():
	return render_template('cdiscount.html')

@app.route('/wordcloud')
def wordcloud():
	return render_template('wordcloud.html')

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
