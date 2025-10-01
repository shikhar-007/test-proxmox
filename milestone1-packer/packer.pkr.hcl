# Proxmox Rocky Linux Golden Image Packer Template
# This template DEPLOYS VMs from the existing STIG-compliant template

packer {
  required_plugins {
    proxmox = {
      version = ">= 1.1.0"
      source  = "github.com/hashicorp/proxmox"
    }
  }
}

# Variable definitions
variable "proxmox_url" {
  type        = string
  description = "Proxmox API URL"
  default     = "https://74.96.90.38:8006/api2/json"
}

variable "proxmox_username" {
  type        = string
  description = "Proxmox username"
  default     = "root@pam"
}

variable "proxmox_password" {
  type        = string
  description = "Proxmox password"
  sensitive   = true
  default     = "1qaz@WSX3edc$RFV"
}

variable "proxmox_node" {
  type        = string
  description = "Proxmox node name"
  default     = "tcnhq-prxmx01"
}

variable "template_name" {
  type        = string
  description = "Name of the existing STIG template"
  default     = "rocky-linux-stig-manual"  # Your template 108
}

variable "vm_id" {
  type        = number
  description = "VM ID for the new deployment"
  default     = 110  # Different from your existing VMs
}

variable "vm_name" {
  type        = string
  description = "Name of the deployed VM"
  default     = "rocky-linux-deployed"
}

variable "ssh_password" {
  type        = string
  description = "SSH password for rocky user"
  sensitive   = true
  default     = "My!temp@123#456"  # Your working password
}

# Proxmox source configuration - CLONE from existing template
source "proxmox-clone" "rocky-linux" {
  # Proxmox connection settings
  proxmox_url              = var.proxmox_url
  username                 = var.proxmox_username
  password                 = var.proxmox_password
  insecure_skip_tls_verify = true
  node                     = var.proxmox_node

  # VM configuration - CLONE from template
  vm_id         = var.vm_id
  vm_name       = var.vm_name
  clone_vm = var.template_name  # Use your existing template 108
  
  # Hardware configuration (can be customized)
  memory        = 2048
  cores         = 2
  sockets       = 1
  cpu_type      = "host"
  os            = "l26"
  qemu_agent    = true

  # Network configuration
  network_adapters {
    model  = "virtio"
    bridge = "vmbr0"
    vlan_tag = "69"
  }

  # Storage configuration
  scsi_controller = "virtio-scsi-pci"
  disks {
    disk_size    = "20G"
    storage_pool = "local"
    type         = "scsi"
    format       = "qcow2"
  }

  # SSH configuration
  ssh_username = "rocky"
  ssh_password = var.ssh_password
  ssh_timeout  = "10m"
  ssh_pty      = true

  # Cloud-init configuration
  cloud_init              = true
  cloud_init_storage_pool = "local"
}

# Build configuration
build {
  name = "rocky-linux-deployment"
  sources = ["source.proxmox-clone.rocky-linux"]

  # Post-deployment configuration
  provisioner "shell" {
    execute_command = "echo '${var.ssh_password}' | {{ .Vars }} sudo -S -E bash '{{ .Path }}'"
    scripts = [
      "scripts/post-deploy-config.sh"  # Customize the deployed VM
    ]
  }

  # Post-processor to generate manifest
  post-processor "manifest" {
    output = "deployment-manifest.json"
    strip_path = true
  }
}