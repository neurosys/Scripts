#!/usr/bin/env bash

who=$(whoami)

if [[ "$who" != "root" ]]
then
    echo "You neet to run this as root"
    exit
fi



nics=( $(ip link | grep -o '^[0-9]\+: \<[a-zA-Z0-9]\+:' | awk '{ print $2; }' | sed -e 's/://' | grep -v "\<lo\>") )

idx=1
for i in ${nics[*]}
do
    nic_ip=$(ip -o addr show $i | grep "inet[^6]" | awk '{ print $4; }')
    echo "$idx. $i $nic_ip"
    idx=$((idx + 1))
done

echo ""
read -p "Choose the network card you want to allow all trafic " out_nic
out_nic_idx=$((out_nic - 1))

echo "You choosed ${nics[$out_nic_idx]} "


sudo iptables -A INPUT  -i ${nics[$out_nic_idx]} -j ACCEPT
sudo iptables -A OUTPUT -o ${nics[$out_nic_idx]} -j ACCEPT

