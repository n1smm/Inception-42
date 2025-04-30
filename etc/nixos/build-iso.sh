#!/usr/bin/env bash
set -e

echo "=== Building NixOS Installation ISO ==="

# Create target-config directory if it doesn't exist
mkdir -p ./target-config

# Check if all required files exist
for file in "./target-config/configuration.nix" "./target-config/home.nix" "./target-config/packages.nix" "./target-config/install.sh"; do
  if [ ! -f "$file" ]; then
    echo "Error: $file not found"
    exit 1
  fi
done

# Make the install script executable
chmod +x ./target-config/install.sh

# Build the ISO
echo "Building ISO image..."
nix-build '<nixpkgs/nixos>' -A config.system.build.isoImage -I nixos-config=./iso.nix

# Get the path to the ISO
ISO_PATH=$(readlink -f result/iso/*.iso)

echo "ISO built successfully: $ISO_PATH"
echo "You can now use this ISO to install NixOS on a virtual machine."
