#!/usr/bin/env bash

which xinput &> /dev/null || { echo "xinput not found"; exit 1; }

# Get the ID of the touchpad device
TOUCHPAD_ID=$(xinput list | grep -i touchpad | grep -o 'id=[0-9]*' | cut -d= -f2)
if [ -z "$TOUCHPAD_ID" ]; then
    echo "No touchpad found"
    exit 1
fi

# Disable the touchpad
xinput enable "$TOUCHPAD_ID" || { echo "Failed to enable touchpad"; exit 1; }
