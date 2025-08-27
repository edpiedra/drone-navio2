#!/usr/bin/env bash
set -Eeuo pipefail

SCRIPT_NAME=$(basename "$0")
source "$MAIN_SCRIPTS_DIR/00_common.env"
source "$MAIN_SCRIPTS_DIR/00_lib.sh"

log "updating system packages..."
sudo apt-get update && sudo apt-get -y -qq dist-upgrade

if [ ! -f "$EXPANSION_INSTALL_FLAG" ]; then
    log "exanding filesystem..."
    sudo raspi-config --expand-rootfs
    touch "$EXPANSION_INSTALL_FLAG"

    #log "preparing for reboot..."
    #bash "$MAIN_SCRIPTS_DIR/11_system_reboot.sh"

    read -p "→ Exanded filesystem. Press ENTER to reboot." _
    sudo reboot
fi 

