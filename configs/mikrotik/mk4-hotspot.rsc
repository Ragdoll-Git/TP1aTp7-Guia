# Actividad complementaria MikroTik · Parte 4: Hotspot para invitados (equivale al TP4)
/interface vlan add name=vlan30 vlan-id=30 interface=ether2 comment="Invitados"
/ip address add address=192.168.30.1/24 interface=vlan30
/interface list member add list=LAN interface=vlan30

/ip pool add name=pool-invitados ranges=192.168.30.100-192.168.30.199
/ip dhcp-server add name=dhcp-invitados interface=vlan30 address-pool=pool-invitados lease-time=30m
/ip dhcp-server network add address=192.168.30.0/24 gateway=192.168.30.1 dns-server=192.168.30.1

# Perfil: "trial" = boton de aceptar terminos (como el portal del TP4); usuario y clave = login tradicional
/ip hotspot profile add name=hsprof-invitados hotspot-address=192.168.30.1 dns-name=portal.lab.local login-by=http-chap,http-pap,trial trial-uptime-limit=1h trial-uptime-reset=1d
/ip hotspot add name=hs-invitados interface=vlan30 address-pool=pool-invitados profile=hsprof-invitados disabled=no
/ip hotspot user add name=invitado1 password=invitado123 server=hs-invitados limit-uptime=1h
