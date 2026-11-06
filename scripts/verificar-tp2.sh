#!/bin/bash
# Script de validación para TP2 (ejecutar en LAB-ROUTER)

echo "--- Verificando TP2 - Routing y NAT ---"

# 1. Dos interfaces activas
IFS=$(ip -4 addr show | grep inet | wc -l)
if [ "$IFS" -ge 3 ]; then # 1 loopback + 2 interfaces
    echo "PASS: Al menos dos interfaces configuradas en el router"
else
    echo "FAIL: Faltan interfaces en el router"
fi

# 2. IP Forwarding
FWD=$(cat /proc/sys/net/ipv4/ip_forward)
if [ "$FWD" = "1" ]; then
    echo "PASS: IP forwarding habilitado"
else
    echo "FAIL: IP forwarding deshabilitado"
fi

# 3. Reglas NAT
NAT=$(nft list ruleset 2>/dev/null | grep masquerade)
if [ -n "$NAT" ]; then
    echo "PASS: Regla NAT (masquerade) detectada en nftables"
else
    echo "FAIL: Regla NAT no encontrada en nftables"
fi

# 4. Salida a Internet del router
if ping -c 1 8.8.8.8 &> /dev/null; then
    echo "PASS: Conectividad a Internet desde el router"
else
    echo "FAIL: Sin conectividad a Internet desde el router"
fi

# Verificación de LAN (LAB-CLIENT)
if ping -c 1 10.20.20.100 &> /dev/null; then
    echo "PASS: Conectividad con el cliente en la LAN (10.20.20.100)"
else
    echo "FAIL: Sin conectividad con el cliente en la LAN (10.20.20.100)"
fi
