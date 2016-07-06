#!/bin/bash

# Fix the display on my ubuntu, so that both my 1920x1080 + 1366x768 displays can function
#xrandr --output HDMI1 --auto --left-of LVDS1 --output LVDS1 --auto --scale 1.0001x1.0001
#xrandr --output HDMI-1 --auto --left-of LVDS-1 --output LVDS1 --auto --scale 1.0001x1.0001

xrandr_output=$(xrandr)
displays=()

while read i
do
    echo "$i" | grep -q "\<connected\>"
    if [[ $? -eq 0 ]]
    then
        displays[${#displays[@]}]=$(echo "$i" | grep -o "^[^ ]\+")
        #echo "displays = ${displays[*]} ${#displays[@]}"
    fi
done < <(echo "$xrandr_output")

if [[ ${#displays[@]} == 2 ]]
then
    xrandr --output ${displays[1]} --auto --left-of ${displays[0]} --output ${displays[0]} --auto
    exit
fi

#echo "End of loop displays = ${displays[*]} ${#displays[@]}"
if [[ ${#displays[@]} != 1 ]]
then
    echo "xrandr reported ${#displays[@]} monitors, I don't know how to handle this"
    exit
fi

