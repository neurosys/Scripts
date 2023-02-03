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

colorA0=#00FF00
colorA1=#50FF00
colorA2=#A0FF00
colorB0=#FFFF00
colorB1=#FFA000
colorB2=#FF5000
colorC0=#FF0000
#colorC1=
#colorC2=
#colorC3=

color=#00FF00

vol=$(getVolumeLevel)

case 1 in
    $(($vol <= 30)))
        color=$colorA0
        ;;
    $(($vol <= 40)))
        color=$colorA1
        ;;
    $(($vol <= 50)))
        color=$colorA2
        ;;
    $(($vol <= 60)))
        color=$colorB0
        ;;
    $(($vol <= 70)))
        color=$colorB1
        ;;
    $(($vol <= 80)))
        color=$colorB2
        ;;
    $(($vol <= 90)))
        color=$colorC0
        ;;
    $(($vol > 90)))
        color=$colorC0
        ;;
esac

volBarSize=20
maxVolPercent=100
volBarUnit=$((maxVolPercent / volBarSize)) # How much toes a unit of the bar represent
volLevel=$((vol / volBarUnit)) # How much of the bar we have filled
#"-----|-----"
volBar="<span foreground=\"$color\">"

extraLevel=0 # How much are we over 100%
if [[ $volLevel -gt $volBarSize ]]
then
    extraLevel=$(((vol - maxVolPercent) / volBarUnit))
fi


for (( i=0; i<volLevel && i < volBarSize; i++ ))
do
    if [[ $extraLevel -gt 0 && $i -le $extraLevel ]]
    then
        volBar+="="
    else
        volBar+="-"
    fi
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
