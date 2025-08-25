#!/usr/bin/env bash
set -Eeuo pipefail

SCRIPT_NAME=$(basename "$0")
source "$MAIN_SCRIPTS_DIR/00_common.env"
source "$MAIN_SCRIPTS_DIR/00_lib.sh"

log "updating system packages..."
sudo apt-get update && sudo apt-get -y -qq dist-upgrade

log "exanding filesystem..."
sudo raspi-config --expand-rootfs

log "preparing for reboot..."
sudo bash "$MAIN_SCRIPTS_DIR/11_system_reboot.sh"