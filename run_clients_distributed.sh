#!/bin/bash
# NOTE that nbr_of_clients must be a multiple of the number of nodes

if [ "$#" -ne 4 ]; then
    echo "Run as SLICE=slice_name SSH_KEY=abs_path_to_ssh_key ./run_clients [abs_path_to_hosts_file] [scale_factor] [nbr_of_clients] [reqs_per_client]"
    exit 1
fi

DEF_SLICE=chalmersple_2018_10_29
DEF_SSH_KEY=~/.ssh/id_rsa_chalmers

echo "Launcher ==> Launching clients on PlanetLab nodes"
declare -a pids
cat $1 | awk "NR % $2 == 0" | tr ',' ' ' | awk '{print $1","$2}' | while read line
do
    ID=$(echo $line | tr ',' ' ' | awk '{print $1}')
    HOST=$(echo $line | tr ',' ' ' | awk '{print $2}')
    CMD="cd /practicalbft/BFTList-client && source ./env/bin/activate && HOSTS_PATH=/practicalbft/BFTList/conf/hosts.txt python client/client.py $ID $3 $4"
    echo "Launcher ==> Launching client on ${HOST}"
    ssh -o StrictHostKeyChecking=no -l ${SLICE:-$DEF_SLICE} -i ${SSH_KEY:-$DEF_SSH_KEY} ${HOST} ${CMD} &> /dev/null &
    pids[${ID}]=$!
done
echo "Launcher ==> Clients launched on PlanetLab nodes!"