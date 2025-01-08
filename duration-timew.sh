#!/usr/bin/env bash

# This script is used to get the current task and its duration from timewarrior
# <script> [toggle|stop]

# Sample outputs:
#
# Tracking audioRework honda
#   Started 2025-01-08T10:18:52
#   Current                  55
#   Total               0:00:03

# Tracking audioRework honda
#   Started 2025-01-08T10:18:52
#   Current               19:23
#   Total               0:00:31

output=$(timew)
cmd="$1"

if [[ "$output" == "There is no active time tracking." ]]
then
    if [[ "$cmd" == "toggle" ]]
    then
        timew continue
    fi

    if [[ "$cmd" == "stop" || -z $cmd ]]
    then
        echo "<>"
        exit 0
    fi
else
    if [[ "$cmd" == "toggle" ]]
    then
        timew stop
        echo "<>"
        exit 0
    fi

    if [[ "$cmd" == "stop" ]]
    then
        timew stop
        echo "<>"
        exit 0
    fi
fi

currentDuration=$(echo "$output" | grep "\<Total\>" | sed -e 's/  Total[^0-9]\+\([0-9:]\+\)$/\1/')
currentTask=$(echo "$output" | grep "\<Tracking\>" | sed -e 's/Tracking \(.*\)$/\1/')

for t in $currentTask
do
    tasks="${tasks} [${t}]"
done

echo "<%{F#FF0000}Tracking:%{F#00FF00}${tasks}: %{F#FF5555}${currentDuration}%{F#FFFFFF}>"


