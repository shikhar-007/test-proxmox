#!/bin/bash
# GitHub Secrets Setup Script
# This script helps you set up GitHub Secrets for the Packer build pipeline

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
REPO_OWNER="Trinity-Technical-Services-LLC"
REPO_NAME="Proxmox_RockyLinux_GoldenImage"

echo -e "${BLUE}=== GitHub Secrets Setup Script ===${NC}"
echo -e "${YELLOW}Repository: ${REPO_OWNER}/${REPO_NAME}${NC}"
echo ""

# Check if GitHub CLI is installed
if ! command -v gh &> /dev/null; then
    echo -e "${RED}Error: GitHub CLI (gh) is not installed${NC}"
    echo "Please install GitHub CLI: https://cli.github.com/"
    exit 1
fi

# Check if user is authenticated
if ! gh auth status &> /dev/null; then
    echo -e "${RED}Error: Not authenticated with GitHub CLI${NC}"
    echo "Please run: gh auth login"
    exit 1
fi

echo -e "${GREEN}✓ GitHub CLI is installed and authenticated${NC}"

# Function to set secret
set_secret() {
    local secret_name="$1"
    local secret_description="$2"
    local current_value=""
    
    echo -e "${BLUE}Setting secret: ${secret_name}${NC}"
    echo -e "${YELLOW}Description: ${secret_description}${NC}"
    
    # Check if secret already exists
    if gh secret list --repo "${REPO_OWNER}/${REPO_NAME}" | grep -q "^${secret_name}"; then
        echo -e "${YELLOW}Secret '${secret_name}' already exists${NC}"
        read -p "Do you want to update it? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            echo -e "${YELLOW}Skipping ${secret_name}${NC}"
            return
        fi
    fi
    
    # Get secret value
    read -s -p "Enter value for ${secret_name}: " current_value
    echo
    
    if [[ -z "$current_value" ]]; then
        echo -e "${YELLOW}Skipping ${secret_name} (empty value)${NC}"
        return
    fi
    
    # Set the secret
    echo "$current_value" | gh secret set "${secret_name}" --repo "${REPO_OWNER}/${REPO_NAME}"
    echo -e "${GREEN}✓ Secret '${secret_name}' set successfully${NC}"
    echo ""
}

# Development Environment Secrets
echo -e "${BLUE}=== Development Environment Secrets ===${NC}"

set_secret "PROXMOX_URL" "Proxmox API URL (e.g., https://your-proxmox:8006/api2/json)"
set_secret "PROXMOX_USERNAME" "Proxmox username (e.g., root@pam)"
set_secret "PROXMOX_PASSWORD" "Proxmox password"
set_secret "PROXMOX_NODE" "Proxmox node name (e.g., tcnhq-prxmx01)"
set_secret "SSH_PASSWORD" "SSH password for rocky user"

# Production Environment Secrets
echo -e "${BLUE}=== Production Environment Secrets ===${NC}"

set_secret "PROXMOX_URL_PROD" "Production Proxmox API URL"
set_secret "PROXMOX_USERNAME_PROD" "Production Proxmox username"
set_secret "PROXMOX_PASSWORD_PROD" "Production Proxmox password"
set_secret "PROXMOX_NODE_PROD" "Production Proxmox node name"
set_secret "SSH_PASSWORD_PROD" "Production SSH password"

# List all secrets
echo -e "${BLUE}=== Current Secrets ===${NC}"
gh secret list --repo "${REPO_OWNER}/${REPO_NAME}"

echo ""
echo -e "${GREEN}✓ GitHub Secrets setup complete!${NC}"
echo ""
echo -e "${YELLOW}Next steps:${NC}"
echo -e "  1. Test the workflow with a manual run"
echo -e "  2. Push to develop branch to trigger dev build"
echo -e "  3. Push to main branch to trigger prod build"
echo ""
echo -e "${BLUE}To test manually:${NC}"
echo -e "  Go to Actions → Packer Build and Deploy → Run workflow"
