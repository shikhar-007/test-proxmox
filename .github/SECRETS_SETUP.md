# GitHub Secrets Setup Guide

## 🔐 **Required GitHub Secrets**

This guide explains how to set up GitHub Secrets for the Packer build pipeline.

## 📋 **Secrets List**

### **Required Secrets**

| Secret Name | Description | Example Value |
|-------------|-------------|---------------|
| `PROXMOX_URL` | Proxmox API URL | `https://YOUR_PROXMOX_IP:8006/api2/json` |
| `PROXMOX_USERNAME` | Proxmox username | `root@pam` |
| `PROXMOX_PASSWORD` | Proxmox password | `YOUR_PROXMOX_PASSWORD` |
| `PROXMOX_NODE` | Proxmox node name | `your-node-name` |
| `SSH_PASSWORD` | SSH password for rocky user | `YOUR_SSH_PASSWORD` |

## 🛠️ **How to Set Up Secrets**

### **Step 1: Navigate to Repository Settings**

1. Go to your GitHub repository
2. Click on **Settings** tab
3. In the left sidebar, click **Secrets and variables** → **Actions**

### **Step 2: Add Secrets**

Click **"New repository secret"** and add each secret:

#### **PROXMOX_URL**
- **Name**: `PROXMOX_URL`
- **Secret**: Your Proxmox API URL (e.g., `https://10.0.0.100:8006/api2/json`)

#### **PROXMOX_USERNAME**
- **Name**: `PROXMOX_USERNAME`
- **Secret**: Your Proxmox username (typically `root@pam`)

#### **PROXMOX_PASSWORD**
- **Name**: `PROXMOX_PASSWORD`
- **Secret**: Your Proxmox root password

#### **PROXMOX_NODE**
- **Name**: `PROXMOX_NODE`
- **Secret**: Your Proxmox node name (check in Proxmox web interface)

#### **SSH_PASSWORD**
- **Name**: `SSH_PASSWORD`
- **Secret**: Password for the `rocky` user in the VM (must be 15+ characters for STIG compliance)

## 🚀 **How It Works**

### **Automatic Builds**
- **Push to main branch** → Triggers automatic build
- **Pull requests** → Validates configuration only

### **Manual Builds**
- Go to **Actions** → **Packer Build and Deploy** → **Run workflow**
- Optionally specify:
  - Proxmox node
  - VM ID (0 for auto-assign)
  - VM name
  - Template name to clone from

### **Dynamic VM Naming**
- **Automatic**: `rocky-linux-<VM_ID>`
- **Manual**: Use your custom name

## 🧪 **Testing**

### **Test with Manual Workflow**
1. Go to **Actions** tab
2. Click **"Packer Build and Deploy"**
3. Click **"Run workflow"**
4. Enter required parameters:
   - Proxmox node name
   - VM ID
   - VM name
   - Template name
5. Click **"Run workflow"**

## ✅ **Verification Checklist**

- [ ] All 5 secrets added to GitHub
- [ ] Secret names match exactly (case-sensitive)
- [ ] Credentials tested manually in Proxmox
- [ ] GitHub Actions workflow tested
- [ ] Build logs show successful authentication

## 🔒 **Security Best Practices**

1. **Never commit credentials** to the repository
2. **Use GitHub Secrets** for all sensitive information
3. **Rotate passwords** regularly
4. **Use different passwords** for different environments (dev, staging, prod)
5. **Limit GitHub Actions** to self-hosted runners on secure networks
6. **Review access logs** regularly in Proxmox

## 📝 **Notes**

- All secrets are encrypted by GitHub
- Secrets are never exposed in logs or outputs
- Only GitHub Actions workflows can access these secrets
- You can update secrets anytime without changing code

---

**⚠️ IMPORTANT: Never share or commit actual passwords. This file contains examples only. Replace with your actual values in GitHub Secrets.**

