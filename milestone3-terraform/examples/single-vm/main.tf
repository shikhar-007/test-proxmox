# Example: Single VM Deployment

module "single_vm" {
  source = "../../"
  
  # Proxmox Configuration
  proxmox_url      = "https://74.96.90.38:8006/api2/json"
  proxmox_username = "root@pam"
  proxmox_password = "1qaz@WSX3edc$RFV"
  proxmox_node     = "tcnhq-prxmx01"
  
  # Template
  template_name = "rocky-linux-stig-manual"
  
  # VM Configuration
  vm_name     = "web-server-01"
  vm_id_start = 200
  vm_count    = 1
  
  # Hardware
  cpu_cores = 2
  memory    = 2048
  
  # Disk
  disk_size_root = "20G"
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
output "vm_ip" {
  value = module.single_vm.vm_ip_addresses[0]
}

output "ssh_command" {
  value = module.single_vm.ssh_commands[0]
}
