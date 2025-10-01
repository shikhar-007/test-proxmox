# Test Repository for Proxmox Rocky Linux Golden Image

This is a **TEST REPOSITORY** for validating the Packer, Ansible, and Terraform workflow before deploying to the client repository.

## ⚠️ **THIS IS A TEST REPOSITORY**

All testing and validation should happen here before pushing to:
- Client Repository: [Trinity-Technical-Services-LLC/Proxmox_RockyLinux_GoldenImage](https://github.com/Trinity-Technical-Services-LLC/Proxmox_RockyLinux_GoldenImage)

## 🧪 **Testing Workflow**

1. **Test Packer configuration** in this repo
2. **Test GitHub Actions workflows** with proper secrets
3. **Validate all functionality** works correctly
4. **Document any issues** and fixes
5. **Only after successful testing** → Push to client repo

## 📋 **Current Status**

- ✅ Packer configuration copied from client repo
- ✅ Ansible testing files copied
- ✅ GitHub Actions workflows copied
- ✅ Documentation copied
- ⏳ Ready for GitHub Actions testing

## 🔐 **GitHub Secrets Required**

Set these secrets in this test repository:

```
PROXMOX_URL=https://74.96.90.38:8006/api2/json
PROXMOX_USERNAME=root@pam
PROXMOX_PASSWORD=1qaz@WSX3edc$RFV
PROXMOX_NODE=tcnhq-prxmx01
SSH_PASSWORD=My!temp@123#456
```

## 🚀 **Testing Steps**

1. Set up GitHub secrets in this test repo
2. Go to Actions → Packer Build and Deploy → Run workflow
3. Monitor the build process
4. Fix any issues that arise
5. Document successful configuration

## 📊 **Test Results**

- [ ] GitHub Actions workflow runs successfully
- [ ] VM deploys from template
- [ ] SSH connectivity works
- [ ] Ansible tests pass
- [ ] All secrets properly configured

## ✅ **Ready for Client Repo**

After all tests pass in this repository, we'll:
1. Document the working configuration
2. Copy changes to client repository
3. Get approval before pushing
4. Push to client repository

---

**This is a safe testing environment - experiment freely!**