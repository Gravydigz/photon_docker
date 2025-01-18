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
touch /etc/systemd/network/10-static-en.network
echo "[Match]" >> /etc/systemd/network/10-static-en.network
echo " " >> /etc/systemd/network/10-static-en.network
echo "[Network]" >> /etc/systemd/network/10-static-en.network
echo "Address=10.0.151.101/24" >> /etc/systemd/network/10-static-en.network
echo "Gateway=10.0.151.254" >> /etc/systemd/network/10-static-en.network
echo "Domains=gravydigz.lan" >> /etc/systemd/network/10-static-en.network
echo "DNS=10.0.151.1" >> /etc/systemd/network/10-static-en.network
echo "DNS=10.0.151.2" >> /etc/systemd/network/10-static-en.network
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
