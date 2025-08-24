#!/usr/bin/env bash
set -Eeuo pipefail

SCRIPT_NAME=$(basename "$0")
source "$MAIN_SCRIPTS_DIR/00_common.env"
source "$MAIN_SCRIPTS_DIR/00_lib.sh"

KERNEL_REPO="https://github.com/emlid/linux-rt-rpi.git"
KERNEL_BRANCH="rpi-5.10.11-navio"
BUILD_DIR="$HOME/navio2-kernel"
FIRMWARE_URL="https://github.com/emlid/rcio-firmware/raw/master/rcio.fw"
INSTALL_FLAG="$LOG_DIR/navio2-kernel"

log "checking to see if previous install ran successfully..."
if [ -f "$INSTALL_FLAG" ]; then 
    log "Navio2 kernal install was already run successfully..."
    return 0 
fi 

log "installing build dependencies..."
sudo apt-get install -y -qq git bc bison flex libssl-dev make libc6-dev libncurses5-dev \
    crossbuild-essential-armhf liblz4-tool libelf-dev u-boot-tools device-tree-compiler \
    wget gcc-arm-linux-gnueabihf g++-arm-linux-gnueabihf

log "cloning Emlid RT kernel..."
if [ -d "$BUILD_DIR" ]; then 
    rm -rf "$BUILD_DIR"
fi 

mkdir -p "$BUILD_DIR"
cd "$BUILD_DIR"
if [ ! -d "linux-rt-rpi" ]; then
    git clone --depth 1 --branch $KERNEL_BRANCH $KERNEL_REPO
fi
cd linux-rt-rpi

log "loading Pi 3 default config..."
make ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf- bcm2709_defconfig

log "enabling Navio2 RCIO modules..."
scripts/config --file .config \
    --enable CONFIG_SPI \
    --enable CONFIG_SPI_BCM2835 \
    --module CONFIG_RCIO_SPI \
    --module CONFIG_RCIO_PWM \
    --enable CONFIG_PREEMPT_RT

set +e
yes "" | make ARCH=arm CROSS_COMPILE=armv-linux-gnueabihf- olddefconfig
MAKE_RC=$?
set -e

if [[ $MAKE_RC -ne 0 ]]; then
    log "WARNING: olddefconfig exited with code $MAKE_RC"
fi

log "building kernel..."
make -j$(nproc) ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf- KCFLAGS="-march=armv7-a -mtune=cortex-a7 -mfpu=neon-vfpv4" zImage modules dtbs

log "installing modules..."
sudo make ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf- modules_install

log "installing kernel and overlays..."
sudo cp arch/arm/boot/zImage /boot/kernel7.img
sudo cp arch/arm/boot/dts/*.dtb /boot/
sudo cp arch/arm/boot/dts/overlays/*.dtb* $OVERLAYS_DIR/
sudo cp arch/arm/boot/dts/overlays/README $OVERLAYS_DIR/

log "installing rcio.fw..."
sudo wget -qO /lib/firmware/rcio.fw $FIRMWARE_URL

log "adding Navio2 overlays..."
sudo bash "$MAIN_SCRIPTS_DIR/21_navio2_overlays.sh"

log "preparing for reboot..."
sudo bash "$MAIN_SCRIPTS_DIR/22_navio2_reboot.sh"

touch "$INSTALL_FLAG"

read -p "→ Navio2 kernel and overlays installed. Press ENTER to reboot." _
sudo reboot