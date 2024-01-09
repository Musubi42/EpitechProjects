## Gateway

# Configurer les interfaces réseaux

echo "Configuration des interfaces réseaux"

echo "dhcp" > /etc/hostname.em0 # Bridge
echo "inet 192.168.42.1 255.255.255.192 192.168.42.191" > /etc/hostname.em1 # Administration
echo "inet 192.168.42.65 255.255.255.192 192.168.42.127" > /etc/hostname.em2 # Server
echo "inet 192.168.42.129 255.255.255.192 192.168.42.191" > /etc/hostname.em3 # Employee

sh /etc/netstart

# Activer le transfert d'IP afin que les paquets puissent voyager entre les interfaces réseaux 

echo "Activation du transfert d'IP"

echo "net.inet.ip.forwarding=1" > /etc/sysctl.conf
sysctl net.inet.ip.forwarding=1

# Configuration de la redirection de traffic

echo "Configuration de la redirection de traffic"

echo "block all
pass in on any proto { tcp udp } to port { 53 80 443 }
pass in inet proto icmp icmp-type { echoreq }
pass in on em1 proto tcp to em2:network
match out on em0 nat-to em0
pass out quick inet keep state" > /etc/pf.conf

pfctl -f /etc/pf.conf

# Configuration du DHCP

echo "Configuration du DHCP"

echo "subnet 192.168.42.0 netmask 255.255.255.192 {
    option routers 192.168.42.1;
    option domain-name-servers 8.8.8.8;
    range 192.168.42.40 192.168.42.60;
}

subnet 192.168.42.64 netmask 255.255.255.192 {
    option routers 192.168.42.65;
    option domain-name-servers 8.8.8.8;
    range 192.168.42.70 192.168.42.110;
    host server {
        hardware ethernet 08:00:27:B4:6D:C8;
        fixed-address 192.168.42.70;
    }
}

subnet 192.168.42.128 netmask 255.255.255.192 {
    option routers 192.168.42.129;
    option domain-name-servers 8.8.8.8;
    range 192.168.42.140 192.168.42.180;
}" > /etc/dhcpd.conf

echo "dhcpd_flags=em1 em2 em3" > /etc/rc.conf.local

rcctl enable dhcpd
rcctl stop dhcpd
rcctl start dhcpd