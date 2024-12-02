#!/usr/bin/env bash

if [[ -z $1 || -z $2 ]]; then
    echo "Usage: $0 <path> <file>"
    exit 1
fi

filePath=$1
file=$2

fileList=$(ls -1 $filePath)
fileIndex=$(echo "$fileList" | grep -n $file | sed -e 's/^\([0-9]\+\).*/\1/')

echo "$fileList" | sxiv - -n $fileIndex

