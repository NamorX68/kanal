# Kanal Infrastructure - Complete Installation Guide

## Overview

This guide provides a step-by-step walkthrough for setting up the Kanal ProxMox infrastructure on Intel i5-13420H hardware with 32GB DDR5 RAM and 1TB NVMe SSD.

---

## Configuration Files Explained

### 1. **README.md** - Main Documentation

**Purpose**: Central project overview and quick start guide
**Contains**:
- Project structure overview
- Hardware specifications summary  
- Resource allocation plan
- Quick start commands

### 2. **config/proxmox-config.yml** - Main Infrastructure Configuration

**Purpose**: Primary ProxMox cluster and network configuration
**Contains**:
- **Cluster**: Server "kanal-pve-01" with IP 192.168.1.10
- **Networks**: 
  - Management: 192.168.1.0/24 (ProxMox Web Interface)
  - VMs: 10.0.100.0/24 (VLAN 100)
  - Containers: 10.0.200.0/24 (VLAN 200)
- **Storage**: 1TB SSD partitioning plan
- **Backup**: Daily at 02:00, 7-day retention

### 3. **config/hardware-specs.yml** - Detailed Hardware Information

**Purpose**: Complete hardware documentation and optimization guidelines
**Contains**:
- **CPU Details**: P-cores vs E-cores, frequencies, virtualization features
- **Memory**: DDR5-5600 specifications
- **Storage**: NVMe PCIe 4.0 details
- **Recommended VM allocation**: How to distribute 32GB RAM and CPU cores

### 4. **config/memory-allocation.yml** - RAM Management Strategy

**Purpose**: Memory allocation and optimization for 32GB system
**Contains**:
- **Host allocation**: ProxMox needs 4GB, 25GB available for VMs
- **VM sizes**: Small (2GB), Medium (4GB), Large (8GB)
- **Sample deployment**: Management, Web, Database, Container, Development VMs
- **Optimizations**: KSM, Balloon Driver, Huge Pages

### 5. **config/cpu-optimization.conf** - CPU Performance Tuning

**Purpose**: Intel i5-13420H specific CPU optimizations
**Contains**:
- **CPU Governor**: Set to "performance" mode
- **Intel Features**: VT-x/VT-d enabled for virtualization
- **P-cores vs E-cores**: Performance vs Efficiency core management
- **Kernel parameters**: 13th Gen Intel optimizations
- **Security vs Performance**: Optional security mitigation disabling

### 6. **templates/ubuntu-server.yml** - VM Template Configuration

**Purpose**: Standard Ubuntu Server template for VM deployment
**Contains**:
- **Template ID**: 9000 (ProxMox standard)
- **Resources**: 2 CPU cores, 4GB RAM, 40GB disk
- **CPU Type**: "host" = uses all Intel CPU features
- **Cloud-Init**: Automatic post-deployment configuration
- **Standard packages**: Essential tools (curl, vim, htop)
- **QEMU Guest Agent**: Better ProxMox integration

### 7. **scripts/setup-proxmox.sh** - Installation Script

**Purpose**: Automated ProxMox post-installation configuration
**Contains**:
- **System updates**: Update all packages first
- **Hardware optimizations**: Enable Intel VT-x/VT-d in GRUB
- **Memory settings**: Swappiness, dirty ratios for 32GB system
- **Huge Pages**: 2GB in 2MB pages for better VM performance
- **Network bridges**: VLAN 100 bridge setup
- **Storage setup**: Create directories for VMs, templates, backups

---

## Final Architecture

After installation, your system will have this structure:

```
┌─────────────────────────────────────────────────────────────┐
│                    Intel i5-13420H Server                    │
│                   32GB DDR5 | 1TB NVMe                      │
└─────────────────────────────────────────────────────────────┘
                               │
┌─────────────────────────────────────────────────────────────┐
│                     ProxMox VE Host                          │
│               (4GB RAM Reserved)                              │
├─────────────────────────────────────────────────────────────┤
│  Management Network: 192.168.1.0/24                        │
│  - Web Interface: https://192.168.1.10:8006                │
│  - SSH Access: ssh root@192.168.1.10                       │
└─────────────────────────────────────────────────────────────┘
                               │
           ┌────────────────────┼────────────────────┐
           │                    │                    │
┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐
│   VM Network    │  │Container Network│  │  Local Storage  │
│ 10.0.100.0/24   │  │ 10.0.200.0/24   │  │                 │
│   (VLAN 100)    │  │   (VLAN 200)    │  │ System: 100GB   │
└─────────────────┘  └─────────────────┘  │ VMs: 700GB      │
                                          │ Backup: 100GB   │
                                          │ Templates: 50GB │
                                          └─────────────────┘

VMs on the system:
┌─────────────────┐ ┌─────────────────┐ ┌─────────────────┐
│  Management VM  │ │ Web Services VM │ │  Database VM    │
│     2GB RAM     │ │     4GB RAM     │ │     6GB RAM     │
│   Monitoring    │ │   Nginx/Apache  │ │ PostgreSQL/MySQL│
└─────────────────┘ └─────────────────┘ └─────────────────┘

┌─────────────────┐ ┌─────────────────┐
│Container Host VM│ │ Development VM  │
│     8GB RAM     │ │     4GB RAM     │
│   Docker/LXC    │ │   Dev Tools     │
└─────────────────┘ └─────────────────┘
```

### Network Layout
- **Management**: 192.168.1.0/24 - ProxMox Web Interface access
- **VM Network**: 10.0.100.0/24 - Internal VM communication  
- **Container Network**: 10.0.200.0/24 - Container/LXC isolation

### Resource Distribution
- **ProxMox Host**: 4GB RAM, 2 CPU cores reserved
- **Available for VMs**: 28GB RAM, 10 CPU cores
- **Storage**: 700GB for VM disks, 100GB for backups

---

## Installation Process

### Phase 1: Hardware Preparation

1. **Receive server without OS**
2. **Configure BIOS/UEFI Settings**:
   - Enable Intel VT-x (Virtualization Technology)
   - Enable Intel VT-d (VT for Directed I/O)
   - Disable Secure Boot
   - Enable UEFI Boot mode
   - Set boot priority to USB first

### Phase 2: ProxMox VE Installation

1. **Download ProxMox VE ISO**
   - Visit: https://www.proxmox.com/de/downloads
   - Download latest ProxMox VE ISO

2. **Create bootable USB stick**
   - Use Rufus (Windows) or Etcher (Mac/Linux)
   - Write ISO to USB stick

3. **Boot from USB and start installer**

4. **ProxMox Installation Settings**:
   - **Target Disk**: Your 1TB NVMe SSD
   - **Filesystem**: ZFS (recommended) or ext4
   - **Country**: Germany
   - **Timezone**: Europe/Berlin
   - **Keyboard Layout**: German
   - **IP Address**: 192.168.1.10/24
   - **Gateway**: 192.168.1.1
   - **DNS**: 8.8.8.8
   - **Hostname**: kanal-pve-01.local
   - **Root Password**: Choose secure password
   - **Email**: your-email@domain.com

5. **Complete installation and reboot**

### Phase 3: Post-Installation Setup

After first boot:

1. **Connect via Web Interface**:
   ```
   URL: https://192.168.1.10:8006
   Username: root
   Password: (your chosen password)
   ```

2. **Transfer configuration files to server**:
   ```bash
   # From your local machine
   scp -r kanal/ root@192.168.1.10:/root/
   ```

3. **Execute setup script**:
   ```bash
   # Connect to ProxMox server via SSH
   ssh root@192.168.1.10
   
   # Navigate to project directory
   cd /root/kanal
   
   # Make script executable
   chmod +x scripts/setup-proxmox.sh
   
   # Run setup script
   ./scripts/setup-proxmox.sh
   
   # Reboot for GRUB changes to take effect
   reboot
   ```

### Phase 4: Network Configuration

1. **Create Network Bridges** (via Web Interface):
   - **vmbr0**: Management network (already exists)
   - **vmbr100**: VM Network (VLAN 100)
   - **vmbr200**: Container Network (VLAN 200)

2. **Configure Storage Pools**:
   - **local**: For ISO files and templates
   - **local-lvm**: For VM disk images
   - **Configure backup storage location**

### Phase 5: Create VM Templates

1. **Upload Ubuntu Server ISO**:
   - Download Ubuntu 22.04.3 Server ISO
   - Upload to `local` storage via web interface

2. **Create Template VM** (VM ID 9000):
   ```
   General:
   - VM ID: 9000
   - Name: ubuntu-22.04-server
   
   OS:
   - Use CD/DVD: ubuntu-22.04.3-live-server-amd64.iso
   - Guest OS: Linux 5.x - 2.6 Kernel
   
   System:
   - Machine: q35
   - BIOS: OVMF (UEFI)
   - Add EFI Disk: Yes
   
   Hard Disk:
   - Bus/Device: SCSI 0
   - Storage: local-lvm
   - Size: 40 GB
   
   CPU:
   - Sockets: 1
   - Cores: 2
   - Type: host
   
   Memory:
   - Memory: 4096 MB
   
   Network:
   - Bridge: vmbr100
   - Model: VirtIO
   ```

3. **Install Ubuntu and configure Cloud-Init**
4. **Convert to template** once setup is complete

### Phase 6: Deploy Production VMs

Create VMs based on the template:

| VM Name | RAM | Cores | Disk | Purpose |
|---------|-----|-------|------|---------|
| Management VM | 2GB | 2 | 40GB | Monitoring, Management Tools |
| Web Services VM | 4GB | 2 | 40GB | Nginx, Apache, Web Applications |
| Database VM | 6GB | 2 | 60GB | PostgreSQL, MySQL |
| Container Host VM | 8GB | 4 | 80GB | Docker, LXC Containers |
| Development VM | 4GB | 2 | 40GB | Development Environment |

**Total allocation**: 24GB RAM, 12 CPU cores

### Phase 7: Backup Strategy Implementation

1. **Create Backup Jobs**:
   - Schedule: Daily at 02:00
   - Mode: Snapshot
   - Retention: 7 days
   - Storage: local or external

2. **Test backup and restore procedures**

3. **Configure email notifications** for backup status

### Phase 8: Monitoring Setup

1. **Enable ProxMox built-in monitoring**
2. **Optional**: Install additional monitoring tools in Management VM:
   - Grafana + Prometheus
   - Zabbix
   - Nagios

---

## Installation Timeline

- **Hardware preparation**: 30 minutes
- **ProxMox installation**: 45 minutes
- **Post-installation setup**: 60 minutes
- **Network and storage configuration**: 45 minutes
- **Template creation**: 90 minutes
- **VM deployment**: 60 minutes
- **Backup setup**: 30 minutes
- **Testing and validation**: 60 minutes

**Total estimated time**: 4-6 hours
**Difficulty level**: Intermediate (Linux knowledge helpful)

---

## Required Tools

- **Web browser** for ProxMox web interface
- **SSH client** (PuTTY for Windows, Terminal for Mac/Linux)
- **SCP/SFTP client** for file transfers
- **USB stick** (8GB minimum) for ProxMox installation
- **Network access** to your router/switch

---

## Next Steps After Installation

1. **Security hardening**:
   - Change default SSH port
   - Configure firewall rules
   - Set up SSL certificates

2. **Monitoring implementation**:
   - Deploy monitoring stack
   - Configure alerts
   - Set up log aggregation

3. **Automation**:
   - Create Ansible playbooks
   - Implement Infrastructure as Code
   - Automate VM deployment

4. **Backup testing**:
   - Regular restore testing
   - Offsite backup setup
   - Disaster recovery procedures

---

## Troubleshooting

### Common Issues

**Issue**: Cannot access web interface
- **Solution**: Check IP configuration, firewall settings

**Issue**: VMs won't start
- **Solution**: Verify hardware virtualization is enabled in BIOS

**Issue**: Poor VM performance
- **Solution**: Apply CPU optimization settings from config files

**Issue**: Storage space warnings
- **Solution**: Review storage allocation, implement cleanup policies

### Support Resources

- ProxMox Documentation: https://pve.proxmox.com/pve-docs/
- ProxMox Community Forum: https://forum.proxmox.com/
- ProxMox Wiki: https://pve.proxmox.com/wiki/

---

*This guide is specifically tailored for the Intel i5-13420H hardware configuration with 32GB DDR5 and 1TB NVMe storage.*