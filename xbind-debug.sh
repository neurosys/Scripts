#!/usr/bin/env bash

# Script used for detecting who has registered a key combination
# It is used when debugging xbindkeys configurations

echo "You need to look at 'jouranlctl -f' output while running this script!!!!!!!!!"
read -p "Press enter when you are " val

KEY=XF86AudioStop
#KEY=Print
xdotool keydown ${KEY}; xdotool key XF86LogGrabInfo; xdotool keyup ${KEY} 
