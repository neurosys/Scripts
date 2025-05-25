#!/usr/bin/env bash

#cat /sys/class/power_supply/BAT1/capacity
percentFull=$(cat /sys/class/power_supply/BAT*/capacity)
isCharging=$(cat /sys/class/power_supply/BAT*/status)

echo "$isCharging $percentFull"

