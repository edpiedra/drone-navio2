#!/usr/bin/env bash
set -Eeuo pipefail

SCRIPT_NAME=$(basename "$0")
source "$MAIN_SCRIPTS_DIR/00_common.env"
source "$MAIN_SCRIPTS_DIR/00_lib.sh"

INSTALL_FLAG="$LOG_DIR/filesystem-expansion"

log "updating system packages..."
sudo apt-get update && sudo apt-get -y -qq dist-upgrade

if [ ! -f "$INSTALL_FLAG" ]; then
    log "exanding filesystem..."
    sudo raspi-config --expand-rootfs
    touch "$INSTALL_FLAG"
fi 

log "preparing for reboot..."
export MAIN_SCRIPTS_DIR=$MAIN_SCRIPTS_DIR
sudo bash "$MAIN_SCRIPTS_DIR/11_system_reboot.sh"

read -p "→ Exanded filesystem. Press ENTER to reboot." _
sudo reboot
