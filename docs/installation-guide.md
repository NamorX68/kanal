# Kanal Infrastructure - Step-by-Step Beginner's Guide

## 🚀 What You'll Build

You'll create a professional virtualization server using ProxMox that can run multiple virtual machines (VMs) on your Intel i5-13420H hardware. Think of it as one powerful computer that acts like many smaller computers.

**What you'll have at the end:**
- 1 ProxMox host managing everything
- 5 virtual machines for different purposes
- Professional networking with VLANs
- Automated backups
- Web-based management interface

---

## 📋 Before You Start - What You Need

### Physical Requirements
- ✅ Your Intel i5-13420H server (32GB RAM, 1TB SSD)
- ✅ Network cable (Ethernet)
- ✅ USB stick (8GB or larger)
- ✅ Another computer to download files and access web interface
- ✅ Access to your router/network

### Software You'll Download
- ✅ ProxMox VE ISO (free)
- ✅ Ubuntu Server ISO (free)
- ✅ Rufus (Windows) or Etcher (Mac/Linux) for USB creation

### Time Required
- ⏱️ **Total time**: 4-6 hours (can be done over multiple days)
- ⏱️ **Active time**: 2-3 hours (rest is waiting for installations)

---

## 📚 Understanding Your Config Files (Don't Skip This!)

Before we start, let's understand what each config file does. These files are your "blueprint" - they tell you exactly what settings to use where.

### 📄 Your Blueprint Files

| File | What It Does | When You'll Use It |
|------|-------------|-------------------|
| `config/proxmox-config.yml` | Network settings, IP addresses, storage layout | Setting up networks and storage |
| `config/memory-allocation.yml` | How much RAM each VM gets | Creating VMs |
| `templates/ubuntu-server.yml` | VM template settings | Creating the Ubuntu template |
| `scripts/setup-proxmox.sh` | Hardware optimizations | After ProxMox installation |

**💡 Think of these as your instruction manual - they tell you exactly what numbers to enter where!**

---

# 🚀 STEP-BY-STEP INSTALLATION

## Step 1: Prepare Your Hardware

### 1.1 Configure BIOS/UEFI (CRITICAL - Don't Skip!)

**Why**: Without these settings, virtualization won't work.

1. **Power on your server** and press **F2** or **Delete** during boot to enter BIOS
2. **Find these settings** (names vary by manufacturer):

| Setting to Find | Set to | Why |
|----------------|--------|----- |
| Intel VT-x or Virtualization Technology | **Enabled** | Allows VMs to run |
| Intel VT-d or VT for Directed I/O | **Enabled** | Better VM performance |
| Secure Boot | **Disabled** | ProxMox needs this off |
| Boot Mode | **UEFI** | Modern boot method |
| USB Boot Priority | **First** | To boot from USB stick |

3. **Save and Exit** (usually F10)

### 1.2 Connect Network Cable
- Plug Ethernet cable into your server
- Connect other end to your router/switch
- **Note**: You'll need internet during installation

---

## Step 2: Download and Prepare ProxMox

### 2.1 Download ProxMox VE ISO

1. **Go to**: https://www.proxmox.com/de/downloads
2. **Click**: "ProxMox Virtual Environment" 
3. **Download**: Latest version (around 1GB file)
4. **Save** to your Downloads folder

### 2.2 Create Bootable USB Stick

**Windows Users:**
1. **Download Rufus**: https://rufus.ie/
2. **Insert USB stick** (8GB+) - **ALL DATA WILL BE DELETED**
3. **Open Rufus**:
   - Device: Your USB stick
   - Boot selection: Click SELECT → Choose ProxMox ISO
   - Partition scheme: MBR
   - Target system: BIOS or UEFI
4. **Click START** and wait

**Mac/Linux Users:**
1. **Download Etcher**: https://www.balena.io/etcher/
2. **Follow same process** as Rufus

---

## Step 3: Install ProxMox VE

### 3.1 Boot from USB

1. **Insert USB stick** into your server
2. **Power on** and it should boot from USB
3. **If not booting from USB**: Restart and press F12/F11 to select boot device

### 3.2 ProxMox Installation Screen

**You'll see ProxMox boot menu:**
1. **Select**: "Install ProxMox VE"
2. **Press Enter**
3. **Wait** for boot process (1-2 minutes)

### 3.3 Installation Wizard

**Screen 1: License Agreement**
- **Click**: "I agree"

**Screen 2: Target Disk Selection**
- **Select**: Your 1TB NVMe SSD (should be only option)
- **Filesystem**: Select **ZFS (RAID0)** (recommended) or **ext4** (simpler)
- **Click**: "Next"

**Screen 3: Location and Time Zone**
- **Country**: Germany
- **Time zone**: Europe/Berlin  
- **Keyboard Layout**: German (or your preference)
- **Click**: "Next"

**Screen 4: Administration Password**
- **Password**: Choose a STRONG password (you'll need this often!)
- **Confirm Password**: Enter same password
- **Email**: your-email@domain.com (for alerts)
- **Click**: "Next"

**Screen 5: Network Configuration** 🚨 **IMPORTANT - Use Your Config File**

*Open `config/proxmox-config.yml` and find these values:*

- **Management Interface**: Should auto-detect your network card
- **Hostname**: `kanal-pve-01.local`
- **IP Address**: `192.168.1.10/24` 
- **Gateway**: `192.168.1.1` (your router IP)
- **DNS Server**: `8.8.8.8`

💡 **If you don't know your router IP**: Usually 192.168.1.1 or 192.168.0.1

**Screen 6: Summary**
- **Review all settings**
- **Click**: "Install"

### 3.4 Wait for Installation
- **Time**: 10-20 minutes
- **Don't touch anything** - let it complete
- **When done**: System will reboot automatically

---

## Step 4: First Login and Basic Setup

### 4.1 Access Web Interface

1. **Remove USB stick** from server
2. **Wait for server to boot** (2-3 minutes)
3. **On another computer**, open web browser
4. **Go to**: `https://192.168.1.10:8006`
5. **Accept SSL warning** (it's normal for first time)

### 4.2 Login to ProxMox

**Login Screen:**
- **User name**: `root`
- **Password**: (the password you set during installation)
- **Realm**: `Linux PAM standard authentication`
- **Language**: English (or German)
- **Click**: "Login"

### 4.3 Dismiss First-Time Messages

**You'll see popup about "No valid subscription"**
- **Just click "OK"** - this is normal for free version
- **Another popup about updates** - click "OK"

**🎉 Congratulations! ProxMox is installed and running!**

---

## Step 5: Apply Hardware Optimizations

### 5.1 Upload Config Files to ProxMox

**Option A: Use Web Interface**
1. **In ProxMox**: Click your node name (`kanal-pve-01`)
2. **Go to**: `Shell` (in the menu)
3. **Type**: `mkdir /root/kanal`
4. **Press Enter**

**Option B: Use SCP (if you know how)**
```bash
scp -r kanal/ root@192.168.1.10:/root/
```

### 5.2 Run Hardware Optimization Script

**In ProxMox Shell (web interface):**

1. **Copy the script content** from `scripts/setup-proxmox.sh`
2. **Create the script**:
   ```bash
   nano /root/setup-proxmox.sh
   ```
3. **Paste the content** (Ctrl+V)
4. **Save and exit** (Ctrl+X, then Y, then Enter)
5. **Make executable**:
   ```bash
   chmod +x /root/setup-proxmox.sh
   ```
6. **Run the script**:
   ```bash
   ./root/setup-proxmox.sh
   ```
7. **Reboot when done**:
   ```bash
   reboot
   ```

**Wait 2-3 minutes for reboot, then login again to web interface.**

---

## Step 6: Configure Networks

### 6.1 Understand Your Network Plan

*Reference: `config/proxmox-config.yml`*

**You'll create 3 networks:**
- **vmbr0**: Management (192.168.1.0/24) - Already exists
- **vmbr100**: VMs (10.0.100.0/24) - We'll create this  
- **vmbr200**: Containers (10.0.200.0/24) - We'll create this

### 6.2 Create VM Network Bridge (vmbr100)

**In ProxMox Web Interface:**

1. **Click**: Your server name (`kanal-pve-01`)
2. **Go to**: `System` → `Network`
3. **Click**: "Create" → "Linux Bridge"
4. **Fill in these values**:

| Field | Value | From Config File |
|-------|-------|------------------|
| Name | `vmbr100` | proxmox-config.yml |
| IPv4/CIDR | `10.0.100.1/24` | vm_networks section |
| Comment | `VM Network VLAN 100` | Description |

5. **Click**: "Create"

### 6.3 Create Container Network Bridge (vmbr200)

**Repeat same process:**

1. **Click**: "Create" → "Linux Bridge"
2. **Fill in**:

| Field | Value |
|-------|----- |
| Name | `vmbr200` |
| IPv4/CIDR | `10.0.200.1/24` |
| Comment | `Container Network VLAN 200` |

3. **Click**: "Create"

### 6.4 Apply Network Configuration

1. **Click**: "Apply Configuration" button
2. **Confirm**: "Yes" to apply changes
3. **Wait**: 30 seconds for networks to activate

**📶 Your networks are now ready for VMs!**

---

## Step 7: Prepare Storage

### 7.1 Check Current Storage

**In ProxMox Web Interface:**

1. **Go to**: `Datacenter` → `Storage`
2. **You should see**:
   - **local**: For ISO files and templates
   - **local-lvm**: For VM disk images

**This is automatically configured during installation - no changes needed!**

### 7.2 Understanding Storage Layout

*Reference: `config/proxmox-config.yml` storage section*

**Your 1TB SSD is divided like this:**
- System: ~100GB (ProxMox itself)
- VM Storage: ~700GB (VM disk images)  
- Available for backups/templates: ~200GB

**📦 Storage is ready - no action needed!**

---

## Step 8: Download Ubuntu Server ISO

### 8.1 Download Ubuntu ISO

**On your other computer:**
1. **Go to**: https://ubuntu.com/download/server
2. **Download**: Ubuntu 22.04.3 LTS Server
3. **File size**: About 1.5GB

### 8.2 Upload to ProxMox

**In ProxMox Web Interface:**

1. **Go to**: `Datacenter` → `kanal-pve-01` → `local` storage
2. **Click**: "Upload" button
3. **Select**: "ISO Image"
4. **Click**: "Select File" → Choose your Ubuntu ISO
5. **Click**: "Upload"
6. **Wait**: 5-10 minutes for upload

**💿 Ubuntu ISO is now ready for VM installation!**

---

## Step 9: Create Ubuntu Template VM

### 9.1 Create New VM

**Click "Create VM" button (top right)**

**General Tab:**

*Reference: `templates/ubuntu-server.yml`*

| Field | Value | Why |
|-------|-------|----- |
| VM ID | `9000` | Standard for templates |
| Name | `ubuntu-22.04-server` | Template name |
| Resource Pool | (leave empty) | Not needed |

**OS Tab:**

| Field | Value |
|-------|----- |
| Use CD/DVD | **Checked** |
| Storage | `local` |
| ISO image | `ubuntu-22.04.3-live-server-amd64.iso` |
| Guest OS Type | `Linux` |
| Version | `5.x - 2.6 Kernel` |

**System Tab:**

| Field | Value | Why |
|-------|-------|----- |
| Machine | `q35` | Modern machine type |
| BIOS | `OVMF (UEFI)` | Modern boot |
| Add EFI Disk | **Checked** | Needed for UEFI |
| EFI Storage | `local-lvm` | Where to store EFI |
| SCSI Controller | `VirtIO SCSI single` | Best performance |
| Qemu Agent | **Checked** | Better integration |

**Hard Disk Tab:**

*Reference: `templates/ubuntu-server.yml` resources section*

| Field | Value |
|-------|----- |
| Bus/Device | `SCSI 0` |
| Storage | `local-lvm` |
| Disk size (GiB) | `40` |
| Cache | `Write back` |
| Discard | **Checked** |

**CPU Tab:**

*Reference: `templates/ubuntu-server.yml` resources section*

| Field | Value | Why |
|-------|-------|----- |
| Sockets | `1` | One CPU socket |
| Cores | `2` | Two CPU cores |
| Type | `host` | Use all CPU features |
| Enable NUMA | **Checked** | Better performance |

**Memory Tab:**

| Field | Value |
|-------|----- |
| Memory (MiB) | `4096` |
| Ballooning Device | **Checked** |

**Network Tab:**

| Field | Value |
|-------|----- |
| Bridge | `vmbr100` |
| Model | `VirtIO (paravirtualized)` |
| Firewall | **Unchecked** |

**Confirm Tab:**
- **Review settings**
- **Uncheck "Start after created"**
- **Click "Finish"**

### 9.2 Install Ubuntu on Template VM

**Start the VM:**
1. **Click** your new VM (ID 9000)
2. **Click** "Start"
3. **Click** "Console" to see the screen

**Ubuntu Installation:**
1. **Select** "Try or Install Ubuntu Server"
2. **Language**: English (or your preference)
3. **Keyboard**: German (or your preference)
4. **Network**: Should auto-configure via DHCP
5. **Proxy**: Leave empty
6. **Mirror**: Use default
7. **Storage**: Use entire disk (40GB)
8. **Profile Setup**:
   - Your name: `Administrator`
   - Server name: `ubuntu-template`
   - Username: `admin`
   - Password: Choose secure password
9. **SSH Setup**: 
   - **Check** "Install OpenSSH server"
   - Import keys: Skip
10. **Snaps**: Don't select any (we'll add later)
11. **Installation**: Wait 10-15 minutes

**When installation completes:**
1. **Click** "Reboot Now"
2. **Wait** for reboot
3. **Login** with username `admin` and your password

### 9.3 Configure Template VM

**In the VM console, run these commands:**

```bash
# Update system
sudo apt update && sudo apt upgrade -y

# Install essential packages
sudo apt install -y qemu-guest-agent curl wget vim htop

# Enable QEMU guest agent
sudo systemctl enable qemu-guest-agent
sudo systemctl start qemu-guest-agent

# Clean up for template
sudo apt autoremove -y
sudo apt autoclean
sudo cloud-init clean
sudo rm -rf /var/lib/cloud/instances
sudo rm /etc/machine-id
sudo touch /etc/machine-id

# Shutdown VM
sudo shutdown -h now
```

### 9.4 Convert to Template

**In ProxMox Web Interface:**
1. **Wait** for VM to shutdown completely
2. **Right-click** VM 9000
3. **Select** "Convert to template"
4. **Confirm** "Yes"

**🎆 Template created! Now you can create VMs from this template.**

---

## Step 10: Create Production VMs

### 10.1 Plan Your VMs

*Reference: `config/memory-allocation.yml` sample_deployment section*

**You'll create 5 VMs:**

| VM Name | VM ID | RAM | Cores | Purpose |
|---------|-------|-----|-------|--------|
| Management VM | 101 | 2GB | 2 | Monitoring, Management |
| Web Services VM | 102 | 4GB | 2 | Web servers, APIs |
| Database VM | 103 | 6GB | 2 | PostgreSQL, MySQL |
| Container Host VM | 104 | 8GB | 4 | Docker containers |
| Development VM | 105 | 4GB | 2 | Development work |

**Total**: 24GB RAM used of 28GB available (4GB buffer)

### 10.2 Clone VMs from Template

**For each VM, do this:**

1. **Right-click** template VM (ID 9000)
2. **Select** "Clone"
3. **Fill in**:

**For Management VM (first one):**
| Field | Value |
|-------|----- |
| VM ID | `101` |
| Name | `management-vm` |
| Mode | `Full Clone` |
| Storage | `local-lvm` |

4. **Click** "Clone"
5. **Wait** for cloning (2-3 minutes)

**Repeat for all 5 VMs with their respective IDs and names.**

### 10.3 Configure Each VM's Resources

**For each cloned VM:**

1. **Click** the VM
2. **Go to** "Hardware" tab
3. **Double-click** "Memory"
4. **Set memory** according to your plan:
   - Management VM: 2048 MB
   - Web Services VM: 4096 MB
   - Database VM: 6144 MB
   - Container Host VM: 8192 MB
   - Development VM: 4096 MB
5. **Click** "OK"

**For Container Host VM only (needs 4 CPU cores):**
1. **Double-click** "Processors"
2. **Set Cores** to `4`
3. **Click** "OK"

### 10.4 Start Your VMs

**Start VMs one by one:**
1. **Select** a VM
2. **Click** "Start"
3. **Click** "Console" to see boot process
4. **Login** with `admin` and your password

**🎉 All VMs are running! You have a complete virtualization infrastructure!**

---

## Step 11: Set Up Backups

### 11.1 Create Backup Job

**In ProxMox Web Interface:**

1. **Go to** `Datacenter` → `Backup`
2. **Click** "Add" to create backup job
3. **Configure**:

*Reference: `config/proxmox-config.yml` backup section*

| Field | Value | Why |
|-------|-------|----- |
| Storage | `local` | Where to store backups |
| Schedule | `02:00` | Daily at 2 AM |
| Day of week | `*` | Every day |
| Selection mode | `Include selected VMs` | Choose what to backup |
| VMs | Select all your VMs | Backup everything |
| Retention | `Keep Last` = `7` | Keep 7 days of backups |
| Compression | `LZO (fast)` | Good balance |
| Mode | `Snapshot` | Backup running VMs |

4. **Click** "Create"

### 11.2 Test Backup

**Run a test backup:**
1. **Select** your backup job
2. **Click** "Run now"
3. **Check** "View Task Log" to monitor
4. **Wait** for completion (10-30 minutes)

**💾 Automated backups are now configured!**

---

# 🎆 You Did It! What You've Built

After installation, your system looks like this:

```
💻 Intel i5-13420H Server (32GB DDR5, 1TB NVMe)
         │
🛜 ProxMox VE Host (Web: https://192.168.1.10:8006)
         │
    ┌────┼────┐
    │    │    │
 🌐 Networks  💾 Storage  📺 Virtual Machines
    │         │         │
vmbr0 🏠    💽 System    📊 Management VM (2GB)
vmbr100 🛜  💾 VM Data   🌐 Web Services VM (4GB)  
vmbr200 🛜  🔄 Backups   🗄 Database VM (6GB)
              📁 Templates  🛜 Container Host VM (8GB)
                        🔧 Development VM (4GB)
```

## 🎉 What You Can Do Now

### Access Everything
- **ProxMox Web Interface**: https://192.168.1.10:8006
- **SSH to VMs**: `ssh admin@VM-IP`
- **VM Consoles**: Through ProxMox web interface

### Your Professional Infrastructure Includes
- ✅ **5 Virtual Machines** ready for different purposes
- ✅ **Automated daily backups** 
- ✅ **Professional networking** with VLANs
- ✅ **Hardware optimization** for your Intel CPU
- ✅ **Web-based management** from any device
- ✅ **Template system** for quick VM deployment

### Resource Usage
- **RAM**: 24GB used, 4GB available (perfect buffer)
- **Storage**: ~300GB used, 700GB available
- **CPU**: Optimized for Intel i5-13420H P-cores and E-cores

---

## 🚑 Next Steps (Optional)

Now that your infrastructure is running, you could:

### Immediate Next Steps
1. **Install software** on your VMs (web servers, databases, etc.)
2. **Set up SSH keys** for secure access
3. **Configure firewalls** on each VM
4. **Test your backups** by restoring a VM

### Advanced Projects  
1. **Install Docker** on Container Host VM
2. **Set up monitoring** with Grafana on Management VM
3. **Create additional templates** (CentOS, Debian, etc.)
4. **Implement SSL certificates** for secure access

### Learning Resources
- **ProxMox Documentation**: https://pve.proxmox.com/pve-docs/
- **ProxMox Community**: https://forum.proxmox.com/
- **YouTube Tutorials**: Search "ProxMox beginner tutorials"

---

## 🆘 Help & Troubleshooting

### Common Issues

**⚠️ Can't access web interface**
- Check: Is server powered on?
- Check: Network cable connected?
- Try: Different browser or incognito mode
- Try: https://192.168.1.10:8006 (with https://)

**⚠️ VMs won't start**  
- Check: Hardware virtualization enabled in BIOS?
- Check: Enough free RAM available?
- Check: VM configuration correct?

**⚠️ Slow performance**
- Check: Hardware optimization script was run?
- Check: VM has QEMU guest agent installed?
- Check: Not over-allocating resources?

### Getting Help
- **Config files issues**: Check your YAML files for typos
- **ProxMox issues**: ProxMox community forum
- **VM issues**: Ubuntu community resources
- **Network issues**: Check router/switch configuration

---

**🎆 Congratulations! You've built a professional virtualization infrastructure!** 

You now have the foundation for hosting websites, databases, development environments, and much more. This setup can grow with your needs and will serve you well for years to come.

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