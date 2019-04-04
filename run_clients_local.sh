#!/bin/bash
# NOTE that nbr_of_clients should be a multiple of the number of nodes
# WARNING not updated with scale_factor; do not use as of right now

if [ "$#" -ne 3 ]; then
    echo "Run as ./run_clients [abs_path_to_hosts_file] [nbr_of_clients] [reqs_per_client]"
    exit 1
fi

NODES=$(cat ${1} | wc -l)
echo "Launcher ==> Launching all clients"
for i in $(seq 0 $(($NODES-1))); do
    source ./env/bin/activate && HOSTS_PATH=$1 python client/client.py $i $2 $3 &
done
echo "Launcher ==> Launched all clients, waiting for completion"
wait
echo "Launcher ==> Done!"
