#!/usr/bin/env bash

if [[ -z "$1" || -z "$2" ]]
then
    echo "${0} <big file> <output file>"
    exit 0
fi


bigFile="$1"
outputFile="$2"

gs -sDEVICE=pdfwrite -dCompatibilityLevel=1.4 -dPDFSETTINGS=/prepress -dNOPAUSE -dQUIET -dBATCH -sOutputFile="$outputFile" "$bigFile"

