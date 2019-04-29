#!/usr/bin/env bash

# todo
# - Show opened
# - Limit to only one instance
# - Scroll display to he last commits
# - Limt display to last X commits

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
colorFile="#0040F0"

dzCmd=

cd $repoPath

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

showListOfCommits() 
{
    export dzCmd="dzen2 -p \
        -l $windowHeight \
        -x $x_coordinate \
        -y $windowYCoordinate \
        -w $windowWidth \
        -m \
        -bg '$commitListWindowBg' \
        -fn '$windowFont' \
        -e 'onstart=uncollapse,scrollhome;button1=menuprint;button3=exit;button4=scrollup:3;button5=scrolldown:3' "
    eval $dzCmd
    #dzen2 -p \
    #    -l $windowHeight \
    #    -x $x_coordinate \
    #    -y $windowYCoordinate \
    #    -w $windowWidth \
    #    -m \
    #    -bg "$commitListWindowBg" \
    #    -fn "$windowFont" \
    #    -e 'onstart=uncollapse,scrollhome;button1=menuprint;button3=exit;button4=scrollup:3;button5=scrolldown:3' \
}

extractCommitId()
{
    sed -u -e 's/^\([^ ]\+\).*/\1/'
    #strace -e read,write sed -u -e 's/^\([^ ]\+\).*/\1/'
    #strace -e read,write awk -F' ' '{ print $1 ; }'
}

displayCommitMessage()
{
    gitCmd="git log \
        --date=short \
        --pretty=format:\"^fg($colorCommitID)%h ^fg($colorDate)%cd^fg() [^fg($colorAuthor)%cn^fg()] %d %n%n^fg($colorBranch)%s^fg()%n%n\" --decorate --name-only -n 1 "

    detailedViewCmd="xterm -e \"tig show {}\""

    killParentCmd="ps xau | tee -a /home/camza/dbg1.txt | grep '$dzCmd' | tee -a /home/camza/dbg2.txt | awk '{ print \$1 }' | tee -a /home/camza/dbg3.txt | xargs kill -15 "

    dzenCmd="dzen2 \
        -p \
        -l $windowHeight \
        -x $x_coordinate \
        -y $windowYCoordinate \
        -w $windowWidth \
        -bg '$commitListWindowBg' \
        -fg '$colorFile' \
        -fn '$windowFont' \
        -e 'onstart=uncollapse,scrollhome;button1=exec:${detailedViewCmd},exit;button3=exit;button4=scrollup:3;button5=scrolldown:3'"
    xargs -r -n 1 -L 1 -P 0 -I{} bash -c \
        "( ( echo && $gitCmd {} ) | $dzenCmd ) & " &

}

main()
{
    (displayTitle ; extractCommits | applyColorMarkupOnCommits) \
        | showListOfCommits \
        | extractCommitId \
        | displayCommitMessage
}

main
