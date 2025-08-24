#!/usr/bin/env bash
set -Eeuo pipefail

SCRIPT_NAME=$(basename "$0")
export REPO="drone-navio2"
export MAIN_SCRIPTS_DIR="$HOME/$REPO/shared/install/scripts"

source "$MAIN_SCRIPTS_DIR/00_common.env"
source "$MAIN_SCRIPTS_DIR/00_lib.sh"

if [ ! -d "$LOG_DIR" ]; then 
    mkdir "$LOG_DIR" 
fi

if [[ "${1:-}" == "--post-navio2-kernel-reboot" ]]; then
    log "post-navio2 kernel reboot tasks starting..."

    for step in "$SCRIPTS_DIR"/1[0-9][0-9]_*.sh; do 
        run_step "$step"
    done 

    bash $HOME/$SCRIPT_NAME/config/install/install.sh
    
    log "✅ Install complete. Logs saved to: $LOG_FILE"
    exit 0
elif [[ "${1:-}" == "--reinstall" ]]; then 
    log "reinstalling all packages..."

    if [ -d "$LOG_DIR" ]; then 
        rm -rf "$LOG_DIR"
        mkdir "$LOG_DIR"
    fi 
fi 

if [ -f "$LOG_FILE" ]; then 
    rm -f "$LOG_FILE"
fi 

for step in "$MAIN_SCRIPTS_DIR"/[0-9][0-9]_*.sh; do 
    run_step "$step"
done 