# GitHub Secrets Setup Guide

## 🔐 **Required GitHub Secrets**

This guide explains how to set up GitHub Secrets for the Packer build pipeline.

## 📋 **Secrets List**

### **Required Secrets**

| Secret Name | Description | Example Value |
|-------------|-------------|---------------|
| `PROXMOX_URL` | Proxmox API URL | `https://74.96.90.38:8006/api2/json` |
| `PROXMOX_USERNAME` | Proxmox username | `root@pam` |
| `PROXMOX_PASSWORD` | Proxmox password | `1qaz@WSX3edc$RFV` |
| `PROXMOX_NODE` | Proxmox node name | `tcnhq-prxmx01` |
| `SSH_PASSWORD` | SSH password for rocky user | `My!temp@123#456` |

## 🛠️ **How to Set Up Secrets**

### **Step 1: Navigate to Repository Settings**

1. Go to your GitHub repository: `https://github.com/Trinity-Technical-Services-LLC/Proxmox_RockyLinux_GoldenImage`
2. Click on **Settings** tab
3. In the left sidebar, click **Secrets and variables** → **Actions**

### **Step 2: Add Secrets**

Click **"New repository secret"** and add each secret:

#### **PROXMOX_URL**
- **Name**: `PROXMOX_URL`
- **Secret**: `https://74.96.90.38:8006/api2/json`

#### **PROXMOX_USERNAME**
- **Name**: `PROXMOX_USERNAME`
- **Secret**: `root@pam`

#### **PROXMOX_PASSWORD**
- **Name**: `PROXMOX_PASSWORD`
- **Secret**: `1qaz@WSX3edc$RFV`

#### **PROXMOX_NODE**
- **Name**: `PROXMOX_NODE`
- **Secret**: `tcnhq-prxmx01`

#### **SSH_PASSWORD**
- **Name**: `SSH_PASSWORD`
- **Secret**: `My!temp@123#456`

## 🚀 **How It Works**

### **Automatic Builds**
- **Push to main branch** → Triggers automatic build
- **Pull requests** → Validates configuration only

### **Manual Builds**
- Go to **Actions** → **Packer Build and Deploy** → **Run workflow**
- Optionally specify:
  - VM name (e.g., "web-server-01")
  - VM ID (0 for auto-assign, or specific number)

### **Dynamic VM Naming**
- **Automatic**: `rocky-linux-12345` (using build number)
- **Manual**: Use your custom name

## 🧪 **Testing**

### **Test with Manual Workflow**
1. Go to **Actions** tab
2. Click **"Packer Build and Deploy"**
3. Click **"Run workflow"**
4. Optionally enter VM name and ID
5. Click **"Run workflow"**

## ✅ **Verification Checklist**

- [ ] All 5 secrets added to GitHub
- [ ] Secret names match exactly (case-sensitive)
- [ ] Credentials tested manually
- [ ] GitHub Actions workflow tested
- [ ] Build logs show successful authentication

---

**⚠️ Important: Never commit actual passwords to the repository. Always use GitHub Secrets for sensitive information.**