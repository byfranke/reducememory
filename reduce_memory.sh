#!/bin/bash

MEM_FREE=$(awk '/^MemFree:/ { print int($2 / 1024) }' /proc/meminfo)
MEM_AVAILABLE=$(awk '/^MemAvailable:/ { print int($2 / 1024) }' /proc/meminfo)
MEM_TOTAL=$(awk '/^MemTotal:/ { print int($2 / 1024) }' /proc/meminfo)

# Allow configuration via environment variable or argument
if [ -n "$1" ]; then
    MEM_MIN="$1" # Command line argument
elif [ -n "$MEM_MIN_ENV" ]; then
    MEM_MIN="$MEM_MIN_ENV" # Environment variable
else
    MEM_MIN=512 # Default value
fi

if ! [[ "$MEM_MIN" =~ ^[0-9]+$ ]]; then
    echo "Invalid MEM_MIN value: '$MEM_MIN'. Expected a non-negative integer in MB." >&2
    exit 2
fi

# Prefer MemAvailable for pressure decisions; fallback to MemFree if unavailable.
if [ -n "$MEM_AVAILABLE" ]; then
    MEM_CURRENT="$MEM_AVAILABLE"
    MEM_METRIC="MemAvailable"
else
    MEM_CURRENT="$MEM_FREE"
    MEM_METRIC="MemFree"
fi

LOG_FILE="/var/log/reduce_memory.log"

if [ "$MEM_CURRENT" -le "$MEM_MIN" ]; then
    sync
    echo 3 > /proc/sys/vm/drop_caches
    echo "$(date '+%Y-%m-%d %H:%M:%S') - Cache cleaned. ${MEM_METRIC}: ${MEM_CURRENT}MB, MemFree: ${MEM_FREE}MB, MemTotal: ${MEM_TOTAL}MB (MEM_MIN=${MEM_MIN}MB)" >> "$LOG_FILE"
fi
