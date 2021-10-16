#!/usr/bin/env bash

cmd=$(basename $0)
inputList=$1
output=$2

if [[ -z "$inputList" || -z "$output" ]]
then
    echo -e "Concatenates video files OF THE SAME ENCODING\n"
    echo -e "\nUsage\n\t${cmd} <file containing list of chunks> <output file>\n"
    echo -e "\n"
    echo -e "\tFile containing list of chunks must have the following format:\n"
    echo -e "\tfile '<filename 01>'"
    echo -e "\tfile '<filename 02>'"
    echo -e "\tfile '<filename 03>'"
    echo -e "\tfile '<filename 04>'"
    echo -e "\tLines starting with '#' are ignored\n"
    exit 0
fi


ffmpeg -f concat -safe 0 -i "$inputList" -c copy "$output"

