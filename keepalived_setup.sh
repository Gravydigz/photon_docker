# Script to install and setup keepalived on docker swarm

# install keepalived package on docker nodes
tdnf install keepalived -y

# setup node1 as master and node2 and node3 as backups
cat > /etc/keepalived/keepalived.conf << EOF
global_defs {
    router_id master_node # naming this node
}

vrrp_script check_nginx {
    script "/etc/keepalived/check_nginx.sh" # success when script returns 0; otherwise failed
    interval 1 # call script interval 1 second
    weight -20
    fall 3 # if failed for 3 times, set priority += weight, which means 100-20=80 here
}

vrrp_instance VI_1 {
    state MASTER
    interface eth0
    virtual_router_id 50
#    mcast_src_ip 192.168.33.10 # IP of this node
    priority 100 # master 100-20=80 must be less than backup priority 90
    advert_int 1 # advert interval 1 second
    authentication {
        auth_type PASS
        auth_pass MyKeepalived23$
    }
    Unicast_peer {
        10.0.0.ip # list other keepalived peers 
        10.0.0.ip
    }
    virtual_ipaddress {
        10.0.0.ip/24 # virtual IP
    }
}
EOF

# start keepalived and enable on boot
systemctl start keepalived
systemctl enable keepalived
