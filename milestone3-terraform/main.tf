# Terraform Configuration for Proxmox VM Deployment
# Deploys VMs from the STIG-compliant Rocky Linux template

terraform {
  required_version = ">= 1.0.0"
  
  required_providers {
    proxmox = {
      source  = "Telmate/proxmox"
      version = "~> 2.9"
    }
  }
}

# Proxmox Provider Configuration
provider "proxmox" {
  pm_api_url      = var.proxmox_url
  pm_user         = var.proxmox_username
  pm_password     = var.proxmox_password
  pm_tls_insecure = true
  pm_parallel     = 2
  pm_timeout      = 600
  pm_log_enable   = true
  pm_log_file     = "terraform-plugin-proxmox.log"
  pm_log_levels = {
    _default    = "debug"
    _capturelog = ""
  }
}

# Deploy VM from STIG Template
resource "proxmox_vm_qemu" "rocky_vm" {
  count = var.vm_count
  
  # VM Naming
  name        = var.vm_count > 1 ? "${var.vm_name_prefix}-${count.index + 1}" : var.vm_name
  desc        = "STIG-compliant Rocky Linux VM deployed from template via Terraform"
  target_node = var.proxmox_node
  vmid        = var.vm_id_start + count.index
  
  # Clone from template
  clone      = var.template_name
  full_clone = true
  
  # VM Configuration
  agent    = 1
  cores    = var.cpu_cores
  sockets  = 1
  cpu      = "host"
  memory   = var.memory
  scsihw   = "virtio-scsi-pci"
  bootdisk = "scsi0"
  onboot   = var.vm_onboot
  
  # Disk Configuration
  disk {
    slot    = 0
    size    = var.disk_size_root
    type    = "scsi"
    storage = var.storage_pool
    iothread = 1
    discard  = "on"
    ssd      = 1
  }
  
  # Network Configuration
  network {
    model  = "virtio"
    bridge = var.network_bridge
    tag    = var.vlan_tag != "" ? var.vlan_tag : null
  }
  
  # Cloud-Init Configuration
  os_type    = "cloud-init"
  ipconfig0  = var.use_dhcp ? "ip=dhcp" : "ip=${var.vm_ip_addresses[count.index]}/${var.vm_ip_netmask},gw=${var.vm_gateway}"
  nameserver = var.dns_servers
  searchdomain = var.search_domain
  
  # Cloud-Init User Configuration
  ciuser     = var.cloud_init_user
  cipassword = var.cloud_init_password
  sshkeys    = var.ssh_public_keys
  
  # Cloud-Init Custom Data
  cicustom = var.cloud_init_custom != "" ? var.cloud_init_custom : null
  
  # Lifecycle
  lifecycle {
    ignore_changes = [
      network,
      disk,
    ]
  }
  
  # Dependencies
  depends_on = []
}

# Ansible Inventory File Generation
resource "local_file" "ansible_inventory" {
  count = var.generate_ansible_inventory ? 1 : 0
  
  filename = "${path.module}/generated_inventory.ini"
  content = templatefile("${path.module}/templates/ansible_inventory.tpl", {
    vms = proxmox_vm_qemu.rocky_vm
    ssh_user = var.cloud_init_user
  })
  
  file_permission = "0644"
}

# Post-Deployment Ansible Verification
resource "null_resource" "ansible_verification" {
  count = var.run_ansible_verification ? var.vm_count : 0
  
  depends_on = [proxmox_vm_qemu.rocky_vm]
  
  triggers = {
    vm_id = proxmox_vm_qemu.rocky_vm[count.index].vmid
  }
  
  provisioner "local-exec" {
    command = <<-EOT
      echo "Waiting for VM to be ready..."
      sleep 60
      
      echo "Running Ansible verification playbook..."
      ansible-playbook -i ${proxmox_vm_qemu.rocky_vm[count.index].default_ipv4_address}, \
        -u ${var.cloud_init_user} \
        -e "ansible_ssh_pass=${var.cloud_init_password}" \
        -e "ansible_ssh_common_args='-o StrictHostKeyChecking=no'" \
        ${path.module}/playbooks/verify.yml
    EOT
    
    environment = {
      ANSIBLE_HOST_KEY_CHECKING = "False"
    }
  }
}
