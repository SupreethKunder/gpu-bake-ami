#!/usr/bin/env bash
set -eux

# ---------------------------
# Cleanup temporary files and directories to reduce AMI size
# ---------------------------
sudo rm -rf /var/tmp/security-reports || true
sudo apt-get clean
sudo rm -rf /var/lib/apt/lists/* /tmp/*