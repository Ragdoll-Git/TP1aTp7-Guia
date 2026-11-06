#!/bin/bash
# Script de validación para TP1 (ejecutar en LAB-CLIENT)

echo "--- Verificando TP1 - DHCP y DNS ---"

# Interfaz del laboratorio (red lab1); se puede pasar como argumento
IFACE=${1:-enp2s0}

# 1. IP
IP=$(ip -4 addr show $IFACE | grep -oP '(?<=inet\s)\d+(\.\d+){3}')
if [ -n "$IP" ]; then
    echo "PASS: Interfaz $IFACE activa con IP $IP"
else
    echo "FAIL: Interfaz sin IP"
fi

# 2. Gateway correcto
GW=$(ip route show default dev $IFACE | awk '{print $3; exit}')
if [ "$GW" = "10.10.10.1" ]; then
    echo "PASS: Default gateway es correcto (10.10.10.1)"
else
    echo "FAIL: Default gateway incorrecto ($GW)"
fi

# 3. DNS correcto
# systemd-resolved: /etc/resolv.conf apunta a 127.0.0.53; el DNS real se lee con resolvectl
DNS=$(resolvectl dns $IFACE 2>/dev/null | awk '{print $NF}')
if [ "$DNS" = "10.10.10.10" ]; then
    echo "PASS: DNS configurado correctamente (10.10.10.10)"
else
    echo "FAIL: DNS incorrecto ($DNS)"
fi

# 4. Resolución
RES=$(dig server.lab.local +short 2>/dev/null || nslookup server.lab.local 2>/dev/null | grep -A1 Name | grep Address | awk '{print $2}')
if [ "$RES" = "10.10.10.10" ]; then
    echo "PASS: Resolución DNS funciona (server.lab.local -> 10.10.10.10)"
else
    echo "FAIL: Falla resolución DNS de server.lab.local"
fi

# 5. Ping
if ping -c 1 10.10.10.10 &> /dev/null; then
    echo "PASS: Ping a LAB-SERVER exitoso"
else
    echo "FAIL: Ping a LAB-SERVER falló"
fi
