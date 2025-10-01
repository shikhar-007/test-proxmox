# Terraform Deployment Automation

This directory contains Terraform configurations for automated deployment of VMs from the STIG-compliant Rocky Linux golden image template.

## Overview

The Terraform automation provides a complete solution for deploying production-ready VMs on Proxmox VE. All deployments are automated through infrastructure-as-code, eliminating manual configuration steps while maintaining security compliance.

## What This Does

- **Template-Based Deployment**: Clones VMs from your STIG-compliant Template 108
- **Cloud-Init Integration**: Automatically configures hostname, networking, and SSH access
- **Disk Management**: Handles automatic disk resizing on first boot
- **Post-Deployment Verification**: Runs Ansible tests to confirm functionality
- **Multi-Instance Support**: Deploy single VMs or multiple instances in parallel

## Directory Structure

```
milestone3-terraform/
├── main.tf                    # Main Terraform configuration
├── variables.tf               # Variable definitions
├── outputs.tf                 # Output definitions
├── terraform.tfvars.example   # Example configuration file
├── deploy.sh                  # Interactive deployment script
├── playbooks/                 # Post-deployment verification
│   └── verify.yml            # Ansible connectivity test
├── templates/                 # Configuration templates
│   └── ansible_inventory.tpl # Ansible inventory generator
└── examples/                  # Example deployments
    ├── single-vm/            # Single VM example
    └── multi-vm/             # Multiple VM example
```

## Quick Start

### Prerequisites

Before you begin, ensure you have:

- Terraform 1.0.0 or later installed
- Ansible 2.9+ (for post-deployment verification)
- Network access to your Proxmox cluster
- Valid Proxmox API credentials
- Existing STIG template (VM 108: rocky-linux-stig-manual)

### Interactive Deployment (Recommended)

The easiest way to deploy is using the interactive script:

```bash
# Run the deployment script
./deploy.sh
```

The script will prompt you for:
- Proxmox node name
- VM name
- VM ID (or 0 for auto-assignment)
- Number of VMs to deploy

### Manual Deployment

If you prefer manual control:

```bash
# Initialize Terraform
terraform init

# Create your configuration
cp terraform.tfvars.example terraform.tfvars
nano terraform.tfvars  # Edit with your settings

# Review the deployment plan
terraform plan

# Deploy the infrastructure
terraform apply

# Connect to your new VM
ssh rocky@<vm-ip>
```

### Deploy Multiple VMs

For deploying several VMs at once:

```bash
cd examples/multi-vm
terraform init
terraform apply

# All VMs deploy in parallel for faster provisioning
```

## Configuration

### Required Variables

You must provide these values in your `terraform.tfvars` file:

```hcl
# Proxmox Connection
proxmox_url      = "https://YOUR_PROXMOX_IP:8006/api2/json"
proxmox_username = "root@pam"
proxmox_password = "YOUR_SECURE_PASSWORD"
proxmox_node     = "your-node-name"

# Template Configuration
template_name = "rocky-linux-stig-manual"

# Cloud-Init User Password
cloud_init_password = "YOUR_STRONG_PASSWORD"  # Minimum 15 characters
```

### Optional Variables

Customize your deployment with these options:

```hcl
# VM Configuration
vm_count       = 3             # How many VMs to deploy
vm_name_prefix = "app-server"  # Prefix for VM names
vm_id_start    = 200           # Starting VM ID

# Hardware Resources
cpu_cores = 4                  # CPU cores per VM
memory    = 4096               # RAM in MB

# Disk Configuration
disk_size_root = "50G"         # Root disk size

# Network Settings
vlan_tag  = "69"               # VLAN tag for network segmentation
use_dhcp  = true               # Use DHCP or static IP

# Post-Deployment
run_ansible_verification = true  # Run Ansible tests after deployment
```

## Key Features

### Template-Based Deployment

VMs are cloned from your existing STIG-compliant template, which means:
- All security hardening is preserved
- Consistent baseline across all deployments  
- Fast provisioning (2-3 minutes per VM)
- No need to repeat STIG compliance work

### Cloud-Init Customization

Each VM is automatically configured with:
- Unique hostname assignment
- Network configuration (static IP or DHCP)
- SSH key injection for secure access
- Custom user data for additional setup

### Automatic Disk Resizing

The disk expansion happens automatically on first boot:
- Grows disk to your specified size
- Expands all filesystems appropriately
- Maintains STIG-compliant partitioning layout
- No manual intervention required

### Post-Deployment Verification

After deployment, Ansible automatically:
- Tests SSH connectivity to each VM
- Verifies basic service functionality
- Creates a test file: `/tmp/ansible_deployed_test.txt`
- Validates STIG compliance is maintained

### Multi-Instance Support

Deploy multiple VMs efficiently:
- Parallel deployment for faster provisioning
- Sequential VM ID assignment
- Auto-generated VM names
- Bulk operations support

## Deployment Examples

### Example 1: Single Web Server

```hcl
vm_name       = "web-server-01"
vm_id_start   = 200
cpu_cores     = 2
memory        = 2048
disk_size_root = "20G"
```

### Example 2: Multiple Application Servers

```hcl
vm_name_prefix = "app-server"
vm_count       = 3
vm_id_start    = 210
cpu_cores      = 4
memory         = 4096
disk_size_root = "50G"
```

### Example 3: Static IP Configuration

```hcl
use_dhcp        = false
vm_ip_addresses = ["192.168.0.100", "192.168.0.101", "192.168.0.102"]
vm_ip_netmask   = "24"
vm_gateway      = "192.168.0.1"
```

## Deployment Workflow

### 1. Plan Your Infrastructure

```bash
# Initialize Terraform (first time only)
terraform init

# See what Terraform will create
terraform plan -out=tfplan
```

Review the plan carefully to ensure it matches your expectations.

### 2. Deploy the Infrastructure

```bash
# Apply the planned changes
terraform apply tfplan
```

Terraform will show progress as it creates your VMs.

### 3. Verify the Deployment

```bash
# Check the deployed VM IP addresses
terraform output vm_ip_addresses

# SSH to your new VM
ssh rocky@<vm-ip>

# Verify the Ansible test file was created
cat /tmp/ansible_deployed_test.txt
```

### 4. Cleanup (When Needed)

```bash
# Remove all deployed resources
terraform destroy
```

## Outputs

Terraform provides several useful outputs after deployment:

### VM Information
- `vm_ids` - List of assigned VM IDs
- `vm_names` - List of VM names
- `vm_ip_addresses` - IP addresses for SSH access
- `ssh_commands` - Ready-to-use SSH commands

### Ansible Integration
- `ansible_inventory` - Ansible inventory entries
- `ansible_inventory_file` - Path to generated inventory file

### Deployment Summary
- `deployment_summary` - Complete deployment information
- `vm_details` - Detailed specifications for each VM

## Performance Metrics

### Deployment Speed

- **Single VM**: Approximately 2-3 minutes
- **Multiple VMs**: 3-5 minutes (parallel deployment)
- **Ansible Verification**: About 30 seconds per VM

### Resource Usage

- **Template Clone**: Nearly instant (linked clone)
- **Full Clone**: 1-2 minutes if required
- **Disk Expansion**: Automatic during first boot

## Troubleshooting

### VM Deployment Fails

If deployment fails, check these common issues:

```bash
# Verify the template exists
qm list | grep rocky-linux-stig-manual

# Test Proxmox connectivity
curl -k https://YOUR_PROXMOX_IP:8006/api2/json/version

# Check Proxmox logs
tail -f /var/log/pve/tasks/index
```

### Cloud-Init Issues

If cloud-init doesn't configure the VM properly:

```bash
# SSH to the VM and check cloud-init status
cloud-init status

# Review cloud-init logs
journalctl -u cloud-init

# Check for errors
cat /var/log/cloud-init-output.log
```

### Ansible Verification Fails

If post-deployment Ansible tests fail:

```bash
# Test SSH connectivity manually
ssh rocky@<vm-ip>

# Run the Ansible playbook manually for troubleshooting
ansible-playbook -i generated_inventory.ini playbooks/verify.yml -v
```

### VM ID Already Exists

If you get a VM ID conflict:

```bash
# Use vm_id_start = 0 to auto-assign IDs
# Or check which IDs are in use: qm list
```

## Best Practices

### Security

- Store credentials in `terraform.tfvars` (excluded by `.gitignore`)
- Use strong passwords (minimum 15 characters for STIG compliance)
- Rotate credentials regularly
- Limit Proxmox API access by IP when possible

### State Management

- Keep Terraform state files secure
- Consider using remote state backends for team environments
- Never commit state files to version control

### Testing

- Always run `terraform plan` before `apply`
- Test in a development environment first
- Verify each deployment with the Ansible tests
- Document any configuration changes

## Integration with Other Tools

### With Ansible

The generated inventory file can be used with any Ansible playbook:

```bash
ansible-playbook -i generated_inventory.ini your-playbook.yml
```

### With Packer

VMs deployed with Terraform can serve as templates after additional configuration:

```bash
# Customize the VM, then convert to template
qm template <VM_ID>
```

## Additional Resources

- [Terraform Proxmox Provider Documentation](https://registry.terraform.io/providers/Telmate/proxmox/latest/docs)
- [Cloud-Init Official Documentation](https://cloudinit.readthedocs.io/)
- [Ansible Getting Started Guide](https://docs.ansible.com/ansible/latest/user_guide/intro_getting_started.html)
- [Proxmox VE Documentation](https://pve.proxmox.com/pve-docs/)

## Success Criteria

This Terraform automation meets all milestone objectives:

- [x] Terraform-only deployment (no manual Proxmox steps)
- [x] Automated VM provisioning through variables
- [x] Automatic disk resizing capability
- [x] Cloud-init customization (hostname, IP, SSH keys)
- [x] Post-deployment Ansible verification
- [x] Idempotent operations (repeated applies show no changes)
- [x] Comprehensive documentation and examples

---

**Status**: All Terraform automation is complete and ready for production use.

For additional help, refer to the main project README or open an issue in the repository.
