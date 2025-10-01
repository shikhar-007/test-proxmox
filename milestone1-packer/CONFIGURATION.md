# Packer Configuration Guide

This guide provides detailed instructions for configuring Packer to deploy VMs from your STIG-compliant Rocky Linux template. The configuration system is designed to be flexible while maintaining security best practices.

## Repository Structure

The Packer configuration is organized as follows:

```
milestone1-packer/
├── packer.pkr.hcl              # Main Packer template
├── variables.pkr.hcl           # Variable definitions
├── terraform.tfvars.example    # Example configuration file
├── build.sh                    # Build automation script
├── scripts/                    # Post-deployment provisioning scripts
└── http/                       # Kickstart configuration files
```

## Configuration Methods

You can configure Packer using any of these three methods, depending on your workflow:

### Method 1: Configuration File (Recommended for Local Development)

This approach uses a variables file to store your configuration settings.

```bash
# Create your configuration file from the example
cp terraform.tfvars.example my-config.tfvars

# Edit the file with your environment-specific settings
nano my-config.tfvars

# Run Packer with your configuration
cd milestone1-packer
packer build -var-file=my-config.tfvars packer.pkr.hcl
```

**Note**: The `.gitignore` file is configured to exclude `*.tfvars` files from version control, preventing accidental credential exposure.

### Method 2: Environment Variables (Recommended for CI/CD)

Override variables using the `PACKER_VAR_` prefix:

```bash
export PACKER_VAR_proxmox_url="https://YOUR_IP:8006/api2/json"
export PACKER_VAR_proxmox_username="root@pam"
export PACKER_VAR_proxmox_password="YOUR_PASSWORD"
export PACKER_VAR_proxmox_node="your-node"
export PACKER_VAR_vm_id="110"
export PACKER_VAR_vm_name="rocky-linux-vm"
export PACKER_VAR_ssh_password="YOUR_SSH_PASSWORD"

# Build with environment variables
packer build packer.pkr.hcl
```

This method is particularly useful for automated pipelines where configuration needs to remain outside the codebase.

### Method 3: GitHub Actions (Recommended for Team Workflows)

The GitHub Actions workflow provides an interactive, secure deployment method.

**Initial Setup:**
1. Configure GitHub Secrets in your repository (see `.github/SECRETS_SETUP.md`)
2. Verify secrets are properly set in repository settings

**Workflow Execution:**
1. Navigate to the Actions tab in GitHub
2. Select "Packer Build and Deploy"
3. Click "Run workflow"
4. Provide deployment parameters:
   - Proxmox node name
   - VM ID (or 0 for auto-assignment)
   - VM name
   - Source template name
5. Execute the workflow

Credentials are automatically retrieved from GitHub Secrets, ensuring secure automation without exposing sensitive information.

## Configuration Example

Here's a complete configuration file example:

```hcl
# Proxmox Connection Settings
proxmox_url      = "https://10.0.0.100:8006/api2/json"
proxmox_username = "root@pam"
proxmox_password = "YourSecurePassword123!"
proxmox_node     = "proxmox-node-01"

# Template Configuration
template_name = "rocky-linux-stig-manual"  # References Template 108

# VM Deployment Settings
vm_id         = 110                    # Specific ID or 0 for auto-assignment
vm_name       = "rocky-linux-web-01"

# Hardware Specifications
memory        = 2048                   # RAM in MB (2GB)
cores         = 2                      # CPU core count
disk_size     = "20G"                  # Root disk size

# Network Configuration
network_bridge = "vmbr0"
vlan_tag       = "69"                  # VLAN 69 for network segmentation

# Storage Configuration
storage_pool   = "local"

# SSH Access
ssh_username   = "rocky"
ssh_password   = "SecurePassword15Chars!"   # Minimum 15 characters (STIG requirement)
```

## GitHub Actions Integration

### Required Secrets

Configure these secrets in your GitHub repository settings:

| Secret Name | Purpose |
|-------------|---------|
| `PROXMOX_URL` | Proxmox API endpoint |
| `PROXMOX_USERNAME` | Authentication username |
| `PROXMOX_PASSWORD` | Authentication password |
| `PROXMOX_NODE` | Default deployment node |
| `SSH_PASSWORD` | VM user password (15+ characters) |

### Workflow Parameters

When executing a workflow, you can specify:

- **Proxmox Node**: Target physical server for deployment
- **VM ID**: Specific identifier or 0 for automatic assignment
- **VM Name**: Descriptive name for the virtual machine
- **Template Name**: Source template (typically `rocky-linux-stig-manual`)

### Naming Conventions

We recommend following these naming patterns:

```
rocky-linux-web-01        # Web servers
rocky-linux-db-02         # Database servers
rocky-linux-app-prod-01   # Production application servers
rocky-linux-test-vm       # Test environments
```

## VM ID Management

Two approaches are available for VM ID assignment:

**Automatic Assignment (Recommended)**
```hcl
vm_id = 0  # Proxmox assigns the next available ID
```
This prevents ID conflicts and is suitable for most deployments.

**Manual Assignment**
```hcl
vm_id = 110  # Explicitly specified ID
```
Use this when you need predictable IDs for documentation or automation purposes. Verify the ID is available before use.

## Build Execution

### Local Build Process

```bash
# Navigate to the Packer directory
cd milestone1-packer

# Initialize Packer (first-time setup)
packer init packer.pkr.hcl

# Validate configuration
packer validate packer.pkr.hcl

# Execute the build
packer build -var-file=my-config.tfvars packer.pkr.hcl
```

### Automated Build Script

A convenience script is provided for streamlined builds:

```bash
# Make the script executable
chmod +x build.sh

# Run the build process
./build.sh
```

The script handles initialization, validation, and build execution automatically.

### GitHub Actions Build

The GitHub Actions workflow handles all build steps automatically. Simply trigger the workflow through the web interface and provide the required parameters.

## Security Guidelines

### Credential Management

1. **Never commit credentials to version control**
   - Use `.gitignore` to exclude configuration files
   - Store passwords in GitHub Secrets or environment variables
   - Use placeholder values in example files

2. **Password Complexity Requirements**
   - Minimum 15 characters for STIG compliance
   - Include uppercase, lowercase, numbers, and special characters
   - Avoid dictionary words or common patterns

3. **Access Control**
   - Limit Proxmox API access by IP address when possible
   - Use dedicated API users rather than root where appropriate
   - Implement network segmentation (VLANs)
   - Enable firewall rules to restrict administrative access

4. **Credential Rotation**
   - Rotate passwords quarterly at minimum
   - Update GitHub Secrets when credentials change
   - Document password changes in your change management system

## Common Deployment Scenarios

### Scenario 1: Testing New Configuration

```bash
# Using GitHub Actions
Node: tcnhq-prxmx01
VM ID: 0 (auto-assign)
VM Name: test-vm
Template: rocky-linux-stig-manual
```

### Scenario 2: Production Web Server Deployment

```bash
Node: tcnhq-prxmx01
VM ID: 0 (auto-assign)
VM Name: rocky-linux-web-prod-01
Template: rocky-linux-stig-manual
```

### Scenario 3: Local Development Build

```bash
# Create and customize configuration
cp terraform.tfvars.example dev-local.tfvars
nano dev-local.tfvars

# Execute build
packer build -var-file=dev-local.tfvars packer.pkr.hcl
```

## Troubleshooting

### Connection Failures

**Symptom**: `Failed to connect to Proxmox`

**Resolution Steps**:
- Verify Proxmox URL format: `https://IP:8006/api2/json`
- Check firewall rules allow port 8006 access
- Confirm credentials are correct by logging in manually
- Verify Proxmox services are running: `systemctl status pve-cluster`

### Template Not Found

**Symptom**: `Template 'rocky-linux-stig-manual' not found`

**Resolution Steps**:
- List available templates: `qm list` on Proxmox
- Verify template name spelling and case
- Confirm you're targeting the correct Proxmox node
- Check template hasn't been deleted or renamed

### VM ID Conflict

**Symptom**: `VM ID already exists`

**Resolution**:
- Use `vm_id = 0` for automatic assignment
- Choose a different VM ID manually
- Remove conflicting VM if no longer needed: `qm destroy <ID>`

### SSH Connection Timeout

**Symptom**: `Timeout waiting for SSH`

**Resolution Steps**:
- Verify VM is running: `qm status <VM_ID>`
- Test network connectivity: `ping <VM_IP>`
- Confirm SSH password is correct
- Check VM firewall rules allow SSH (port 22)
- Verify cloud-init completed successfully

## Additional Documentation

- **Project Overview**: `../README.md`
- **Manual Setup**: `../docs/MANUAL_SETUP_GUIDE.md`
- **GitHub Secrets**: `../.github/SECRETS_SETUP.md`
- **Terraform Deployment**: `../milestone3-terraform/README.md`

## Pre-Deployment Checklist

Before initiating a build, verify:

- [ ] Template 108 exists and is accessible
- [ ] Proxmox credentials are valid
- [ ] GitHub Secrets configured (if using Actions)
- [ ] Network VLAN 69 is properly configured
- [ ] Storage pool has sufficient available space
- [ ] VM ID is available (if not using auto-assignment)
- [ ] Configuration file created and validated (for local builds)

---

For additional assistance or to report issues, please refer to the main project documentation or open an issue in the repository.
