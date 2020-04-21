#!/usr/bin/env bash
#set -euo pipefail

# -e - script stops after first command failure
# -u - script stops on first use of unset variable
# -o pipefail - if any command in a set of piped commands fail, the overall status is the one of the failed command

userName=
password=
sleepBetweenDownloads=130
outputFolder=
limitDownloads=
listOfUrlsFile=
urlToDownload=
isOneShot=0
startPlaylistItem=
#---------
currentUrlFileName=__currently_downloading_url__.txt
logFile=output.log
listOfDoneUrls=__completed_urls__.txt
tmpFileName=__tmp_file_name__.tmp
outputFilePrefix=
playListStart=

function doDownload() {
    local url=$1

    youtube-dl                                                 \
        --username "${userName}"                               \
        --password "${password}"                               \
        --verbose                                              \
        --sleep-interval "${sleepBetweenDownloads}"            \
        --restrict-filenames                                   \
        --all-subs                                             \
        $playListStart                                         \
        -o ${outputFilePrefix}'%(playlist_title)s/%(chapter_number)s - %(chapter)s/%(playlist_index)s-%(title)s.%(ext)s' \
        $1 2>&1 | tee -a $logFile
    errCode=$?
    if [[ $errCode -ne 0 ]]
    then
        echo "youtube-dl exited with code $errCode"
        exit 1
    fi

}

function prepareCommandLine() {

    # if a playlist is specified, add the coresponding command prefix
    if [[ -n $startPlaylistItem ]]
    then
        playListStart="--playlist-start $startPlaylistItem"
    fi

    # Make sure that if an output folder exists, it ends in '/'
    if [[ -n $outputFolder ]]
    then
        echo "$outputFolder" | grep "/$"
        if [ $? -eq 1 ]
        then
            outputFilePrefix="$outputFolder/"
        else
            outputFilePrefix="$outputFolder"
        fi
    fi
}

function download() {
    local url=$1
    prepareCommandLine
    doDownload $1
}

function showHelp() {
    echo " plural.sh --todo <file with urls> [--limit <how many urls to download>]"
    echo " plural.sh --one-shot <url> [--start <nr>]"
    echo " --user "
    echo " --pwd"
    echo " --sleep <time>"
    echo " --output-folder <path>"
}

function parseOptions() {
    while [[ -n $1 ]]
    do
        case "$1" in
            "--user")
                userName="$2"
                shift
                ;;
            "--pwd")
                password="$2"
                shift
                ;;
            "--sleep")
                sleepBetweenDownloads="$2"
                shift
                ;;
            "--limit")
                limitDownloads="$2"
                shift
                ;;
            "--todo")
                listOfUrlsFile="$2"
                shift
                ;;
            "--start")
                startPlaylistItem="$2"
                shift
                ;;
            "--one-shot")
                urlToDownload="$2"
                isOneShot=1
                shift
                ;;
            "--output-folder")
                outputFolder="$2"
                shift
                ;;

            "*")
                echo "Unkown param '$1'"
                exit 1
                ;;
        esac
        shift
    done
}

function dumpCfg() {
    echo "userName=$userName"
    echo "password=$password"
    echo "sleepBetweenDownloads=$sleepBetweenDownloads"
    echo "logFile=$logFile"
    echo "outputFolder=$outputFolder"
    echo "limitDownloads=$limitDownloads"
    echo "listOfUrlsFile=$listOfUrlsFile"
    echo "urlToDownload=$urlToDownload"
    echo "isOneShot=$isOneShot"
    echo "startPlaylistItem=$startPlaylistItem"
}

function extractFirstUrlFronTodoList() {
    local listOfUrls=$1
    local outputVar=$2
    local xOut=
    if [[ ! -f $listOfUrls ]]
    then
        echo "ERROR: No file containing urls '$listOfUrlsFile'"
        exit 1
    fi

    if [[ -z $outputVar ]]
    then
        echo "ERROR: [Line $LINENO] No output variable provided"
    fi

    xOut=$(head -n 1 $listOfUrls)
    eval "$outputVar='$xOut'"
}

function main() {
    if [[ $# -eq 0 ]]
    then
        showHelp
        exit 0
    fi
    parseOptions $*

    if [[ -z $urlToDownload && -z $listOfUrlsFile ]]
    then
        echo "No file containing urls or a single url have been received"
        showHelp
        exit 1
    fi
    #dumpCfg

    local currentUrl=
    if [[ $isOneShot -eq 1 ]]
    then
        currentUrl="$urlToDownload"
        echo "Downloading only one url $currentUrl"
        download "$currentUrl"
        exit 0
    fi

    downloadedItems=0
    echo "Downloading urls from $listOfUrlsFile"
    extractFirstUrlFronTodoList "$listOfUrlsFile" currentUrl
    while [[ -n $currentUrl ]]
    do
        # Remove the url from the todo file
        tail -n +2 "$listOfUrlsFile" > "$tmpFileName"
        mv "$tmpFileName" "$listOfUrlsFile"
        echo $currentUrl > $currentUrlFileName

        echo "Currently downloading $currentUrl"
        download "$currentUrl"

        # Move curent url to done list
        cat $currentUrlFileName >> $listOfDoneUrls
        rm $currentUrlFileName

        downloadedItems=$(($downloadedItems + 1))
        if [[ $downloadedItems -eq $limitDownloads ]]
        then
            echo "Downloaded $limitDownloads items, exiting"
            exit 0
        fi

        # Extract the next url
        extractFirstUrlFronTodoList "$listOfUrlsFile" currentUrl
    done

}

main $*
