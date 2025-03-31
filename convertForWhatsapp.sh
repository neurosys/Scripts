#!/usr/bin/env bash

ffmpeg -i to_view/Pilot.mp4 -c:v libx264 -profile:v baseline -level 3.0 -pix_fmt yuv420p sendable_video.mp4
