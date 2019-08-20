#!/usr/bin/env bash

fgColor="#FFFFFF"
bgColor="#707000"
windowFont="-*-bitstream vera sans mono-*-*-*-*-*-*-*-*-*-*-*-*" 

dzenDisplay()
{
    #nrOfLines=$1
    nrOfLines=30
    dzen2                 \
        -p                \
        -l $nrOfLines     \
        -bg "$bgColor"    \
        -fg "$fgColor"    \
        -fn "$windowFont" \
        -e "onstart=uncollapse,scrollhome,hide;entertitle=grabkeys;enterslave=grabkeys;leaveslave=ungrabkeys;key_Escape=ungrabkeys,exit;button1=exit;button3=exit;button4=scrollup:3;button5=scrolldown:3" \
        #
}


content=
while IFS= read -r line
do
    if [ "$line" == "" ] 
    then
        break
    fi
    content=$(echo "$content" ; echo $line)
done



echo "content='$content'"

nrOfLines=$(echo "$content" | wc -l)
echo "lines=$nrOfLines"

(echo ""
for i in $content
do
    echo "^p(_CENTER)$i^p()"
done) | dzenDisplay $nrOfLines
