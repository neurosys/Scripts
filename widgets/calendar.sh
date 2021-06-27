#!/usr/bin/env bash

# long live xfontsel
#windowFont="Ubuntu Mono derivative Powerline" 
#windowFont="-*-bitstream vera sans mono-*-*-*-*-*-*-*-*-*-*-*-*" 
windowFont="-*-fira mono-*-*-*-*-17-*-*-*-*-*-*-*" 
#windowFont="Ubuntu Mono derivative Powerline" 
windowBg="#444444"
windowWidth=210

weekendMarkup='#96A0DF'
todayMarkup='#FF0000'

BLOCK_X=

. ~/.bin/widgets/xutils.sh

displayFullCalendar()
{
    dzen2  \
        -p \
        -x $BLOCK_X \
        -y 50 \
        -w $windowWidth \
        -l 40  \
        -bg "$windowBg" \
        -fn "$windowFont" \
        -e "onstart=uncollapse,scrollhome,hide;entertitle=grabkeys;enterslave=grabkeys;leaveslave=ungrabkeys;leavetitle=ungrabkeys;key_Escape=ungrabkeys,exit;button1=exit;button3=exit;button4=scrollup:3;button5=scrolldown:3"
}

formatMonth()
{
    local i=$1
    d=$(date '+%Y %m ' --date="15 $i month")
    if [ $i -eq 0 ]
    then
        cal -m $(date '+%d %m %Y' --date="15 $i month") | calformat -w "^fg($weekendMarkup)" -we "^fg()" -t "^fg($todayMarkup)" -te "^fg()" --today $(date +%-d) #| \
            #sed -e "s:\(\<[0-9]\{1,2\}\>\):^ca(1, ~/.bin/widgets/calendar.sh ${d} \1 )\1^ca():g" 
            #sed -e 's:\(\<[0-9]\{1,2\}\>\):^ca(1, gvim -c Calendar ~/vimwiki/diary/'$d'\1.wiki )\1^ca():g' 
    else
        cal -m $(date '+%d %m %Y' --date="15 $i month") | calformat -w "^fg($weekendMarkup)" -we "^fg()" # | \
            #sed -e "s:\(\<[0-9]\{1,2\}\>\):^ca(1, ~/.bin/widgets/calendar.sh ${d} \1 )\1^ca():g" 
            #sed -e 's:\(\<[0-9]\{1,2\}\>\):^ca(1, gvim -c Calendar ~/vimwiki/diary/'$d'\1.wiki )\1^ca():g' 
    fi
}


launchEditor()
{
    urxvt -e bash -c "tmux new-session -d -s mySession 'vim $tmpTaskFile' \; attach \;"
}

extractDetails()
{
    local tmpTaskFile=$1
    local taskDetailes=$(cat $tmpTaskFile)
    local proj=$( echo "$taskDetailes" | sed -n -e '/^project:/p' | sed -e 's/^project: *//' )
    local due=$( echo "$taskDetailes" | sed -n -e '/^due:/p' | sed -e 's/^due: *//' )
    local description=$( echo "$taskDetailes" | sed -n -e '/^description:/p' | sed -e 's/^description: *//' )

    if [[ -n "$proj" && -n "$description" ]]
    then
        # OBS: task expects date to be in the format YYYY-MM-DD single digits for month or day won't do
        local cmd="task add \"project:$proj\" \"due:$due\" -- \"$description\""
        eval $cmd
    fi
}

addZeroInFront()
{
    local x=$1
    echo $x | sed -e 's/^\([0-9]\)$/0\1/'
}

createTemplateFile()
{
    USER=$(whoami)
    tmpTaskFile="/var/tmp/$USER-task-warrior-${1}.tmp"
    touch $tmpTaskFile
    echo "due: ${1}-$(addZeroInFront $2)-$(addZeroInFront $3)"  >> $tmpTaskFile
    echo "project: "                                            >> $tmpTaskFile
    echo "description: "                                        >> $tmpTaskFile
    echo $tmpTaskFile
}

parseArguments()
{
    while [[ -n $1 ]]
    do
        case $1 in
            "-x")
                shift
                BLOCK_X=$1
                ;;
            "time")
                date "+%Y-%m-%d    %H:%M:%S"
                exit 0
                ;;
        esac
        shift
    done
}

parseArguments $*

    date '+%Y-%m-%d'

    BLOCK_BUTTON=${BLOCK_BUTTON:-1}
    BLOCK_X=${BLOCK_X:-0}
    adjustCoordinateToFitInMonitor $BLOCK_X $windowWidth BLOCK_X 
    if [ $BLOCK_BUTTON == "1" ]
    then
        # calformat is in my confs repository
        (echo "" ; for i in {-1..12} ; do formatMonth $i ; done) | displayFullCalendar
    fi

exit 0

    echo "$*"
    # $1 - Year
    # $2 - Month
    # $3 - Day
    templateFile=$(createTemplateFile $1 $2 $3) 
    urxvt -e bash -c "tmux new-session -d -s mySession 'vim $templateFile' \; attach \;"  
    extractDetails $templateFile 
    rm -f $templateFile





