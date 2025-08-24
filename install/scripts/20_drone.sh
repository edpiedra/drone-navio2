#!/usr/bin/env bash
set -Eeuo pipefail

SCRIPT_NAME=$(basename "$0")
source "$MAIN_SCRIPTS_DIR/00_common.env"
source "$MAIN_SCRIPTS_DIR/00_lib.sh"
source "$CONFIG_SCRIPTS_DIR/00_common.env"

INSTALL_FLAG="$LOG_DIR/drone"

log "checking to see if previous install ran successfully..."
if [ -f "$INSTALL_FLAG" ]; then 
    log "OpenNI SDK install was already run successfully..."
    return 0 
fi 

log "installing requirements in drone virtual environment..."
sudo apt-get install -y -qq python3-opencv python3-numpy 
cd "$PROJECT_DIR"

if [ ! -d .venv ]; then 
log "creating virtual environment..."
    python3 -m venv .venv --system-site-packages
    set +u; source .venv/bin/activate; set -u
    python3 -m pip install "$NAVIO2_WHEEL"
    python3 -m pip install -r requirements.txt
    set +u; deactivate; set -u
else 
    set +u; source .venv/bin/activate; set -u
    python3 -m pip install "$NAVIO2_WHEEL"
    python3 -m pip install -r requirements.txt
    set +u; deactivate; set -u
fi

touch "$INSTALL_FLAG"