#!/usr/bin/env bash
set -eux

# ---------------------------
# Refresh apt sources completely
# ---------------------------
sudo add-apt-repository -y main
sudo add-apt-repository -y universe
sudo add-apt-repository -y multiverse
sudo add-apt-repository -y restricted

# ---------------------------
# Update system
# ---------------------------
sudo apt-get update -y && sudo apt-get upgrade -y

# ---------------------------
# Install essentials
# ---------------------------
sudo apt-get install -y build-essential git curl wget jq unzip apt-transport-https ca-certificates gnupg lsb-release