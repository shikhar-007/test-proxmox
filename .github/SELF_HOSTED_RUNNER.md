# Self-Hosted GitHub Runner Setup

## Why You Need This

If your Proxmox server is on a private network (and it probably is for security reasons), GitHub's cloud-hosted runners can't reach it. The solution is to set up a self-hosted runner - essentially a machine on your local network that GitHub can talk to, which can then talk to your Proxmox server.

Think of it as a bridge between GitHub and your internal infrastructure.

## Prerequisites

Before you start, you'll need:

- A Linux machine with network access to your Proxmox server
- Ability to reach the Proxmox API (port 8006)
- Root or sudo access on the runner machine
- About 15 minutes to set everything up

**Supported Operating Systems:**
- Rocky Linux 8 or 9
- Ubuntu 20.04 or 22.04
- Debian 11 or 12
- Any modern Linux distribution

## Choosing a Runner Machine

You have several options for where to host your runner:

**Option 1: Dedicated VM on Proxmox** (Recommended)
- Pros: Isolated, secure, easy to manage
- Cons: Uses some resources on your Proxmox host
- Best for: Production environments

**Option 2: Existing Server on Same Network**
- Pros: No additional VM needed
- Cons: Shares resources with other services
- Best for: Testing or small deployments

**Option 3: Proxmox Host Itself**
- Pros: Direct access, no network hops
- Cons: Potential security concerns, requires careful setup
- Best for: Lab environments only (not recommended for production)

## Installation Steps

### Step 1: Prepare Your Runner Machine

Install the required software on your chosen machine.

**For Rocky Linux / CentOS / RHEL:**
```bash
# Update the system
sudo dnf update -y

# Install prerequisites
sudo dnf install -y git curl wget unzip

# Install Packer
cd /tmp
wget https://releases.hashicorp.com/packer/1.10.3/packer_1.10.3_linux_amd64.zip
unzip packer_1.10.3_linux_amd64.zip
sudo mv packer /usr/local/bin/
sudo chmod +x /usr/local/bin/packer

# Verify installation
packer version
```

**For Ubuntu / Debian:**
```bash
# Update the system
sudo apt update && sudo apt upgrade -y

# Install prerequisites
sudo apt install -y git curl wget unzip

# Install Packer
cd /tmp
wget https://releases.hashicorp.com/packer/1.10.3/packer_1.10.3_linux_amd64.zip
unzip packer_1.10.3_linux_amd64.zip
sudo mv packer /usr/local/bin/
sudo chmod +x /usr/local/bin/packer

# Verify installation
packer version
```

### Step 2: Register the Runner with GitHub

Now you need to connect your runner to your GitHub repository.

1. **Navigate to your repository settings**:
   - Go to your GitHub repository
   - Click **Settings** tab
   - In the left sidebar, click **Actions** → **Runners**

2. **Add a new runner**:
   - Click the **New self-hosted runner** button
   - Select **Linux** as the operating system
   - Select **x64** as the architecture

3. **Follow the provided commands**:

GitHub will show you custom commands with a unique token. They'll look something like this:

```bash
# Create a directory for the runner
mkdir actions-runner && cd actions-runner

# Download the latest runner package
curl -o actions-runner-linux-x64-2.319.0.tar.gz -L \
  https://github.com/actions/runner/releases/download/v2.319.0/actions-runner-linux-x64-2.319.0.tar.gz

# Extract the package
tar xzf ./actions-runner-linux-x64-2.319.0.tar.gz

# Configure the runner
./config.sh --url https://github.com/YOUR_ORG/YOUR_REPO --token YOUR_UNIQUE_TOKEN

# Test the runner (optional)
./run.sh
```

**Important**: Use the exact commands GitHub shows you, as they include your specific repository URL and authentication token.

### Step 3: Configure as a System Service

Running the runner as a service ensures it starts automatically and keeps running even after you log out.

```bash
# Install as a systemd service
sudo ./svc.sh install

# Start the service
sudo ./svc.sh start

# Verify it's running
sudo ./svc.sh status

# Enable automatic startup on boot
sudo systemctl enable actions.runner.*
```

### Step 4: Verify the Runner

Check that your runner is properly connected:

1. Go back to the Runners page in GitHub Settings
2. You should see your runner listed with a green "Idle" status
3. The runner name will be the hostname of your machine by default

**Troubleshooting**: If the runner shows as "Offline":
- Check the service status: `sudo ./svc.sh status`
- Review logs: `journalctl -u actions.runner.* -f`
- Verify network connectivity to GitHub

## Testing Your Runner

Now let's make sure the runner can actually reach your Proxmox server.

### Test 1: Network Connectivity

```bash
# Test Proxmox API access
curl -k https://YOUR_PROXMOX_IP:8006/api2/json/version

# You should see JSON output with version information
```

### Test 2: Packer Access

```bash
# Try initializing Packer
cd /path/to/your/packer/config
packer init packer.pkr.hcl

# Should download plugins successfully
```

### Test 3: Run a Workflow

Trigger a workflow in GitHub Actions and watch it execute on your runner:

1. Go to the **Actions** tab in your repository
2. Select **"Packer Build and Deploy"**
3. Click **"Run workflow"**
4. Provide the parameters
5. Watch the job - it should run on your self-hosted runner

## Security Considerations

### Runner Machine Security

**Best Practices:**
- Keep the runner OS updated regularly
- Use a dedicated user account (not root) for the runner service
- Implement firewall rules to restrict access
- Monitor runner logs for suspicious activity

**Firewall Configuration:**
```bash
# Allow outbound connections to GitHub (port 443)
# Allow connections to Proxmox (port 8006)
# Block everything else unless specifically needed

# Example for firewalld (Rocky Linux)
sudo firewall-cmd --permanent --add-rich-rule='rule family="ipv4" destination address="YOUR_PROXMOX_IP" port port="8006" protocol="tcp" accept'
sudo firewall-cmd --reload
```

### Network Security

- Place the runner on a management VLAN if possible
- Don't expose the runner to the internet
- Use VPN access for remote management
- Implement network segmentation

### Access Control

- Limit who can trigger workflows in GitHub
- Use repository secrets for all credentials
- Rotate secrets regularly
- Monitor GitHub Actions usage

## Maintenance

### Updating the Runner

GitHub releases new runner versions regularly. To update:

```bash
# Stop the service
sudo ./svc.sh stop

# Navigate to the actions-runner directory
cd ~/actions-runner

# Download and extract the new version
# (Get the URL from GitHub's runner download page)

# Start the service
sudo ./svc.sh start
```

### Monitoring

Check your runner's health regularly:

```bash
# Check service status
sudo ./svc.sh status

# View recent logs
journalctl -u actions.runner.* --since "1 hour ago"

# Check resource usage
top -p $(pgrep Runner.Listener)
```

### Troubleshooting Common Issues

**Runner goes offline unexpectedly:**
```bash
# Check logs
journalctl -u actions.runner.* -n 100

# Restart the service
sudo ./svc.sh stop
sudo ./svc.sh start
```

**Workflows fail with connection errors:**
```bash
# Test Proxmox connectivity from runner
curl -k https://YOUR_PROXMOX_IP:8006/api2/json/version

# Check firewall rules
sudo firewall-cmd --list-all
```

**Packer fails to download plugins:**
```bash
# Verify internet connectivity
ping -c 3 releases.hashicorp.com

# Check proxy settings if applicable
echo $HTTP_PROXY
echo $HTTPS_PROXY
```

## Multiple Runners

You can set up multiple runners for redundancy or load distribution:

1. Follow the same setup process on additional machines
2. Give each runner a unique name during configuration
3. GitHub will distribute jobs across available runners
4. Useful for high-availability setups

## Cleanup

If you need to remove a runner:

```bash
# Stop the service
sudo ./svc.sh stop

# Uninstall the service
sudo ./svc.sh uninstall

# Remove the runner from GitHub
./config.sh remove --token YOUR_REMOVAL_TOKEN

# Delete the runner directory
cd ..
rm -rf actions-runner
```

Then remove it from GitHub's runner list in the repository settings.

## Additional Resources

- [GitHub Actions Runner Documentation](https://docs.github.com/en/actions/hosting-your-own-runners)
- [Proxmox VE API Documentation](https://pve.proxmox.com/pve-docs/api-viewer/)
- [Packer Documentation](https://www.packer.io/docs)

## Success Checklist

Before considering your runner fully operational:

- [ ] Runner shows as "Idle" in GitHub
- [ ] Can successfully ping Proxmox API
- [ ] Packer commands execute successfully
- [ ] Test workflow completes successfully
- [ ] Service starts automatically on reboot
- [ ] Logs are accessible and understandable
- [ ] Firewall rules are properly configured
- [ ] Security best practices implemented

---

**Note**: A properly configured self-hosted runner should require minimal maintenance once set up. Monitor it periodically, keep it updated, and it will reliably execute your GitHub Actions workflows with access to your private infrastructure.
