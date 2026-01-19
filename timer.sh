#!/usr/bin/env bash

# usage:
# timer.sh <hours>:<minutes>:<seconds> <message>
# timer.sh <minutes> <message>
# timer.sh ::<seconds> <message>

if [[ -z $2 ]] ; then
    echo "Usage: $0 <minutes>:<seconds> <message>"
    exit 0
fi

which zenity &> /dev/null 
if [[ $? -ne 0 ]] 
then
    echo "This script requires 'zenity' to display the message box."
    exit 1
fi

inputTime=$1
message=$2

if [[ $inputTime == *:* ]] 
then
    minutes=${inputTime%%:*} 
    seconds=${inputTime##*:} 

    if [[ -z $minutes ]] 
    then
        minutes=0 
    fi

    if [[ -z $seconds ]] 
    then
        seconds=0 
    fi

    inputTime=$((10#$minutes * 60 + 10#$seconds)) 
else
    inputTime=$((10#$inputTime * 60)) 
fi

limit=$((60 * inputTime)) 
total=$limit

echo "" 

while [[ 0 -le $limit ]] 
do 
    # Clear the line
    for _ in $(seq 1 255) 
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

echo "Finished waiting for $inputTime."
echo "" 
zenity --text="$message" --warning --title="Timer Finished"

