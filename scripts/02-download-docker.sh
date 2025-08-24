#!/usr/bin/env bash
set -eux

# ---------------------------
# Install Docker
# ---------------------------
curl -fsSL https://get.docker.com | sh
sudo usermod -aG docker ubuntu
sudo systemctl enable docker