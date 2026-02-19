#!/bin/bash

MEM_FREE=$(awk '/^MemFree/ { print $2 / 1024 }' /proc/meminfo | cut -d. -f1)
MEM_TOTAL=$(awk '/^MemTotal/ { print $2 / 1024 }' /proc/meminfo | cut -d. -f1)

# Allow configuration via environment variable or argument
if [ -n "$1" ]; then
    MEM_MIN="$1" # Command line argument
elif [ -n "$MEM_MIN_ENV" ]; then
    MEM_MIN="$MEM_MIN_ENV" # Environment variable
else
    MEM_MIN=512 # Default value
fi

LOG_FILE="/var/log/reduce_memory.log"

if [ "$MEM_FREE" -le "$MEM_MIN" ]; then
    sync
    echo 3 > /proc/sys/vm/drop_caches
    echo "$(date '+%Y-%m-%d %H:%M:%S') - Cache cleaned. MemFree: ${MEM_FREE}MB, MemTotal: ${MEM_TOTAL}MB (MEM_MIN=${MEM_MIN}MB)" >> "$LOG_FILE"
fi
