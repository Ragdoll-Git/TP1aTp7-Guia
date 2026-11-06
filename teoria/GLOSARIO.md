# Glosario · Teoría TP1 + TP2

Definiciones breves y operativas. Entre paréntesis, dónde aparece en los laboratorios.

| Término | Definición |
|---|---|
| **DHCP** | *Dynamic Host Configuration Protocol*. Protocolo cliente-servidor (UDP 67 servidor / 68 cliente) que entrega automáticamente la configuración de red de un host: IP, máscara, gateway, DNS, dominio y tiempo de concesión. Configura parámetros; no da conectividad por sí mismo. (TP1: `dnsmasq` en LAB-SERVER) |
| **DORA** | Secuencia de cuatro mensajes con la que un cliente obtiene su configuración DHCP: **D**iscover (el cliente busca servidores, por broadcast), **O**ffer (el servidor propone una IP), **R**equest (el cliente pide esa oferta), **A**CK (el servidor confirma). Los cuatro comparten el mismo Transaction ID. |
| **Lease** | Concesión temporal de una dirección IP por DHCP. El cliente intenta renovarla a mitad de su duración (T1) y, si no lo logra y vence, debe dejar de usar la dirección. (TP1: 1 h) |
| **Pool** | Rango de direcciones que un servidor DHCP puede asignar dinámicamente. Debe estar dentro de la subred y excluir las direcciones fijas. (TP1: 10.10.10.100–10.10.10.200) |
| **DNS** | *Domain Name System*. Sistema distribuido y jerárquico que responde consultas como "¿qué IP tiene este nombre?". Usa el puerto 53 (UDP la mayoría de las consultas; TCP cuando hace falta). Traduce nombres; el tráfico de datos no pasa por él. |
| **Resolver** | Componente que resuelve nombres. En cada host hay un *stub resolver* (biblioteca del sistema) que pregunta al servidor DNS configurado; un *resolver recursivo* (p. ej. 8.8.8.8) recorre la jerarquía DNS en nombre del cliente. |
| **FQDN** | *Fully Qualified Domain Name*. Nombre completo y sin ambigüedad de un host, incluyendo todos sus dominios hasta la raíz: `server.lab.local.` (el punto final suele omitirse). |
| **Gateway** (default gateway) | Dirección IP de un router, **dentro de la misma subred del host**, al que éste entrega todo el tráfico destinado a redes que no son locales y para las que no tiene una ruta más específica. (TP2: 10.20.20.1) |
| **Router** | Equipo con interfaces en redes distintas que reenvía paquetes entre ellas según su tabla de rutas. En Linux requiere `net.ipv4.ip_forward = 1`. (TP2: LAB-ROUTER) |
| **Routing table** (tabla de rutas) | Lista de destinos (prefijos) con la interfaz y el próximo salto por donde enviar cada uno. Se consulta con `ip route`; para un destino puntual, `ip route get <IP>`. Si varias rutas coinciden, gana la de prefijo más largo. |
| **Default route** (ruta por defecto) | Ruta `0.0.0.0/0` (en Linux, `default`): coincide con cualquier destino y se usa sólo cuando no hay otra más específica. Apunta al gateway. |
| **Forwarding** (IP forwarding) | Capacidad del kernel de reenviar paquetes que no están dirigidos a una de sus propias direcciones. En Linux: `sysctl net.ipv4.ip_forward` (0 = host, 1 = router). |
| **NAT** | *Network Address Translation*. Modificación de direcciones IP (y a veces puertos) de los paquetes al atravesar un equipo. No es routing ni firewall. |
| **SNAT** | NAT de origen: reemplaza la IP de origen por una IP fija indicada en la regla. Se usa para que una red privada salga a Internet con la IP del router. |
| **DNAT** | NAT de destino: reemplaza la IP (y/o puerto) de destino. Se usa para publicar un servidor interno ("abrir un puerto"). No se usa en el TP2. |
| **Masquerade** | Variante de SNAT que usa automáticamente la IP actual de la interfaz de salida. Adecuada cuando la IP WAN es dinámica. En nftables: `oifname "enp1s0" masquerade` en una cadena `nat` con hook `postrouting`. (TP2) |
| **ARP** | *Address Resolution Protocol*. Obtiene la MAC correspondiente a una IP **de la red local** (pregunta por broadcast, respuesta unicast). Para destinos remotos, el host sólo resuelve la MAC de su gateway. Caché: `ip neigh`. |
| **ICMP** | *Internet Control Message Protocol*. Mensajes de control y error de IP: Echo Request/Reply (ping), Time Exceeded (traceroute), Destination/Port Unreachable. |
| **TTL** | *Time To Live*. Campo del encabezado IP que cada router decrementa en 1; al llegar a 0 el paquete se descarta y se envía ICMP Time Exceeded al origen. Evita bucles infinitos. (No confundir con el TTL de DNS, que es tiempo de caché en segundos.) |
| **traceroute** | Herramienta que descubre el camino hacia un destino enviando sondas con TTL creciente (1, 2, 3…) y registrando qué router responde en cada salto. El primer salto es el gateway del host. |
| **Wireshark** | Analizador de protocolos con interfaz gráfica. Permite capturar o abrir capturas (`.pcap`) y filtrarlas (`dhcp`, `dns`, `arp`, `icmp`) para inspeccionar cada campo de cada capa. |
| **tcpdump** | Capturador de tráfico de línea de comandos. Útil en VMs sin entorno gráfico: `tcpdump -i <interfaz> -n [-e] [-w archivo.pcap] <filtro>`. La captura guardada se puede abrir luego en Wireshark. |

## Términos complementarios

| Término | Definición |
|---|---|
| **DHCP Relay** | Agente (normalmente en un router) que reenvía como unicast los mensajes DHCP de una subred hacia un servidor ubicado en otra, porque el broadcast no atraviesa routers. |
| **APIPA / link-local** | Dirección `169.254.0.0/16` que un host se autoasigna cuando no obtiene respuesta de DHCP (por defecto en Windows/macOS; en Linux depende del gestor de red). Sólo sirve dentro del enlace; es una pista de que DHCP falló. |
| **Registro A / AAAA / CNAME / PTR / MX** | Tipos de registro DNS: nombre→IPv4, nombre→IPv6, alias hacia otro nombre, IP→nombre (resolución inversa), servidor de correo del dominio. |
| **NXDOMAIN / SERVFAIL** | Códigos de respuesta DNS: el nombre no existe / el servidor no pudo resolver. Ambos indican que el servidor **respondió**; un *timeout* indica que no hubo respuesta. |
| **Conntrack** | Tabla de seguimiento de conexiones del kernel Linux. NAT la usa para revertir cada traducción en la vuelta; la regla de NAT sólo se evalúa en el primer paquete de cada conexión. `conntrack -L` la muestra. |
| **PAT / NAPT** | Traducción de dirección **y puerto**, que permite que muchos hosts compartan una IP pública. Implícita en SNAT/masquerade de Linux. |
| **RFC 1918** | Norma que reserva los rangos privados `10.0.0.0/8`, `172.16.0.0/12` y `192.168.0.0/16`, no enrutables en Internet. |
