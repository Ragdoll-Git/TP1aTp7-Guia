# Actividad complementaria MikroTik · Parte 1: LAN, DHCP y DNS (equivale al TP1)
# ether1 = WAN (red "default", DHCP de fábrica) · ether2 = LAN (red "lab1")
/system identity set name=lab-mikrotik

/ip address add address=10.10.10.1/24 interface=ether2 comment="LAN lab1"

/ip pool add name=pool-lan ranges=10.10.10.100-10.10.10.199
/ip dhcp-server add name=dhcp-lan interface=ether2 address-pool=pool-lan lease-time=1h
/ip dhcp-server network add address=10.10.10.0/24 gateway=10.10.10.1 dns-server=10.10.10.1 domain=lab.local

/ip dns set servers=1.1.1.1,8.8.8.8 allow-remote-requests=yes
/ip dns static add name=router.lab.local address=10.10.10.1
/ip dns static add name=server.lab.local address=10.10.10.10
