# Packer Configuration Guide

## 🎯 **Flexible Configuration for Different Environments**

This guide explains how to configure Packer for different environments (dev, staging, prod) and GitHub Actions.

## 📁 **Configuration Structure**

```
milestone1-packer/
├── packer.pkr.hcl              # Main Packer template
├── variables.pkr.hcl           # Variable definitions
├── terraform.tfvars.example    # Example variables file
├── environments/               # Environment-specific configs
│   ├── dev.tfvars             # Development environment
│   ├── staging.tfvars         # Staging environment
│   └── prod.tfvars            # Production environment
├── build.sh                   # Flexible build script
└── .github/workflows/         # GitHub Actions workflows
    └── packer-build.yml       # CI/CD pipeline
```

## 🔧 **Configuration Methods**

### **1. Environment Files (Recommended)**

Use environment-specific `.tfvars` files:

```bash
# Development
./build.sh -e dev

# Production
./build.sh -e prod

# Custom environment
./build.sh -f environments/custom.tfvars
```

### **2. Environment Variables**

Override any variable using `PACKER_VAR_` prefix:

```bash
export PACKER_VAR_proxmox_node="different-node"
export PACKER_VAR_vm_id="120"
export PACKER_VAR_vm_name="my-custom-vm"
./build.sh -e dev
```

### **3. Command Line Arguments**

Use the build script with specific parameters:

```bash
./build.sh -e dev -i 120 -n "my-vm" -b "build-123"
```

## 🌍 **Environment Configurations**

### **Development Environment** (`environments/dev.tfvars`)
```hcl
# Smaller resources for development
memory    = 1024
cores     = 1
disk_size = "10G"
vm_id     = 110
```

### **Production Environment** (`environments/prod.tfvars`)
```hcl
# Larger resources for production
memory    = 4096
cores     = 4
disk_size = "50G"
vm_id     = 0  # Auto-assign
```

## 🚀 **GitHub Actions Integration**

### **Secrets Required**

Set these secrets in your GitHub repository:

#### **Development Environment**
- `PROXMOX_URL`
- `PROXMOX_USERNAME`
- `PROXMOX_PASSWORD`
- `PROXMOX_NODE`
- `SSH_PASSWORD`

#### **Production Environment**
- `PROXMOX_URL_PROD`
- `PROXMOX_USERNAME_PROD`
- `PROXMOX_PASSWORD_PROD`
- `PROXMOX_NODE_PROD`
- `SSH_PASSWORD_PROD`

### **Workflow Triggers**

1. **Automatic Triggers**:
   - Push to `main` → Production build
   - Push to `develop` → Development build
   - Pull requests → Validation only

2. **Manual Triggers**:
   - Workflow dispatch with environment selection
   - Custom VM name input

### **Dynamic VM Naming**

GitHub Actions automatically generates unique VM names:

```yaml
# Development
vm_name: "rocky-linux-dev-12345"

# Production  
vm_name: "rocky-linux-prod-12345"

# Custom (via workflow dispatch)
vm_name: "my-custom-vm-name"
```

## 🔄 **VM ID Management**

### **Auto-Assignment** (Recommended for CI/CD)
```hcl
vm_id = 0  # Packer will auto-assign next available ID
```

### **Fixed Assignment** (For specific environments)
```hcl
vm_id = 110  # Specific VM ID
```

### **Dynamic Assignment** (GitHub Actions)
```yaml
PACKER_VAR_vm_id: ${{ github.run_number }}  # Uses build number
```

## 🏗️ **Build Process**

### **Local Development**
```bash
# Quick development build
./build.sh -e dev

# Custom build with specific parameters
./build.sh -e dev -i 120 -n "test-vm" -b "feature-123"
```

### **CI/CD Pipeline**
```yaml
# Automatic on push to develop
- name: Build Development VM
  env:
    PACKER_VAR_vm_id: ${{ github.run_number }}
    PACKER_VAR_vm_name: rocky-linux-dev-${{ github.run_number }}
  run: packer build -var-file="environments/dev.tfvars" packer.pkr.hcl
```

## 🔐 **Security Best Practices**

### **Secrets Management**
- ✅ Use GitHub Secrets for sensitive data
- ✅ Never commit passwords to repository
- ✅ Use different credentials per environment
- ✅ Rotate secrets regularly

### **Environment Isolation**
- ✅ Separate Proxmox nodes per environment
- ✅ Different VLANs per environment
- ✅ Isolated storage pools
- ✅ Environment-specific SSH keys

## 📊 **Configuration Examples**

### **Example 1: Development Build**
```bash
./build.sh -e dev
# Uses: environments/dev.tfvars
# VM ID: 110
# VM Name: rocky-linux-dev-manual-20240930-180000
```

### **Example 2: Production Build with Custom Name**
```bash
./build.sh -e prod -n "web-server-01"
# Uses: environments/prod.tfvars
# VM ID: Auto-assigned
# VM Name: web-server-01
```

### **Example 3: GitHub Actions Production Build**
```yaml
# Triggered on push to main
# VM ID: 12345 (build number)
# VM Name: rocky-linux-prod-12345
# Environment: prod
```

## 🐛 **Troubleshooting**

### **Common Issues**

1. **VM ID Conflict**:
   ```bash
   # Use auto-assignment
   ./build.sh -e dev -i 0
   ```

2. **Missing Environment File**:
   ```bash
   # Create custom environment
   cp environments/dev.tfvars environments/custom.tfvars
   # Edit custom.tfvars
   ./build.sh -f environments/custom.tfvars
   ```

3. **Invalid Variables**:
   ```bash
   # Validate configuration
   packer validate packer.pkr.hcl
   ```

### **Debug Mode**
```bash
# Enable verbose logging
export PACKER_LOG=1
export PACKER_LOG_PATH=packer.log
./build.sh -e dev
```

## 📚 **Best Practices**

1. **Use Environment Files**: Keep configurations organized
2. **Auto-Assign VM IDs**: Avoid conflicts in CI/CD
3. **Unique VM Names**: Include build ID or timestamp
4. **Separate Credentials**: Different secrets per environment
5. **Validate First**: Always validate before building
6. **Test Locally**: Test configurations before CI/CD

---

**This configuration system provides maximum flexibility while maintaining security and organization across different environments.**
