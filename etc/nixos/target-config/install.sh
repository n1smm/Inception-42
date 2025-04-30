#!/usr/bin/env bash
set -e

# Installation script for NixOS
echo "=== NixOS Installation Script ==="

# Check if running as root
if [ "$(id -u)" -ne 0 ]; then
    echo "This script must be run as root" 
    exit 1
fi

# Prompt for target disk
echo "Available disks:"
lsblk -o NAME,MAJ:MIN,RM,SIZE,RO,FSTYPE,MOUNTPOINTS,PATH
echo ""
read -p "Enter target disk path (e.g., /dev/sda): " TARGET_DISK

# Confirm disk selection
echo "WARNING: This will erase all data on $TARGET_DISK"
read -p "Are you sure? (y/N): " CONFIRM
if [[ ! "$CONFIRM" =~ ^[Yy]$ ]]; then
    echo "Installation aborted."
    exit 1
fi

# Partition the disk
echo "Creating partitions on $TARGET_DISK..."
parted -s "$TARGET_DISK" -- mklabel msdos
parted -s "$TARGET_DISK" -- mkpart primary 1MiB -8GiB
parted -s "$TARGET_DISK" -- mkpart primary linux-swap -8GiB 100%

# Format partitions
echo "Formatting partitions..."
ROOT_PART="${TARGET_DISK}1"
SWAP_PART="${TARGET_DISK}2"

mkfs.ext4 -L nixos "$ROOT_PART"
mkswap -L swap "$SWAP_PART"

# Mount partitions
echo "Mounting partitions..."
mount "$ROOT_PART" /mnt
swapon "$SWAP_PART"

# Generate hardware configuration
echo "Generating hardware configuration..."
nixos-generate-config --root /mnt

# Copy our prepared configuration
echo "Copying NixOS configuration..."
cp -r /etc/nixos/target/configuration.nix /mnt/etc/nixos/
cp -r /etc/nixos/target/home.nix /mnt/etc/nixos/
cp -r /etc/nixos/target/packages.nix /mnt/etc/nixos/

# Install NixOS
echo "Installing NixOS..."
nixos-install --no-root-passwd

echo "Installation complete! You can now reboot into your new NixOS system."
