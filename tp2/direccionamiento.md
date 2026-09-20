# Direccionamiento — grupo 0X

| | |
|---|---|
| **Bloque IPv4** | `16.0.0.0/16` — 65.536 direcciones |
| **Bloque IPv6** | `1600::/32` |
| Integrantes | Matías Lopez (02670/0) · Juan David Alvarez (03100/2) · Lautaro Nahuel Lopes (02978/9) |

**Criterio:** VLSM de mayor a menor. Las LAN arrancan en `16.0.0.0`; los enlaces punto a
punto van todos juntos en `16.0.6.0/24`. Cada router toma la **primera dirección
utilizable** de su LAN.

> ### ⚠️ Net5 y Net6 NO tienen enlace punto a punto
>
> El enunciado dice *"y las punto a punto con leaf"* solo para **Net1, Net2, Net3 y
> Net4**. Para Net5 dice únicamente *"una red de 500 hosts"* y para Net6 *"una red de 10
> hosts"*.
>
> En la figura 6, **n15 y n16 son switches**, no routers. Entonces:
> - La **LAN de Net5 cuelga directo de spine1** → el gateway es una interfaz de spine1
> - La **LAN de Net6 cuelga directo de spine2** → el gateway es una interfaz de spine2
>
> Son **16 enlaces punto a punto**, no 18. **Verificar esto al abrir el `.imn`** — si
> n15/n16 resultan ser routers, hay que agregar 2 enlaces `/30` y correr los gateways.

---

## 1. LANs

| Red | Hosts | Prefijo | Dirección de red | Gateway | Rango asignable | Broadcast |
|---|---|---|---|---|---|---|
| **Net5** | 500 | `/23` | `16.0.0.0` | **spine1** → `16.0.0.1` | 16.0.0.1 – 16.0.1.254 | `16.0.1.255` |
| **Net1-A** | 200 | `/24` | `16.0.2.0` | n1 → `16.0.2.1` | 16.0.2.1 – 16.0.2.254 | `16.0.2.255` |
| **Net1-B** | 200 | `/24` | `16.0.3.0` | n2 → `16.0.3.1` | 16.0.3.1 – 16.0.3.254 | `16.0.3.255` |
| **Net2-A** | 100 | `/25` | `16.0.4.0` | n17 → `16.0.4.1` | 16.0.4.1 – 16.0.4.126 | `16.0.4.127` |
| **Net3-A** | 100 | `/25` | `16.0.4.128` | n21 → `16.0.4.129` | 16.0.4.129 – 16.0.4.254 | `16.0.4.255` |
| **Net3-B** | 60 | `/26` | `16.0.5.0` | n22 → `16.0.5.1` | 16.0.5.1 – 16.0.5.62 | `16.0.5.63` |
| **Net2-B** | 30 | `/27` | `16.0.5.64` | n18 → `16.0.5.65` | 16.0.5.65 – 16.0.5.94 | `16.0.5.95` |
| **Net4-A** | 20 | `/27` | `16.0.5.96` | n23 → `16.0.5.97` | 16.0.5.97 – 16.0.5.126 | `16.0.5.127` |
| **Net4-B** | 20 | `/27` | `16.0.5.128` | n24 → `16.0.5.129` | 16.0.5.129 – 16.0.5.158 | `16.0.5.159` |
| **Net6** | 10 | `/28` | `16.0.5.160` | **spine2** → `16.0.5.161` | 16.0.5.161 – 16.0.5.174 | `16.0.5.175` |

**Máscaras:** /23 `255.255.254.0` · /24 `255.255.255.0` · /25 `255.255.255.128`
· /26 `255.255.255.192` · /27 `255.255.255.224` · /28 `255.255.255.240`

Subtotal: 512+256+256+128+128+64+32+32+32+16 = **1456 direcciones**

---

## 2. Enlaces punto a punto — `16.0.6.0/26`

16 enlaces `/30` (máscara `255.255.255.252`), 2 direcciones utilizables cada uno.

### Router de LAN ↔ leaf

| # | Tramo | Red | Router | Leaf |
|---|---|---|---|---|
| 1 | n1 ↔ leaf1 | `16.0.6.0/30` | n1 → `.1` | leaf1 → `.2` |
| 2 | n2 ↔ leaf1 | `16.0.6.4/30` | n2 → `.5` | leaf1 → `.6` |
| 3 | n17 ↔ leaf2 | `16.0.6.8/30` | n17 → `.9` | leaf2 → `.10` |
| 4 | n18 ↔ leaf2 | `16.0.6.12/30` | n18 → `.13` | leaf2 → `.14` |
| 5 | n21 ↔ leaf3 | `16.0.6.16/30` | n21 → `.17` | leaf3 → `.18` |
| 6 | n22 ↔ leaf3 | `16.0.6.20/30` | n22 → `.21` | leaf3 → `.22` |
| 7 | n23 ↔ leaf4 | `16.0.6.24/30` | n23 → `.25` | leaf4 → `.26` |
| 8 | n24 ↔ leaf4 | `16.0.6.28/30` | n24 → `.29` | leaf4 → `.30` |

### Leaf ↔ spine

| # | Tramo | Red | Leaf | Spine |
|---|---|---|---|---|
| 9 | leaf1 ↔ spine1 | `16.0.6.32/30` | leaf1 → `.33` | spine1 → `.34` |
| 10 | leaf1 ↔ spine2 | `16.0.6.36/30` | leaf1 → `.37` | spine2 → `.38` |
| 11 | leaf2 ↔ spine1 | `16.0.6.40/30` | leaf2 → `.41` | spine1 → `.42` |
| 12 | leaf2 ↔ spine2 | `16.0.6.44/30` | leaf2 → `.45` | spine2 → `.46` |
| 13 | leaf3 ↔ spine1 | `16.0.6.48/30` | leaf3 → `.49` | spine1 → `.50` |
| 14 | leaf3 ↔ spine2 | `16.0.6.52/30` | leaf3 → `.53` | spine2 → `.54` |
| 15 | leaf4 ↔ spine1 | `16.0.6.56/30` | leaf4 → `.57` | spine1 → `.58` |
| 16 | leaf4 ↔ spine2 | `16.0.6.60/30` | leaf4 → `.61` | spine2 → `.62` |

Subtotal: 16 × 4 = **64 direcciones**

**TOTAL: 1520 de 65.536** · Libre: `16.0.5.176`–`16.0.5.255` y `16.0.6.64`–`16.0.255.255`

---

## 3. Interfaces por nodo

Renombrar `ethN` según lo que muestre CORE.

| Nodo | Interfaz | Dirección | Va a |
|---|---|---|---|
| **n1** | eth0 | `16.0.2.1/24` | LAN Net1-A |
| | eth1 | `16.0.6.1/30` | leaf1 |
| **n2** | eth0 | `16.0.3.1/24` | LAN Net1-B |
| | eth1 | `16.0.6.5/30` | leaf1 |
| **n17** | eth0 | `16.0.4.1/25` | LAN Net2-A |
| | eth1 | `16.0.6.9/30` | leaf2 |
| **n18** | eth0 | `16.0.5.65/27` | LAN Net2-B |
| | eth1 | `16.0.6.13/30` | leaf2 |
| **n21** | eth0 | `16.0.4.129/25` | LAN Net3-A |
| | eth1 | `16.0.6.17/30` | leaf3 |
| **n22** | eth0 | `16.0.5.1/26` | LAN Net3-B |
| | eth1 | `16.0.6.21/30` | leaf3 |
| **n23** | eth0 | `16.0.5.97/27` | LAN Net4-A |
| | eth1 | `16.0.6.25/30` | leaf4 |
| **n24** | eth0 | `16.0.5.129/27` | LAN Net4-B |
| | eth1 | `16.0.6.29/30` | leaf4 |
| **leaf1** | eth0 | `16.0.6.2/30` | n1 |
| | eth1 | `16.0.6.6/30` | n2 |
| | eth2 | `16.0.6.33/30` | spine1 |
| | eth3 | `16.0.6.37/30` | spine2 |
| **leaf2** | eth0 | `16.0.6.10/30` | n17 |
| | eth1 | `16.0.6.14/30` | n18 |
| | eth2 | `16.0.6.41/30` | spine1 |
| | eth3 | `16.0.6.45/30` | spine2 |
| **leaf3** | eth0 | `16.0.6.18/30` | n21 |
| | eth1 | `16.0.6.22/30` | n22 |
| | eth2 | `16.0.6.49/30` | spine1 |
| | eth3 | `16.0.6.53/30` | spine2 |
| **leaf4** | eth0 | `16.0.6.26/30` | n23 |
| | eth1 | `16.0.6.30/30` | n24 |
| | eth2 | `16.0.6.57/30` | spine1 |
| | eth3 | `16.0.6.61/30` | spine2 |
| **spine1** | eth0 | `16.0.6.34/30` | leaf1 |
| | eth1 | `16.0.6.42/30` | leaf2 |
| | eth2 | `16.0.6.50/30` | leaf3 |
| | eth3 | `16.0.6.58/30` | leaf4 |
| | **eth4** | **`16.0.0.1/23`** | **LAN Net5** (vía switch n15) |
| **spine2** | eth0 | `16.0.6.38/30` | leaf1 |
| | eth1 | `16.0.6.46/30` | leaf2 |
| | eth2 | `16.0.6.54/30` | leaf3 |
| | eth3 | `16.0.6.62/30` | leaf4 |
| | **eth4** | **`16.0.5.161/28`** | **LAN Net6** (vía switch n16) |

**n15 y n16 son switches** → sin IP.
**n3, n4, n19, n20, n25, n26, n27, n28** también son switches → sin IP.

### PCs

| PC | Red | Dirección | Gateway |
|---|---|---|---|
| n11 | Net1-A | `16.0.2.10/24` | `16.0.2.1` |
| n12 | Net1-B | `16.0.3.10/24` | `16.0.3.1` |
| n13 | Net2-A | `16.0.4.10/25` | `16.0.4.1` |
| n14 | Net2-B | `16.0.5.70/27` | `16.0.5.65` |
| n29 | Net3-A | `16.0.4.140/25` | `16.0.4.129` |
| n30 | Net3-B | `16.0.5.10/26` | `16.0.5.1` |
| n31 | Net4-A | `16.0.5.100/27` | `16.0.5.97` |
| n32 | Net4-A | `16.0.5.101/27` | `16.0.5.97` |
| **n33** | Net4-B | `16.0.5.130/27` | `16.0.5.129` |
| n34 | Net5 | `16.0.0.10/23` | `16.0.0.1` |
| n35 | Net6 | `16.0.5.170/28` | `16.0.5.161` |

> Verificar contra el `.imn` qué PC cuelga de qué switch.

---

## 4. IPv6 — punto (a), solo Net5 ↔ Net6

Bloque `1600::/32`. Toda LAN lleva **/64**, sin importar los hosts.

| Segmento | Prefijo | Nodo | Dirección |
|---|---|---|---|
| **LAN Net5** | `1600:0:0:5::/64` | spine1 eth4 | `1600:0:0:5::1/64` |
| | | n34 | `1600:0:0:5::10/64` |
| **LAN Net6** | `1600:0:0:6::/64` | spine2 eth4 | `1600:0:0:6::1/64` |
| | | n35 | `1600:0:0:6::10/64` |
| **Túnel 6in4** | `1600:0:0:ffff::/64` | spine1 tun6 | `1600:0:0:ffff::1/64` |
| | | spine2 tun6 | `1600:0:0:ffff::2/64` |

El túnel va **entre los dos spines**, porque son ellos los que tienen las LANs IPv6.
Como extremos IPv4 se usan las interfaces hacia leaf1: **spine1 `16.0.6.34`** y
**spine2 `16.0.6.38`**. El túnel transita por leaf1 como IPv4 común (protocolo 41).

```bash
# ── spine1 ───────────────────────────────────────
ip -6 addr add 1600:0:0:5::1/64 dev eth4
ip tunnel add tun6 mode sit remote 16.0.6.38 local 16.0.6.34 ttl 64
ip link set tun6 up
ip -6 addr add 1600:0:0:ffff::1/64 dev tun6
ip -6 route add 1600:0:0:6::/64 dev tun6
sysctl -w net.ipv6.conf.all.forwarding=1
ip6tables -P FORWARD ACCEPT

# ── spine2 ───────────────────────────────────────
ip -6 addr add 1600:0:0:6::1/64 dev eth4
ip tunnel add tun6 mode sit remote 16.0.6.34 local 16.0.6.38 ttl 64
ip link set tun6 up
ip -6 addr add 1600:0:0:ffff::2/64 dev tun6
ip -6 route add 1600:0:0:5::/64 dev tun6
sysctl -w net.ipv6.conf.all.forwarding=1
ip6tables -P FORWARD ACCEPT

# ── n34 (PC de Net5) ─────────────────────────────
ip -6 addr add 1600:0:0:5::10/64 dev eth0
ip -6 route add default via 1600:0:0:5::1

# ── n35 (PC de Net6) ─────────────────────────────
ip -6 addr add 1600:0:0:6::10/64 dev eth0
ip -6 route add default via 1600:0:0:6::1
```

**Los leafs no se tocan** — solo ven paquetes IPv4 con protocolo 41.
**Requisito:** el ruteo IPv4 spine1 ↔ spine2 (vía leaf1) tiene que andar primero.

### Verificación
```bash
# desde n34
ping6 -c 4 1600:0:0:6::10
traceroute6 1600:0:0:6::10       # 2 saltos IPv6: spine1 (túnel) y spine2
```

---

## 5. Ruteo estático — punto (b)

**Regla anti-loop:** los `default` van **solo hacia arriba**. Hacia abajo, **rutas
específicas**. Los **spines NO llevan default**.

### PCs
```bash
ip route add default via <gateway de su LAN>
```

### Routers de LAN — n1, n2, n17, n18, n21, n22, n23, n24
```bash
ip route add default via <IP del leaf>      # n1: via 16.0.6.2
```

### Leafs — específicas hacia abajo, default hacia arriba
```bash
# leaf1
ip route add 16.0.2.0/24 via 16.0.6.1       # Net1-A vía n1
ip route add 16.0.3.0/24 via 16.0.6.5       # Net1-B vía n2
ip route add default via 16.0.6.34          # spine1
# ⚠️ leaf1 es el tránsito del túnel: necesita también
ip route add 16.0.5.160/28 via 16.0.6.38    # Net6 vía spine2
```

### Spines — sin default, solo específicas
```bash
# spine1  (tiene Net5 conectada en eth4)
ip route add 16.0.2.0/24   via 16.0.6.33    # Net1-A  vía leaf1
ip route add 16.0.3.0/24   via 16.0.6.33    # Net1-B  vía leaf1
ip route add 16.0.4.0/25   via 16.0.6.41    # Net2-A  vía leaf2
ip route add 16.0.5.64/27  via 16.0.6.41    # Net2-B  vía leaf2
ip route add 16.0.4.128/25 via 16.0.6.49    # Net3-A  vía leaf3
ip route add 16.0.5.0/26   via 16.0.6.49    # Net3-B  vía leaf3
ip route add 16.0.5.96/27  via 16.0.6.57    # Net4-A  vía leaf4
ip route add 16.0.5.128/27 via 16.0.6.57    # Net4-B  vía leaf4
ip route add 16.0.5.160/28 via 16.0.6.33    # Net6    vía leaf1 → spine2

# spine2  (tiene Net6 conectada en eth4) — idéntico pero por sus propios enlaces
ip route add 16.0.2.0/24   via 16.0.6.37
ip route add 16.0.3.0/24   via 16.0.6.37
ip route add 16.0.4.0/25   via 16.0.6.45
ip route add 16.0.5.64/27  via 16.0.6.45
ip route add 16.0.4.128/25 via 16.0.6.53
ip route add 16.0.5.0/26   via 16.0.6.53
ip route add 16.0.5.96/27  via 16.0.6.61
ip route add 16.0.5.128/27 via 16.0.6.61
ip route add 16.0.0.0/23   via 16.0.6.37    # Net5 vía leaf1 → spine1
```

**Por qué no hace falta un enlace spine1↔spine2:** Net1 a Net4 cuelgan de leafs que
tocan **los dos** spines, así que llegan a Net5 y a Net6 directo. El **único** par que
necesita cruzar de un spine al otro es **Net5 ↔ Net6**, y se resuelve ruteando por
leaf1. *(Esto es para defender en el coloquio.)*

### Verificación anti-loop
```bash
ping 1.2.3.4
# Network Unreachable (3/0)  → bien
# Time Exceeded (11/0)       → HAY LOOP
```

---

## 6. Orden de los puntos (c) y (e)

⚠️ **Hacer (e) antes que (c).**

El punto (e) pide capturar el tráfico **n11 → n33**. El punto (c) —alternativo— pide
ponerle a **n33** una IP privada RFC-1918 y NAT.

Si hacen (c) primero, n33 queda detrás de NAT y la captura de (e) muestra otra cosa.
Primero capturan con n33 en su `16.0.5.130/27`, después cambian a privada + NAT.

---

## 7. Checklist

- [ ] Verificar en el `.imn` que n15 y n16 sean switches
- [ ] Ninguna red se superpone
- [ ] Cada bloque arranca en múltiplo de su tamaño
- [ ] Cada interfaz tiene IP de la red de su segmento
- [ ] Los /30 usan solo las 2 direcciones del medio
- [ ] Las LAN IPv6 son /64
- [ ] `ping` a IP inexistente → Network Unreachable, no Time Exceeded
- [ ] (e) capturado antes de hacer (c)
