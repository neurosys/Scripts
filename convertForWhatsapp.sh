#!/usr/bin/env bash

input=$1
output=$2

if [[ "$input" == "" || "$output" == "" ]]
then
    echo "$0 <input_file> <output_file>"
    echo -e "\toutput file it's recommented to be an .mp4"
    echo ""
    exit 0
fi

ffmpeg -i "$input" -c:v libx264 -profile:v baseline -level 3.0 -pix_fmt yuv420p "$2" sendable_video.mp4
