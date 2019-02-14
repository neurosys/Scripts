#!/usr/bin/env bash

# Example
# tunnel_for_rdp.sh 172.16.0.222 3889

LOCAL_LISTENING_PORT=${2:-3389}

if [[ -n $1 ]]
then
    DESTINATION_IP=$1
else
    echo "ERR: please enter a destination ip"
    echo -e "\t$0 <destination ip> [local listening ip]"
    exit 1
fi


socat tcp-listen:${LOCAL_LISTENING_PORT},reuseaddr,fork tcp:${DESTINATION_IP}:3389

