from fabric.api import local, settings, abort, run, cd, env, hosts
from fabric.contrib.console import confirm

@hosts("sites@folky.fr")
def deploy():
	local('git checkout deployed')
	local('git merge master')
	local('rm static/.gitignore -f')
	local('rm templates/.gitignore -f')
	local('git add -u .')
	# local('git commit -m "updated"')
	local('git push heroku deployed:master')
	# code_dir = '/home/sites/helloalien'
	# with cd(code_dir):
	# 	run("git pull")
	# 	run("venv/bin/python webapp.py collectstatic")
