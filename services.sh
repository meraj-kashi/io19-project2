#! /bin/bash
set -ex

master_ip=$(nova list | grep swarm1.projectx | awk '{ split($12, v, "="); print v[2]}')
worker_node1_ip=$(nova list | grep swarm2.projectx | awk '{ split($12, v, "="); print v[2]}')
worker_node2_ip=$(nova list | grep swarm3.projectx | awk '{ split($12, v, "="); print v[2]}')
#set hostname in master
ssh -o StrictHostKeyChecking=no ubuntu@$master_ip echo $master_ip 'swarm1 | sudo tee -a /etc/hosts'
ssh -o StrictHostKeyChecking=no ubuntu@$master_ip echo $worker_node1_ip 'swarm2 | sudo tee -a /etc/hosts'
ssh -o StrictHostKeyChecking=no ubuntu@$master_ip echo $worker_node2_ip 'swarm3 | sudo tee -a /etc/hosts'
#set hostname in worker-1
ssh -o StrictHostKeyChecking=no ubuntu@$worker_node1_ip echo $master_ip 'swarm1 | sudo tee -a /etc/hosts'
ssh -o StrictHostKeyChecking=no ubuntu@$worker_node1_ip echo $worker_node1_ip 'swarm2 | sudo tee -a /etc/hosts'
ssh -o StrictHostKeyChecking=no ubuntu@$worker_node1_ip echo $worker_node2_ip 'swarm3 | sudo tee -a /etc/hosts'
#set hostname in worker-2
ssh -o StrictHostKeyChecking=no ubuntu@$worker_node2_ip echo $master_ip 'swarm1 | sudo tee -a /etc/hosts'
ssh -o StrictHostKeyChecking=no ubuntu@$worker_node2_ip echo $worker_node1_ip 'swarm2 | sudo tee -a /etc/hosts'
ssh -o StrictHostKeyChecking=no ubuntu@$worker_node2_ip echo $worker_node2_ip 'swarm3 | sudo tee -a /etc/hosts'
#Initiate Docker Swarm
ssh -o StrictHostKeyChecking=no ubuntu@$master_ip sudo docker swarm init --advertise-addr  $master_ip || true
swarm_command=$(ssh -o StrictHostKeyChecking=no ubuntu@$master_ip 'docker swarm join-token manager | grep docker')
echo $swarm_command
ssh -o StrictHostKeyChecking=no ubuntu@$worker_node1_ip 'sudo '$swarm_command || true
ssh -o StrictHostKeyChecking=no ubuntu@$worker_node2_ip 'sudo '$swarm_command || true

#Setup GlusterFs on Master Node
ssh -o StrictHostKeyChecking=no ubuntu@$master_ip sudo gluster peer probe swarm1
ssh -o StrictHostKeyChecking=no ubuntu@$master_ip sudo gluster peer probe swarm2
ssh -o StrictHostKeyChecking=no ubuntu@$master_ip sudo gluster peer probe swarm3
ssh -o StrictHostKeyChecking=no ubuntu@$master_ip sudo gluster volume create swarm-gfs replica 3 swarm1:/gluster/brick swarm2:/gluster/brick swarm3:/gluster/brick force
ssh -o StrictHostKeyChecking=no ubuntu@$master_ip sudo gluster volume start swarm-gfs
ssh -o StrictHostKeyChecking=no ubuntu@$master_ip echo 'localhost:/swarm-gfs /mnt glusterfs defaults,_netdev,backupvolfile-server=localhost 0 0 | sudo tee -a /etc/fstab'
ssh -o StrictHostKeyChecking=no ubuntu@$master_ip sudo mount.glusterfs localhost:/swarm-gfs /mnt
ssh -o StrictHostKeyChecking=no ubuntu@$master_ip sudo chown -R root:docker /mnt

#Setup GlusterFs on worker Node 1
ssh -o StrictHostKeyChecking=no ubuntu@$worker_node1_ip sudo gluster volume start swarm-gfs
ssh -o StrictHostKeyChecking=no ubuntu@$worker_node1_ip echo 'localhost:/swarm-gfs /mnt glusterfs defaults,_netdev,backupvolfile-server=localhost 0 0 | sudo tee -a /etc/fstab'
ssh -o StrictHostKeyChecking=no ubuntu@$worker_node1_ip sudo mount.glusterfs localhost:/swarm-gfs /mnt
ssh -o StrictHostKeyChecking=no ubuntu@$worker_node1_ip sudo chown -R root:docker /mnt

#Setup GlusterFs on worker Node 2
ssh -o StrictHostKeyChecking=no ubuntu@$worker_node2_ip sudo gluster volume start swarm-gfs
ssh -o StrictHostKeyChecking=no ubuntu@$worker_node2_ip echo 'localhost:/swarm-gfs /mnt glusterfs defaults,_netdev,backupvolfile-server=localhost 0 0 | sudo tee -a /etc/fstab'
ssh -o StrictHostKeyChecking=no ubuntu@$worker_node2_ip sudo mount.glusterfs localhost:/swarm-gfs /mnt
ssh -o StrictHostKeyChecking=no ubuntu@$worker_node2_ip sudo chown -R root:docker /mnt

#Deploy services to the Swarm
ssh -o StrictHostKeyChecking=no ubuntu@$master_ip git clone https://github.com/meraj-kashi/io19-project2-microservices.git






