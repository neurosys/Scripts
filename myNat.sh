#!/usr/bin/env bash

who=$(whoami)

if [[ "$who" != "root" ]]
then
    echo "You neet to run this as root"
    exit
fi


echo "Choose the network card connected to WAN"
echo ""

nics=( $(ip link | grep -o '^[0-9]\+: \<[a-zA-Z0-9]\+:' | awk '{ print $2; }' | sed -e 's/://' | grep -v "\<lo\>") )

idx=1
for i in ${nics[*]}
do
    nic_ip=$(ip -o addr show $i | grep "inet[^6]" | awk '{ print $4; }')
    echo "$idx. $i $nic_ip"
    idx=$((idx + 1))
done

echo ""
read -p "Choose the network you want to use for nat: " out_nic
out_nic_idx=$((out_nic - 1))

echo "You choosed ${nics[$out_nic_idx]} as output interface"

# the network card is the one twoards WAN
shared_nic=${nics[$out_nic_idx]}

# Enable routing
echo 1 > /proc/sys/net/ipv4/ip_forward

# Enable NAT
iptables -t nat -A POSTROUTING -o $shared_nic -j MASQUERADE

#
iptables -F
