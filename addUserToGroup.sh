#!/usr/bin/env bash

echo "Enter group where you want your courent user to be added to"
read -r grp

if [[ -z "$grp" ]]
then
    echo "No group has been entered, exiting"
    return 0
fi

grep -q $grp /etc/group
if [[ $? -ne 0 ]]
then
    echo "Err: can't find group '$grp'"
    return
fi


sudo usermod -aG $grp $USER 
if [[ $? -ne 0 ]]
then
    echo "Err: Unable to add user to group"
    return
fi

newgrp $grp
if [[ $? -ne 0 ]]
then
    echo "Err: Unable login user to group"
    return
fi

groups
