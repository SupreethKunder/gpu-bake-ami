#!/usr/bin/env bash
set -eux

# ---------------------------
# Install required packages
# ---------------------------
sudo apt-get update -y
sudo apt-get install -y linux-headers-$(uname -r) dkms

# ---------------------------
# Install NVIDIA driver
# ---------------------------
sudo apt-get update -y && sudo apt-get install -y wget gnupg software-properties-common

# ---------------------------
# Add NVIDIA CUDA repo
# ---------------------------
wget https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2204/x86_64/cuda-keyring_1.1-1_all.deb
sudo dpkg -i cuda-keyring_1.1-1_all.deb
sudo apt-get update -y

# ---------------------------
# Install recommended driver + CUDA toolkit
# ---------------------------
sudo apt-get -y install nvidia-driver-535 nvidia-dkms-535 cuda-toolkit-12-2
distribution=$(. /etc/os-release;echo $ID$VERSION_ID)
curl -fsSL https://nvidia.github.io/libnvidia-container/gpgkey | sudo gpg --dearmor -o /usr/share/keyrings/nvidia-container-toolkit.gpg
curl -fsSL https://nvidia.github.io/libnvidia-container/$distribution/libnvidia-container.list | sed 's#deb https://#deb [signed-by=/usr/share/keyrings/nvidia-container-toolkit.gpg] https://#' | sudo tee /etc/apt/sources.list.d/nvidia-container-toolkit.list >/dev/null
sudo apt-get update -y
sudo apt-get install -y nvidia-container-toolkit
sudo nvidia-ctk runtime configure --runtime=docker || true
sudo systemctl restart docker