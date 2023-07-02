#!/usr/bin/env bash

if [[ "$1" == "left" ]]
then
    xrandr --output DisplayPort-0 --auto --set TearFree on --output DisplayPort-1 --off

fi

if [[ "$1" == "right" ]]
then
    xrandr --output DisplayPort-0 --off --output DisplayPort-1 --auto --set TearFree on

fi

if [[ "$1" == "all" ]]
then
    xrandr --output DisplayPort-0 --auto --set TearFree on --left-of DisplayPort-1 --output DisplayPort-1 --auto --set TearFree on

fi

if [[ "$1" == "none" ]]
then
    xrandr --output DisplayPort-0 --off --output DisplayPort-1 --off
fi

cd ~/.myconfig/xorg/

./launch_polybar.sh
