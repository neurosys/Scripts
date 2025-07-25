#!/usr/bin/env bash

# This script simulates a caps lock press for situations
# where the caps is disabled in software, but somehow it got activated

which xdotool >/dev/null 2>&1 || {
    echo "xdotool is not installed. Please install it to use this script."
    exit 1
}

xdotool key Caps_Lock
