# Example: Multiple VM Deployment

module "multi_vm" {
  source = "../../"
  
  # Proxmox Configuration
  proxmox_url      = "https://74.96.90.38:8006/api2/json"
  proxmox_username = "root@pam"
  proxmox_password = "1qaz@WSX3edc$RFV"
  proxmox_node     = "tcnhq-prxmx01"
  
  # Template
  template_name = "rocky-linux-stig-manual"
  
  # VM Configuration
  vm_name_prefix = "app-server"
  vm_id_start    = 210
  vm_count       = 3
  
  # Hardware
  cpu_cores = 4
  memory    = 4096
  
  # Disk
  disk_size_root = "50G"
  storage_pool   = "local"
  
  # Network
  network_bridge = "vmbr0"
  vlan_tag       = "69"
  use_dhcp       = true
  
  # Cloud-Init
  cloud_init_user     = "rocky"
  cloud_init_password = "My!temp@123#456"
  
  # Ansible
  generate_ansible_inventory = true
  run_ansible_verification   = true
}

# Outputs
output "vm_ips" {
  value = module.multi_vm.vm_ip_addresses
}

output "ssh_commands" {
  value = module.multi_vm.ssh_commands
}

output "ansible_inventory" {
  value = module.multi_vm.ansible_inventory
}
