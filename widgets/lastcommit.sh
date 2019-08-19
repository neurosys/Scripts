#!/usr/bin/env bash

# todo
# - check for network
# - 
# - 

repoPath=$1
limit=${2:-100}
nrOfDisplayedCommits=40

cd $repoPath

extractFetchRemoteHostname()
{
    local resProtocol=$1
    local resHost=$2
    local resPort=$3

    local origin=$(git remote -v | grep "\<origin\>" | grep "(fetch)")
    local originUrl=$(echo "$origin" | awk '{ print $2 }')
    local oldIFS=$IFS

    IFS=':'
    read -r protocol host port <<< $(echo "$originUrl" )
    IFS=$oldIFS

    eval "$resProtocol='$protocol'"

    # Remove the // from after the protocol name and username if there is any
    host=$(echo $host | sed -e 's;^//;;' | sed -e 's/.*@//' )
    eval "$resHost='$host'"

    # Remove any path from the port
    port=$(echo $port | sed -e 's;/.*$;;')
    eval "$resPort='$port'"

}

testConnection()
{
    local host=$1
    local port=$2

    #local cmd="nmap -oG - -p $port $host | grep 'Ports: $port/open' &> /dev/null"
    local cmd="nc -z -w 1 $host $port"
    eval "$cmd"
    local res=$?
    return $res
}

testConnectionByProtocol()
{
    local protocol=$1
    local host=$2

    case $protocol in
        ssh)
            local port=${3:-22}
            testConnection $host $port
            return $?
            ;;
        http)
            local port=${3:-80}
            testConnection $host $port
            return $?
            ;;
        https)
            local port=${3:-443}
            testConnection $host $port
            return $?
            ;;
        *)
            #echo "Unknown protocol"
            return 1
            ;;
    esac
}

selectColorBasedOnTime()
{
    local res=$1
    local gitCmd="git log --date=short --pretty=format:%cd --date=relative -1"
    local timeOfLastCommit=$(eval $gitCmd | sed -e 's/ ago//' -e 's/,.*$//')
    local units=$(echo $timeOfLastCommit | awk '{ print $2 }')
    local nrOfUnits=$(echo $timeOfLastCommit | awk '{ print $1 }')
    local color=

    echo $units > /home/camza/color.txt
    echo $nrOfUnits >> /home/camza/color.txt
    case $units in
        "minutes")
            case $nrOfUnits in
                [1-9])
                    color="#FF0000"
                    ;;
                [1-3][0-9])
                    color="#C00000"
                    ;;
                [4-6][0-9])
                    color="#100000"
                    ;;
                [7-9][0-9])
                    color="#800000"
                    ;;
            esac
            ;;
        "hours")
            case $nrOfUnits in
                [1-9])
                    color="#500000"
                    ;;
                1[0-9])
                    color="#505000"
                    ;;
                2[0-9])
                    color="#505050"
                    ;;
            esac
            ;;
        "days")
            color="#909000"
            ;;
        "weeks")
            color="#505000"
            ;;
        "months")
            color="#FF00FF"
            ;;
        "year")
            color="#555555"
            ;;
        "years")
            color="#555555"
            ;;
        *)
            color="#FFFFFF"
    esac

    eval "$res='$color'"

    #"seconds"
    #"minutes"
    #"hours" # 23 hours
    #"days" # 8 days
    #"weeks" 5 weeks
}


if [ "$BLOCK_BUTTON" != "1" ]
then
    protocol=
    host=
    port=
    extractFetchRemoteHostname "protocol" "host" "port" 
    testConnectionByProtocol $protocol ${host} $port 
    netCon=$?
    pullSuccess=

    if [ $netCon -eq 0 ]
    then
        git pull &> /dev/null
        pullSuccess=$?
    fi

    fullLogMessage=$(git log -1 --pretty=format:"%cn %cd %s" --date=relative)
    briefLogMessage=$(echo "$fullLogMessage" | sed -e "s/^\(.\{$limit\}\).*/\1/g")

    if [ $netCon -eq 1 ]
    then
        briefLogMessage="[Link Down] $briefLogMessage"
    else
        if [ $pullSuccess -eq 1 ]
        then
            briefLogMessage="[git down] $briefLogMessage"
        fi
    fi

    echo "$briefLogMessage"
    echo ""
    displayColor=""
    selectColorBasedOnTime displayColor
    echo $displayColor
else
    fullLogMessage=$(git log -1 --pretty=format:"%cn %cd %s" --date=relative)
    briefLogMessage=$(echo "$fullLogMessage" | sed -e "s/^\(.\{$limit\}\).*/\1/g")
    echo "$briefLogMessage"
    i3-msg -q exec ~/.bin/widgets/dzcommits.sh $repoPath $nrOfDisplayedCommits $BLOCK_X
    #echo "BLOCK_X=$BLOCK_X" > /home/camza/.bin/commit-monitor/dbg.txt
fi

#echo "#FF00FF"


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

