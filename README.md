# 🏗️ Kanal Infrastructure

**Transform your Intel i5-13420H into a professional virtualization server!**

Build a complete ProxMox infrastructure that runs 5 virtual machines with automated backups, professional networking, and web-based management - all optimized for your hardware.

---

## 🚀 What You'll Get

After following this guide, you'll have:

- 🖥️ **ProxMox VE Server** - Professional virtualization platform
- 💻 **5 Virtual Machines** - Ready for different projects
- 🌐 **Professional Networking** - VLANs and isolated networks
- 💾 **Automated Backups** - Daily backups with 7-day retention
- 🎛️ **Web Management** - Control everything from any device
- ⚡ **Hardware Optimized** - Tuned for Intel i5-13420H performance

---

## 📋 Your Hardware Setup

- **CPU**: Intel Core i5-13420H (8 cores/12 threads, up to 4.6 GHz)
- **Memory**: 32 GB DDR5-5600 (2x 16GB)
- **Storage**: 512 GB NVMe SSD PCIe 4.0 ⚠️ *Compact but sufficient*
- **Power**: 180W external adapter

**Optimized for efficient virtualization!** ✅

---

## 🎯 Quick Start

### 1. 📖 Read the Complete Guide
**Start here**: [`docs/installation-guide.md`](docs/installation-guide.md)

*This is a comprehensive step-by-step tutorial designed for beginners. It will guide you through everything from BIOS settings to running VMs.*

### 2. 🛠️ What's in This Project

| Folder | What's Inside | When You Use It |
|--------|---------------|-----------------|
| `config/` | Network settings, RAM allocation, hardware specs | During ProxMox configuration |
| `templates/` | Ubuntu Server VM template settings | When creating VMs |
| `scripts/` | Hardware optimization script | After ProxMox installation |
| `docs/` | Complete installation guide | Your main reference |

### 3. ⚡ Installation Overview

1. **Download ProxMox VE ISO** (free)
2. **Configure BIOS** (enable virtualization)
3. **Install ProxMox** on your server
4. **Run optimization script** for your Intel CPU
5. **Create VM template** with Ubuntu
6. **Deploy 6 production VMs** (optimized for 512GB storage)
7. **Configure storage-efficient backups** (3-day retention)

**Total time**: 4-6 hours | **Difficulty**: Beginner-friendly

---

## 🏛️ Final Architecture

After installation, your system will look like this:

```
🖥️ Intel i5-13420H Server (32GB DDR5, 512GB NVMe)
    ↓
🌐 ProxMox VE Host (https://192.168.1.10:8006)
    ↓
┌─────────────────────────────────────────┐
│         Your 5 Virtual Machines        │
├─────────────────────────────────────────┤
│ 📊 Management VM (2GB) - Monitoring    │
│ 🌐 Web Services VM (4GB) - Websites    │
│ 🗄️ Database VM (6GB) - Data storage    │
│ 🐳 Container Host VM (8GB) - Docker    │
│ 🔨 Development VM (4GB) - Coding       │
└─────────────────────────────────────────┘
```

**Resource Usage**: 28GB RAM used, 4GB buffer remaining
**Storage**: 400GB available for VMs (50GB saved with NAS backup!)

---

## 📂 Configuration Files Explained

### 🔧 Hardware & Performance
- `config/hardware-specs.yml` - Your Intel CPU specifications and optimization settings
- `config/cpu-optimization.conf` - Performance tuning for P-cores and E-cores
- `config/memory-allocation.yml` - How to distribute your 32GB RAM

### 🌐 Network & Infrastructure  
- `config/proxmox-config.yml` - Network settings, IP addresses, storage layout
- `templates/ubuntu-server.yml` - VM template optimized for your hardware

### 🚀 Automation
- `scripts/setup-proxmox.sh` - Hardware optimization script (run once after installation)

---

## 🎓 Learning Path

### 👶 **Beginner** (Start Here)
1. Read the complete [`installation-guide.md`](docs/installation-guide.md)
2. Follow each step exactly as written
3. Don't skip the BIOS configuration!

### 🚀 **Intermediate** (After Basic Setup)
- Install Docker on Container Host VM
- Set up web servers on Web Services VM
- Configure databases on Database VM

### 🏆 **Advanced** (Future Projects)
- Implement monitoring with Grafana
- Set up load balancing
- Create additional VM templates
- Implement Infrastructure as Code

---

## ❓ Getting Help

### 🆘 Common Issues
- **Can't access web interface?** → Check network configuration
- **VMs won't start?** → Verify BIOS virtualization settings
- **Slow performance?** → Ensure optimization script was run

### 📚 Resources
- **ProxMox Documentation**: https://pve.proxmox.com/pve-docs/
- **Community Forum**: https://forum.proxmox.com/
- **Our Installation Guide**: [`docs/installation-guide.md`](docs/installation-guide.md)

---

## 🎉 Ready to Start?

**➡️ Begin with the [Complete Installation Guide](docs/installation-guide.md)**

This guide will take you from zero to a fully functional virtualization infrastructure. Every step is explained for beginners, with exact values from your configuration files.

---

*Built for Intel i5-13420H • Optimized for 32GB DDR5 • Ready for production*