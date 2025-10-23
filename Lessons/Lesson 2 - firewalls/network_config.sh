#!/bin/bash
# --- VirtualBox Network Configuration Script ---
# This script sets correct IPs & network adapters for all lab VMs
# Designed for your segmentation setup (DMZ, Server, Client zones)

# ---------- VM NAMES ----------
ROUTER="companyrouter"
DNS="dns"
WEB="web"
DB="database"
EMPLOYEE="employee"
RED="red"

# ---------- NETWORK NAMES ----------
INTERNAL_NET="intnet_internal"
FAKE_INTERNET="vboxnet1"    # host-only network
# NAT will be used for router only (optional for updates)

# ---------- COMPANY ROUTER CONFIG ----------
VBoxManage modifyvm "$ROUTER" --nic1 intnet --intnet1 "$INTERNAL_NET"
VBoxManage modifyvm "$ROUTER" --nic2 hostonly --hostonlyadapter2 "$FAKE_INTERNET"
VBoxManage modifyvm "$ROUTER" --nic3 nat

# Optional: ensure it starts clean
VBoxManage controlvm "$ROUTER" poweroff soft 2>/dev/null
VBoxManage startvm "$ROUTER" --type headless

# Assign IPs (router-on-a-stick setup)
# (You’ll run these inside the router VM via SSH or cloud-init)
echo "Inside router, run:"
cat <<'EOF'
nmcli connection add type ethernet con-name eth0 ifname eth2 autoconnect yes
nmcli connection modify eth2 ipv4.method manual
nmcli connection modify eth2 ipv4.addresses "172.30.10.1/24 172.30.20.1/24 172.30.30.1/24"
nmcli connection up eth2
EOF

# ---------- INTERNAL MACHINES ----------
# DNS (Server zone)
VBoxManage modifyvm "$DNS" --nic1 intnet --intnet1 "$INTERNAL_NET"
VBoxManage guestproperty set "$DNS" "/VirtualBox/GuestInfo/Net/0/V4/IP" "172.30.20.4"

# Web (DMZ)
VBoxManage modifyvm "$WEB" --nic1 intnet --intnet1 "$INTERNAL_NET"
VBoxManage guestproperty set "$WEB" "/VirtualBox/GuestInfo/Net/0/V4/IP" "172.30.10.10"

# Database (Server)
VBoxManage modifyvm "$DB" --nic1 intnet --intnet1 "$INTERNAL_NET"
VBoxManage guestproperty set "$DB" "/VirtualBox/GuestInfo/Net/0/V4/IP" "172.30.20.15"

# Employee (Client)
VBoxManage modifyvm "$EMPLOYEE" --nic1 intnet --intnet1 "$INTERNAL_NET"
VBoxManage guestproperty set "$EMPLOYEE" "/VirtualBox/GuestInfo/Net/0/V4/IP" "172.30.30.123"

# Red (attacker/fake internet)
VBoxManage modifyvm "$RED" --nic1 hostonly --hostonlyadapter1 "$FAKE_INTERNET"
VBoxManage guestproperty set "$RED" "/VirtualBox/GuestInfo/Net/0/V4/IP" "192.168.62.50"

echo "✅ Network configuration applied to all VMs."
echo "⚙️  Next step: set static IPs inside the OS (use /etc/sysconfig/network-scripts or /etc/netplan)."
