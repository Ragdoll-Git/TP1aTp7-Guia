# Preguntas de repaso · Teoría TP1 + TP2

30 preguntas que combinan conceptos, verdadero/falso justificado, diagnóstico, interpretación de topologías, de comandos y de capturas.

> Las salidas de comandos y capturas de este documento son **ejemplos conceptuales** armados para el ejercicio, no resultados reales de laboratorio.

---

## A · Conceptuales

1. ¿Qué problema resuelve DHCP? Nombrá cuatro parámetros que puede entregar y para qué sirve cada uno.
2. ¿Por qué el mensaje DHCP Discover tiene como origen `0.0.0.0` y como destino `255.255.255.255`?
3. Explicá con tus palabras la diferencia entre un **pool** y una **reserva** DHCP.
4. ¿Qué diferencia hay entre un nombre de host, un dominio y un FQDN? Ejemplificá con `server.lab.local`.
5. ¿Qué decide la máscara de subred cuando un host va a enviar un paquete?
6. ¿Qué diferencia hay entre un Linux con `net.ipv4.ip_forward = 0` y uno con `1`?
7. ¿Por qué una red con direcciones privadas necesita NAT para navegar por Internet? ¿Qué pasaría con la respuesta si no lo hubiera?
8. Explicá la diferencia entre **routing** y **NAT** con un ejemplo en el que exista uno sin el otro.

## B · Verdadero o falso (justificá siempre)

9. "DHCP le da Internet al cliente."
10. "El servidor DNS de una red siempre es el router."
11. "DHCP necesita que el cliente tenga una IP previamente para poder pedir la suya."
12. "Si el servidor DHCP se apaga, todos los clientes pierden su IP en ese instante."
13. "Todo el tráfico que va hacia Internet pasa por el servidor DNS."
14. "NAT es un firewall."
15. "Si `ping 8.8.8.8` funciona, entonces la navegación web funciona."
16. "El cliente averigua por ARP la MAC del servidor web al que se conecta en Internet."

## C · Interpretación de topologías y configuraciones

17. Un cliente tiene:
    ```text
    IP:      10.20.20.100/24
    gateway: 10.20.30.1
    ```
    ¿Existe algún problema? ¿Qué destinos podrá alcanzar?
18. En la red `10.10.10.0/24`, el servidor DHCP (10.10.10.10) tiene configurado `dhcp-range=10.10.10.5,10.10.10.50`. ¿Qué problema de diseño ves?
19. Un router tiene en la WAN `192.168.122.50/24` y en la LAN `10.20.20.1/24`. Un cliente de la LAN pone como gateway `192.168.122.50`. ¿Funciona? ¿Por qué?
20. Un cliente tiene IP `10.20.20.100/16` (máscara equivocada) y gateway `10.20.20.1`. Intenta llegar a `10.20.99.5`, que está en otra red detrás del router. ¿Qué hace el cliente y qué observás?

## D · Interpretación de comandos

21. ¿Qué significa cada línea de esta salida?
    ```text
    $ ip route
    default via 10.20.20.1 dev enp1s0
    10.20.20.0/24 dev enp1s0 proto kernel scope link src 10.20.20.100
    ```
22. En esta salida de `dig`, ¿qué servidor respondió, qué se preguntó y cuál fue la respuesta?
    ```text
    ;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 4242
    ;; QUESTION SECTION:
    ;server.lab.local.        IN  A
    ;; ANSWER SECTION:
    server.lab.local.   0     IN  A   10.10.10.10
    ;; SERVER: 10.10.10.10#53(10.10.10.10) (UDP)
    ```
23. `dig nube.lab.local` devuelve `status: NXDOMAIN`. ¿Hay un problema de red? ¿Qué revisarías?
24. En el cliente, `cat /etc/resolv.conf` muestra `nameserver 127.0.0.53`. Un compañero dice que el DNS está mal configurado. ¿Tiene razón? ¿Qué comando usarías para comprobarlo?
25. `sysctl net.ipv4.ip_forward` devuelve `0` en el router. ¿Qué prueba del cliente funcionará y cuál no: `ping 10.20.20.1`, `ping <IP WAN del router>`, `ping 8.8.8.8`?

## E · Diagnóstico

26. `ping 1.1.1.1` funciona. `ping example.com` falla. ¿Dónde investigarías primero y con qué comandos?
27. El cliente tiene IP correcta y hace ping al servidor por IP, pero no por nombre. Ordená los pasos de diagnóstico.
28. El router tiene Internet, el cliente llega al router, pero el cliente no llega a Internet. ¿Cómo distinguís entre un problema de forwarding y uno de NAT usando `tcpdump`?

## F · Interpretación de capturas

29. En una captura con filtro `dhcp` ves sólo mensajes **DHCP Discover** repetidos, todos con el mismo Transaction ID y sin Offer. Proponé tres causas posibles.
30. Capturás simultáneamente en las dos interfaces del router mientras el cliente hace ping a 1.1.1.1:
    ```text
    LAN (enp2s0):  IP 10.20.20.100 > 1.1.1.1: ICMP echo request, id 7, seq 1
    WAN (enp1s0):  IP 10.20.20.100 > 1.1.1.1: ICMP echo request, id 7, seq 1
    ```
    No aparece ningún echo reply. ¿Qué funciona, qué falta y cómo lo corregirías?
