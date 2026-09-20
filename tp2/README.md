# TP2 — Direccionamiento, ruteo estático y capturas

Topología spine-leaf de la **figura 6**. Consigna en
[`redes-II-ing-practica_2.pdf`](redes-II-ing-practica_2.pdf), **página 9**.

| | |
|---|---|
| Bloque IPv4 asignado | |
| Bloque IPv6 asignado | |
| Entrega | |

| | |
|---|---|
| `direccionamiento.md` | el diseño IPv4/IPv6 — **el grueso del trabajo** |
| `configs/` | un `.sh` por nodo |
| `capturas/` | `.pcap` y screenshots |

Después se suman `topologia.imn` y `informe.md`.

---

## A tener en cuenta (pautas del profe)

**Ojo con los bucles.** Cada leaf se conecta a los dos spines, así que con ruteo
estático es fácil armar un loop. Regla: los **default van solo hacia arriba**
(PC → router → leaf → spine) y hacia abajo van **rutas específicas**. Los spines **no
llevan default** — acá no hay salida a Internet, el tráfico desconocido tiene que morir
arriba, no rebotar.
Se verifica con `ping` a una IP que no exista: si contesta **Network Unreachable (3/0)**
está bien; si contesta **Time Exceeded (11/0)**, hay loop.

**Para el IPv6 de Net5–Net6, usar un túnel 6in4.** Es mucho menos laburo que IPv6
nativo: se toca **solo n15 y n16**, el core sigue siendo IPv4 puro y los spines ni se
enteran. Requiere que el ruteo IPv4 ya funcione.

```bash
# en n15 (idem en n16 invirtiendo local/remote)
ip tunnel add tun6 mode sit remote <IPv4-n16> local <IPv4-n15> ttl 64
ip link set tun6 up
ip -6 addr add 2001:db8:0:ffff::1/64 dev tun6
ip -6 route add <prefijo-Net6>::/64 dev tun6
```

**No hace falta IPv6 en todos lados** — solo Net5 y Net6. Net1 a Net4 quedan IPv4 puro.

**Si el IPv6 no pasa de un router a otro, no es tu config.** Son dos cosas del
simulador:

```bash
sysctl -w net.ipv6.conf.all.forwarding=1   # viene APAGADO en los nodos de CORE
ip6tables -P FORWARD ACCEPT                # la política por defecto es DROP
```

El segundo es el script `ipv6-unfilter.sh` de la carpeta de la práctica.
Ojo además: al poner `forwarding=1` el nodo **deja de aceptar Router Advertisements**;
si necesita rutear *y* recibir RA, va `sysctl -w net.ipv6.conf.eth0.accept_ra=2`.

**NAT — punto (c), alternativo.** Los comandos están en
`linux.net.commands-nat.xtended.txt` de la práctica 1:

```bash
sysctl -w net.ipv4.ip_forward=1
iptables -P FORWARD ACCEPT
iptables -t nat -A POSTROUTING -s 192.168.1.0/24 -o eth0 -j MASQUERADE
```

**MTU — punto (g), alternativo.** `ip link set dev eth1 mtu 500`, después
`ping -s 1400` y capturar. El dato lindo para la presentación: si bajás el MTU **por
debajo de 1280** en el camino IPv6, IPv6 se rompe (es su mínimo obligatorio) y el router
devuelve **Packet Too Big** en vez de fragmentar.

---

## Orden sugerido

1. VLSM IPv4 en papel → `direccionamiento.md`
2. Armar la topología en CORE
3. IPv4 + ruteo estático → **verificar que no haya loop**
4. Túnel 6in4 n15 ↔ n16 → punto (a)
5. Capturas (e) (f) (h)
6. Alternativos: NAT (c) y MTU (g)

Del 4 en adelante depende de que el 3 ande. No arrancar con IPv6 antes de tener IPv4
funcionando.

---

## Qué mirar en cada captura

- **(e)** n11 y n33 están en **redes distintas** → n11 hace ARP **del gateway**, no de
  n33. La IP destino es n33 de punta a punta, la **MAC cambia en cada salto**. Echo
  Request **8/0**, Reply **0/0**.
- **(f)** TTL creciente → cada router devuelve **Time Exceeded 11/0**. El destino
  responde **3/3** si la sonda es UDP (Linux) o **0/0** si es ICMP (Windows).
- **(h)** **NDP** en vez de ARP: NS **135** / NA **136**, a multicast solicited-node
  `ff02::1:ffXX:XXXX`. MAC destino `33:33:ff:` + últimos 3 bytes de la IPv6. Hop Limit
  **255**. Echo Request/Reply **128/129**.

```bash
tcpdump -i eth0 -w /media/sf_tpi/tp2/capturas/e-n11-n33.pcap 'arp or icmp'
tcpdump -i eth0 -w /media/sf_tpi/tp2/capturas/f-traceroute.pcap 'icmp or udp'
tcpdump -i eth0 -w /media/sf_tpi/tp2/capturas/h-icmpv6.pcap 'icmp6'
```

---

## Qué falta

- [ ] Direccionamiento IPv4 (VLSM)
- [ ] IPv6 Net5 / Net6 — **(a)**
- [ ] Topología en CORE
- [ ] Ruteo estático IPv4 e IPv6 — **(b)**
- [ ] ping + traceroute — **(d)**
- [ ] Captura n11 → n33: ARP e ICMP — **(e)**
- [ ] Captura del traceroute — **(f)**
- [ ] IPv6 + ICMPv6 — **(h)**
- [ ] Informe / presentación
- [ ] *Alternativo:* NAT en n33 — **(c)**
- [ ] *Alternativo:* MTU y fragmentación — **(g)**
