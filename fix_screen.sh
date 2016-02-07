#!/bin/bash

# Fix the display on my ubuntu, so that both my 1920x1080 + 1366x768 displays can function
xrandr --output HDMI1 --auto --left-of LVDS1 --output LVDS1 --auto --scale 1.0001x1.0001
