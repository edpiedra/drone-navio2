#!/usr/bin/env bash
set -Eeuo pipefail

SCRIPT_NAME=$(basename "$0")
source "$MAIN_SCRIPTS_DIR/00_common.env"
source "$MAIN_SCRIPTS_DIR/00_lib.sh"

INSTALL_FLAG="$LOG_DIR/ardupilot"

log "checking to see if previous install ran successfully..."
if [ -f "$INSTALL_FLAG" ]; then 
    log "ArduPilot install was already run successfully..."
    return 0 
fi 

log "getting the code..."
if [ -d "$ARDUPILOT_DIR" ]; then 
    rm -rf "$ARDUPILOT_DIR"
fi 

cd "$HOME"

git clone https://github.com/ArduPilot/ardupilot.git
cd $ARDUPILOT_DIR
git submodule update --init --recursive

log "installing build tools..."
sudo apt install -y -qq python3-serial python3-dev libtool libxml2-dev libxslt1-dev \
  gawk python3-pip pkg-config build-essential ccache libffi-dev \
  libjpeg-dev zlib1g-dev python3-empy python3-pexpect
sudo python3 -m pip install --upgrade pymavlink MAVProxy --break-system-packages

log "building ArduCopter for Navio2..."
./waf configure --board=navio2
./waf copter

log "adding ArduPilot as a service..."
sudo bash "$SCRIPTS_DIR/221_ardupilot_service.sh"

touch "$INSTALL_FLAG"