#!/bin/bash

# Installs and configures reduce_memory.sh to run periodically

# Define installation paths
SCRIPT_PATH="/usr/local/bin/reduce_memory.sh"
SERVICE_PATH="/etc/systemd/system/reduce_memory.service"
TIMER_PATH="/etc/systemd/system/reduce_memory.timer"

# Check for root privileges
if [ "$(id -u)" != "0" ]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi

# Copy the script to the target location
cp -v reduce_memory.sh $SCRIPT_PATH

# Ensure the script is executable
chmod +x $SCRIPT_PATH

# Copy systemd service and timer files
cp -v reduce_memory.service $SERVICE_PATH
cp -v reduce_memory.timer $TIMER_PATH

# Reload systemd to recognize new units
systemctl daemon-reload

# Enable and start the timer
systemctl enable reduce_memory.timer
systemctl start reduce_memory.timer

echo "Installation complete. reduce_memory.sh will run every 10 minutes."
