#!/usr/bin/env bash
set -Eeuo pipefail

REPO="drone-navio2"
LOG_DIR="$HOME/logs"

if [ ! -d "$LOG_DIR" ]; then 
    mkdir "$LOG_DIR" 
fi 

INSTALL_FLAG="$LOG_DIR/initialize"

echo "checking to see if previous initialization ran successfully..."
if [ -f "$INSTALL_FLAG" ]; then 
    log "Initialization was already run successfully..."
    if [[ "${1:-}" == "--reinstall" ]]; then
        bash "$HOME/$REPO/shared/install/install.sh --reinstall"
    else 
        bash "$HOME/$REPO/shared/install/install.sh"
    fi
fi 

SCRIPTS_DIR="$HOME/scripts"
GIT_PULL_SCRIPT="$SCRIPTS_DIR/git_pull.sh"

MODEL=$(tr -d '\0' < /proc/device-tree/model)
OS_CODENAME=$(grep VERSION_CODENAME /etc/os-release | cut -d= -f2)
ARCH=$(uname -m)

echo "found: $MODEL : $OS_CODENAME : $ARCH"

if [[ "$MODEL" == *"Raspberry Pi 3"* && "$OS_CODENAME" == "bookworm" && "$ARCH" == "armv7l" ]]; then
    BRANCH="rpi3-bookworm-32bit"
elif [[ "$MODEL" == *"Raspberry Pi 3"* && "$OS_CODENAME" == "bullseye" && "$ARCH" == "aarch64" ]]; then
    echo "rpi3-bullseye-64bit"
elif [[ "$MODEL" == *"Raspberry Pi 4"* && "$OS_CODENAME" == "bookworm" && "$ARCH" == "aarch64" ]]; then
    echo "rpi3-bookworm-64bit"
else
    echo "⚠️  Unknown or unsupported combination"
fi

echo "installing system package..."
sudo apt-get update && sudo apt-get install -y -qq git 

echo "cloning $BRANCH..."
cd $HOME
git clone https://github.com/edpiedra/$REPO.git 
cd $HOME/$REPO 
git worktree add ./shared main_branch
git worktree add ./config $BRANCH 

echo "creating git pull scripts..."
if [ ! -d $SCRIPTS_DIR ]; then 
    mkdir $SCRIPTS_DIR 
fi 

cat <<EOF | sudo tee "$GIT_PULL_SCRIPT" > /dev/null
#!/bin/bash

cd $HOME/$REPO
git pull origin

cd $HOME/$REPO/shared 
git pull origin main_branch 

cd $HOME/$REPO/config 
git pull origin $BRANCH 
EOF

touch $INSTALL_FLAG 

echo "installing $BRANCH..."
bash "$HOME/$REPO/shared/install/install.sh"
