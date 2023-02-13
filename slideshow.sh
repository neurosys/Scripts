#!/usr/bin/env bash

dir="${1:-.}"

mpv --shuffle --loop-file=inf --image-display-duration=inf "$dir"

