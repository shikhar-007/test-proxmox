# Test configuration for Packer build
# Using your actual Proxmox settings

# Proxmox Connection
proxmox_url      = "https://74.96.90.38:8006/api2/json"
proxmox_username = "root@pam"
proxmox_password = "1qaz@WSX3edc$RFV"
proxmox_node     = "tcnhq-prxmx01"

# Template Configuration
template_name = "rocky-linux-stig-manual"

# VM Configuration
vm_id   = 110
vm_name = "rocky-linux-test"

# Hardware Configuration
memory    = 1024
cores     = 1
disk_size = "10G"

# Network Configuration
network_bridge = "vmbr0"
vlan_tag       = "69"

# Storage Configuration
storage_pool = "local"

# SSH Configuration
ssh_username = "rocky"
ssh_password = "My!temp@123#456"

# Build Configuration
build_id = "test-build"
