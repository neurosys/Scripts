#!/usr/bin/env bash

if [[ "$1" == "left" ]]
then
    xrandr --output DisplayPort-1 --auto --set TearFree on --output DisplayPort-2 --off

fi

if [[ "$1" == "right" ]]
then
    xrandr --output DisplayPort-1 --off --output DisplayPort-2 --auto --set TearFree on

fi

if [[ "$1" == "all" ]]
then
    xrandr --output DisplayPort-1 --auto --set TearFree on --left-of DisplayPort-2 --output DisplayPort-2 --auto --set TearFree on

fi

if [[ "$1" == "none" ]]
then
    xrandr --output DisplayPort-1 --off --output DisplayPort-2 --off
fi

cd ~/.myconfig/xorg/

./launch_polybar.sh
