#!/usr/bin/env bash

# todo
# - comment stuff
# - clean a bit 

repoPath=$1
nrOfDisplayedCommits=$2
x_coordinate=$3

windowHeight=20
windowYCoordinate=40
windowWidth=1200

commitListWindowBg="#444444"
commitShowWindowBg="#222222"
windowFont="Ubuntu Mono derivative Powerline" 
colorCommitID="#FF00FF"
colorAuthor="#FF0000"
colorDate="#00FF00"
colorText="#FFFFFF"
colorBranch="#00FFFF"
#colorFile="#0040F0" # Blue...
colorFile="#00FF00"

lockFile="/var/tmp/${USER}-git-dzen-history-lock-cmd"

cd $repoPath

. ~/.bin/widgets/xutils.sh


displayTitle()
{
    local branch=$(git branch | grep "^\*" | sed -e 's/^* \(.*\)/\1/')
    echo "Last $nrOfDisplayedCommits commits of branch '$branch'"
}

extractCommits()
{
    git log -$nrOfDisplayedCommits --pretty=format:"%h [%cn] (%cd) %s" --date=relative
}

applyColorMarkupOnCommits()
{
    # Order is important here as 
    sed \
    -e 's/(\([^)]\+\))/^fg('$colorDate')\1^fg('$colorText')/' \
    -e 's/^/^fg('$colorCommitID')/'  \
    -e 's/\[\([^]]\+\)\]/^fg('$colorAuthor')\1/'
}

stripSapcesAndEscapesFromCmd() 
{
    sed \
        -e 's/ \+/ /g' \
        -e "s/'//g"    \
        -e "s/,/ /g"   \
        -e "s/;/ /g"   \
        -e "s/:/ /g"   \
        -e "s/=/ /g" 
}

checkForPreexistingWindow()
{
    if [ ! -f $lockFile ]
    then
        # No lock file -> No window is running right now
        return 0
    fi

    local cmdFromLockFile=$(cat $lockFile)
    pid=$(ps xau | grep "$cmdFromLockFile" | grep -v "grep" | awk '{ print $2 }' )
    if [ -z $pid ]
    then
        # While there is a lock file, it must be from a previous run that crashed somehow
        return 0
    else
        exit 1
    fi
}

showListOfCommits() 
{
    local dzCmd="dzen2 -p \
        -l $windowHeight \
        -x $x_coordinate \
        -y $windowYCoordinate \
        -w $windowWidth \
        -m \
        -bg '$commitListWindowBg' \
        -fn '$windowFont' \
        -e 'onstart=uncollapse,scrollhome;entertitle=grabkeys;enterslave=grabkeys;leaveslave=ungrabkeys;leavetitle=ungrabkeys;button1=menuprint;button3=exit;button4=scrollup:3;button5=scrolldown:3;key_Escape=ungrabkeys,exit'"

    checkForPreexistingWindow
    if [ $? -ne 0 ]
    then
        # A window is already running
        exit 1
    fi
    local stripedCommand=$(echo "$dzCmd" | stripSapcesAndEscapesFromCmd) 
    echo $stripedCommand &> $lockFile
    eval $dzCmd
}

extractCommitId()
{
    # That fucking '-u' is for "unbuffered", see below how I discovered I needed this
    # without it, sed doesn't output the results as soon as they're ready
    # (I know I'll be comming later for that strace command)
    sed -u -e 's/^\([^ ]\+\).*/\1/'
    #strace -e read,write sed -u -e 's/^\([^ ]\+\).*/\1/'
    #strace -e read,write awk -F' ' '{ print $1 ; }'
}

displayCommitMessage()
{
    local gitCmd="git log \
        --date=short \
        --pretty=format:\"^fg($colorCommitID)%h ^fg($colorDate)%cd^fg() [^fg($colorAuthor)%cn^fg()] %d %n%n^fg($colorBranch)%s^fg()%n%n\" --decorate --name-only -n 1 "

    local detailedViewCmd="~/.bin/widgets/dzdisplaycommit.sh {} $lockFile"

    local dzenCmd="dzen2 \
        -p \
        -l $windowHeight \
        -x $x_coordinate \
        -y $windowYCoordinate \
        -w $windowWidth \
        -bg '$commitListWindowBg' \
        -fg '$colorFile' \
        -fn '$windowFont' \
        -e 'onstart=uncollapse,scrollhome;entertitle=grabkeys;enterslave=grabkeys;leaveslave=ungrabkeys;leavetitle=ungrabkeys;key_Escape=ungrabkeys,exit;button1=exec:${detailedViewCmd},exit;button3=exit;button4=scrollup:3;button5=scrolldown:3'"
    xargs -r -n 1 -L 1 -P 0 -I{} bash -c \
        "( ( echo && $gitCmd {} ) | $dzenCmd ) & " &

}

main()
{
    adjustCoordinateToFitInMonitor $x_coordinate $windowWidth x_coordinate 
    commits=$( displayTitle ; extractCommits | applyColorMarkupOnCommits ) 

    echo "$commits" | showListOfCommits \
        | extractCommitId \
        | displayCommitMessage
}

main
