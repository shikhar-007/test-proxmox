# Packer Variables for Rocky Linux Template Deployment
# Simplified configuration focused on core requirements

# Proxmox Connection Variables
variable "proxmox_url" {
  type        = string
  description = "Proxmox API URL"
  default     = ""
  # Can be overridden with: PACKER_VAR_proxmox_url
}

variable "proxmox_username" {
  type        = string
  description = "Proxmox username"
  default     = ""
  # Can be overridden with: PACKER_VAR_proxmox_username
}

variable "proxmox_password" {
  type        = string
  description = "Proxmox password"
  sensitive   = true
  default     = ""
  # Can be overridden with: PACKER_VAR_proxmox_password
}

variable "proxmox_node" {
  type        = string
  description = "Proxmox node name"
  default     = ""
  # Can be overridden with: PACKER_VAR_proxmox_node
}

# Template Configuration
variable "template_name" {
  type        = string
  description = "Name of the existing STIG template"
  default     = "rocky-linux-stig-manual"
  # Can be overridden with: PACKER_VAR_template_name
}

# VM Configuration
variable "vm_id" {
  type        = number
  description = "VM ID for the new deployment (0 = auto-assign)"
  default     = 0
  # Can be overridden with: PACKER_VAR_vm_id
}

variable "vm_name" {
  type        = string
  description = "Name of the deployed VM"
  default     = ""
  # Can be overridden with: PACKER_VAR_vm_name
}

# Hardware Configuration
variable "memory" {
  type        = number
  description = "VM memory in MB"
  default     = 2048
  # Can be overridden with: PACKER_VAR_memory
}

variable "cores" {
  type        = number
  description = "Number of CPU cores"
  default     = 2
  # Can be overridden with: PACKER_VAR_cores
}

variable "disk_size" {
  type        = string
  description = "Disk size (e.g., '20G')"
  default     = "20G"
  # Can be overridden with: PACKER_VAR_disk_size
}

# Network Configuration
variable "network_bridge" {
  type        = string
  description = "Network bridge name"
  default     = "vmbr0"
  # Can be overridden with: PACKER_VAR_network_bridge
}

variable "vlan_tag" {
  type        = string
  description = "VLAN tag (empty string for no VLAN)"
  default     = "69"
  # Can be overridden with: PACKER_VAR_vlan_tag
}

# Storage Configuration
variable "storage_pool" {
  type        = string
  description = "Storage pool name"
  default     = "local"
  # Can be overridden with: PACKER_VAR_storage_pool
}

variable "storage_pool_type" {
  type        = string
  description = "Storage pool type (lvm, zfs, dir)"
  default     = "lvm"
  # Can be overridden with: PACKER_VAR_storage_pool_type
}

# SSH Configuration
variable "ssh_username" {
  type        = string
  description = "SSH username"
  default     = "rocky"
  # Can be overridden with: PACKER_VAR_ssh_username
}

variable "ssh_password" {
  type        = string
  description = "SSH password"
  sensitive   = true
  default     = ""
  # Can be overridden with: PACKER_VAR_ssh_password
}

# Build Configuration
variable "build_id" {
  type        = string
  description = "Build ID (usually from CI/CD)"
  default     = ""
  # Can be overridden with: PACKER_VAR_build_id
}