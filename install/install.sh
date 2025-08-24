#!/usr/bin/env bash
set -Eeuo pipefail

source "$MAIN_SCRIPTS_DIR/00_common.env"
source "$MAIN_SCRIPTS_DIR/00_lib.sh"

export CONFIG_SCRIPTS_DIR="$HOME/$SCRIPT_NAME/config/install/scripts"
source "$CONFIG_SCRIPTS_DIR/00_common.env"


for step in "$CONFIG_SCRIPTS_DIR"/[0-9][0-9]_*.sh; do 
    run_step "$step"
done 