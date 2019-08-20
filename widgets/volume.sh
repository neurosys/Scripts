#!/usr/bin/env bash

# Font change (icon)
# "^fn($iconfont)$text^fn()"
#
#
# ICON='~/dzen_bitmaps/xbm8x8/arch_10x10.xbm'
# ICM=~/dzen_bitmaps/xbm8x8/arch_10x10.xbm
# IC1=~/dzen_bitmaps/xbm8x8/fox.xbm
# IC2=~/dzen_bitmaps/xbm8x8/shroom.xbm
# IC3=~/dzen_bitmaps/xbm8x8/info_03.xbm
# IC4=~/dzen_bitmaps/xbm8x8/dish.xbm

# echo ^i | dzen2

#pamixer --get-volume
#pamixer --set-volume
#pamixer -i <x>
#pamixer -d <x>
#pamixer -t # Toggle

# Progress bar
#width=100
#for i in 0 10 20 30 40 50 60 70 80 90 100 
#do
#    x=$((width - i))
#    echo "^fg(#FFFF00)^r(${i}x30)^ro(${x}x30)^fg(#FF00FF)" ; sleep 1
#
#done \
#    | dzen2 \
#        -w 100 \
#        -x 300 \
#        -y 300 \
#        -h 35 \
#        -e 'entertitle=grabkeys;button1=exit;button3=exit;button4=exec:pamixer -i 3 ;button5=exec:pamixer -d 3 ;key_Escape=ungrabkeys,exit'
#



maxVolume=100
height=34
volumeBarSize=1000

pipeName="/var/tmp/${USER}-volume-bar.tmp"
. ~/.bin/widgets/xutils.sh

startDzen2()
{
    while true
    do
        if read line < $pipeName
        then
            if [ "$line" == "exit" ]
            then
                break
            fi
            #echo $line
            computeVolume $line
        fi
    done |\
        tee /dev/tty | dzen2 \
        -w ${volumeBarSize} \
        -x $BLOCK_X \
        -y 100 \
        -h $height \
        -bg "#FFFFFF" \
        -e 'entertitle=grabkeys;leavetitle=ungrabkeys;enterslave=grabkeys;leaveslave=ungrabkeys;button1=exec:~/.bin/widgets/volume.sh exit,exit;button3=exec:~/.bin/widgets/volume.sh exit,exit;button4=exec:~/.bin/widgets/volume.sh inc;button5=exec:~/.bin/widgets/volume.sh dec;key_Escape=exec:~/.bin/widgets/volume.sh exit,ungrabkeys,exit'

    rm -f $pipeName
}

computeVolume()
{
    currentVolume=$1
    x=$((maxVolume - currentVolume))
    # scale everything 10 times
    x=$((x * 10))
    currentVolume=$((currentVolume * 10))
    echo "^fg(#FF00FF)^r(${currentVolume}x30)^ro(${x}x30)^fg(#FF00FF)"
}

case $1 in
    inc)
        pamixer -i 3
        ;;
    dec)
        pamixer -d 3
        ;;
    exit)
        echo "exit" > $pipeName
        exit 0
        ;;
    *)
        pamixer --get-volume
        if [ "$BLOCK_BUTTON" != "1" ]
        then
            exit 0
        fi

        if [ ! -p $pipeName ]
        then
            echo "File doesn't exists, creating... $pipeName"
            mkfifo $pipeName
            pamixer --get-volume > $pipeName &
        fi
        echo "original BLOCK_X=$BLOCK_X"    > /var/tmp/camza-dbg-volume.tmp
        echo "volumeBarSize=$volumeBarSize"    >> /var/tmp/camza-dbg-volume.tmp
        adjustCoordinateToFitInMonitor $BLOCK_X $volumeBarSize BLOCK_X 
        echo "adjusted BLOCK_X=$BLOCK_X"    >> /var/tmp/camza-dbg-volume.tmp
        startDzen2
esac

if [ -p $pipeName ]
then
    pamixer --get-volume > $pipeName
fi
