#!/usr/bin/env bash

fileName=bibi.fs
size=1024M
fileSystem=ext4


#dd if=/dev/zero of=$fileName count=1024 bs=1M

#mkfs -t fileSystem  $fileName

#echo "Use following command to mount"
#echo "sudo mount -t ext4 -o loop $fileName <mount point>"
