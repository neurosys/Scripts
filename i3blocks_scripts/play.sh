#!/usr/bin/env bash

case $BLOCK_BUTTON in
    1)
        # Left click
        playerctl -p spotify play-pause
        ;;
    2)
        # Middle click
        playerctl -p spotify loop Playlist
        ;;
    3)
        # Right click
        playerctl -p spotify loop Track
        ;;
    4)
        playerctl -p spotify previous
        # Scroll up
        ;;
    5)
        # Scroll down
        playerctl -p spotify next
        ;;
esac

cmd="org.freedesktop.DBus.Properties.Get"
domain="org.mpris.MediaPlayer2"
path="/org/mpris/MediaPlayer2"

meta=$(dbus-send --print-reply --dest=${domain}.spotify \
    /org/mpris/MediaPlayer2 org.freedesktop.DBus.Properties.Get string:${domain}.Player string:Metadata)

artist=$(echo "$meta" | sed -nr '/xesam:artist"/,+2s/^ +string "(.*)"$/\1/p' | tail -1  | sed 's/\&/\\&/g' | sed 's#\/#\\/#g')
album=$(echo "$meta" | sed -nr '/xesam:album"/,+2s/^ +variant +string "(.*)"$/\1/p' | tail -1| sed 's/\&/\\&/g'| sed 's#\/#\\/#g')
title=$(echo "$meta" | sed -nr '/xesam:title"/,+2s/^ +variant +string "(.*)"$/\1/p' | tail -1 | sed 's/\&/\\&/g'| sed 's#\/#\\/#g')

echo "[${artist} - ${title}]"
