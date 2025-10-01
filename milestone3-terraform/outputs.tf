# Terraform Outputs for Proxmox VM Deployment

# VM Information
output "vm_ids" {
  description = "List of deployed VM IDs"
  value       = proxmox_vm_qemu.rocky_vm[*].vmid
}

output "vm_names" {
  description = "List of deployed VM names"
  value       = proxmox_vm_qemu.rocky_vm[*].name
}

output "vm_ip_addresses" {
  description = "List of VM IP addresses"
  value       = proxmox_vm_qemu.rocky_vm[*].default_ipv4_address
}

output "vm_mac_addresses" {
  description = "List of VM MAC addresses"
  value       = proxmox_vm_qemu.rocky_vm[*].network[0].macaddr
}

# SSH Connection Information
output "ssh_commands" {
  description = "SSH commands to connect to VMs"
  value = [
    for vm in proxmox_vm_qemu.rocky_vm :
    "ssh ${var.cloud_init_user}@${vm.default_ipv4_address}"
  ]
}

output "ssh_connection_info" {
  description = "Detailed SSH connection information"
  value = {
    for vm in proxmox_vm_qemu.rocky_vm :
    vm.name => {
      ip       = vm.default_ipv4_address
      user     = var.cloud_init_user
      vm_id    = vm.vmid
      hostname = vm.name
    }
  }
}

# Ansible Integration
output "ansible_inventory" {
  description = "Ansible inventory entries"
  value = join("\n", [
    for vm in proxmox_vm_qemu.rocky_vm :
    "${vm.name} ansible_host=${vm.default_ipv4_address} ansible_user=${var.cloud_init_user}"
  ])
}

output "ansible_inventory_file" {
  description = "Path to generated Ansible inventory file"
  value       = var.generate_ansible_inventory ? local_file.ansible_inventory[0].filename : null
}

# Deployment Summary
output "deployment_summary" {
  description = "Summary of deployed VMs"
  value = {
    total_vms     = var.vm_count
    template_used = var.template_name
    proxmox_node  = var.proxmox_node
    vlan_tag      = var.vlan_tag
    deployment_time = timestamp()
  }
}

# VM Details
output "vm_details" {
  description = "Detailed information for each VM"
  value = {
    for vm in proxmox_vm_qemu.rocky_vm :
    vm.name => {
      vm_id      = vm.vmid
      ip_address = vm.default_ipv4_address
      mac_address = vm.network[0].macaddr
      cpu_cores  = var.cpu_cores
      memory_mb  = var.memory
      disk_size  = var.disk_size_root
      template   = var.template_name
      node       = var.proxmox_node
    }
  }
}

# Network Information
output "network_configuration" {
  description = "Network configuration for deployed VMs"
  value = {
    bridge      = var.network_bridge
    vlan_tag    = var.vlan_tag
    use_dhcp    = var.use_dhcp
    gateway     = var.use_dhcp ? "DHCP" : var.vm_gateway
    dns_servers = var.dns_servers
  }
}

# Cloud-Init Configuration
output "cloud_init_status" {
  description = "Cloud-init configuration status"
  value = {
    user            = var.cloud_init_user
    ssh_keys_added  = var.ssh_public_keys != "" ? "Yes" : "No"
    custom_config   = var.cloud_init_custom != "" ? "Yes" : "No"
  }
}
