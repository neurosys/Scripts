#!/usr/bin/env bash

# This script calls tig in a terminal on the commit provided as a paramer so you can see details about he commit
#
# All this things have been gathered into a single script because dzen2 has some serious limitations in handling 
# complex commands so creating a script was the logical thing to do
# 
# Input parameters
# $1 - git commit hash code
# $2 - path to lock file
#
# The commit has code is needed for obvious reasons.
# The need for the path to the lock file is somewhat more elusive so here's the explanation:
#       due to the combination of async processing and command chanining via pipe, we have no means of closing the 
#       parent window so when created it saves in the lock file the command as it would be outputed by ps so we
#       could stop he process from here. Not an elegant solution, but it works, if you find a better one, please
#       let me know

extractParentPid()
{
    local lockFile=$1
    local dzCmd=$(cat $lockFile)
    pid=$(ps xau | grep "$dzCmd" | grep -v "grep" | awk '{ print $2 }' )
    echo "$pid"
}

displayCmd() 
{
    # Only xterm containing tig
    #xterm -e "tig show $1"

    # tig inside tmux inside xterm
    #xterm -e bash -c "tmux new-session -d -s mySession 'tig' \; attach \;"
    urxvt -e bash -c "tmux new-session -d -s mySession 'tig' \; attach \;"
    #gnome-terminal -- tmux new-session -d -s mySession 'tig' \; attach \;
    #mate-terminal -- tmux new-session -d -s mySession 'tig' \; attach \;
}

verifyParameters()
{
    if [ -z $1 || -z $2 ]
    then
        echo "$0 error calling the script, not enough parameters"
        echo "    $0 <git commit id> <path to lock file>"
        exit 1
    fi
}

main() 
{
    verifyParameters $*

    pid=$(extractParentPid $2)
    kill -15 "$pid"
    displayCmd $1
}


main $*
