
# Force the sync of time
#ntpd -gq

# Switch to using the local time instead of utc
timedatectl set-local-rtc 1 --adjust-system-clock

