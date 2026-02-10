#!/bin/bash
# This script will install dependencies for ansible EE build. 

#install dependencies for ansible EE build
# Add Docker's official GPG key:
echo "installing docker dependencies..."
apt update -y
apt install -y ca-certificates curl
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to Apt sources:
tee /etc/apt/sources.list.d/docker.sources <<EOF
Types: deb
URIs: https://download.docker.com/linux/ubuntu
Suites: $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}")
Components: stable
Signed-By: /etc/apt/keyrings/docker.asc
EOF

apt update -y

apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# install python3-pip
echo "installing python3-pip..."
apt install -y python3-pip

# install python3-venv
echo "installing python3-venv..."
apt install -y python3-venv

# create python venvironment for ansible EE build
echo "creating python virtual environment for ansible EE build..."
python3 -m venv "$1"

# activate the virtual environment
echo "activating python virtual environment for ansible EE build..."
source "$1/bin/activate"

# install ansible-navigator
echo "installing ansible-navigator..."
pip install ansible-navigator

# install ansible-builder
echo "installing ansible-builder..."
pip install ansible-builder
