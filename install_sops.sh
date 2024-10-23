#!/bin/bash

# Install SOPS
SOPS_VERSION=v3.9.0

set -e
ARCH=$(dpkg --print-architecture)
echo "Detected architecture: $ARCH"

case $ARCH in
    amd64)  SOPS_ARCH="amd64" ;;
    arm64)  SOPS_ARCH="arm64" ;;
    armhf)  SOPS_ARCH="arm" ;;
    *) echo "Unsupported architecture: $ARCH" && exit 1 ;;
esac

echo "SOPS architecture: $SOPS_ARCH"
SOPS_URL="https://github.com/getsops/sops/releases/download/${SOPS_VERSION}/sops-${SOPS_VERSION}.linux.${SOPS_ARCH}"
echo "Downloading SOPS from: $SOPS_URL"

curl -L "$SOPS_URL" -o /usr/local/bin/sops
chmod +x /usr/local/bin/sops

echo "Verifying SOPS installation:"
if /usr/local/bin/sops --version; then
    echo "SOPS installed successfully"
else
    echo "SOPS installation failed"
    exit 1
fi
