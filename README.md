# Redes de Datos II

Matías Lopez · Juan David Alvarez · Lautaro Nahuel Lopes

| Trabajo | Estado |
|---|---|
| [`tp2/`](tp2/) | incisos obligatorios completos — faltan los alternativos *(c)* y *(g)* |

## Setup

```bash
git clone https://github.com/MatiasLopezING/redes2.git
```

Montar **esa carpeta** en la VM para que CORE la vea:

1. VirtualBox → la VM (apagada) → *Configuración* → *Carpetas compartidas* → agregar la
   carpeta, nombre **`tpi`**, automontar ✅, solo lectura ❌
2. En la VM: `sudo usermod -aG vboxsf $USER` y reiniciar
3. Queda en `/media/sf_tpi`

Se edita y se hace git desde Windows; CORE corre en la VM.
La `.ova` no va al repo, cada uno la tiene local.

## Git

Todo en `main`, sin ramas.

```bash
git pull --rebase
git add -A && git commit -m "tp2: ..."
git pull --rebase && git push
```

- `git pull --rebase` **antes de tocar nada**
- **El `.imn` lo toca uno a la vez** y avisa por el grupo
- Las configs van en scripts, no clickeadas en la GUI

---

# TP2 — topología spine-leaf (figura 6)

Enunciado: `tp2/redes-II-ing-practica_2.pdf`, **pág. 9**.

| Bloque IPv4 | Bloque IPv6 |
|---|---|
| `16.0.0.0/16` | `1600::/32` |

| Archivo | |
|---|---|
| `informe.md` | **el entregable** — 34 figuras |
| `direccionamiento.md` | qué IP va en cada interfaz |
| `topologia.imn` | la topología de CORE |
| `configs/configurar.sh` | configura cualquier nodo |
| `capturas/` | las figuras, nombradas `Ejercicio<X>_fotoN_...` |

## Cómo levantar la red

1. En la VM: `core-gui &` → abrir `/media/sf_tpi/tp2/topologia.imn` → **Start** (▶)
2. En la terminal de **cada router y cada PC** (doble click en el nodo):

```bash
bash /media/sf_tpi/tp2/configs/configurar.sh
```

El script detecta solo qué nodo es. Los hubs y switches no se configuran.
Orden: spines → leafs → routers de LAN → PCs.

```bash
# probar, desde n11
ping -c2 16.0.5.130    # a n33, cruza toda la topología (TTL 59)
ping -c2 1.2.3.4       # debe dar Net Unreachable, NO Time Exceeded
```

## Estado

| Inciso | | Figuras |
|---|---|---|
| a) IPv6 en Net5 y Net6 + túnel | ✅ | 2 |
| b) Ruteo estático IPv4 e IPv6 | ✅ | 17 |
| *c) NAT en n33* | ⬜ | *alternativo* |
| d) ping y traceroute | ✅ | 3 |
| e) Captura n11 → n33: ARP e ICMP | ✅ | 4 |
| f) Traceroute capturado | ✅ | 4 |
| *g) MTU y fragmentación* | ⬜ | *alternativo* |
| h) IPv6 e ICMPv6 | ✅ | 4 |

Pendiente que no es configuración: en CORE, destildar los servicios
**zebra / OSPFv2 / OSPFv3** de cada router — el enunciado pide ruteo **estático**.
(El script igual los mata y limpia sus rutas al arrancar.)

## Decisiones (para el coloquio)

**VLSM de mayor a menor** — cada bloque queda alineado a su propio tamaño. 1520 de 65 536
direcciones usadas (2,3%).

**Los 16 enlaces punto a punto, todos en `16.0.6.0/26`**, de a `/30`.

**Net5 y Net6 no tienen enlace punto a punto** — el enunciado solo dice *"una red de 500
hosts"* y *"una red de 10 hosts"*, y n15/n16 son switches. Cuelgan directo de los spines.

**Ruteo: default hacia arriba, rutas específicas hacia abajo, los spines sin default.**
Esa regla hace imposible el bucle: el tráfico desconocido muere en el spine en lugar de
rebotar. Se demuestra en la figura D.3.

**No hace falta enlace spine1 ↔ spine2.** Net1–Net4 cuelgan de leafs conectados a ambos
spines. El único par que cruza es Net5 ↔ Net6, y va por leaf1.

**IPv6 con túnel 6in4** entre los dos spines, en vez de nativo: se tocan 2 nodos en lugar
de 4 y los leafs solo ven IPv4. Cuesta 20 bytes por datagrama (MTU 1480).

**Las rutas de tránsito `/29`.** Al principio las tablas de los spines solo tenían las
LANs y el ping de n1 a n24 fallaba — pero con `ping -I 16.0.2.1` andaba. El camino de ida
estaba bien; faltaba la vuelta hacia las redes `/30`. Se agregaron sumarizadas: los dos
enlaces de cada leaf quedaron contiguos, así que cada par de `/30` entra en un `/29`.
8 rutas en lugar de 16.

## Ojo

**Las interfaces no son simétricas.** CORE las numeró según el orden en que se trazaron
los enlaces:

| | eth0 | eth1 | eth2 | eth3 | eth4 |
|---|---|---|---|---|---|
| spine1 | leaf1 | **LAN Net5** | leaf2 | leaf3 | leaf4 |
| spine2 | leaf4 | leaf3 | **LAN Net6** | leaf2 | leaf1 |
| leaf1 | n1 | n2 | spine1 | spine2 | |
| leaf2/3/4 | router | router | **spine2** | **spine1** | |
| n1, n2 | **leaf** | LAN | | | |
| n17…n24 | **LAN** | leaf | | | |

**Si algo no anda:**

| Síntoma | Causa |
|---|---|
| El ping no pasa de un router | `sysctl -w net.ipv4.ip_forward=1` |
| Pasa en un sentido y no en el otro | `sysctl -w net.ipv4.conf.all.rp_filter=0` |
| IPv6 no atraviesa un router | `sysctl -w net.ipv6.conf.all.forwarding=1` |
| IPv6 sigue sin pasar | `ip6tables -P FORWARD ACCEPT` |
| Ping a IP inexistente da Time Exceeded | **hay un bucle de ruteo** |
| Aparecen rutas `proto zebra` | daemons de CORE — el script los mata |
| IPv4 anda pero IPv6 no, en el mismo cable | falta la link-local `fe80::` → ver abajo |

**Dos trampas de IPv6 en el simulador** (documentadas en el informe, inciso h):

1. `ip addr flush dev X` **sin `-4` borra también la `fe80::`**, y sin link-local el NDP
   no funciona. El script ya limpia solo IPv4 y las IPv6 de scope global.
2. Los switches de CORE son bridges de Linux y **filtran el multicast de NDP**. ARP usa
   broadcast y pasa; NDP usa multicast y no. Por eso los vecinos IPv6 de n34/n35 se
   cargan con `ip -6 neigh replace`.
