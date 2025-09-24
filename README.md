# Kanal Infrastructure

ProxMox-based infrastructure setup and management for the Kanal project.

## Project Structure

```
kanal/
├── config/           # Infrastructure configuration files
├── templates/        # VM and container templates
├── scripts/         # Setup and management scripts
├── docs/           # Documentation
└── README.md       # This file
```

## Quick Start

1. **Initial Setup**
   ```bash
   chmod +x scripts/setup-proxmox.sh
   sudo ./scripts/setup-proxmox.sh
   ```

2. **Configuration**
   - Edit `config/proxmox-config.yml` for your environment
   - Customize VM templates in `templates/`

3. **Network Configuration**
   - Management network: 192.168.1.0/24
   - VM network: 10.0.100.0/24 (VLAN 100)
   - Container network: 10.0.200.0/24 (VLAN 200)

## Components

- **ProxMox Cluster**: Primary infrastructure virtualization platform
- **Network Bridges**: Isolated networks for different workloads
- **VM Templates**: Pre-configured Ubuntu Server templates
- **Backup Strategy**: Daily backups with 7-day retention

## Hardware Specifications

- **CPU**: Intel Core i5-13420H (8 cores/12 threads, up to 4.6 GHz)
- **Memory**: 32 GB DDR5-5600 (2x 16GB)
- **Storage**: 1 TB NVMe SSD PCIe 4.0
- **Power**: 180W external adapter

## Resource Allocation

- **Host Reserved**: 4 GB RAM, 2 CPU cores
- **VM Available**: 28 GB RAM, 10 CPU cores
- **Storage Layout**: 
  - System: 100 GB
  - VMs: 700 GB  
  - Backups: 100 GB
  - Templates: 50 GB
  - Reserved: 50 GB

## Next Steps

- Install ProxMox VE on hardware
- Configure storage backend
- Set up monitoring and alerting
- Deploy initial VMs using templates