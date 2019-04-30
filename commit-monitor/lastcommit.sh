#!/usr/bin/env bash

# todo
# - check for network
# - 
# - 

repoPath=$1
limit=${2:-70}
nrOfDisplayedCommits=20

cd $repoPath

#git pull &> /dev/null

if [ $? -ne 0 ]
then
    echo "Unable to 'git pull'"
    exit 0
fi

fullLogMessage=$(git log -1 --pretty=format:"%cn %cd %s" --date=relative)
briefLogMessage=$(echo "$fullLogMessage" | sed -e 's/^\(.\{'$limit'\}\).*/\1/g')

if [ $BLOCK_BUTTON == "1" ]
then
    echo "bb=$BLOCK_BUTTON"
    i3-msg -q exec ~/.bin/commit-monitor/dzcommits.sh $repoPath $nrOfDisplayedCommits $BLOCK_X
else
    echo "$briefLogMessage"
fi

echo ""
echo "#FF00FF"


# 1 Line full_text
# 2 line short_text
# 3 line color
# 4 Line background color

# when clicked the following env variables are passed to the script
#BLOCK_BUTTON=1
#BLOCK_INSTANCE=
#BLOCK_NAME=git
#BLOCK_X=2442 #This is he X coordinate in the screen where the click has been made
#BLOCK_Y=1

