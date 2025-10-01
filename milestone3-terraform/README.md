# Milestone 3: Terraform Deployment Automation

This directory contains Terraform modules and configurations for automated deployment of VMs from the STIG-compliant Rocky Linux golden image.

## 🎯 Objectives

- Provide Terraform-only automation for VM deployment
- Deploy from golden image with cloud-init customization
- Implement automatic disk resizing capabilities
- Include post-deployment Ansible verification
- Support multi-instance deployments

## 📁 Directory Structure

```
milestone3-terraform/
├── main.tf                    # Main Terraform configuration
├── variables.tf               # Variable definitions
├── outputs.tf                 # Output definitions
├── terraform.tfvars.example   # Example variables file
├── playbooks/                 # Ansible playbooks
│   └── verify.yml            # Post-deployment verification
├── templates/                 # Template files
│   └── ansible_inventory.tpl # Ansible inventory template
└── examples/                  # Example deployments
    ├── single-vm/            # Single VM deployment
    └── multi-vm/             # Multiple VM deployment
```

## 🚀 Quick Start

### Prerequisites

- Terraform 1.0.0+
- Ansible 2.9+ (for post-deployment verification)
- Network access to Proxmox cluster
- Valid Proxmox credentials
- Existing STIG template (VM 108)

### Deploy Single VM

```bash
# Initialize Terraform
terraform init

# Create terraform.tfvars
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars with your settings

# Plan deployment
terraform plan

# Deploy
terraform apply

# Verify
ssh rocky@<vm-ip>
```

### Deploy Multiple VMs

```bash
# Use the multi-vm example
cd examples/multi-vm

# Initialize and apply
terraform init
terraform apply

# All VMs will be deployed in parallel
```

## ⚙️ Configuration

### Required Variables

```hcl
# Proxmox connection
proxmox_url      = "https://74.96.90.38:8006/api2/json"
proxmox_username = "root@pam"
proxmox_password = "your-password"
proxmox_node     = "tcnhq-prxmx01"

# Cloud-Init credentials
cloud_init_password = "your-password"
```

### Optional Variables

```hcl
# VM Configuration
vm_count       = 3             # Number of VMs
vm_name_prefix = "app-server"  # VM name prefix
vm_id_start    = 200          # Starting VM ID

# Hardware
cpu_cores = 4
memory    = 4096

# Disk
disk_size_root = "50G"

# Network
vlan_tag  = "69"
use_dhcp  = true

# Ansible
run_ansible_verification = true
```

## 🔧 Features

### 1. Template-Based Deployment
- Clones from existing STIG-compliant template
- Maintains all security hardening
- Fast deployment (2-3 minutes per VM)

### 2. Cloud-Init Customization
- Dynamic hostname assignment
- Static IP or DHCP configuration
- SSH key injection
- Custom user data support

### 3. Automatic Disk Resizing
- Grows disk to specified size
- Expands filesystems automatically
- Maintains STIG partitioning

### 4. Post-Deployment Verification
- Ansible connectivity test
- Service status verification
- Creates test file: `/tmp/ansible_deployed_test.txt`
- STIG compliance check

### 5. Multi-Instance Support
- Deploy multiple VMs in parallel
- Sequential VM IDs
- Auto-generated names
- Bulk operations

## 📊 Outputs

### VM Information
```hcl
output "vm_ids"          # List of VM IDs
output "vm_names"        # List of VM names
output "vm_ip_addresses" # List of IP addresses
output "ssh_commands"    # SSH connection commands
```

### Ansible Integration
```hcl
output "ansible_inventory"      # Ansible inventory entries
output "ansible_inventory_file" # Generated inventory file path
```

### Deployment Summary
```hcl
output "deployment_summary" # Complete deployment summary
output "vm_details"        # Detailed VM information
```

## 🧪 Usage Examples

### Example 1: Single Web Server
```hcl
vm_name     = "web-server-01"
vm_id_start = 200
cpu_cores   = 2
memory      = 2048
disk_size_root = "20G"
```

### Example 2: Multiple App Servers
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

## 🔄 Workflow

### 1. Infrastructure Planning
```bash
terraform init
terraform plan -out=tfplan
```

### 2. Deployment
```bash
terraform apply tfplan
```

### 3. Verification
```bash
# Check outputs
terraform output vm_ip_addresses

# SSH to VMs
ssh rocky@<vm-ip>

# Verify test file
cat /tmp/ansible_deployed_test.txt
```

### 4. Cleanup
```bash
terraform destroy
```

## 📈 Performance Metrics

### Deployment Speed
- **Single VM**: ~2-3 minutes
- **Multiple VMs**: ~3-5 minutes (parallel deployment)
- **Ansible Verification**: ~30 seconds per VM

### Resource Usage
- **Template Clone**: Instant (linked clone)
- **Full Clone**: ~1-2 minutes
- **Disk Expansion**: Automatic on first boot

## ✅ Acceptance Criteria

- [x] **Terraform-Only**: No manual Proxmox steps required
- [x] **Automated Provisioning**: VM config via variables
- [x] **Disk Resizing**: Automatic filesystem expansion
- [x] **Cloud-Init Customization**: Dynamic hostname/IP/SSH keys
- [x] **Ansible Verification**: Post-deploy test file creation
- [x] **Idempotence**: Multiple applies show no drift
- [x] **Documentation**: Complete usage guide

## 🐛 Troubleshooting

### Common Issues

**VM deployment fails:**
```bash
# Check template exists
qm list | grep rocky-linux-stig-manual

# Verify Proxmox connectivity
curl -k https://74.96.90.38:8006/api2/json/version
```

**Cloud-init not working:**
```bash
# SSH to VM and check cloud-init logs
cloud-init status
journalctl -u cloud-init
```

**Ansible verification fails:**
```bash
# Test SSH manually
ssh rocky@<vm-ip>

# Run playbook manually
ansible-playbook -i generated_inventory.ini playbooks/verify.yml
```

## 📚 References

- [Terraform Proxmox Provider](https://registry.terraform.io/providers/Telmate/proxmox/latest/docs)
- [Cloud-Init Documentation](https://cloudinit.readthedocs.io/)
- [Ansible Documentation](https://docs.ansible.com/)

---

**Milestone 3 Status: ✅ COMPLETED**

All Terraform automation is ready for deployment!
