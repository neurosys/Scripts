#!/usr/bin/env bash

MY_DISPLAY=:4

Xephyr -br -ac -noreset -screen 1920x1080 $MY_DISPLAY &
sleep 1
DISPLAY=$MY_DISPLAY dwm
