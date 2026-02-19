#!/bin/bash

# Installs and configures reduce_memory.sh to run periodically
# Now with uninstall option, standard and custom install, and log rotation

SCRIPT_PATH="/usr/local/bin/reduce_memory.sh"
SERVICE_PATH="/etc/systemd/system/reduce_memory.service"
TIMER_PATH="/etc/systemd/system/reduce_memory.timer"
LOGROTATE_PATH="/etc/logrotate.d/reduce_memory"
LOGROTATE_SRC="$(pwd)/reduce_memory.logrotate"

function uninstall() {
    echo "Removing service, timer, script and logrotate..."
    systemctl stop reduce_memory.timer
    systemctl disable reduce_memory.timer
    rm -f "$SERVICE_PATH" "$TIMER_PATH" "$SCRIPT_PATH" "$LOGROTATE_PATH"
    systemctl daemon-reload
    echo "Uninstallation complete."
    exit 0
}

if [ "$(id -u)" != "0" ]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi

if [[ "$1" == "uninstall" ]]; then
    uninstall
fi

function install_default() {
    cp -v reduce_memory.sh "$SCRIPT_PATH"
    chmod +x "$SCRIPT_PATH"
    cp -v reduce_memory.service "$SERVICE_PATH"
    cp -v reduce_memory.timer "$TIMER_PATH"
    cp -v reduce_memory.logrotate "$LOGROTATE_PATH"
    systemctl daemon-reload
    systemctl enable reduce_memory.timer
    systemctl start reduce_memory.timer
    echo "Standard installation complete. The script will run every 10 minutes and logrotate is configured."
}

function install_custom() {
    read -p "Enter the minimum free memory limit in MB (default 512): " MEM_MIN
    MEM_MIN=${MEM_MIN:-512}
    sed "s/^MEM_MIN=.*/MEM_MIN=$MEM_MIN # Define minimum free memory limit in MB/" reduce_memory.sh > /tmp/reduce_memory.sh
    cp -v /tmp/reduce_memory.sh "$SCRIPT_PATH"
    chmod +x "$SCRIPT_PATH"
    cp -v reduce_memory.service "$SERVICE_PATH"
    cp -v reduce_memory.timer "$TIMER_PATH"
    cp -v reduce_memory.logrotate "$LOGROTATE_PATH"
    systemctl daemon-reload
    systemctl enable reduce_memory.timer
    systemctl start reduce_memory.timer
    echo "Custom installation complete. MEM_MIN=$MEM_MIN MB. Logrotate configured."
}

PS3="Choose installation type: "
select opt in "Standard (MEM_MIN=512MB)" "Custom"; do
    case $REPLY in
        1) install_default; break;;
        2) install_custom; break;;
        *) echo "Invalid option";;
    esac
done
