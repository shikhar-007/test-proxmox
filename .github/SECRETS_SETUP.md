# GitHub Secrets Setup Guide

This guide walks you through configuring GitHub Secrets for the Packer build pipeline. These secrets allow GitHub Actions to securely connect to your Proxmox environment without exposing credentials in the codebase.

## Required Secrets

You'll need to configure five secrets in your GitHub repository. Here's what each one does:

| Secret Name | Description | Example Format |
|-------------|-------------|----------------|
| `PROXMOX_URL` | Proxmox API endpoint | `https://10.0.0.100:8006/api2/json` |
| `PROXMOX_USERNAME` | Proxmox authentication username | `root@pam` |
| `PROXMOX_PASSWORD` | Proxmox authentication password | Your secure password |
| `PROXMOX_NODE` | Target Proxmox node name | `proxmox-node-01` |
| `SSH_PASSWORD` | Rocky user SSH password | Minimum 15 characters (STIG requirement) |

## Configuration Steps

### Step 1: Access Repository Settings

Navigate to your GitHub repository and access the secrets configuration:

1. Open your repository at `https://github.com/Trinity-Technical-Services-LLC/Proxmox_RockyLinux_GoldenImage`
2. Click the **Settings** tab
3. In the left sidebar, expand **Secrets and variables**
4. Select **Actions**

### Step 2: Add Each Secret

Click **"New repository secret"** and configure each of the following:

#### PROXMOX_URL
```
Name: PROXMOX_URL
Value: https://YOUR_PROXMOX_IP:8006/api2/json
```
Use your Proxmox server's IP address or hostname. The URL must include `https://` and end with `/api2/json`.

#### PROXMOX_USERNAME
```
Name: PROXMOX_USERNAME
Value: root@pam
```
Typically `root@pam` for full administrative access. If you've created a dedicated API user, use that instead.

#### PROXMOX_PASSWORD
```
Name: PROXMOX_PASSWORD
Value: (your actual Proxmox password)
```
This is the password for the username specified above. GitHub encrypts this value - it cannot be viewed once saved.

#### PROXMOX_NODE
```
Name: PROXMOX_NODE
Value: tcnhq-prxmx01
```
The name of your Proxmox node. You can find this in the Proxmox web interface under Datacenter. If you have multiple nodes, choose your primary deployment target.

#### SSH_PASSWORD
```
Name: SSH_PASSWORD
Value: (minimum 15 characters)
```
This password will be used for the rocky user on deployed VMs. Must be at least 15 characters to meet STIG security requirements.

## How the Workflow Uses These Secrets

Once configured, the GitHub Actions workflow uses these secrets to:

**Manual Workflow Execution:**
- Navigate to the Actions tab
- Select "Packer Build and Deploy"
- Click "Run workflow"
- Provide runtime parameters (node name, VM ID, VM name, template name)
- Credentials are automatically loaded from GitHub Secrets

**Automated Builds:**
Currently disabled by default. When enabled, builds trigger automatically on repository pushes.

## Verifying Your Configuration

After adding all secrets, test the setup:

1. Go to the **Actions** tab in your repository
2. Select **"Packer Build and Deploy"** from the workflows list
3. Click **"Run workflow"**
4. Enter the following parameters:
   - Node name: Your Proxmox node (e.g., `tcnhq-prxmx01`)
   - VM ID: `110` or `0` for auto-assignment
   - VM name: `test-vm` or your preferred name
   - Template name: `rocky-linux-stig-manual`
5. Click **"Run workflow"** and monitor the execution

If the workflow fails with authentication errors, verify that:
- All secret names are spelled correctly (they're case-sensitive)
- Your Proxmox credentials work when logging in manually
- GitHub can reach your Proxmox server (check firewall rules)

## Security Considerations

**Best Practices:**
- Never commit passwords or credentials to the repository
- Rotate passwords regularly (at least quarterly)
- Use strong, unique passwords for each environment
- Review GitHub Actions logs periodically for suspicious activity

**Network Security:**
If your Proxmox server is behind a firewall, you'll need either:
- Firewall rules allowing GitHub's IP ranges (changes frequently)
- A self-hosted GitHub runner on your local network (recommended)

See `.github/SELF_HOSTED_RUNNER.md` for instructions on setting up a self-hosted runner.

## Troubleshooting

**Secret names are case-sensitive**
Ensure you've typed the names exactly as shown: `PROXMOX_URL`, not `proxmox_url`.

**Connection timeout errors**
If workflows fail with connection timeouts, your Proxmox server may not be accessible from GitHub's servers. Consider using a self-hosted runner.

**Authentication failures**
Verify your credentials by logging into Proxmox manually. Ensure you're using the correct username format (`root@pam`, not just `root`).

**STIG password policy violations**
The SSH password must be at least 15 characters. Use a mix of uppercase, lowercase, numbers, and special characters.

## Additional Resources

- **Main README**: `../README.md` - Project overview and quick start
- **Self-Hosted Runner Guide**: `SELF_HOSTED_RUNNER.md` - Local runner setup
- **Packer Configuration**: `../milestone1-packer/CONFIGURATION.md` - Detailed Packer setup

---

**Important**: GitHub Secrets are encrypted and secure. Once saved, secret values cannot be viewed - only updated or deleted. This ensures your credentials remain protected even from repository administrators.
