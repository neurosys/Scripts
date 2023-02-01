#!/usr/bin/env bash

#output="/home/neurosys/debug_i3blocks.txt"
#echo "=========================================================================================" >> $output
#env >> $output

# BLOCK_BUTTON 1 (left click)
# BLOCK_BUTTON 2 (middle click)
# BLOCK_BUTTON 3 (right click)
# BLOCK_BUTTON 4 (scroll up)
# BLOCK_BUTTON 5 (scroll down)

#echo "<span foreground=\"#FF00FF\">b=$BLOCK_BUTTON x=$BLOCK_X y=$BLOCK_Y</span> <span foreground=\"#00FFFF\">$(date)</span>"

function getVolumeLevel() {
    echo $(pulsemixer --get-volume | awk '{ print $1 }')
}

function incVolumeLevel() {
    pulsemixer --change-volume +5
}

function decVolumeLevel() {
    pulsemixer --change-volume -5
}

function toggleVolume() {
    pulsemixer --toggle-mute
}

function externalMixer() {
    i3-msg -q exec "pavucontrol-qt --tab 3"
}

function isMuted() {
    pulsemixer --get-mute
}

#color1=#

vol=$(getVolumeLevel)
volLevel=$(echo $vol | awk '{ printf "%d", $1 / 10}')
#"-----|-----"
volBarSize=10
volBar="<span foreground=\"#00FF00\">"

for (( i=0; i<volLevel; i++ ))
do
    volBar+="-"
done

volBar+="</span>"
volBar+="|"
volBar+="<span foreground=\"#FFFFFF\">"

for (( i=volLevel; i<volBarSize; i++ ))
do
    volBar+="-"
done

volBar+="</span>"

muted=$(isMuted)

if [[ -n "$BLOCK_BUTTON" ]]
then
    case "$BLOCK_BUTTON" in
        "1")
            # Left click
            toggleVolume
            muted=$(isMuted)
            ;;
        "2")
            # Middle click
            ;;
        "3")
            # Right click
            externalMixer
            ;;
        "4")
            # Scroll up
            incVolumeLevel
            ;;
        "5")
            # Scroll down
            decVolumeLevel
            ;;
    esac
fi

if [[ $muted -eq 0 ]]
then
    #echo "b=$BLOCK_BUTTON x=$BLOCK_X y=$BLOCK_Y $vol $volBar"
    echo "$vol $volBar"
else
    echo "MUTED"
fi
