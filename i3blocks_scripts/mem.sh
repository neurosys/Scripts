#!/usr/bin/env bash


mem=$(free -m | awk '/Mem:/{ printf "%.2f:%.2f",  ($3 / 1024), ($2 / 1024) }')

used=$(echo "$mem" | awk -F : '{ print $1 ; }')
total=$(echo "$mem" | awk -F : '{ print $2 ; }')
percent=$(echo "$mem" | awk -F : '{ printf "%.2f", ($1 / $2 * 100) ; }')

greenThreshold=50
yellowThreshold=80
redThreshold=93

alert=$(echo "${percent}:${greenThreshold}:${yellowThreshold}:${redThreshold}" | awk -F: '{ if ($1 < $2) { print 0; exit }  if ($1 < $3) { print 1; exit; } if ($1 < $4) { print 2; exit } print 3 }')
color="#00FF00"
case "$alert" in
    "0")
        color="#00FFFF"
        ;;
    "1")
        color="#00FF00"
        ;;
    "2")
        color="#FFFF00"
        ;;
    "3")
        color="#FF0000"
        ;;
esac


echo "${used}G/${total}G [${percent}%]"
echo ""
echo "$color"


