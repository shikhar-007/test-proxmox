# Quick Reference: Manual STIG Template Creation

## VM Settings Summary

### Proxmox VM Configuration
- **VM ID:** 108 (or next available)
- **Name:** rocky-linux-stig-manual
- **OS:** Linux 6.x - 2.6 Kernel
- **BIOS:** SeaBIOS
- **Machine:** pc
- **Qemu Agent:** ✅ Enable

### Hardware Configuration
- **CPU:** 2 cores, Type: host
- **Memory:** 2048 MB
- **Main Disk:** 20GB (SCSI, Write back, Discard, SSD emulation)
- **Additional Disks:**
  - sdb: 2GB for /tmp
  - sdc: 5GB for /var
  - sdd: 2GB for /var/log
  - sde: 1GB for /var/log/audit
  - sdf: 1GB for /var/tmp

### Network Configuration
- **Bridge:** vmbr0
- **Model:** VirtIO
- **Firewall:** ✅ Enable

## Installation Summary

### Partitioning
```
sda1: /boot/efi    - 512MB  - EFI
sda2: /boot        - 1GB    - xfs
sda3: swap         - 2GB    - swap
sda4: /            - 16.5GB - xfs
sdb:  /tmp         - 2GB    - xfs (nodev,nosuid,noexec)
sdc:  /var         - 5GB    - xfs (nodev)
sdd:  /var/log     - 2GB    - xfs (nodev,nosuid,noexec)
sde:  /var/log/audit - 1GB - xfs (nodev,nosuid,noexec)
sdf:  /var/tmp     - 1GB    - xfs (nodev,nosuid,noexec)
```

### User Configuration
- **Root Password:** RootPassword123!
- **User:** rocky
- **User Password:** RockyLinux123!
- **Administrator:** ✅ Enable

## Key Commands

### Essential Package Installation
```bash
sudo dnf install -y openscap-scanner scap-security-guide rsyslog audit cloud-init cloud-utils-growpart firewalld chrony dnf-automatic
```

### SSH Hardening
```bash
sudo sed -i 's/#PermitRootLogin yes/PermitRootLogin no/' /etc/ssh/sshd_config
sudo systemctl restart sshd
```

### Audit Configuration
```bash
sudo systemctl enable auditd
sudo systemctl start auditd
```

### Firewall Configuration
```bash
sudo systemctl enable firewalld
sudo systemctl start firewalld
sudo firewall-cmd --permanent --add-service=ssh
sudo firewall-cmd --reload
```

### SELinux Configuration
```bash
sudo setenforce 1
sudo sed -i 's/^SELINUX=.*/SELINUX=enforcing/' /etc/selinux/config
```

## Verification Commands

### Check Partitioning
```bash
lsblk
mount | grep -E "(tmp|var)"
```

### Check Services
```bash
sudo systemctl status sshd auditd firewalld chronyd
```

### Check STIG Compliance
```bash
sudo oscap xccdf eval --profile xccdf_org.ssgproject.content_profile_stig /usr/share/xml/scap/ssg/content/ssg-rocky9-ds.xml
```

## Template Conversion

### Cleanup Before Template
```bash
sudo dnf clean all
sudo rm -rf /tmp/* /var/tmp/*
sudo cloud-init clean --logs
sudo rm -f /etc/ssh/ssh_host_*
sudo rm -f /etc/machine-id
sudo touch /etc/machine-id
sudo shutdown -h now
```

### In Proxmox
1. Right-click VM → "Convert to template"
2. Confirm conversion

## Testing Template

### Clone and Test
1. Right-click template → "Clone"
2. Configure Cloud-Init
3. Start VM
4. SSH test: `ssh rocky@<VM_IP>`

## Troubleshooting

### Common Issues
- **VM won't start:** Check console, verify ISO
- **SSH fails:** Check service status, firewall
- **STIG issues:** Run OpenSCAP scan

### Useful Commands
```bash
# Check system status
sudo systemctl status sshd auditd firewalld

# Check logs
sudo journalctl -u sshd
sudo ausearch -m avc

# Check network
ip addr show
sudo firewall-cmd --list-all
```

