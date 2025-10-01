#!/bin/bash
# Packer Build Script for Rocky Linux Template Deployment
# This script deploys VMs from the existing STIG-compliant template

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Default configuration
ENVIRONMENT="dev"
VAR_FILE=""
VM_ID=""
VM_NAME=""
BUILD_ID=""

# Function to show usage
show_usage() {
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  -e, --environment ENV    Environment (dev, staging, prod) [default: dev]"
    echo "  -f, --var-file FILE      Custom variables file"
    echo "  -i, --vm-id ID          VM ID (0 for auto-assign)"
    echo "  -n, --vm-name NAME      VM name"
    echo "  -b, --build-id ID       Build ID"
    echo "  -h, --help              Show this help"
    echo ""
    echo "Examples:"
    echo "  $0                                    # Build with dev environment"
    echo "  $0 -e prod                           # Build with prod environment"
    echo "  $0 -f custom.tfvars                  # Build with custom variables"
    echo "  $0 -e dev -i 120 -n my-vm           # Build with specific VM ID and name"
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -e|--environment)
            ENVIRONMENT="$2"
            shift 2
            ;;
        -f|--var-file)
            VAR_FILE="$2"
            shift 2
            ;;
        -i|--vm-id)
            VM_ID="$2"
            shift 2
            ;;
        -n|--vm-name)
            VM_NAME="$2"
            shift 2
            ;;
        -b|--build-id)
            BUILD_ID="$2"
            shift 2
            ;;
        -h|--help)
            show_usage
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            show_usage
            exit 1
            ;;
    esac
done

# Set default var file if not specified
if [[ -z "$VAR_FILE" ]]; then
    VAR_FILE="environments/${ENVIRONMENT}.tfvars"
fi

# Generate build ID if not provided
if [[ -z "$BUILD_ID" ]]; then
    BUILD_ID="manual-$(date +%Y%m%d-%H%M%S)"
fi

# Generate VM name if not provided
if [[ -z "$VM_NAME" ]]; then
    VM_NAME="rocky-linux-${ENVIRONMENT}-${BUILD_ID}"
fi

# Generate VM ID if not provided
if [[ -z "$VM_ID" ]]; then
    VM_ID=$((100 + RANDOM % 900))  # Random ID between 100-999
fi

echo -e "${BLUE}=== Packer Rocky Linux Template Deployment ===${NC}"
echo -e "${YELLOW}Environment: ${ENVIRONMENT}${NC}"
echo -e "${YELLOW}Variables File: ${VAR_FILE}${NC}"
echo -e "${YELLOW}VM ID: ${VM_ID}${NC}"
echo -e "${YELLOW}VM Name: ${VM_NAME}${NC}"
echo -e "${YELLOW}Build ID: ${BUILD_ID}${NC}"
echo ""

# Check if Packer is installed
if ! command -v packer &> /dev/null; then
    echo -e "${RED}Error: Packer is not installed${NC}"
    echo "Please install Packer: https://www.packer.io/downloads"
    exit 1
fi

# Check if variables file exists
if [[ ! -f "$VAR_FILE" ]]; then
    echo -e "${RED}Error: Variables file '${VAR_FILE}' not found${NC}"
    echo "Available environment files:"
    ls -la environments/*.tfvars 2>/dev/null || echo "No environment files found"
    exit 1
fi

echo -e "${GREEN}✓ Variables file '${VAR_FILE}' found${NC}"

# Validate Packer configuration
echo -e "${BLUE}Validating Packer configuration...${NC}"
if ! packer validate packer.pkr.hcl; then
    echo -e "${RED}Error: Packer configuration validation failed${NC}"
    exit 1
fi

echo -e "${GREEN}✓ Packer configuration is valid${NC}"

# Initialize Packer plugins
echo -e "${BLUE}Initializing Packer plugins...${NC}"
packer init packer.pkr.hcl

# Build the VM from template
echo -e "${BLUE}Starting VM deployment from template...${NC}"
echo -e "${YELLOW}This will create a new VM (${VM_ID}) from the STIG template${NC}"
echo ""

# Ask for confirmation (skip in CI/CD)
if [[ -z "$CI" ]]; then
    read -p "Do you want to continue? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo -e "${YELLOW}Build cancelled${NC}"
        exit 0
    fi
fi

# Prepare environment variables
export PACKER_VAR_vm_id="$VM_ID"
export PACKER_VAR_vm_name="$VM_NAME"
export PACKER_VAR_build_id="$BUILD_ID"
export PACKER_VAR_environment="$ENVIRONMENT"

# Run Packer build
echo -e "${BLUE}Running Packer build...${NC}"
if packer build -var-file="$VAR_FILE" packer.pkr.hcl; then
    echo -e "${GREEN}✓ VM deployment successful!${NC}"
    echo ""
    echo -e "${BLUE}Deployment Summary:${NC}"
    echo -e "  Environment: ${ENVIRONMENT}"
    echo -e "  VM ID: ${VM_ID}"
    echo -e "  VM Name: ${VM_NAME}"
    echo -e "  Build ID: ${BUILD_ID}"
    echo -e "  Status: Deployed and configured"
    echo ""
    echo -e "${YELLOW}Next steps:${NC}"
    echo -e "  1. Check VM in Proxmox web interface"
    echo -e "  2. Test SSH connectivity"
    echo -e "  3. Run Ansible tests"
    echo -e "  4. Use with Terraform for production deployments"
else
    echo -e "${RED}✗ VM deployment failed${NC}"
    exit 1
fi