# keepalived_setup.sh
# Script to install and setup keepalived on docker swarm

# Set static variables
virtual_ip=10.0.151.100/24
auth_pass=AllYourBase64#

# Set dynamic variables
node = $(cat /etc/hostname)
case $node in
  docker1)
    peer1=10.0.151.2
    peer2=10.0.151.3
    gateway=10.0.151.254
    router_id=master
    state=MASTER
    priority=100
    ;;
  docker2)
    peer1=10.0.151.1
    peer2=10.0.151.3
    gateway=10.0.151.254
    router_id=backup1
    state=BACKUP
    priority=80
    ;;
  docker3)
    peer1=10.0.151.1
    peer2=10.0.151.2
    gateway=10.0.151.254
    router_id=backup2
    state=BACKUP
    priority=60
    ;;
  *)
    peer1=10.0.151.2
    peer2=10.0.151.3
    gateway=10.0.151.254
    state=BACKUP
    priority=0
    ;;
esac

echo "Variables Set"
echo "router_id: $router_id"
echo "state: $state"
echo "priority: $priority"
echo "peer1: $peer1"
echo "peer2: $peer2"
echo "virtual_ip: $virtual_ip"
echo "auth_pass: $auth_pass"

# install keepalived package on docker nodes
tdnf install keepalived -y
echo "keepalived package installed"

# setup node1 as master and node2 and node3 as backups
cat > /etc/keepalived/keepalived.conf << EOF
global_defs {
    router_id $router_id # naming this node
}

vrrp_instance VI_1 {
    state $state
    interface eth0
    virtual_router_id 50
#    mcast_src_ip 192.168.33.10 # IP of this node
    priority $priority # master 100-20=80 must be less than backup priority 90
    advert_int 1 # advert interval 1 second
    authentication {
        auth_type PASS
        auth_pass $auth_pass
    }
    Unicast_peer {
        $peer1 # list other keepalived peers 
        $peer2
    }
    virtual_ipaddress {
        $virtual_ip # virtual IP
    }
}
EOF
echo "keepalived.conf added"

# start keepalived and enable on boot
systemctl start keepalived
systemctl enable keepalived
echo "Keepalived started and enabled on boot"
