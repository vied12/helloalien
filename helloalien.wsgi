import sys
activate_this = "/home/sites/helloalien/venv/activate_this.py"
execfile(activate_this, dict(__file__=activate_this))

sys.path.insert(0, "/home/sites/helloalien")

from webapp import app as application
