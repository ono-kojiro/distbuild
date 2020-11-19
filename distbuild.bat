1>2# : ^
'''
@ECHO OFF
python "%~f0"
EXIT /B
REM ^
'''

#!/usr/bin/env python

import time
import jenkins

import json

import threading, queue

from pprint import pprint

def read_json(filepath) :
	fp = open(filepath, mode='r', encoding='utf-8')
	data = json.loads(fp.read())
	fp.close()
	
	return data

def run_job(server) :
	pass
	
def main() :
	targets = [
		'kernel',
		'driver',
		'bootrom',
		'cellos',
		'startup'
	]
	
	hosts = [
		{
			'url' : 'http://localhost:8080',
			'job' : 'diffbuild',
			'api_token' : 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
		},

		{
			'url' : 'http://192.168.0.93:8080',
			'job' : 'diffbuild',
			'api_token' : 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
		}
	]

	num_hosts = 2
	
	q = queue.Queue()
	for target in targets :
		q.put(target)
	
	
	username = 'admin'
	
	servers = []
	for host in hosts :
		url = host['url']
		job = host['job']
		api_token = host['api_token']
		
		server = \
			jenkins.Jenkins(url,
				username=username,
				password=api_token
			)
		
		user = server.get_whoami()
		version = server.get_version()
		print('absoluteUrl : {0}'.format(user['absoluteUrl']))
		print('version : {0}'.format(version))
		jobs = server.get_jobs()
		print('{0}'.format(url))
		for job in jobs :
			#job_info = server.get_job_info(job)
			print('  {0}, {1}'.format(job['name'], job['url']))

		servers.append(server)

		#user = server.get_whoami()
		#version = server.get_version()

	print('')
	print('distbuild')
	while 1 :
		if q.empty() :
			break
		
		target = q.get()
		#print(target)
		
		while 1 :
			found = 0
			for i in range(len(hosts)) :
				host   = hosts[i]
				server = servers[i]
				
				url = host['url']

				#print(url)
				queue_info = server.get_queue_info()
				#pprint(queue_info)
				
				if len(queue_info) == 0 :
					print('throw job {0} to {1}'.format(target, url))
					server.build_job('diffbuild',
						{
							'BUILD_DIR' : 'C:\home\onoko\devel\cellos_cmake',
							'TARGETS' : target
						}
					)
					found = 1
					break
			
			if found :
				break
			else :
				pass
				#print('wait 5sec')
				time.sleep(5)
		

if __name__ == '__main__' :
	main()
