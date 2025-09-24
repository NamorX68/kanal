#!/bin/bash

# Kanal ProxMox Infrastructure Setup Script

set -e

echo "Starting ProxMox infrastructure setup..."

# Update system
echo "Updating system packages..."
apt update && apt upgrade -y

# Install required packages
echo "Installing required packages..."
apt install -y wget curl gnupg2 software-properties-common

# Hardware-specific optimizations for Intel i5-13420H
echo "Applying hardware-specific optimizations..."

# Enable Intel VT-x and VT-d in GRUB
if ! grep -q "intel_iommu=on" /etc/default/grub; then
    sed -i 's/GRUB_CMDLINE_LINUX_DEFAULT="quiet"/GRUB_CMDLINE_LINUX_DEFAULT="quiet intel_iommu=on iommu=pt processor.max_cstate=1 intel_idle.max_cstate=0"/' /etc/default/grub
    update-grub
fi

# Configure memory settings for 32GB system
echo "vm.swappiness=10" >> /etc/sysctl.conf
echo "vm.dirty_ratio=15" >> /etc/sysctl.conf
echo "vm.dirty_background_ratio=5" >> /etc/sysctl.conf
echo "kernel.shmmax=17179869184" >> /etc/sysctl.conf  # 16GB for shared memory

# Configure huge pages (2GB)
echo "vm.nr_hugepages=1024" >> /etc/sysctl.conf

# Configure ProxMox repository (if needed)
if ! grep -q "pve-no-subscription" /etc/apt/sources.list.d/pve-enterprise.list 2>/dev/null; then
    echo "Configuring ProxMox repositories..."
    echo "deb http://download.proxmox.com/debian/pve bullseye pve-no-subscription" > /etc/apt/sources.list.d/pve-no-subscription.list
    wget -O- "http://download.proxmox.com/debian/proxmox-release-bullseye.gpg" | apt-key add -
    apt update
fi

# Configure network bridges
echo "Configuring network bridges..."
cat > /etc/systemd/network/vmbr100.netdev << EOF
[NetDev]
Name=vmbr100
Kind=bridge
EOF

cat > /etc/systemd/network/vmbr100.network << EOF
[Match]
Name=vmbr100

[Network]
DHCP=no
IPForward=yes
Address=10.0.100.1/24
EOF

# Enable and start systemd-networkd
systemctl enable systemd-networkd
systemctl start systemd-networkd

# Create storage directories
echo "Creating storage directories..."
mkdir -p /var/lib/vz/{template/cache,template/iso,images,dump,snippets}

# Set permissions
chmod 755 /var/lib/vz
chmod 755 /var/lib/vz/template
chmod 755 /var/lib/vz/template/cache
chmod 755 /var/lib/vz/template/iso
chmod 755 /var/lib/vz/images
chmod 755 /var/lib/vz/dump
chmod 755 /var/lib/vz/snippets

echo "ProxMox infrastructure setup completed!"
echo "Please reboot the system to apply all changes."