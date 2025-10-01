#!/bin/bash
# SSH configuration script for STIG compliance

set -euo pipefail

echo "Configuring SSH for STIG compliance..."

# Backup original SSH config
cp /etc/ssh/sshd_config /etc/ssh/sshd_config.backup

# Configure SSH for STIG compliance
cat > /etc/ssh/sshd_config << 'EOF'
# SSH Configuration for STIG Compliance

# Protocol version
Protocol 2

# Port configuration
Port 22

# Address family
AddressFamily any

# Listen addresses
ListenAddress 0.0.0.0

# Host keys
HostKey /etc/ssh/ssh_host_rsa_key
HostKey /etc/ssh/ssh_host_ecdsa_key
HostKey /etc/ssh/ssh_host_ed25519_key

# Logging
SyslogFacility AUTH
LogLevel INFO

# Authentication
LoginGraceTime 60
PermitRootLogin no
StrictModes yes
MaxAuthTries 3
MaxSessions 10

# Pubkey authentication
PubkeyAuthentication yes
AuthorizedKeysFile .ssh/authorized_keys

# Password authentication
PasswordAuthentication yes
PermitEmptyPasswords no
ChallengeResponseAuthentication no

# Kerberos options
KerberosAuthentication no
KerberosOrLocalPasswd yes
KerberosTicketCleanup yes

# GSSAPI options
GSSAPIAuthentication no
GSSAPICleanupCredentials yes

# Set this to 'yes' to enable PAM authentication, account processing,
# and session processing. If this is enabled, PAM authentication will
# be allowed through the ChallengeResponseAuthentication and
# PasswordAuthentication. Depending on your PAM configuration,
# PAM authentication via ChallengeResponseAuthentication may bypass
# the setting of "PermitRootLogin without-password".
# If you just want the PAM account and session checks to run without
# PAM authentication, then enable this but set PasswordAuthentication
# and ChallengeResponseAuthentication to 'no'.
UsePAM yes

# Allow client to pass locale environment variables
AcceptEnv LANG LC_CTYPE LC_NUMERIC LC_TIME LC_COLLATE LC_MONETARY LC_MESSAGES
AcceptEnv LC_PAPER LC_NAME LC_ADDRESS LC_TELEPHONE LC_MEASUREMENT
AcceptEnv LC_IDENTIFICATION LC_ALL LANGUAGE
AcceptEnv XMODIFIERS

# Override default of no subsystems
Subsystem sftp /usr/libexec/openssh/sftp-server

# Client alive settings
ClientAliveInterval 300
ClientAliveCountMax 2

# Compression
Compression delayed

# Banner
Banner /etc/issue.net

# Allow users
AllowUsers rocky

# Deny users
DenyUsers root

# X11 forwarding
X11Forwarding no
X11DisplayOffset 10
X11UseLocalhost yes

# Print motd
PrintMotd yes
PrintLastLog yes
TCPKeepAlive yes

# UsePrivilegeSeparation
UsePrivilegeSeparation sandbox

# MaxStartups
MaxStartups 10:30:60

# Banner
Banner /etc/issue.net

# AllowTcpForwarding
AllowTcpForwarding no

# GatewayPorts
GatewayPorts no

# PermitTunnel
PermitTunnel no

# ChrootDirectory
ChrootDirectory none

# VersionAddendum
VersionAddendum none

# UseDNS
UseDNS no

# PidFile
PidFile /var/run/sshd.pid

# MaxStartups
MaxStartups 10:30:60

# PermitTunnel
PermitTunnel no

# ChrootDirectory
ChrootDirectory none

# VersionAddendum
VersionAddendum none

# UseDNS
UseDNS no

# PidFile
PidFile /var/run/sshd.pid
EOF

# Create SSH banner
cat > /etc/issue.net << 'EOF'
***************************************************************************
*                                                                         *
*  This system is for the use of authorized users only.  Individuals     *
*  using this computer system without authority, or in excess of their   *
*  authority, are subject to having all of their activities on this      *
*  system monitored and recorded by system personnel.                     *
*                                                                         *
*  In the course of monitoring individuals improperly using this         *
*  system, or in the course of system maintenance, the activities of     *
*  authorized users may also be monitored.  Anyone using this system     *
*  expressly consents to such monitoring and is advised that if such     *
*  monitoring reveals possible evidence of criminal activity, system     *
*  personnel may provide the evidence of such monitoring to law          *
*  enforcement officials.                                                 *
*                                                                         *
***************************************************************************
EOF

# Set proper permissions
chmod 644 /etc/issue.net
chmod 600 /etc/ssh/sshd_config

# Create .ssh directory for rocky user
mkdir -p /home/rocky/.ssh
chmod 700 /home/rocky/.ssh
chown rocky:rocky /home/rocky/.ssh

# Create authorized_keys file
touch /home/rocky/.ssh/authorized_keys
chmod 600 /home/rocky/.ssh/authorized_keys
chown rocky:rocky /home/rocky/.ssh/authorized_keys

# Configure SSH client
cat > /etc/ssh/ssh_config << 'EOF'
# SSH Client Configuration for STIG Compliance

Host *
    GSSAPIAuthentication no
    StrictHostKeyChecking ask
    UserKnownHostsFile ~/.ssh/known_hosts
    HashKnownHosts yes
    SendEnv LANG LC_*
    ForwardX11 no
    ForwardX11Trusted no
    ForwardAgent no
    Protocol 2
    Ciphers aes128-ctr,aes192-ctr,aes256-ctr
    MACs hmac-sha2-256,hmac-sha2-512
    ServerAliveInterval 300
    ServerAliveCountMax 2
EOF

# Set proper permissions
chmod 644 /etc/ssh/ssh_config

# Restart SSH service
systemctl restart sshd
systemctl enable sshd

echo "SSH configuration completed successfully"