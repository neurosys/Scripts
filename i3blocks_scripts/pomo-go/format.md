
- minutes:
    + integer > 0
- Operation "^(start|stop|pause|resume) [0-9]{4}-[0-9]{2}-[0-9]{2}_[0-9]{2}:[0-9]{2}:[0-9]{2}$"
    + name: {start|stop|pause|resume}
    + timestamp: `full timestamp in format YYYY-MM-DD_HH:MM:SS`
- Empty line separates different pomodoros

Example:

minutes 25
start 2025-11-25_10:23:59
pause 2025-11-25_10:33:55
resume 2025-11-25_10:35:00
end 2025-11-25_10:48:59
