


import json
from wood import Wood

w = Wood(__name__,debug=True)

@w.route(r"/callback")
def hereauth_callback(self):
	print(self.request.body)
	self.write({
		'jumpUrl': 'http://localhost:6000/jump'
		})

@w.route(r"/jump")
def hereauth_jump(self):
	self.write('welcome!')

if __name__ == '__main__':
	w.start(5000)

