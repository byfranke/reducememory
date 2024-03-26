#!/bin/bash

MEM_FREE=$(awk '/^MemFree/ { print $2 / 1024 }' /proc/meminfo | cut -d. -f1)
MEM_TOTAL=$(awk '/^MemTotal/ { print $2 / 1024 }' /proc/meminfo | cut -d. -f1)

MEM_MIN=512 # Define minimum free memory limit in MB

if [ "$MEM_FREE" -le "$MEM_MIN" ]; then
    sync
    echo 3 > /proc/sys/vm/drop_caches
fi
