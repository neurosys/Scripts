#!/usr/bin/env bash

if command -v batcat &> /dev/null
then
    batcat $*
else 
    bat $*
fi
