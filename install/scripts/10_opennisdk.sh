#!/usr/bin/env bash
set -Eeuo pipefail

SCRIPT_NAME=$(basename "$0")
source "$MAIN_SCRIPTS_DIR/00_common.env"
source "$MAIN_SCRIPTS_DIR/00_lib.sh"
source "$CONFIG_SCRIPTS_DIR/00_common.env"

OPENNISDK_SOURCE="$PROJECT_DIR/sdks/$ARM_VERSION"
INSTALL_FLAG="$LOG_DIR/opennisdk"

log "checking to see if previous install ran successfully..."
if [ -f "$INSTALL_FLAG" ]; then 
    log "OpenNI SDK install was already run successfully..."
    return 0 
fi 

log "installing prerequisites..."
sudo apt-get install -y -qq freeglut3-dev 
sudo apt-get install --reinstall -y -qq libudev1

log "copying OpenNI SDK distribution..."
if [ -d "$OPENNISDK_DIR" ]; then 
    rm -r "$OPENNISDK_DIR"
fi 

mkdir "$OPENNISDK_DIR"
cp -r "$OPENNISDK_SOURCE" "$OPENNISDK_DIR"

log "installing OpenNI SDK..."
cd "$OPENNISDK_DEST"
sudo chmod +x install.sh
sudo ./install.sh

log "sourcing OpenNI development environment..."
source OpenNIDevEnvironment

read -p "→ OpenNI SDK installed. Replug your device, then press ENTER." _

log "verifying Orbbec device..."
if lsusb | grep -q 2bc5:0407; then
    echo "Orbbec Astra Mini S detected."
elif lsusb | grep -q 2bc5; then
    echo "[ERROR] Non-supported Orbbec device detected (e.g., Astra Pro)."
    exit 1
else
    echo "[ERROR] No Orbbec device found."
    exit 1
fi

log "building $SIMPLE_READ_EXAMPLE..."
cd "$SIMPLE_READ_EXAMPLE"

if [ ! -d "$OPENNISDK_REDIST_DIR" ]; then
  log "[ERROR] Missing $OPENNISDK_REDIST_DIR (did the SDK extract correctly?)"
  exit 1
fi

make -j"$(nproc)" \
  OPENNI2_DIR="$OPENNISDK_DEST" \
  OPENNI2_REDIST="$OPENNISDK_REDIST_DIR" \
  OPENNI2_INCLUDE="$OPENNISDK_DEST/Include"

log "making $SIMPLE_READ_EXAMPLE executable///"
chmod 777 "$SIMPLE_READ_EXAMPLE/Bin/Arm-Release/SimpleRead"

touch "$INSTALL_FLAG"