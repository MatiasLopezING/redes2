# TP2

Topología spine-leaf de la figura 6. Enunciado: `redes-II-ing-practica_2.pdf`, **pág. 9**.

| Bloque IPv4 | Bloque IPv6 |
|---|---|
| `16.0.0.0/16` | `1600::/32` |

| Archivo | |
|---|---|
| `direccionamiento.md` | el diseño: qué IP va en cada interfaz |
| `informe.md` | el entregable — falta pegar las figuras |
| `topologia.imn` | la topología de CORE |
| `configs/configurar.sh` | configura cualquier nodo |
| `capturas/` | `.pcap` y screenshots |

---

## Cómo levantar la red

1. En la VM: `core-gui &` → abrir `/media/sf_tpi/tp2/topologia.imn`
2. **Start** (▶)
3. En la terminal de **cada router y cada PC** (doble click en el nodo):

```bash
bash /media/sf_tpi/tp2/configs/configurar.sh
```

El script detecta solo qué nodo es. Los hubs y switches no se configuran.
Orden: spines → leafs → routers de LAN → PCs.

**Probar:**

```bash
# desde n11
ping -c2 16.0.5.130    # a n33, cruza toda la topología (TTL 59)
ping -c2 1.2.3.4       # debe dar Network Unreachable, NO Time Exceeded
```

---

## Estado

- [x] Topología — 35 nodos, 37 enlaces
- [x] Direccionamiento IPv4 + IPv6
- [x] 14 routers configurados (2 spines, 4 leafs, 8 de LAN)
- [ ] 11 PCs — n11 n12 n13 n14 n29 n30 n31 n32 n33 n34 n35
- [ ] **(d)** ping + traceroute
- [ ] **(e)** captura n11 → n33: ARP e ICMP
- [ ] **(f)** captura del traceroute
- [ ] **(h)** IPv6 n34 ↔ n35 + ICMPv6
- [ ] Informe: pegar las figuras
- [ ] *(c)* NAT en n33 — alternativo
- [ ] *(g)* MTU y fragmentación — alternativo

Dos pendientes que no son configuración:

- En CORE, destildar los servicios **zebra / OSPFv2 / OSPFv3** de cada router — el
  enunciado pide ruteo **estático**.
- Las PCs quedaron creadas como tipo `router` en el `.imn`. Funciona igual, pero
  conviene cambiarlas a tipo *PC*.

---

## Decisiones (para el coloquio)

**VLSM de mayor a menor** — así cada bloque queda alineado a su propio tamaño.

**Los 16 enlaces punto a punto, todos en `16.0.6.0/24`**, de a `/30`.

**Net5 y Net6 no tienen enlace punto a punto** — el enunciado solo dice *"una red de 500
hosts"* y *"una red de 10 hosts"*, y n15/n16 son switches. Cuelgan directo de los spines.

**Ruteo: default hacia arriba, rutas específicas hacia abajo, los spines sin default.**
Esa regla hace imposible el bucle. Como no hay salida a Internet, el tráfico desconocido
muere en el spine en lugar de rebotar.

**No hace falta enlace spine1 ↔ spine2.** Net1–Net4 cuelgan de leafs conectados a ambos
spines. El único par que cruza es Net5 ↔ Net6, y va por leaf1.

**IPv6 con túnel 6in4** entre los dos spines, en vez de nativo: se tocan 2 nodos en lugar
de 4 y los leafs solo ven IPv4.

**Las rutas de tránsito `/29`.** Al principio las tablas de los spines solo tenían las
LANs y el ping de n1 a n24 fallaba — pero con `ping -I 16.0.2.1` andaba. El camino de ida
estaba bien; faltaba la vuelta hacia las redes `/30`. Se agregaron sumarizadas: los dos
enlaces de cada leaf quedaron contiguos, así que cada par de `/30` entra en un `/29`.

---

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
