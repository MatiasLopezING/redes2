# Configuración manual, nodo por nodo

> **Las direcciones IP ya no hace falta cargarlas.** Están guardadas en `topologia.imn` y
> CORE las aplica sola al apretar **Start**. Acá quedan únicamente las **rutas**, los
> **sysctl** y el **túnel**, que el `.imn` no puede guardar.

Cada bloque se pega **entero** en la terminal del nodo (doble click sobre el nodo).
Son idempotentes: podés pegarlos dos veces sin problema.

**Orden:** spines → leafs → routers de LAN → PCs.
**No se configuran** los hubs (n3 n4 n19 n20 n25 n26 n27 n28) ni los switches (n15 n16).

---

# 1 · Spines

## n5-spine1 — **sin ruta por defecto** (es lo que evita el bucle)

```bash
sysctl -qw net.ipv4.ip_forward=1
sysctl -qw net.ipv6.conf.all.forwarding=1
sysctl -qw net.ipv4.conf.all.rp_filter=0
iptables -P FORWARD ACCEPT; ip6tables -P FORWARD ACCEPT
ip route replace 16.0.2.0/24 via 16.0.6.33
ip route replace 16.0.3.0/24 via 16.0.6.33
ip route replace 16.0.4.0/25 via 16.0.6.41
ip route replace 16.0.5.64/27 via 16.0.6.41
ip route replace 16.0.4.128/25 via 16.0.6.49
ip route replace 16.0.5.0/26 via 16.0.6.49
ip route replace 16.0.5.96/27 via 16.0.6.57
ip route replace 16.0.5.128/27 via 16.0.6.57
ip route replace 16.0.5.160/28 via 16.0.6.33
ip route replace 16.0.6.0/29 via 16.0.6.33
ip route replace 16.0.6.32/29 via 16.0.6.33
ip route replace 16.0.6.8/29 via 16.0.6.41
ip route replace 16.0.6.40/29 via 16.0.6.41
ip route replace 16.0.6.16/29 via 16.0.6.49
ip route replace 16.0.6.48/29 via 16.0.6.49
ip route replace 16.0.6.24/29 via 16.0.6.57
ip route replace 16.0.6.56/29 via 16.0.6.57
ip tunnel del tun6 2>/dev/null
ip tunnel add tun6 mode sit remote 16.0.6.38 local 16.0.6.34 ttl 64
ip link set tun6 up
ip -6 addr add 1600:0:0:ffff::1/64 dev tun6
ip -6 route replace 1600:0:0:6::/64 dev tun6
```

## n6-spine2 — **sin ruta por defecto**

```bash
sysctl -qw net.ipv4.ip_forward=1
sysctl -qw net.ipv6.conf.all.forwarding=1
sysctl -qw net.ipv4.conf.all.rp_filter=0
iptables -P FORWARD ACCEPT; ip6tables -P FORWARD ACCEPT
ip route replace 16.0.2.0/24 via 16.0.6.37
ip route replace 16.0.3.0/24 via 16.0.6.37
ip route replace 16.0.4.0/25 via 16.0.6.45
ip route replace 16.0.5.64/27 via 16.0.6.45
ip route replace 16.0.4.128/25 via 16.0.6.53
ip route replace 16.0.5.0/26 via 16.0.6.53
ip route replace 16.0.5.96/27 via 16.0.6.61
ip route replace 16.0.5.128/27 via 16.0.6.61
ip route replace 16.0.0.0/23 via 16.0.6.37
ip route replace 16.0.6.0/29 via 16.0.6.37
ip route replace 16.0.6.32/29 via 16.0.6.37
ip route replace 16.0.6.8/29 via 16.0.6.45
ip route replace 16.0.6.40/29 via 16.0.6.45
ip route replace 16.0.6.16/29 via 16.0.6.53
ip route replace 16.0.6.48/29 via 16.0.6.53
ip route replace 16.0.6.24/29 via 16.0.6.61
ip route replace 16.0.6.56/29 via 16.0.6.61
ip tunnel del tun6 2>/dev/null
ip tunnel add tun6 mode sit remote 16.0.6.34 local 16.0.6.38 ttl 64
ip link set tun6 up
ip -6 addr add 1600:0:0:ffff::2/64 dev tun6
ip -6 route replace 1600:0:0:5::/64 dev tun6
```

---

# 2 · Leafs

## n7-leaf1 — es el tránsito entre los dos spines

```bash
sysctl -qw net.ipv4.ip_forward=1
sysctl -qw net.ipv6.conf.all.forwarding=1
sysctl -qw net.ipv4.conf.all.rp_filter=0
iptables -P FORWARD ACCEPT; ip6tables -P FORWARD ACCEPT
ip route replace 16.0.2.0/24 via 16.0.6.1
ip route replace 16.0.3.0/24 via 16.0.6.5
ip route replace 16.0.5.160/28 via 16.0.6.38
ip route replace 16.0.0.0/23 via 16.0.6.34
ip route replace default via 16.0.6.34
```

## n8-leaf2 — default hacia spine1

```bash
sysctl -qw net.ipv4.ip_forward=1
sysctl -qw net.ipv6.conf.all.forwarding=1
sysctl -qw net.ipv4.conf.all.rp_filter=0
iptables -P FORWARD ACCEPT; ip6tables -P FORWARD ACCEPT
ip route replace 16.0.4.0/25 via 16.0.6.9
ip route replace 16.0.5.64/27 via 16.0.6.13
ip route replace default via 16.0.6.42
```

## n9-leaf3 — default hacia spine1

```bash
sysctl -qw net.ipv4.ip_forward=1
sysctl -qw net.ipv6.conf.all.forwarding=1
sysctl -qw net.ipv4.conf.all.rp_filter=0
iptables -P FORWARD ACCEPT; ip6tables -P FORWARD ACCEPT
ip route replace 16.0.4.128/25 via 16.0.6.17
ip route replace 16.0.5.0/26 via 16.0.6.21
ip route replace default via 16.0.6.50
```

## n10-leaf4 — default hacia spine1

```bash
sysctl -qw net.ipv4.ip_forward=1
sysctl -qw net.ipv6.conf.all.forwarding=1
sysctl -qw net.ipv4.conf.all.rp_filter=0
iptables -P FORWARD ACCEPT; ip6tables -P FORWARD ACCEPT
ip route replace 16.0.5.96/27 via 16.0.6.25
ip route replace 16.0.5.128/27 via 16.0.6.29
ip route replace default via 16.0.6.58
```

---

# 3 · Routers de LAN

## n1 — LAN Net1-A — default hacia su leaf

```bash
sysctl -qw net.ipv4.ip_forward=1
sysctl -qw net.ipv6.conf.all.forwarding=1
sysctl -qw net.ipv4.conf.all.rp_filter=0
iptables -P FORWARD ACCEPT; ip6tables -P FORWARD ACCEPT
ip route replace default via 16.0.6.2
```

## n2 — LAN Net1-B — default hacia su leaf

```bash
sysctl -qw net.ipv4.ip_forward=1
sysctl -qw net.ipv6.conf.all.forwarding=1
sysctl -qw net.ipv4.conf.all.rp_filter=0
iptables -P FORWARD ACCEPT; ip6tables -P FORWARD ACCEPT
ip route replace default via 16.0.6.6
```

## n17 — LAN Net2-A — default hacia su leaf

```bash
sysctl -qw net.ipv4.ip_forward=1
sysctl -qw net.ipv6.conf.all.forwarding=1
sysctl -qw net.ipv4.conf.all.rp_filter=0
iptables -P FORWARD ACCEPT; ip6tables -P FORWARD ACCEPT
ip route replace default via 16.0.6.10
```

## n18 — LAN Net2-B — default hacia su leaf

```bash
sysctl -qw net.ipv4.ip_forward=1
sysctl -qw net.ipv6.conf.all.forwarding=1
sysctl -qw net.ipv4.conf.all.rp_filter=0
iptables -P FORWARD ACCEPT; ip6tables -P FORWARD ACCEPT
ip route replace default via 16.0.6.14
```

## n21 — LAN Net3-A — default hacia su leaf

```bash
sysctl -qw net.ipv4.ip_forward=1
sysctl -qw net.ipv6.conf.all.forwarding=1
sysctl -qw net.ipv4.conf.all.rp_filter=0
iptables -P FORWARD ACCEPT; ip6tables -P FORWARD ACCEPT
ip route replace default via 16.0.6.18
```

## n22 — LAN Net3-B — default hacia su leaf

```bash
sysctl -qw net.ipv4.ip_forward=1
sysctl -qw net.ipv6.conf.all.forwarding=1
sysctl -qw net.ipv4.conf.all.rp_filter=0
iptables -P FORWARD ACCEPT; ip6tables -P FORWARD ACCEPT
ip route replace default via 16.0.6.22
```

## n23 — LAN Net4-A — default hacia su leaf

```bash
sysctl -qw net.ipv4.ip_forward=1
sysctl -qw net.ipv6.conf.all.forwarding=1
sysctl -qw net.ipv4.conf.all.rp_filter=0
iptables -P FORWARD ACCEPT; ip6tables -P FORWARD ACCEPT
ip route replace default via 16.0.6.26
```

## n24 — LAN Net4-B — default hacia su leaf

```bash
sysctl -qw net.ipv4.ip_forward=1
sysctl -qw net.ipv6.conf.all.forwarding=1
sysctl -qw net.ipv4.conf.all.rp_filter=0
iptables -P FORWARD ACCEPT; ip6tables -P FORWARD ACCEPT
ip route replace default via 16.0.6.30
```

---

# 4 · PCs

En las PCs alcanza con **una línea**:

## n11

```bash
ip route replace default via 16.0.2.1
```

## n12

```bash
ip route replace default via 16.0.3.1
```

## n13

```bash
ip route replace default via 16.0.4.1
```

## n14

```bash
ip route replace default via 16.0.5.65
```

## n29

```bash
ip route replace default via 16.0.4.129
```

## n30

```bash
ip route replace default via 16.0.5.1
```

## n31

```bash
ip route replace default via 16.0.5.97
```

## n32

```bash
ip route replace default via 16.0.5.129
```

## n33

```bash
ip route replace default via 16.0.5.129
```

## n34

```bash
ip route replace default via 16.0.0.1
ip -6 route replace default via 1600:0:0:5::1 dev eth0
```

## n35

```bash
ip route replace default via 16.0.5.161
ip -6 route replace default via 1600:0:0:6::1 dev eth0
```

---

# 5 · Verificación

Desde **n11**:

```bash
ping -c2 16.0.5.130       # a n33 — debe dar TTL 59
traceroute 16.0.5.130     # 6 saltos
ping -c2 1.2.3.4          # Net Unreachable desde 16.0.6.34, NO Time Exceeded
```

Desde **spine1**:

```bash
ping6 -c2 1600:0:0:6::1   # la LAN Net6, cruzando el túnel
```
