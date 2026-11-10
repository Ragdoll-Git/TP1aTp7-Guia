# 6 · TP5 · Wi-Fi empresarial: 802.1X, EAP y RADIUS

**La idea:** en WPA2-PSK todos comparten una clave. En **WPA2-Enterprise** cada persona entra con su usuario y contraseña, y **el AP nunca ve esa contraseña**: solo reenvía la conversación a un servidor **RADIUS**.

| Rol | Quién es en el laboratorio | Qué hace |
|---|---|---|
| **Supplicant** (cliente) | `wpa_supplicant` en el namespace `cliente` | Presenta las credenciales |
| **Authenticator** (AP) | `hostapd` | **No** conoce contraseñas: bloquea hasta que RADIUS diga que sí |
| **Authentication Server** | FreeRADIUS | Verifica y responde Accept/Reject (+ atributos + claves) |

Dos tramos, dos protocolos: **cliente ↔ AP = EAPOL** (por el aire) y **AP ↔ RADIUS = RADIUS** (UDP 1812).

**PEAP-MSCHAPv2** (el método de este TP): el cliente arma un **túnel TLS** con el servidor, valida su certificado y, dentro del túnel, manda usuario y contraseña. Al final RADIUS entrega al AP unas claves (`MS-MPPE-*`) de donde sale la PMK. **Cada usuario tiene claves propias**, a diferencia de WPA2-PSK.

## Antes de empezar

- TP6 hecho: existen las radios (`iw dev`) y el namespace `cliente`. Si no, volvé al capítulo 5.
- AP y cliente del TP6 apagados.
- Snapshot `antes-tp5`.

## Parte A · Probar solo FreeRADIUS (sin Wi-Fi)

**Paso 1.** Agregá los usuarios **al principio** de `/etc/freeradius/3.0/mods-config/files/authorize` (antes de cualquier línea `DEFAULT`):

```text
alumno1   Cleartext-Password := "alumno123"
docente1  Cleartext-Password := "docente123"
```

**Paso 2.** Validar y reiniciar:

```bash
# ↓ valida la configuración; debe terminar en 'Configuration appears to be OK'
freeradius -XC | tail -1          # debe decir: Configuration appears to be OK

# ↓ reinicia el servicio para que lea los usuarios nuevos
systemctl restart freeradius
```

**Paso 3.** Probar con `radtest` (simula a un AP, sin EAP):

```bash
# ↓ simula al AP: usuario, clave, servidor, puerto y secreto compartido
radtest alumno1 alumno123  127.0.0.1 0 testing123

# ↓ lo mismo con la clave equivocada (tiene que rechazar)
radtest alumno1 incorrecta 127.0.0.1 0 testing123
```

✅ El primero termina en `Received Access-Accept`, el segundo en `Received Access-Reject`.

`testing123` es el **secreto compartido** AP↔RADIUS (por defecto para `localhost`). En producción se cambia.

## Parte B · 802.1X real con el AP virtual

**Paso 4.** AP WPA2-Enterprise, `/etc/hostapd/tp5-eap.conf`:

```ini
interface=wlan0
driver=nl80211
ssid=UNCUYO-EDU
hw_mode=g
channel=1
ieee8021x=1
wpa=2
wpa_key_mgmt=WPA-EAP
rsn_pairwise=CCMP
own_ip_addr=127.0.0.1
nas_identifier=ap-lab
auth_server_addr=127.0.0.1
auth_server_port=1812
auth_server_shared_secret=testing123
ctrl_interface=/run/hostapd
```

**Paso 5.** Cliente, `/root/tp5-wpa.conf`:

```ini
ctrl_interface=/run/wpa_supplicant
network={
  ssid="UNCUYO-EDU"
  key_mgmt=WPA-EAP
  eap=PEAP
  identity="alumno1"
  password="alumno123"
  phase2="auth=MSCHAPV2"
  ca_cert="/etc/ssl/certs/ssl-cert-snakeoil.pem"
}
```

`ca_cert` hace que el cliente **valide** el certificado del servidor. En Debian, FreeRADIUS usa un certificado autofirmado (*snakeoil*) que en el laboratorio funciona como su propia CA.

**Paso 6.** Capturar los dos tramos y encender:

> 💡 **Tip:** este bloque tiene varias líneas; podés guardarlo en un archivo (por ejemplo `capturar-y-conectar-8021x.sh`) y ejecutarlo con `bash capturar-y-conectar-8021x.sh`.

```bash
tcpdump -i lo -w tp5-radius.pcap udp port 1812 &      # AP <-> RADIUS

tcpdump -i hwsim0 -w tp5-aire.pcap &                  # cliente <-> AP

hostapd -B -f /root/hostapd-tp5.log /etc/hostapd/tp5-eap.conf

ip netns exec cliente wpa_supplicant -B -i wlan1 -c /root/tp5-wpa.conf -f /root/wpa-tp5.log

sleep 10
```

**Paso 7.** Mirá los logs. ✅ En `/root/wpa-tp5.log`:

```text
CTRL-EVENT-EAP-STARTED EAP authentication started
CTRL-EVENT-EAP-PROPOSED-METHOD vendor=0 method=4 -> NAK
CTRL-EVENT-EAP-PROPOSED-METHOD vendor=0 method=25
CTRL-EVENT-EAP-METHOD EAP vendor 0 method 25 (PEAP) selected
CTRL-EVENT-EAP-SUCCESS EAP authentication completed successfully
CTRL-EVENT-CONNECTED - Connection to 02:00:00:00:00:00 completed
```

y en `/root/hostapd-tp5.log`:

```text
wlan0: EAPOL-4WAY-HS-COMPLETED 02:00:00:00:01:00
wlan0: STA 02:00:00:00:01:00 IEEE 802.1X: authenticated - EAP type: 25 (PEAP)
```

**Paso 8.** Analizar la captura RADIUS: `pkill tcpdump; tshark -r tp5-radius.pcap`. Esperá unos 20 paquetes: ~10 rondas `Access-Request` / `Access-Challenge` y un `Access-Accept` final con `MS-MPPE-Recv-Key` y `MS-MPPE-Send-Key`.

## Evidencia a guardar

- [ ] `tp5-terminal.log`
- [ ] Salida de los dos `radtest`
- [ ] `tp5-radius.pcap` y `tp5-aire.pcap`
- [ ] Los dos logs (cliente y AP)

## Preguntas para el informe

1. El servidor propuso primero el método 4 (MD5) y el cliente respondió **NAK**. ¿Qué es un NAK en EAP y por qué no aceptó MD5?
2. `radtest` necesitó 1 intercambio; PEAP, 10. ¿Qué se negocia en esas rondas?
3. ¿Por qué el `Access-Accept` de PEAP lleva claves (`MS-MPPE-*`) y el de `radtest` no?
4. ¿En qué tramo viajan las credenciales y cómo están protegidas? ¿Las ves en `tp5-aire.pcap`?
5. ¿Qué riesgo corre un cliente configurado **sin** `ca_cert`? (Investigá "evil twin".)
6. Compará PEAP-MSCHAPv2 con EAP-TLS: ¿qué necesita cada uno del lado del cliente?

## Si algo sale mal

| Síntoma | Causa |
|---|---|
| `radtest` → Reject con clave correcta | El usuario quedó **después** de una línea `DEFAULT`, o no reiniciaste FreeRADIUS |
| `radtest` sin respuesta | Secreto incorrecto o servicio caído |
| Cliente en bucle `EAP-STARTED` | Certificado rechazado (`ca_cert` mal) o fase 2 distinta |
| Quiero ver qué pasa adentro | `systemctl stop freeradius && freeradius -X` (modo debug) |

## Dejar listo para el TP7

```bash
pkill hostapd; ip netns exec cliente pkill wpa_supplicant; pkill tcpdump
```

➡️ Siguiente: [`07-tp7-integrador.md`](07-tp7-integrador.md)
