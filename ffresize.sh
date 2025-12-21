#!/usr/bin/env bash

# Change the resolution of a video file using ffmpeg

if [ "$#" -ne 3 ]; then
    echo "Usage: $0 <input_video> width:height <output_video>"
    exit 1
fi

ffmpeg -i "$1" -vf "scale=$2" "$3"
