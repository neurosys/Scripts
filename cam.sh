#!/usr/bin/env bash

# Open the webcam to see how beautiful you are

# To capture sound with alsa add :input-slave=alsa:// 

vlc v4l2:// :v4l-vdev="/dev/video0"

