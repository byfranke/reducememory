#!/bin/bash

# Clears memory cache on Linux systems

# Calculate free and total memory in MB
MEM_FREE=$(awk '/^MemFree/ { print $2 / 1024 }' /proc/meminfo | cut -d. -f1)
MEM_TOTAL=$(awk '/^MemTotal/ { print $2 / 1024 }' /proc/meminfo | cut -d. -f1)

# Define minimum free memory limit in MB
MEM_MIN=512

# Clear cache if free memory is below the minimum threshold
if [ "$MEM_FREE" -le "$MEM_MIN" ]; then
    # Synchronize cached writes to persistent storage
    sync
    # Clear memory cache
    echo 3 > /proc/sys/vm/drop_caches
fi
