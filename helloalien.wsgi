import sys
activate_this = "/home/sites/helloalien/venv/bin/activate_this.py"
execfile(activate_this, dict(__file__=activate_this))

sys.path.insert(0, "/home/sites/helloalien")
sys.path.insert(1, "/home/sites/helloalien/sources")

from webapp import app as application
