#!/bin/bash
# STIG-compliant partitioning setup script
# This script configures additional disks for STIG-required paths

set -euo pipefail

echo "Starting STIG partitioning setup..."

# Wait for all disks to be available
sleep 10

# Get list of available disks (excluding the main disk sda)
DISKS=($(lsblk -d -n -o NAME | grep -E '^sd[b-f]$' | sort))

if [ ${#DISKS[@]} -lt 5 ]; then
    echo "Error: Expected at least 5 additional disks, found ${#DISKS[@]}"
    lsblk
    exit 1
fi

# Assign disks to STIG paths
TMP_DISK="/dev/${DISKS[0]}"      # /tmp
VAR_DISK="/dev/${DISKS[1]}"      # /var
VAR_LOG_DISK="/dev/${DISKS[2]}"  # /var/log
VAR_LOG_AUDIT_DISK="/dev/${DISKS[3]}"  # /var/log/audit
VAR_TMP_DISK="/dev/${DISKS[4]}"  # /var/tmp

echo "Disk assignments:"
echo "  /tmp: $TMP_DISK"
echo "  /var: $VAR_DISK"
echo "  /var/log: $VAR_LOG_DISK"
echo "  /var/log/audit: $VAR_LOG_AUDIT_DISK"
echo "  /var/tmp: $VAR_TMP_DISK"

# Create filesystems on additional disks
echo "Creating filesystems..."

# /tmp partition
mkfs.xfs -f $TMP_DISK
echo "$TMP_DISK /tmp xfs defaults,nodev,nosuid,noexec 0 0" >> /etc/fstab

# /var partition
mkfs.xfs -f $VAR_DISK
echo "$VAR_DISK /var xfs defaults,nodev 0 0" >> /etc/fstab

# /var/log partition
mkfs.xfs -f $VAR_LOG_DISK
echo "$VAR_LOG_DISK /var/log xfs defaults,nodev,nosuid,noexec 0 0" >> /etc/fstab

# /var/log/audit partition
mkfs.xfs -f $VAR_LOG_AUDIT_DISK
echo "$VAR_LOG_AUDIT_DISK /var/log/audit xfs defaults,nodev,nosuid,noexec 0 0" >> /etc/fstab

# /var/tmp partition
mkfs.xfs -f $VAR_TMP_DISK
echo "$VAR_TMP_DISK /var/tmp xfs defaults,nodev,nosuid,noexec 0 0" >> /etc/fstab

# Create mount points
mkdir -p /tmp /var /var/log /var/log/audit /var/tmp

# Mount the new partitions
mount -a

# Set proper permissions for STIG compliance
chmod 755 /tmp
chmod 755 /var
chmod 755 /var/log
chmod 755 /var/log/audit
chmod 755 /var/tmp

# Set ownership
chown root:root /tmp /var /var/log /var/log/audit /var/tmp

echo "STIG partitioning setup completed successfully"
echo "Current mount status:"
mount | grep -E "(tmp|var)"