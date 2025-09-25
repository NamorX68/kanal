# Storage Optimization Guide for 512GB SSD

## 🚨 Important: Limited Storage Considerations

Your Intel i5-13420H system has a **512GB SSD** instead of 1TB. This requires careful storage management to run your complete FastAPI + N8N + Monitoring infrastructure efficiently.

---

## 💾 Storage Allocation Breakdown

### **Total: 512GB NVMe SSD**

| Component | Allocation | Actual Usage | Notes |
|-----------|------------|--------------|--------|
| ProxMox System | 80GB | ~50GB | Host OS and tools |
| VM Storage | 350GB | ~155GB | All 6 VMs with thin provisioning |
| Backups | 50GB | ~30GB | 3 days retention with compression |
| Templates/ISOs | 20GB | ~10GB | Ubuntu ISO + VM templates |
| Swap/Buffer | 12GB | Variable | System swap and buffer |

**Key Strategy**: **Thin Provisioning** saves ~115GB by allocating space on-demand!

---

## 🖥️ VM Disk Allocation (Thin Provisioned)

| VM | Allocated | Actual Use | Purpose |
|---|---|---|---|
| Management VM | 20GB | ~10GB | Minimal system tools |
| **Web Services VM** | 40GB | ~25GB | FastAPI apps, Python packages |
| **Database VM** | 80GB | ~40GB | PostgreSQL data (monitor growth!) |
| Workflow VM | 30GB | ~20GB | N8N workflows and logs |
| **Monitoring VM** | 60GB | ~35GB | Grafana/Loki logs (grows fast!) |
| Development VM | 40GB | ~25GB | Dev tools, Git repos |

**Total Allocated**: 270GB
**Actual Usage**: ~155GB
**Savings with Thin Provisioning**: 115GB ⚡

---

## ⚠️ Critical Monitoring Points

### **1. Database VM Growth**
```bash
# Monitor PostgreSQL size
sudo -u postgres psql -c "SELECT pg_size_pretty(pg_database_size('api_production'));"
```
- **Watch for**: Rapid data growth
- **Action**: Consider data archiving if >60GB

### **2. Monitoring VM Log Storage**
```bash
# Check Loki log storage
du -sh /opt/loki/data/
```
- **Watch for**: Log files growing >40GB
- **Action**: Implement log rotation and cleanup

### **3. Overall System Usage**
```bash
# Check ProxMox host storage
df -h
pvs && vgs && lvs  # LVM storage overview
```

---

## 🔧 Storage Optimization Strategies

### **1. Backup Optimization**
```yaml
# Optimized backup settings
retention: 3 days          # Instead of 7 days
compression: lzo           # 30-50% space savings
backup_critical_only: true # Skip development VM if needed
```

### **2. Thin Provisioning Best Practices**
```bash
# Enable thin provisioning when creating VMs
qm set <vmid> --scsi0 local-lvm:40,discard=on

# Monitor thin usage
lvs -o +data_percent,metadata_percent
```

### **3. Log Management**
```bash
# Rotate logs aggressively
logrotate -f /etc/logrotate.conf

# Clean old journal logs
journalctl --vacuum-time=7d
```

### **4. Package Cache Cleanup**
```bash
# On each VM, run monthly:
apt autoremove && apt autoclean
pip cache purge  # Python packages
```

---

## 📊 Storage Monitoring Dashboard

### **Disk Usage Alerts**
- ⚠️ **Warning**: 80% usage (410GB)
- 🚨 **Critical**: 90% usage (460GB)

### **Per-VM Monitoring**
```bash
# Check VM disk usage from ProxMox host
qm config <vmid> | grep -i disk
qm monitor <vmid> info block
```

### **Weekly Storage Review**
1. Check overall ProxMox storage: `df -h`
2. Review VM disk growth: `lvs -o +data_percent`
3. Clean up old backups if needed
4. Monitor database and log growth

---

## 🆘 Emergency Procedures

### **When Storage Hits 85%**

**Immediate Actions:**
```bash
# 1. Clean old backups
find /var/lib/vz/dump/ -name "*.vma" -mtime +2 -delete

# 2. Clean logs
journalctl --vacuum-size=1G
find /var/log -name "*.log.*" -mtime +3 -delete

# 3. Clean package caches
apt clean && apt autoremove
```

**Short-term Solutions:**
- Stop Development VM temporarily
- Reduce backup retention to 1 day
- Move large files to external storage

**Long-term Solutions:**
- Add external USB storage for backups
- Implement cloud backup solution
- Consider SSD upgrade to 1TB

---

## 📈 Growth Projections

### **Expected Growth Rates**
- **Database**: 2-5GB/month (depends on usage)
- **Logs (Loki)**: 1-3GB/month
- **Application Data**: 1-2GB/month
- **Development Files**: 2-4GB/month

### **Capacity Planning**
- **6 months**: ~180GB usage (comfortable)
- **12 months**: ~220GB usage (monitor closely)
- **18 months**: May need storage expansion

---

## 🔧 Advanced Optimization

### **1. External Backup Solution**
```bash
# Setup USB backup drive
mkdir /mnt/backup-usb
mount /dev/sdb1 /mnt/backup-usb

# Weekly backup to USB
rsync -av /var/lib/vz/dump/ /mnt/backup-usb/proxmox-backups/
```

### **2. Database Optimization**
```sql
-- PostgreSQL space optimization
VACUUM FULL;
REINDEX DATABASE api_production;

-- Monitor table sizes
SELECT schemaname,tablename,pg_size_pretty(size)
FROM (
  SELECT schemaname,tablename,pg_relation_size(schemaname||'.'||tablename) as size
  FROM pg_tables WHERE schemaname NOT IN ('information_schema','pg_catalog')
) AS TABLES ORDER BY size DESC;
```

### **3. Log Rotation Configuration**
```bash
# /etc/logrotate.d/custom-apps
/opt/api/logs/*.log {
    daily
    rotate 7
    compress
    missingok
    notifempty
    copytruncate
}
```

---

## ✅ Storage Health Checklist

### **Daily (Automated)**
- [ ] Rotate application logs
- [ ] Clean temporary files
- [ ] Monitor critical VMs

### **Weekly (Manual)**
- [ ] Check overall storage usage
- [ ] Review backup sizes
- [ ] Clean package caches
- [ ] Monitor database growth

### **Monthly (Planned)**
- [ ] Full storage review
- [ ] Cleanup old development files
- [ ] Optimize database
- [ ] Plan for growth

---

## 🎯 Key Takeaways

1. **512GB is sufficient** with proper management
2. **Thin provisioning is critical** - saves ~115GB
3. **Monitor database and logs** - they grow fastest
4. **3-day backup retention** balances safety and space
5. **External storage** recommended for long-term backups
6. **Regular cleanup** prevents storage emergencies

**With these optimizations, your 512GB SSD will comfortably run the complete FastAPI + N8N + Monitoring infrastructure!** 🚀