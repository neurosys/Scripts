#!/bin/bash

windowFont="-*-bitstream vera sans mono-*-*-*-*-*-*-*-*-*-*-*-*" 
windowBg="#444444"
windowWidth=1200

weekendMarkup='#96A0DF'
todayMarkup='#FF0000'

cal=$(for i in April May June July August September ; do cal -m $i | calformat ; done)
echo "$cal"

"dzen2 \
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
