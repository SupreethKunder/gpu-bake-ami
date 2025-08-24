#!/usr/bin/env bash
set -eux

# ---------------------------
# Disable root login and password authentication
# ---------------------------
sudo sed -i 's/^#\?PasswordAuthentication.*/PasswordAuthentication no/' /etc/ssh/sshd_config
sudo sed -i 's/^#\?PermitRootLogin.*/PermitRootLogin no/' /etc/ssh/sshd_config
sudo systemctl restart ssh

# ---------------------------
# Sysctl hardening
# ---------------------------
sudo tee /etc/sysctl.d/99-cis.conf > /dev/null <<EOF
net.ipv4.ip_forward = 0
net.ipv4.conf.all.accept_source_route = 0
net.ipv4.conf.default.accept_source_route = 0
net.ipv4.conf.all.accept_redirects = 0
net.ipv4.conf.default.accept_redirects = 0
net.ipv4.conf.all.secure_redirects = 0
net.ipv4.conf.default.secure_redirects = 0
net.ipv4.conf.all.log_martians = 1
net.ipv4.conf.default.log_martians = 1
net.ipv4.icmp_echo_ignore_broadcasts = 1
net.ipv4.icmp_ignore_bogus_error_responses = 1
net.ipv4.tcp_syncookies = 1
net.ipv6.conf.all.accept_redirects = 0
net.ipv6.conf.default.accept_redirects = 0
net.ipv6.conf.all.accept_source_route = 0
net.ipv6.conf.default.accept_source_route = 0
EOF
sudo sysctl --system

# ---------------------------
# Install auditd
# ---------------------------
sudo apt-get update -y
sudo apt-get install -y auditd
sudo systemctl enable auditd

# ---------------------------
# Persistent journald logs
# ---------------------------
sudo sed -i 's/^#\?Storage=.*/Storage=persistent/' /etc/systemd/journald.conf
sudo systemctl restart systemd-journald

# ---------------------------
# Install security utilities
# ---------------------------
sudo apt-get install -y fail2ban needrestart apt-listchanges

# ---------------------------
# Configure Fail2Ban
# ---------------------------
sudo tee /etc/fail2ban/jail.local > /dev/null <<EOF
[DEFAULT]
bantime  = 3600
findtime  = 600
maxretry = 5
destemail = root@localhost
sender = fail2ban@$(hostname)
mta = sendmail
banaction = iptables-multiport
backend = systemd

[sshd]
enabled = true
port = ssh
logpath = /var/log/auth.log
EOF

sudo systemctl enable fail2ban
sudo systemctl restart fail2ban

echo "System hardening and Fail2Ban configuration completed."
