import subprocess
import re
import time
import os

rebuild_list = []
error = 1


def handle_error():
    global error
    global rebuild_list
    while error:
        failed = os.popen('nova list | grep "ERROR"')
        error_list = failed.read()
        error_array = re.findall(" [a-zA-Z0-9]*.projectx", error_list)

        if error_array:
            for i in error_array:
                rebuild_list.append((i.replace(" ", "")).replace(".projectx", ""))
        else:
            error = 0
            rebuild_list = []

        for i in rebuild_list:
            subprocess.run('nova delete ' + i + '.projectx', shell=True)
            time.sleep(10)
            subprocess.run('mln start -p projectx -h ' + i, shell=True)
            time.sleep(20)
        rebuild_list = []
        


def vm_deploy():

    print('------------- Start Deployment ------------')
    # Build mln project
    subprocess.run('mln build -f projectx.mln -r', shell=True)
    time.sleep(30)

    # Start deployment infra with MLN
    subprocess.run('mln start -p projectx', shell=True)
    time.sleep(30)

    handle_error()

def swarm_deploy():
    print('------------- Start Swarm Deployment ------------')
    subprocess.run('chmode +x ./swarm.sh', shell=True)
    subprocess.run('./swarm.sh', shell=True)



vm_deploy()
swarm_deploy()


