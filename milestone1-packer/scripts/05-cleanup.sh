#!/bin/bash
# Cleanup script for Packer build

set -euo pipefail

echo "Starting cleanup process..."

# Clear package cache
dnf clean all

# Clear temporary files
rm -rf /tmp/*
rm -rf /var/tmp/*

# Clear logs
find /var/log -type f -name "*.log" -exec truncate -s 0 {} \;
find /var/log -type f -name "*.log.*" -delete

# Clear cloud-init data
cloud-init clean --logs

# Clear bash history
rm -f /root/.bash_history
rm -f /home/rocky/.bash_history

# Clear SSH host keys (will be regenerated on first boot)
rm -f /etc/ssh/ssh_host_*

# Clear machine ID
rm -f /etc/machine-id
touch /etc/machine-id

# Clear network configuration
rm -f /etc/sysconfig/network-scripts/ifcfg-*

# Clear cloud-init instance data
rm -rf /var/lib/cloud/instances/*

# Clear audit logs
rm -f /var/log/audit/audit.log*

# Clear systemd journal
journalctl --vacuum-time=1s

# Clear package manager history
rm -f /var/lib/dnf/history.sqlite*

# Clear yum cache
rm -rf /var/cache/yum/*

# Clear dnf cache
rm -rf /var/cache/dnf/*

# Clear pip cache
rm -rf /root/.cache/pip/*

# Clear user caches
rm -rf /home/rocky/.cache/*

# Clear temporary systemd files
rm -rf /var/lib/systemd/coredump/*

# Clear crash dumps
rm -rf /var/crash/*

# Clear core dumps
find / -name "core" -type f -delete 2>/dev/null || true

# Clear swap
swapoff -a
dd if=/dev/zero of=/dev/sda3 bs=1M count=1024 2>/dev/null || true

# Clear free space
dd if=/dev/zero of=/tmp/zero bs=1M 2>/dev/null || true
rm -f /tmp/zero

# Set proper permissions
chmod 700 /root
chmod 755 /home/rocky
chmod 700 /home/rocky/.ssh

# Final system update
dnf update -y

echo "Cleanup completed successfully"