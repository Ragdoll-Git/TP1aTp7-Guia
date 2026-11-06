# Fallas comunes y glosario 

## Método: de abajo hacia arriba, un cambio por vez

Mirá las capas **en este orden**. La primera que falla es el problema.

> Si trabajás por SSH como el usuario `lab`, poné `sudo` delante de estos comandos (`iw`, `bridge`, `nft`, `journalctl`, `tcpdump`…). Sin `sudo`, algunos dicen `command not found` y otros no muestran nada.

| Capa | Pregunta | Comando |
|---|---|---|
| Radio | ¿El AP está activo? ¿El cliente asociado? | log de hostapd (`AP-ENABLED`), `iw dev wlan1 link`, `iw dev wlan0 station dump` |
| Autenticación | ¿EAP terminó bien? ¿RADIUS aceptó? | log de wpa_supplicant (`EAP-SUCCESS`), `freeradius -X` |
| VLAN | ¿Cayó en la VLAN correcta? | log de hostapd (`VLAN ID`), `bridge link` |
| IP | ¿Recibió IP de su rango? | `ip -n <ns> -br addr`, captura `dhcp` en el bridge |
| Gateway | ¿Llega a su gateway? | `ping 192.168.X.1` |
| Firewall | ¿Qué se descarta? | `journalctl -k \| grep TP7-DROP`, `nft list ruleset` |
| NAT / salida | ¿Sale traducido por la WAN? | `tcpdump -n -i enp0s3` |
| DNS | ¿Resuelve? | `dig @<gateway> example.com` |

## Síntomas frecuentes

| Síntoma | Causa más probable |
|---|---|
| dnsmasq en `failed` al instalarlo | Puerto 53 ocupado por systemd-resolved: `bind-interfaces` + `interface=` |
| Perdí la conexión con la VM | `netplan apply` por SSH: usá la consola de la VM |
| Desaparecieron las IPs de los bridges | Se reinició systemd-networkd (`netplan apply`): reasignalas |
| El TP2 "funciona" con el router mal | El cliente tiene su propia salida (¿quedó conectado el cable del NAT del cliente?): mirá `ip route` |
| `Not connected.` en `iw link` | Consultaste muy pronto, hostapd no corre o se movió el phy equivocado |
| hostapd: `did not include required VLAN ID` | Falta copiar los atributos del `inner-tunnel` (capítulo 7, paso 2) |
| El ping sigue andando tras borrar el NAT | Entrada de conntrack: lanzá un ping nuevo |
| Los phy cambiaron de número | Recargaste `mac80211_hwsim`: mirá `iw dev` |

## Filtros útiles de Wireshark / tshark

| Qué | Filtro |
|---|---|
| DHCP | `dhcp` |
| DNS | `dns` |
| Etiquetas 802.1Q | `vlan` · `vlan.id == 10` |
| Beacons de un SSID | `wlan.fc.type_subtype == 8 && wlan.ssid == "WIFI-UNCUYO"` |
| Autenticación / asociación | `wlan.fc.type_subtype == 11` · `wlan.fc.type_subtype == 0` |
| 4-way handshake | `eapol` |
| EAP (802.1X) | `eap` |
| RADIUS | `radius` · `radius.code == 2` (Accept) · `radius.code == 11` (Challenge) |

## Comandos que vas a usar todo el tiempo

```bash
ip -br addr           # interfaces e IPs (resumen)

ip route              # rutas;  ip route get <IP> = qué ruta usaría

ip neigh              # caché ARP

resolvectl status     # DNS por interfaz

ss -lunp              # quién escucha en qué puerto UDP

nft list ruleset      # reglas de firewall / NAT

tcpdump -i <if> -n -w archivo.pcap <filtro>       # capturar

tshark -r archivo.pcap -Y "<filtro>"              # analizar

ip netns exec <ns> <comando>                      # ejecutar "en otra computadora"
```

## Glosario express

| Término | En una frase |
|---|---|
| **DHCP** | Servicio que le da IP, gateway y DNS a quien se conecta |
| **DNS** | Traduce nombres a IPs |
| **Gateway** | El router por donde se sale de tu red |
| **NAT / masquerade** | Cambiar la IP privada de origen por la del router para salir a Internet |
| **conntrack** | Tabla de conexiones activas; hace que las respuestas vuelvan |
| **VLAN** | Red lógica separada en capa 2, identificada con un número |
| **Trunk** | Enlace que lleva varias VLANs con etiquetas 802.1Q |
| **Namespace** | "Computadora" simulada dentro de Linux, con su propia red |
| **SSID** | El nombre de una red Wi-Fi |
| **Beacon** | Trama con la que el AP anuncia su SSID |
| **PSK** | Clave compartida de Wi-Fi |
| **4-way handshake** | Los 4 mensajes (EAPOL) con los que cliente y AP acuerdan las claves de cifrado |
| **802.1X** | Control de acceso por puerto: nadie entra hasta que el servidor lo autoriza |
| **EAP / PEAP** | Protocolo de autenticación / su variante con túnel TLS + usuario y contraseña |
| **RADIUS** | Servidor que verifica credenciales y devuelve atributos (como la VLAN) |
| **Supplicant / Authenticator** | El cliente / el AP, en la jerga de 802.1X |
| **Portal cautivo** | Página a la que se redirige a los invitados hasta que aceptan |

Glosario ampliado y 30 preguntas de repaso: [`teoria/GLOSARIO.md`](teoria/GLOSARIO.md) y [`teoria/PREGUNTAS-REPASO.md`](teoria/PREGUNTAS-REPASO.md).
