#!/usr/bin/env bash

# usage:
# timer.sh <seconds> <message>

if [[ -z $2 ]] ; then
    echo "Usage: $0 <seconds> <message>"
    exit 0
fi

seconds=$1
message=$2

limit=$((60 * seconds)) 
total=$limit

echo "" 

while [[ 0 -le $limit ]] 
do 
    # Clear the line
    for i in $(seq 1 255) 
    do
        echo -en '\b' 
     done 

    minutes=$((limit / 60))
    seconds=$((limit % 60))
    elapsed=$((total - limit))
    percent=$((elapsed * 100 / total))

    # Print the message and the remaining time
    printf "% 5d seconds remaining (% 4d minutes and % 2d seconds) %02d%%" $limit $minutes $seconds $percent
    sleep 1 
    limit=$((limit - 1)) 
done 

echo "" 
notify-send "$message"

