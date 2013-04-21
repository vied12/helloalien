from pymongo import MongoClient
import uuid
from flask import Flask
app       = Flask(__name__)
app.config.from_pyfile("../settings.cfg")

def get_collection(collection):
	client = MongoClient(app.config['MONGO_HOST'])
	db     = client['platinium']
	return db[collection]

cs = get_collection('contributions')
cs.remove()
for i in range(1, 11):
	c = {
		'medias' : [
			{'url':'static/images/paysages/%s.jpg' % i, 'type':'picture'},
			{'url':'static/images/paysages/sound.mp3', 'type':'audio'}
		],
		'referer': str(uuid.uuid4())
	}
	cs.insert(c)
