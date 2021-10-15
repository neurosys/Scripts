#!/usr/bin/env bash

input=$1
output=$2
quality=${3:-24}

cmd=$(basename $0)
if [[ -z "$input" || -z "$output" ]]
then
    echo -e "Usage:\n\t$cmd <input file> <output file> [<compression>]\n"
    echo -e "\t<compresson>: 18 - 24 (constant rate factor) default 24\n\n"
    echo -e "\t\tHigher the compression, smaller the size and the quality\n\n"
    exit 1
fi

ffmpeg -i "$input" -vcodec libx265 -crf $quality "$output"

