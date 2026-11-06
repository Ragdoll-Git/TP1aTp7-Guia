# Redes Inalámbricas · Laboratorio paso a paso

Versión reordenada y simplificada de Material basado en el repositorio [mendezgarabetti/redes-inalambricas-lab](https://github.com/mendezgarabetti/redes-inalambricas-lab) Asi se puede entender mejor que hay que hacer y por que. **Se hace de arriba hacia abajo, un archivo después del otro.** No hay que saltar de sección.

## Orden cronológico de cómo ir haciendo los trabajos

*Nota: Lo único que cambia es que el **TP6 se hace antes del TP5** porque tiene que ver con la radio virtual de WiFi que se configura primero en el TP6 y se usa después en el TP5.* ~~cositas de Mendez~~

| # | TP | Archivo | Qué vas a hacer | Dónde se trabaja | Tiempo aprox. |
|---|---|---|---|---|---|
| 0 | — | [`00-preparar-el-entorno.md`](00-preparar-el-entorno.md) | Crear las 2 VMs en VirtualBox e instalar los programas | Tu PC + las VMs | 1 h |
| 1 | TP1 | [`01-tp1-dhcp-dns.md`](01-tp1-dhcp-dns.md) | Un servidor que da IP y nombres | `lab-server` y `lab-client` | 45 min |
| 2 | TP2 | [`02-tp2-routing-nat.md`](02-tp2-routing-nat.md) | Un router que da salida a Internet (NAT) | `lab-server` (como router) y `lab-client` | 45 min |
| 3 | TP3 | [`03-tp3-vlans-firewall.md`](03-tp3-vlans-firewall.md) | Separar redes con VLANs y filtrar con firewall | solo `lab-server` | 1 h |
| 4 | TP4 | [`04-tp4-portal-cautivo.md`](04-tp4-portal-cautivo.md) | Un "Acepto los términos" para invitados | solo `lab-server` | 45 min |
| 5 | **TP6** | [`05-tp6-wifi-virtual.md`](05-tp6-wifi-virtual.md) | Un Wi-Fi que existe solo dentro de la VM | solo `lab-server` | 1 h |
| 6 | **TP5** | [`06-tp5-radius-8021x.md`](06-tp5-radius-8021x.md) | Wi-Fi con usuario y contraseña (RADIUS) | solo `lab-server` | 1 h |
| 7 | TP7 | [`07-tp7-integrador.md`](07-tp7-integrador.md) | Juntar todo: cada usuario cae en su VLAN | solo `lab-server` | 2 h |
| 8 | Optativo | [`08-mikrotik-opcional.md`](08-mikrotik-opcional.md) | Repetir TP1–TP4 en un MikroTik | 3.ª VM | 2 h |

Si algo falla, consultá: [`Fallas-y-Glosario.md`](Fallas-y-Glosario.md)


## Cómo leer cada capítulo

Todos tienen la misma forma:

1. **La idea en una frase.** Qué se está haciendo y por qué.
2. **Antes de empezar.** Qué tiene que estar listo.
3. **Pasos numerados.** Cada uno dice *dónde* se escribe (en qué VM), *qué* se escribe y *qué debería pasar*.
4. **Pruebas.** Tabla de "hago esto → debería ver esto".
5. **Evidencia a guardar.** Qué capturar para el informe.
6. **Si algo sale mal.**

## Convenciones

- 🖥️ `lab-server` = la VM donde está el servidor.

- 💻 `lab-client` = la VM cliente.

- 🖥️ PC real, anfitrión, o host = Es tu computadora física que almacena las VMs

- Los bloques de código se copian y pegan **tal cual**, salvo lo que esté entre `<ángulos>`.

- Las interfaces de red en VirtualBox se llaman `enp0s3` y `enp0s8`, pero si se llaman de otra forma las podes verificar con `ip -br link`.

- Las líneas que empiezan con `# ↓` son **comentarios** que explican el comando de abajo. No hace falta copiarlas (si las copiás, no pasa nada).
- Las contraseñas (`alumno123`, `testing123`, etc.) son **solo de laboratorio**.

## 5 reglas de oro

1. **Un cambio por vez.** Cambiás, probás, anotás. Si cambiás tres cosas juntas y se rompe, no sabés cuál fue.

2. **Podés "grabar" la terminal con:** `script -a <tpNumero>-terminal.log`
Cuando termines de hacer todos los comandos de un TP cortás la grabación con `exit`, te saldrá `Script done`.

    *Esa es una evidencia de los comandos que ejecutaste y sus resultados.*

3. **Guardá las capturas en archivo** (`tcpdump -w <captura-algo>.pcap`), las podés ver en la terminal con *tshark* o *termshark*; o con *wireshark* si las querés copiar a tu computadora.

4. **Sacá un snapshot de la VM antes de cada TP avanzado**: VirtualBox → Máquina → Tomar instantánea → `<Nombre-del-snapshot>`.

5. **Podés usar SSH, pero con cuidado.** En algunos TP vas a necesitar varias terminales abiertas, así que SSH es muy útil (cómo activarlo: [Paso 5 del capítulo 0](00-preparar-el-entorno.md#paso-5-opcional-pero-útil--entrar-por-ssh)).

    Pero también vas a usar `netplan apply` para aplicar cambios de red, y eso puede cortar la conexión SSH. Si pasa, volvé a conectarte o usá la consola de la VM.

## Qué hay en este repositorio

| Carpeta | Qué es |
|---|---|
| `00-…` a `08-…` | Los capítulos de la guía, en orden |
| [`configs/`](configs/) | Archivos de configuración que usan los TP (`portal.py`, `nftables-tp7.conf`, `hostapd-*.conf`, `dnsmasq-tp7.conf`, etc.). En el capítulo 0 se clona este repositorio en `lab-server` (queda en `~/guia`) para tenerlos a mano |
| [`scripts/`](scripts/) | `verificar-tp1.sh` y `verificar-tp2.sh`: comprueban con PASS/FAIL que el TP quedó bien |
| [`teoria/`](teoria/) | [Glosario](teoria/GLOSARIO.md), [preguntas de repaso](teoria/PREGUNTAS-REPASO.md) y PDF de teoría de TP1 y TP2 |

`configs/`, `scripts/` y `teoria/` son material del repositorio original [mendezgarabetti/redes-inalambricas-lab](https://github.com/mendezgarabetti/redes-inalambricas-lab) (Mgter. Ing. Miguel Méndez Garabetti), copiado sin modificar. La autoría de ese material es de su autor.
