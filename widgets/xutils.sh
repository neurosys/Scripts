#!/usr/bin/env bash

# Private function this is called from getMonitorRange()
# Input:
# $1 - line from output of xrandr that shows the resolution of the monitor and its offset in the array of monitors
# $2 - name of the variable where the result should be placed
# $3 - the X coordinate where the click has been made
#
# Returns:
# The maximum x coordinate of the monitor where the click has been made
#
# Example:
# For a display 1920x1080+1920+0  (+1920 means it's the second monitor and to it's left there are 1920 pixels)
# with a click made at 3555, this function returns the 3840 since that's 1920 (the offset) + 1920 (the width of the current monitor)
#
extractMonitorEdge()
{
    local line="$1"
    local res="$2"
    local xCoordinate=$3
    local monitorOffset=$(echo "$line" | cut -d'+' -f2)
    local monitorWidth=$(echo "$line" | cut -d'x' -f1)
    local maxRange=$((monitorOffset + monitorWidth))

    if [[ $monitorOffset -le $xCoordinate && $xCoordinate -le $maxRange ]]
    then
        #echo "THIS IS IT "
        eval "$res='$maxRange'"
    fi
}

# Input:
# $1 - x coordinate of the click
# $2 - name of the variable where the result should be placed 
# 
# Return:
# Maximum x coordinate where the monitor, on which the click produced, ends
getMonitorXEdge()
{
    local xrandrOutput=$(xrandr)
    local xCoordinate=$1
    local res="$2"
    local monitors=$(echo "$xrandrOutput" | sed -n "s/.*\<connected \(primary \)\?\([0-9x+]\+\).*/\2/p")
    local xLimit=
    for i in $monitors
    do
        extractMonitorEdge "$i" xLimit $xCoordinate
    done

    eval "$res='$xLimit'"
}

# Input:
# $1 - X coordinate where the click took place
# $2 - width of the window
# $3 - name of hte variable where the result should be placed
#
# Returns:
# The adjusted X coordinate so the window would fit on the monitor where the click took place
adjustCoordinateToFitInMonitor()
{
    local xCoordinate=$1
    local width=$2
    local res=$3

    local limit=
    getMonitorXEdge $xCoordinate limit 

    local endOfWindow=$((xCoordinate + width))
    local x=
    if [[ $endOfWindow -gt $limit ]]
    then
        x=$((limit - width))
    else
        x=$xCoordinate
    fi

    eval "$res='$x'"
}

