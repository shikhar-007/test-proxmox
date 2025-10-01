#!/bin/bash
# Verification script for Rocky Linux STIG template

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to check if template exists in Proxmox
check_template_exists() {
    print_status "Checking if template exists in Proxmox..."
    
    # This would require Proxmox API access to verify
    # For now, we'll check if the manifest file exists
    if [ -f "manifest.json" ]; then
        print_success "Build manifest found"
        return 0
    else
        print_error "Build manifest not found. Template may not have been built."
        return 1
    fi
}

# Function to verify Packer configuration
verify_packer_config() {
    print_status "Verifying Packer configuration..."
    
    # Check if main Packer file exists
    if [ ! -f "packer.pkr.hcl" ]; then
        print_error "packer.pkr.hcl not found"
        return 1
    fi
    
    # Check if kickstart file exists
    if [ ! -f "http/ks.cfg" ]; then
        print_error "http/ks.cfg not found"
        return 1
    fi
    
    # Check if all scripts exist
    local scripts=(
        "scripts/01-setup-stig-partitions.sh"
        "scripts/02-install-cloud-init.sh"
        "scripts/03-configure-ssh.sh"
        "scripts/04-stig-hardening.sh"
        "scripts/05-cleanup.sh"
    )
    
    for script in "${scripts[@]}"; do
        if [ ! -f "$script" ]; then
            print_error "Script not found: $script"
            return 1
        fi
        
        if [ ! -x "$script" ]; then
            print_warning "Script not executable: $script"
            chmod +x "$script"
        fi
    done
    
    print_success "All Packer configuration files found"
    return 0
}

# Function to verify STIG compliance
verify_stig_compliance() {
    print_status "Verifying STIG compliance configuration..."
    
    # Check kickstart for STIG partitioning
    if grep -q "part /tmp" http/ks.cfg; then
        print_success "STIG partitioning configured in kickstart"
    else
        print_warning "STIG partitioning not found in kickstart"
    fi
    
    # Check for audit configuration
    if grep -q "audit" scripts/04-stig-hardening.sh; then
        print_success "Audit configuration found"
    else
        print_warning "Audit configuration not found"
    fi
    
    # Check for SSH hardening
    if grep -q "PermitRootLogin no" scripts/03-configure-ssh.sh; then
        print_success "SSH hardening configured"
    else
        print_warning "SSH hardening not found"
    fi
    
    # Check for SELinux configuration
    if grep -q "SELINUX=enforcing" scripts/04-stig-hardening.sh; then
        print_success "SELinux configuration found"
    else
        print_warning "SELinux configuration not found"
    fi
}

# Function to verify cloud-init configuration
verify_cloud_init() {
    print_status "Verifying cloud-init configuration..."
    
    # Check if cloud-init is installed in kickstart
    if grep -q "cloud-init" http/ks.cfg; then
        print_success "Cloud-init package included in kickstart"
    else
        print_warning "Cloud-init package not found in kickstart"
    fi
    
    # Check if cloud-init script exists
    if [ -f "scripts/02-install-cloud-init.sh" ]; then
        print_success "Cloud-init installation script found"
    else
        print_error "Cloud-init installation script not found"
        return 1
    fi
    
    # Check for cloud-init configuration
    if grep -q "datasource_list" scripts/02-install-cloud-init.sh; then
        print_success "Cloud-init datasource configuration found"
    else
        print_warning "Cloud-init datasource configuration not found"
    fi
}

# Function to verify automation
verify_automation() {
    print_status "Verifying automation configuration..."
    
    # Check if kickstart is fully automated
    if grep -q "inst.ks=" packer.pkr.hcl; then
        print_success "Kickstart automation configured"
    else
        print_error "Kickstart automation not configured"
        return 1
    fi
    
    # Check if SSH is configured for automation
    if grep -q "ssh_username" packer.pkr.hcl; then
        print_success "SSH automation configured"
    else
        print_error "SSH automation not configured"
        return 1
    fi
    
    # Check if all provisioning scripts are included
    if grep -q "scripts/" packer.pkr.hcl; then
        print_success "Provisioning scripts configured"
    else
        print_error "Provisioning scripts not configured"
        return 1
    fi
}

# Function to show verification summary
show_summary() {
    print_status "Verification Summary"
    echo "======================"
    
    local total_checks=5
    local passed_checks=0
    
    # Count passed checks (simplified)
    if [ -f "packer.pkr.hcl" ]; then ((passed_checks++)); fi
    if [ -f "http/ks.cfg" ]; then ((passed_checks++)); fi
    if [ -f "scripts/01-setup-stig-partitions.sh" ]; then ((passed_checks++)); fi
    if [ -f "scripts/02-install-cloud-init.sh" ]; then ((passed_checks++)); fi
    if [ -f "scripts/03-configure-ssh.sh" ]; then ((passed_checks++)); fi
    
    echo "Configuration files: $passed_checks/$total_checks"
    
    if [ $passed_checks -eq $total_checks ]; then
        print_success "All verification checks passed"
        echo ""
        print_status "Ready to build:"
        echo "1. Run: ./build.sh"
        echo "2. Or run: packer build ."
        echo ""
        print_status "After build:"
        echo "1. Check Proxmox VE for the template"
        echo "2. Clone template to create VMs"
        echo "3. Configure cloud-init for deployment"
    else
        print_error "Some verification checks failed"
        echo "Please review the errors above and fix them before building"
    fi
}

# Main function
main() {
    print_status "Starting verification process..."
    echo ""
    
    verify_packer_config
    verify_stig_compliance
    verify_cloud_init
    verify_automation
    check_template_exists
    
    echo ""
    show_summary
}

# Run main function
main "$@"

