# Actividad complementaria MikroTik · Parte 2: NAT y protección del router (equivale al TP2)
/ip firewall nat add chain=srcnat out-interface=ether1 action=masquerade comment="NAT LAN -> WAN"

# input: el router sólo acepta lo que inició o lo que viene de adentro
/ip firewall filter
add chain=input connection-state=established,related action=accept comment="input: respuestas"
add chain=input connection-state=invalid action=drop comment="input: invalidos"
add chain=input protocol=icmp action=accept comment="input: ping"
add chain=input in-interface=ether1 action=drop comment="input: nada mas desde la WAN"
