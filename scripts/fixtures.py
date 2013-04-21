from pymongo import MongoClient
import uuid

def get_collection(collection):
	client = MongoClient()
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
