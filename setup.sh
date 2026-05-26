#!/bin/bash

# Installs and configures reduce_memory.sh to run periodically
# Now with uninstall option, standard and custom install, and log rotation

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

SCRIPT_PATH="/usr/local/bin/reduce_memory.sh"
SERVICE_PATH="/etc/systemd/system/reduce_memory.service"
TIMER_PATH="/etc/systemd/system/reduce_memory.timer"
LOGROTATE_PATH="/etc/logrotate.d/reduce_memory"
ENV_PATH="/etc/default/reduce_memory"

function uninstall() {
    echo "Removing service, timer, script and logrotate..."
    systemctl disable --now reduce_memory.timer >/dev/null 2>&1
    systemctl stop reduce_memory.service >/dev/null 2>&1
    rm -f "$SERVICE_PATH" "$TIMER_PATH" "$SCRIPT_PATH" "$LOGROTATE_PATH" "$ENV_PATH"
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

function write_env_file() {
    local mem_min="$1"
    cat > "$ENV_PATH" <<EOF
MEM_MIN_ENV=$mem_min
EOF
    chmod 644 "$ENV_PATH"
}

function install_default() {
    cp -v "$SCRIPT_DIR/reduce_memory.sh" "$SCRIPT_PATH"
    chmod +x "$SCRIPT_PATH"
    cp -v "$SCRIPT_DIR/reduce_memory.service" "$SERVICE_PATH"
    cp -v "$SCRIPT_DIR/reduce_memory.timer" "$TIMER_PATH"
    cp -v "$SCRIPT_DIR/reduce_memory.logrotate" "$LOGROTATE_PATH"
    write_env_file 512
    systemctl daemon-reload
    systemctl enable reduce_memory.timer
    systemctl start reduce_memory.timer
    echo "Standard installation complete. MEM_MIN=512 MB, timer enabled, and logrotate configured."
}

function install_custom() {
    read -p "Enter the minimum free memory limit in MB (default 512): " MEM_MIN
    MEM_MIN=${MEM_MIN:-512}
    if ! [[ "$MEM_MIN" =~ ^[0-9]+$ ]]; then
        echo "Invalid value. Please enter a non-negative integer."
        exit 1
    fi

    cp -v "$SCRIPT_DIR/reduce_memory.sh" "$SCRIPT_PATH"
    chmod +x "$SCRIPT_PATH"
    cp -v "$SCRIPT_DIR/reduce_memory.service" "$SERVICE_PATH"
    cp -v "$SCRIPT_DIR/reduce_memory.timer" "$TIMER_PATH"
    cp -v "$SCRIPT_DIR/reduce_memory.logrotate" "$LOGROTATE_PATH"
    write_env_file "$MEM_MIN"
    systemctl daemon-reload
    systemctl enable reduce_memory.timer
    systemctl start reduce_memory.timer
    echo "Custom installation complete. MEM_MIN=$MEM_MIN MB, timer enabled, and logrotate configured."
}

PS3="Choose installation type: "
select opt in "Standard (MEM_MIN=512MB)" "Custom"; do
    case $REPLY in
        1) install_default; break;;
        2) install_custom; break;;
        *) echo "Invalid option";;
    esac
done
