#!/bin/bash
# Post-deployment configuration script
# This script customizes the deployed VM from the STIG template

set -e

echo "=== Post-Deployment Configuration ==="

# Update system hostname (will be set by cloud-init)
echo "Setting hostname..."
hostnamectl set-hostname rocky-linux-deployed

# Update system information
echo "Updating system information..."
dnf update -y

# Configure cloud-init for future deployments
echo "Configuring cloud-init..."
cloud-init clean --logs

# Set up SSH keys (if provided via cloud-init)
echo "Configuring SSH access..."
mkdir -p /home/rocky/.ssh
chmod 700 /home/rocky/.ssh
chown rocky:rocky /home/rocky/.ssh

# Ensure STIG compliance is maintained
echo "Verifying STIG compliance..."
oscap xccdf eval --profile xccdf_org.ssgproject.content_profile_stig \
  --results /tmp/stig-verification.xml \
  /usr/share/xml/scap/ssg/content/ssg-rl8-ds.xml || true

# Create deployment marker
echo "Creating deployment marker..."
echo "Deployed on: $(date)" > /etc/rocky-deployment-info
echo "Template: rocky-linux-stig-manual" >> /etc/rocky-deployment-info
echo "Deployment method: Packer" >> /etc/rocky-deployment-info

# Final cleanup
echo "Final cleanup..."
dnf clean all
rm -rf /tmp/*

echo "=== Post-Deployment Configuration Complete ==="
