#!/bin/bash
# Terraform Deployment Script for Rocky Linux VMs
# This script provides an interactive deployment experience

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}=== Terraform VM Deployment Script ===${NC}"
echo -e "${YELLOW}Deploy VMs from STIG-compliant Rocky Linux template${NC}"
echo ""

# Check if Terraform is installed
if ! command -v terraform &> /dev/null; then
    echo -e "${RED}Error: Terraform is not installed${NC}"
    echo "Please install Terraform: https://www.terraform.io/downloads"
    exit 1
fi

echo -e "${GREEN}✓ Terraform is installed${NC}"
terraform version
echo ""

# Check if terraform.tfvars exists
if [ ! -f "terraform.tfvars" ]; then
    echo -e "${YELLOW}terraform.tfvars not found. Creating from example...${NC}"
    if [ -f "terraform.tfvars.example" ]; then
        cp terraform.tfvars.example terraform.tfvars
        echo -e "${GREEN}✓ Created terraform.tfvars from example${NC}"
        echo -e "${YELLOW}Please edit terraform.tfvars with your settings${NC}"
        echo ""
        read -p "Press Enter to continue after editing terraform.tfvars..."
    else
        echo -e "${RED}Error: terraform.tfvars.example not found${NC}"
        exit 1
    fi
fi

# Interactive prompts for required values
echo -e "${BLUE}=== Deployment Configuration ===${NC}"
echo ""

# Proxmox Node
echo -e "${YELLOW}Available Proxmox nodes: tcnhq-prxmx01, tcnhq-prxmx02, tcnhq-prxmx03${NC}"
read -p "Enter Proxmox node name [tcnhq-prxmx01]: " PROXMOX_NODE
PROXMOX_NODE=${PROXMOX_NODE:-tcnhq-prxmx01}
export TF_VAR_proxmox_node="$PROXMOX_NODE"

# VM Name
read -p "Enter VM name [rocky-linux-vm-001]: " VM_NAME
VM_NAME=${VM_NAME:-rocky-linux-vm-001}
export TF_VAR_vm_name="$VM_NAME"

# VM ID
read -p "Enter starting VM ID [200]: " VM_ID
VM_ID=${VM_ID:-200}
export TF_VAR_vm_id_start="$VM_ID"

# VM Count
read -p "How many VMs to deploy [1]: " VM_COUNT
VM_COUNT=${VM_COUNT:-1}
export TF_VAR_vm_count="$VM_COUNT"

# Summary
echo ""
echo -e "${BLUE}=== Deployment Summary ===${NC}"
echo -e "  Proxmox Node: ${GREEN}$PROXMOX_NODE${NC}"
echo -e "  VM Name: ${GREEN}$VM_NAME${NC}"
echo -e "  Starting VM ID: ${GREEN}$VM_ID${NC}"
echo -e "  VM Count: ${GREEN}$VM_COUNT${NC}"
echo ""

# Confirm
read -p "Proceed with deployment? (y/N): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo -e "${YELLOW}Deployment cancelled${NC}"
    exit 0
fi

# Initialize Terraform
echo -e "${BLUE}Initializing Terraform...${NC}"
terraform init

# Validate configuration
echo -e "${BLUE}Validating Terraform configuration...${NC}"
terraform validate

# Plan deployment
echo -e "${BLUE}Planning deployment...${NC}"
terraform plan -out=tfplan

# Apply deployment
echo -e "${BLUE}Deploying VMs...${NC}"
if terraform apply tfplan; then
    echo ""
    echo -e "${GREEN}✓ Deployment successful!${NC}"
    echo ""
    
    # Show outputs
    echo -e "${BLUE}=== Deployment Results ===${NC}"
    terraform output
    
    echo ""
    echo -e "${YELLOW}Next steps:${NC}"
    echo -e "  1. SSH to VMs: terraform output ssh_commands"
    echo -e "  2. Check Ansible inventory: cat generated_inventory.ini"
    echo -e "  3. Verify deployment: cat /tmp/ansible_deployed_test.txt"
    echo -e "  4. Destroy when done: terraform destroy"
else
    echo -e "${RED}✗ Deployment failed${NC}"
    echo "Check the logs above for errors"
    exit 1
fi
