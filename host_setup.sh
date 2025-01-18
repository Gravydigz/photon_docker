# host_setup.sh
# Script to complete the setup for PhotonOS
# "Go here for info https://vmware.github.io/photon/docs-v5/administration-guid"

# Script expects the node number
node="${1:-999}"

if [ $node -eq 1 ] || [ $node -eq 2 ] || [ $node -eq 3 ]; then
  echo "Setup for node number $node"
else
  echo "Missing parameter, this script expects the node number"
  exit 1
fi

# Set variables for the script
# variable 1 is hostname
# variable 2 is ip_addr
# variable 3 is gateway

case $node in
  1)
    hostname=docker$node
    ip_addr=10.0.151.$node
    gateway=10.0.151.254
    ;;
  2)
    hostname=docker$node
    ip_addr=10.0.151.$node
    gateway=10.0.151.254
    ;;
  3)
    hostname=docker$node
    ip_addr=10.0.151.$node
    gateway=10.0.151.254
    ;;
  *)
    hostname=dockerX
    ip_addr=10.0.151.199
    gateway=10.0.151.254
    ;;
esac

# Set static Variables
gateway=10.0.151.254
domain=gravydigz.lan
dns1=10.0.151.1
dns2=10.0.151.2
user=linuxadmin

echo "Variables Set"
echo "hostname: $hostname"
echo "ip_addr: $ip_addr"
echo "gateway: $gateway"
echo "domain: $domain"
echo "dns1: $dns1"
echo "dns2: $dns2"
echo "user: $user"

# Force ntp update
timedatectl set-ntp off
timedatectl set-ntp on
echo "NTP restarted"

# Deal with boot issues
#"echo \"blacklist floppy\" | tee /etc/modprobe.d/blacklist-floppy.conf"
#"rmmod floppy"
#"dpkg-reconfigure initramfs-tools"

# Reset the Machine ID for cloned images
echo -n > /etc/machine-id
systemd-machine-id-setup
echo "Machine ID set to $(cat /etc/machine-id)"

# Install and update system packages
tdnf install -y nano less
tdnf update -y
echo "System packages installed and updated"

# Configure Network
echo "$hostname" > /etc/hostname
echo "Hostname set to $(cat /etc/hostname)"

cat > /etc/systemd/network/10-static-en.network << EOF
[Match]

[Network]
Address=$ip_addr
Gateway=$gateway
Domains=$domain
DNS=$dns1
DNS=$dns2
EOF

chmod 644 /etc/systemd/network/10-static-en.network
chown systemd-network:systemd-network /etc/systemd/network/10-static-en.network
systemctl restart systemd-networkd
systemctl restart systemd-resolved
echo "Static IP setup and network restarted"

# Enable ping through iptables
iptables --list
iptables -A INPUT -p ICMP -j ACCEPT
iptables -A OUTPUT -p ICMP -j ACCEPT
iptables-save > /etc/systemd/scritps/ip4save
echo "iptables updated

# Create new user
useradd -m -G sudo,docker $user
passwd --expire changeme
echo "Users $user added"

# Start docker and enable on boot
systemctl start docker
systemctl enable docker
echo "Docker started and enabled on boot"
