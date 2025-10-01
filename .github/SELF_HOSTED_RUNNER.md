# Self-Hosted GitHub Runner Setup

## 🎯 **Why Self-Hosted Runner?**

GitHub Actions cloud runners **cannot access your Proxmox server** because it's on a private network. A self-hosted runner solves this by running on a machine that has access to Proxmox.

## 📋 **Prerequisites**

- A Linux machine (Ubuntu, Rocky Linux, etc.) that can access Proxmox
- Network access to Proxmox API (port 8006)
- Packer installed on the runner machine
- Git installed on the runner machine

## 🚀 **Setup Steps**

### **Step 1: Prepare Runner Machine**

You can use:
- A VM on Proxmox itself
- A machine in the same network as Proxmox
- The Proxmox host itself (if secure)

**Install prerequisites:**
```bash
# Update system
sudo dnf update -y  # Rocky Linux
# or
sudo apt update && sudo apt upgrade -y  # Ubuntu

# Install required packages
sudo dnf install -y git curl wget  # Rocky Linux
# or
sudo apt install -y git curl wget  # Ubuntu

# Install Packer
wget https://releases.hashicorp.com/packer/1.10.3/packer_1.10.3_linux_amd64.zip
unzip packer_1.10.3_linux_amd64.zip
sudo mv packer /usr/local/bin/
packer version
```

### **Step 2: Add Runner to GitHub Repository**

1. **Go to**: https://github.com/shikhar-007/test-proxmox/settings/actions/runners
2. **Click**: "New self-hosted runner"
3. **Select**: Linux
4. **Follow the instructions** shown on the page

You'll see commands like:
```bash
# Download runner
mkdir actions-runner && cd actions-runner
curl -o actions-runner-linux-x64-2.319.0.tar.gz -L https://github.com/actions/runner/releases/download/v2.319.0/actions-runner-linux-x64-2.319.0.tar.gz
tar xzf ./actions-runner-linux-x64-2.319.0.tar.gz

# Configure runner
./config.sh --url https://github.com/shikhar-007/test-proxmox --token YOUR_TOKEN

# Run the runner
./run.sh
```

### **Step 3: Configure Runner as Service**

```bash
# Install runner as systemd service
sudo ./svc.sh install

# Start the service
sudo ./svc.sh start

# Check status
sudo ./svc.sh status
```

### **Step 4: Verify Runner is Online**

1. **Go to**: https://github.com/shikhar-007/test-proxmox/settings/actions/runners
2. **Check**: Runner shows as "Idle" (green circle)
3. **Verify**: Runner name appears in the list

## 🧪 **Testing the Self-Hosted Runner**

### **Step 1: Trigger Workflow**

1. Go to **Actions** → **Packer Build and Deploy**
2. Click **Run workflow**
3. The workflow will now run on your self-hosted runner

### **Step 2: Monitor Execution**

Watch the workflow progress:
- Runs on your self-hosted runner
- Has access to Proxmox network
- Can connect to Proxmox API
- Successfully deploys VMs

## 📊 **Expected Results**

✅ **Workflow runs on self-hosted runner**  
✅ **Connects to Proxmox successfully**  
✅ **Deploys VM from template**  
✅ **All steps complete successfully**  

## 🐛 **Troubleshooting**

### **Runner Not Showing Up**
```bash
# Check runner service status
sudo systemctl status actions.runner.shikhar-007-test-proxmox.*

# Check runner logs
journalctl -u actions.runner.shikhar-007-test-proxmox.* -f
```

### **Runner Offline**
```bash
# Restart runner service
sudo ./svc.sh restart

# Or manually run
./run.sh
```

### **Permission Issues**
```bash
# Ensure proper permissions
chown -R runner:runner ~/actions-runner
```

## 🔒 **Security Considerations**

- Use a dedicated runner machine (don't use Proxmox host)
- Keep runner machine updated
- Use minimal permissions
- Monitor runner logs regularly
- Rotate runner tokens periodically

## 📚 **Alternative: Use Proxmox Host as Runner**

If secure enough, you can use the Proxmox host itself:

```bash
# On Proxmox host
cd /opt
mkdir actions-runner && cd actions-runner

# Download and configure runner (follow GitHub instructions)

# Run as service
sudo ./svc.sh install
sudo ./svc.sh start
```

---

**Once the self-hosted runner is set up, the GitHub Actions workflow will work perfectly!** 🚀
