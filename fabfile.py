from fabric.api import local, settings, abort, run, cd, env, hosts
from fabric.contrib.console import confirm

@hosts("sites@folky.fr")
def deploy():
	code_dir = '/home/sites/helloalien'
	with cd(code_dir):
		run("git pull")
		run("venv/bin/python webapp.py collectstatic")