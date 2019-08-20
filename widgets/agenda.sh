#!/usr/bin/env bash

date '+%H:%M:%S'

windowFont="-*-bitstream vera sans mono-*-*-*-*-*-*-*-*-*-*-*-*" 
windowBg="#444444"
windowWidth=1200

weekendMarkup='#96A0DF'
todayMarkup='#FF0000'

. ~/.bin/widgets/xutils.sh

displayTodayAgenda()
{
    local cmd="dzen2 \
        -p \
        -l 20 \
        -x $BLOCK_X \
        -y 80 \
        -w $windowWidth \
        -bg '$windowBg' \
        -fn '$windowFont' \
        -e 'onstart=uncollapse,scrollhome,hide;entertitle=grabkeys;enterslave=grabkeys;leaveslave=ungrabkeys;key_Escape=ungrabkeys,exit;button1=exit;button3=exit;button4=scrollup:3;button5=scrolldown:3' \
    "
    eval $cmd
}

if [ $BLOCK_BUTTON == "1" ]
then
    today=$(date '+%Y-%m-%-d')
    adjustCoordinateToFitInMonitor $BLOCK_X $windowWidth BLOCK_X 
    # calformat is in my confs repository
    #(echo "" ; echo "bibi" ; cat ~/vimwiki/diary/${today}.wiki ) | displayTodayAgenda
    (echo "" ; task due:today ) | displayTodayAgenda
fi
