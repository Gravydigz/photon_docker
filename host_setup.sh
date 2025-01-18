# "Go here for info https://vmware.github.io/photon/docs-v5/administration-guid"

# Force ntp update
timedatectl set-ntp off
timedatectl set-ntp on

# Deal with boot issues
#"echo \"blacklist floppy\" | tee /etc/modprobe.d/blacklist-floppy.conf"
#"rmmod floppy"
#"dpkg-reconfigure initramfs-tools"

# Reset the Machine ID for cloned images
echo -n > /etc/machine-id
systemd-machine-id-setup

# Update system
tdnf update -y

# Configure Network
echo "docker1" > /etc/hostname
cat > /etc/systemd/network/10-static-en.network << EOF
[Match]

[Network]
Address=10.0.151.101/24
Gateway=10.0.151.254
Domains=gravydigz.lan
DNS=10.0.151.1
DNS=10.0.151.2
EOF

chmod 644 /etc/systemd/network/10-static-en.network
chown systemd-network:systemd-network /etc/systemd/network/10-static-en.network
systemctl restart systemd-networkd
systemctl restart systemd-resolved

# Install other helpful packages
tdnf install -y nano less

# Enable ping through iptables
iptables --list
iptables -A INPUT -p ICMP -j ACCEPT
iptables -A OUTPUT -p ICMP -j ACCEPT
iptables-save > /etc/systemd/scritps/ip4save

# Create new user
useradd -m -G sudo,docker admin_tr
passwd --expire changeme

# Start docker and enable at boot
systemctl start docker
systemctl enable docker
