#!/usr/bin/env bash

if [[ -z "$1" ]]
then
    echo "Usage: $0 <brightness_value>"
    echo -e "\tBrightness value should be between 0 and 100."
    exit 1
fi

sudo tee /sys/class/backlight/nvidia_wmi_ec_backlight/brightness <<< $1

