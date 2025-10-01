#!/bin/bash
# Cloud-init installation and configuration script

set -euo pipefail

echo "Installing and configuring cloud-init..."

# Update system
dnf update -y

# Install cloud-init and related packages
dnf install -y cloud-init cloud-utils-growpart

# Configure cloud-init for Proxmox
cat > /etc/cloud/cloud.cfg.d/99-proxmox.cfg << 'EOF'
# Proxmox-specific cloud-init configuration
datasource_list: [ NoCloud, ConfigDrive ]
datasource:
  NoCloud:
    fs_label: cidata
EOF

# Configure cloud-init to handle network configuration
cat > /etc/cloud/cloud.cfg.d/99-network-config.cfg << 'EOF'
# Network configuration
network:
  config: enabled
  ethernets:
    eth0:
      dhcp4: true
      dhcp6: false
EOF

# Configure cloud-init user data template
cat > /etc/cloud/cloud.cfg.d/99-user-data.cfg << 'EOF'
# Default user data configuration
users:
  - name: rocky
    sudo: ALL=(ALL) NOPASSWD:ALL
    shell: /bin/bash
    lock_passwd: false
    ssh_authorized_keys: []
  - name: root
    lock_passwd: false
    ssh_authorized_keys: []

# Package update
package_update: true
package_upgrade: true

# Timezone
timezone: America/New_York

# Final message
final_message: "Cloud-init setup completed successfully"
EOF

# Configure cloud-init to preserve hostname
cat > /etc/cloud/cloud.cfg.d/99-preserve-hostname.cfg << 'EOF'
preserve_hostname: false
EOF

# Enable cloud-init services
systemctl enable cloud-init
systemctl enable cloud-init-local
systemctl enable cloud-config
systemctl enable cloud-final

# Configure log rotation for cloud-init
cat > /etc/logrotate.d/cloud-init << 'EOF'
/var/log/cloud-init.log {
    weekly
    rotate 4
    compress
    delaycompress
    missingok
    notifempty
    create 644 root root
}

/var/log/cloud-init-output.log {
    weekly
    rotate 4
    compress
    delaycompress
    missingok
    notifempty
    create 644 root root
}
EOF

# Create cloud-init metadata template
mkdir -p /var/lib/cloud/seed/nocloud
cat > /var/lib/cloud/seed/nocloud/meta-data << 'EOF'
instance-id: rocky-linux-template
local-hostname: rocky-linux-template
EOF

cat > /var/lib/cloud/seed/nocloud/user-data << 'EOF'
#cloud-config
users:
  - name: rocky
    sudo: ALL=(ALL) NOPASSWD:ALL
    shell: /bin/bash
    lock_passwd: false
    ssh_authorized_keys: []

package_update: true
package_upgrade: true

timezone: America/New_York

final_message: "Cloud-init setup completed successfully"
EOF

# Set proper permissions
chmod 600 /var/lib/cloud/seed/nocloud/user-data
chmod 600 /var/lib/cloud/seed/nocloud/meta-data

echo "Cloud-init installation and configuration completed"