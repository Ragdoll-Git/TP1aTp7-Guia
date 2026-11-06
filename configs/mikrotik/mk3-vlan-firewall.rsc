# Actividad complementaria MikroTik · Parte 3: VLANs y firewall entre VLANs (equivale al TP3)
# Router "on a stick": las VLAN 10 y 20 viajan etiquetadas por ether2 (trunk)
/interface vlan
add name=vlan10 vlan-id=10 interface=ether2 comment="Alumnos"
add name=vlan20 vlan-id=20 interface=ether2 comment="Docentes"

/ip address
add address=192.168.10.1/24 interface=vlan10
add address=192.168.20.1/24 interface=vlan20

# Lista de interfaces internas (se usa en el firewall)
/interface list add name=LAN
/interface list member
add list=LAN interface=ether2
add list=LAN interface=vlan10
add list=LAN interface=vlan20

# forward: politica restrictiva, como el "policy drop" del TP3
/ip firewall filter
add chain=forward connection-state=established,related action=accept comment="fwd: respuestas"
add chain=forward connection-state=invalid action=drop comment="fwd: invalidos"
add chain=forward in-interface=vlan20 out-interface=vlan10 action=accept comment="fwd: docentes -> alumnos"
add chain=forward in-interface-list=LAN out-interface=ether1 action=accept comment="fwd: redes internas -> Internet"
add chain=forward action=drop comment="fwd: todo lo demas"
