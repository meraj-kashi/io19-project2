#! /bin/bash
set -ex

master_ip=$(nova list | grep swarm1.projectx | awk '{ split($12, v, "="); print v[2]}')
worker_node1_ip=$(nova list | grep swarm2.projectx | awk '{ split($12, v, "="); print v[2]}')
worker_node2_ip=$(nova list | grep swarm3.projectx | awk '{ split($12, v, "="); print v[2]}')
#set hostname!
ssh -o StrictHostKeyChecking=no $master_ip sudo docker swarm init --advertise-addr  $master_ip
swarm_command=$(ssh -o StrictHostKeyChecking=no $master_ip 'docker swarm join-token manager | grep docker')
echo $swarm_command
ssh $worker_node1_ip 'sudo '$swarm_command
ssh $worker_node2_ip 'sudo '$swarm_command

