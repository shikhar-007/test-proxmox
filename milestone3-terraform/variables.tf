# Terraform Variables for Proxmox VM Deployment

# Proxmox Connection Variables
variable "proxmox_url" {
  description = "Proxmox API URL"
  type        = string
}

variable "proxmox_username" {
  description = "Proxmox username (e.g., root@pam)"
  type        = string
}

variable "proxmox_password" {
  description = "Proxmox password"
  type        = string
  sensitive   = true
}

variable "proxmox_node" {
  description = "Proxmox node name"
  type        = string
}

# Template Configuration
variable "template_name" {
  description = "Name of the STIG-compliant template to clone from"
  type        = string
  default     = "rocky-linux-stig-manual"
}

# VM Configuration
variable "vm_name" {
  description = "VM name (used for single VM deployments)"
  type        = string
  default     = "rocky-linux-vm"
}

variable "vm_name_prefix" {
  description = "VM name prefix (used for multiple VM deployments)"
  type        = string
  default     = "rocky-linux"
}

variable "vm_count" {
  description = "Number of VMs to deploy"
  type        = number
  default     = 1
  
  validation {
    condition     = var.vm_count > 0 && var.vm_count <= 10
    error_message = "VM count must be between 1 and 10."
  }
}

variable "vm_id_start" {
  description = "Starting VM ID (subsequent VMs will increment from this)"
  type        = number
  default     = 200
}

variable "vm_onboot" {
  description = "Start VM on boot"
  type        = bool
  default     = true
}

# Hardware Configuration
variable "cpu_cores" {
  description = "Number of CPU cores"
  type        = number
  default     = 2
  
  validation {
    condition     = var.cpu_cores > 0 && var.cpu_cores <= 16
    error_message = "CPU cores must be between 1 and 16."
  }
}

variable "memory" {
  description = "Memory in MB"
  type        = number
  default     = 2048
  
  validation {
    condition     = var.memory >= 512 && var.memory <= 32768
    error_message = "Memory must be between 512MB and 32GB."
  }
}

# Disk Configuration
variable "disk_size_root" {
  description = "Root disk size (e.g., '20G', '50G')"
  type        = string
  default     = "20G"
}

variable "storage_pool" {
  description = "Proxmox storage pool name"
  type        = string
  default     = "local"
}

# Network Configuration
variable "network_bridge" {
  description = "Network bridge name"
  type        = string
  default     = "vmbr0"
}

variable "vlan_tag" {
  description = "VLAN tag (leave empty for no VLAN)"
  type        = string
  default     = "69"
}

variable "use_dhcp" {
  description = "Use DHCP for IP configuration"
  type        = bool
  default     = true
}

variable "vm_ip_addresses" {
  description = "List of static IP addresses for VMs (used when use_dhcp is false)"
  type        = list(string)
  default     = []
}

variable "vm_ip_netmask" {
  description = "IP netmask (e.g., '24' for /24)"
  type        = string
  default     = "24"
}

variable "vm_gateway" {
  description = "Default gateway IP"
  type        = string
  default     = "192.168.0.1"
}

variable "dns_servers" {
  description = "DNS servers (space-separated)"
  type        = string
  default     = "8.8.8.8 8.8.4.4"
}

variable "search_domain" {
  description = "DNS search domain"
  type        = string
  default     = ""
}

# Cloud-Init Configuration
variable "cloud_init_user" {
  description = "Cloud-init default user"
  type        = string
  default     = "rocky"
}

variable "cloud_init_password" {
  description = "Cloud-init user password"
  type        = string
  sensitive   = true
}

variable "ssh_public_keys" {
  description = "SSH public keys to inject (newline-separated)"
  type        = string
  default     = ""
}

variable "cloud_init_custom" {
  description = "Custom cloud-init configuration file path"
  type        = string
  default     = ""
}

# Ansible Configuration
variable "generate_ansible_inventory" {
  description = "Generate Ansible inventory file"
  type        = bool
  default     = true
}

variable "run_ansible_verification" {
  description = "Run Ansible verification playbook after deployment"
  type        = bool
  default     = true
}

# Tags and Metadata
variable "tags" {
  description = "Tags to apply to VMs"
  type        = map(string)
  default     = {
    environment = "production"
    managed_by  = "terraform"
    stig_compliant = "true"
  }
}
