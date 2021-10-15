#!/usr/bin/env bash

#ffmpeg -i 2021-06-19-Masina_in_flacari_VICO5939.MP4 -acodec copy -vcodec copy -ss 02:10 -t 00:00:20 flacari_out.mp4
# -to "$end"
# -t "$length"

function help() {
    echo -e "Usage:\n"
    echo -e "\t$(basename $0) <input file> <start moment> <end moment> <output file>\n\n"
    echo -e "Format:"
    echo -e "\tstart: 01:23:45"
    echo -e "\t  end: 01:23:45"
}

in="$1"
start=$2
end=$3
out="$4"

function checkParam() {
    if [[ -z "$1" ]]
    then
        echo -e "Argument ${2} is missing\n\n"
        help
        exit 1
    fi
}

checkParam "$in"    "<input file>"
checkParam "$out"   "<output file>"
checkParam "$start" "<start moment>"
checkParam "$end"   "<end moment>"

ffmpeg -i "$in" -acodec copy -vcodec copy -ss $start -to "$end" "$out"
