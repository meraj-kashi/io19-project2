import subprocess
import re
import time
import os

# Deploy 3 nodes with MLN installed Docker on top

# Initiate Swarm cluster

get_master_ip=os.popen("nova list | grep swarm-1 ")
read_master_ip=get_master_ip.read()
master_ip=re.findall("\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}",read_master_ip)

print(master_ip)

