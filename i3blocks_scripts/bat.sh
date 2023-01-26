#!/usr/bin/env bash

status=$(cat /sys/class/power_supply/BAT1/status)

fgColor="#FF0000"
if [[ "$status" == "Charging" || "$status" == "Full" ]]
then
    fgColor="#00FF00"
fi

capacity=$(cat /sys/class/power_supply/BAT1/capacity)

echo "$capacity"
echo "" # This should have been the short text
echo $fgColor
echo "" # This would have been the background color
