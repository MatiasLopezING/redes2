#!/bin/bash
# =============================================================================
#  TP2 — Configuración de todos los nodos — grupo 0X
#  Bloque IPv4: 16.0.0.0/16   ·   Bloque IPv6: 1600::/32
#
#  Las interfaces (ethN) están tomadas del topologia.imn REAL, no inventadas.
#
#  USO: en la terminal de CUALQUIER nodo de CORE, siempre la misma línea:
#      bash /media/sf_tpi/tp2/configs/configurar.sh
#
#  Si el hostname no coincide, pasarlo a mano:
#      bash /media/sf_tpi/tp2/configs/configurar.sh n1
# =============================================================================

NODO="${1:-$(hostname)}"
echo "=== Configurando: $NODO ==="

ip4 () {
    # OJO: "ip addr flush" sin -4 borra TAMBIEN la link-local fe80::, y sin ella
    # el NDP no funciona (IPv6 queda muerto aunque IPv4 ande). Por eso se limpia
    # IPv4 y solo las IPv6 de scope global (las 2001:: que asigna CORE).
    ip -4 addr flush dev "$1" 2>/dev/null
    ip -6 addr flush dev "$1" scope global 2>/dev/null
    ip addr add "$2" dev "$1"
    ip link set "$1" up
    [ -z "$(ip -6 addr show dev "$1" scope link)" ] && ip -6 addr add "fe80::$(tr -dc a-f0-9 </dev/urandom|head -c4):$(tr -dc a-f0-9 </dev/urandom|head -c4)/64" dev "$1" 2>/dev/null
    echo "    $1 → $2"
}
ruta () { ip route add "$1" via "$2" 2>/dev/null || ip route replace "$1" via "$2"; }
router () {
    # CORE arranca zebra/ospfd por defecto. El enunciado pide ruteo ESTÁTICO,
    # así que se detienen los daemons y se limpian las rutas que dejaron
    # (las 10.0.x.x que CORE asignó automáticamente al crear la topología).
    killall -q zebra ospfd ospf6d bgpd ripd 2>/dev/null
    ip route  flush proto zebra 2>/dev/null
    ip -6 route flush proto zebra 2>/dev/null
    sysctl -qw net.ipv4.ip_forward=1
    sysctl -qw net.ipv6.conf.all.forwarding=1
    sysctl -qw net.ipv4.conf.all.rp_filter=0
    sysctl -qw net.ipv4.conf.default.rp_filter=0
    iptables  -P FORWARD ACCEPT 2>/dev/null
    ip6tables -P FORWARD ACCEPT 2>/dev/null
}
host () {
    killall -q zebra ospfd ospf6d 2>/dev/null
    ip route  flush proto zebra 2>/dev/null
    ip -6 route flush proto zebra 2>/dev/null
    sysctl -qw net.ipv4.ip_forward=0
}

case "$NODO" in

# ══ ROUTERS DE LAN ═════════════════════════════════════════════════════════
# OJO: en n1 y n2 el enlace al leaf es eth0 y la LAN es eth1.
#      En n17..n24 es al revés: LAN en eth0, leaf en eth1.

n1|n1-*)             # eth0→leaf1 · eth1→hub Net1-A
    router
    ip4 eth0 16.0.6.1/30
    ip4 eth1 16.0.2.1/24
    ruta default 16.0.6.2 ;;

n2|n2-*)             # eth0→leaf1 · eth1→hub Net1-B
    router
    ip4 eth0 16.0.6.5/30
    ip4 eth1 16.0.3.1/24
    ruta default 16.0.6.6 ;;

n17|n17-*)           # eth0→hub Net2-A · eth1→leaf2
    router
    ip4 eth0 16.0.4.1/25
    ip4 eth1 16.0.6.9/30
    ruta default 16.0.6.10 ;;

n18|n18-*)           # eth0→hub Net2-B · eth1→leaf2
    router
    ip4 eth0 16.0.5.65/27
    ip4 eth1 16.0.6.13/30
    ruta default 16.0.6.14 ;;

n21|n21-*)           # eth0→hub Net3-A · eth1→leaf3
    router
    ip4 eth0 16.0.4.129/25
    ip4 eth1 16.0.6.17/30
    ruta default 16.0.6.18 ;;

n22|n22-*)           # eth0→hub Net3-B · eth1→leaf3
    router
    ip4 eth0 16.0.5.1/26
    ip4 eth1 16.0.6.21/30
    ruta default 16.0.6.22 ;;

n23|n23-*)           # eth0→hub Net4-A · eth1→leaf4
    router
    ip4 eth0 16.0.5.97/27
    ip4 eth1 16.0.6.25/30
    ruta default 16.0.6.26 ;;

n24|n24-*)           # eth0→hub Net4-B · eth1→leaf4
    router
    ip4 eth0 16.0.5.129/27
    ip4 eth1 16.0.6.29/30
    ruta default 16.0.6.30 ;;

# ══ LEAFS ══════════════════════════════════════════════════════════════════
# OJO: en leaf1  eth2→spine1 y eth3→spine2
#      en leaf2/3/4 está INVERTIDO: eth2→spine2 y eth3→spine1

n7|*leaf1*)          # eth0→n1 · eth1→n2 · eth2→spine1 · eth3→spine2
    router
    ip4 eth0 16.0.6.2/30
    ip4 eth1 16.0.6.6/30
    ip4 eth2 16.0.6.33/30
    ip4 eth3 16.0.6.37/30
    ruta 16.0.2.0/24   16.0.6.1      # Net1-A vía n1
    ruta 16.0.3.0/24   16.0.6.5      # Net1-B vía n2
    ruta default       16.0.6.34     # → spine1
    # leaf1 es el TRÁNSITO entre los dos spines (Net5 ↔ Net6)
    ruta 16.0.5.160/28 16.0.6.38     # Net6 vía spine2
    ruta 16.0.0.0/23   16.0.6.34 ;;  # Net5 vía spine1

n8|*leaf2*)          # eth0→n17 · eth1→n18 · eth2→spine2 · eth3→spine1
    router
    ip4 eth0 16.0.6.10/30
    ip4 eth1 16.0.6.14/30
    ip4 eth2 16.0.6.45/30
    ip4 eth3 16.0.6.41/30
    ruta 16.0.4.0/25  16.0.6.9       # Net2-A vía n17
    ruta 16.0.5.64/27 16.0.6.13      # Net2-B vía n18
    ruta default      16.0.6.42 ;;   # → spine1

n9|*leaf3*)          # eth0→n21 · eth1→n22 · eth2→spine2 · eth3→spine1
    router
    ip4 eth0 16.0.6.18/30
    ip4 eth1 16.0.6.22/30
    ip4 eth2 16.0.6.53/30
    ip4 eth3 16.0.6.49/30
    ruta 16.0.4.128/25 16.0.6.17     # Net3-A vía n21
    ruta 16.0.5.0/26   16.0.6.21     # Net3-B vía n22
    ruta default       16.0.6.50 ;;  # → spine1

n10|*leaf4*)         # eth0→n23 · eth1→n24 · eth2→spine2 · eth3→spine1
    router
    ip4 eth0 16.0.6.26/30
    ip4 eth1 16.0.6.30/30
    ip4 eth2 16.0.6.61/30
    ip4 eth3 16.0.6.57/30
    ruta 16.0.5.96/27  16.0.6.25     # Net4-A vía n23
    ruta 16.0.5.128/27 16.0.6.29     # Net4-B vía n24
    ruta default       16.0.6.58 ;;  # → spine1

# ══ SPINES — sin ruta por defecto (si no, se arma loop) ════════════════════

n5|*spine1*)         # eth0→leaf1 · eth1→LAN Net5 · eth2→leaf2 · eth3→leaf3 · eth4→leaf4
    router
    ip4 eth0 16.0.6.34/30
    ip4 eth1 16.0.0.1/23             # ══ LAN Net5 (vía switch n15)
    ip4 eth2 16.0.6.42/30
    ip4 eth3 16.0.6.50/30
    ip4 eth4 16.0.6.58/30
    ruta 16.0.2.0/24   16.0.6.33     # Net1-A vía leaf1
    ruta 16.0.3.0/24   16.0.6.33     # Net1-B vía leaf1
    ruta 16.0.4.0/25   16.0.6.41     # Net2-A vía leaf2
    ruta 16.0.5.64/27  16.0.6.41     # Net2-B vía leaf2
    ruta 16.0.4.128/25 16.0.6.49     # Net3-A vía leaf3
    ruta 16.0.5.0/26   16.0.6.49     # Net3-B vía leaf3
    ruta 16.0.5.96/27  16.0.6.57     # Net4-A vía leaf4
    ruta 16.0.5.128/27 16.0.6.57     # Net4-B vía leaf4
    ruta 16.0.5.160/28 16.0.6.33     # Net6 vía leaf1 → spine2
    # Redes de TRÁNSITO (los /30 entre routers y leafs, y entre leafs y spines).
    # Sin estas rutas el ICMP de respuesta no encuentra camino de vuelta cuando
    # el origen es la interfaz de un enlace punto a punto. Se sumarizan en /29
    # porque los dos enlaces de cada leaf quedaron contiguos y alineados.
    ruta 16.0.6.0/29   16.0.6.33     # enlaces de leaf1
    ruta 16.0.6.32/29  16.0.6.33
    ruta 16.0.6.8/29   16.0.6.41     # enlaces de leaf2
    ruta 16.0.6.40/29  16.0.6.41
    ruta 16.0.6.16/29  16.0.6.49     # enlaces de leaf3
    ruta 16.0.6.48/29  16.0.6.49
    ruta 16.0.6.24/29  16.0.6.57     # enlaces de leaf4
    ruta 16.0.6.56/29  16.0.6.57
    # ── IPv6: LAN Net5 + túnel 6in4 hacia spine2 ──
    ip -6 addr add 1600:0:0:5::1/64 dev eth1 2>/dev/null
    ip tunnel del tun6 2>/dev/null
    ip tunnel add tun6 mode sit remote 16.0.6.38 local 16.0.6.34 ttl 64
    ip link set tun6 up
    ip -6 addr add 1600:0:0:ffff::1/64 dev tun6
    ip -6 route add 1600:0:0:6::/64 dev tun6 2>/dev/null ;;

n6|*spine2*)         # eth0→leaf4 · eth1→leaf3 · eth2→LAN Net6 · eth3→leaf2 · eth4→leaf1
    router
    ip4 eth0 16.0.6.62/30
    ip4 eth1 16.0.6.54/30
    ip4 eth2 16.0.5.161/28           # ══ LAN Net6 (vía switch n16)
    ip4 eth3 16.0.6.46/30
    ip4 eth4 16.0.6.38/30
    ruta 16.0.2.0/24   16.0.6.37     # Net1-A vía leaf1
    ruta 16.0.3.0/24   16.0.6.37     # Net1-B vía leaf1
    ruta 16.0.4.0/25   16.0.6.45     # Net2-A vía leaf2
    ruta 16.0.5.64/27  16.0.6.45     # Net2-B vía leaf2
    ruta 16.0.4.128/25 16.0.6.53     # Net3-A vía leaf3
    ruta 16.0.5.0/26   16.0.6.53     # Net3-B vía leaf3
    ruta 16.0.5.96/27  16.0.6.61     # Net4-A vía leaf4
    ruta 16.0.5.128/27 16.0.6.61     # Net4-B vía leaf4
    ruta 16.0.0.0/23   16.0.6.37     # Net5 vía leaf1 → spine1
    # Redes de tránsito, sumarizadas en /29 (ver comentario en spine1)
    ruta 16.0.6.0/29   16.0.6.37     # enlaces de leaf1
    ruta 16.0.6.32/29  16.0.6.37
    ruta 16.0.6.8/29   16.0.6.45     # enlaces de leaf2
    ruta 16.0.6.40/29  16.0.6.45
    ruta 16.0.6.16/29  16.0.6.53     # enlaces de leaf3
    ruta 16.0.6.48/29  16.0.6.53
    ruta 16.0.6.24/29  16.0.6.61     # enlaces de leaf4
    ruta 16.0.6.56/29  16.0.6.61
    # ── IPv6: LAN Net6 + túnel 6in4 hacia spine1 ──
    ip -6 addr add 1600:0:0:6::1/64 dev eth2 2>/dev/null
    ip tunnel del tun6 2>/dev/null
    ip tunnel add tun6 mode sit remote 16.0.6.34 local 16.0.6.38 ttl 64
    ip link set tun6 up
    ip -6 addr add 1600:0:0:ffff::2/64 dev tun6
    ip -6 route add 1600:0:0:5::/64 dev tun6 2>/dev/null ;;

# ══ PCs ════════════════════════════════════════════════════════════════════
# Net4-A tiene SOLO a n31. Net4-B tiene a n32 y n33.

n11|n11-*)  host; ip4 eth0 16.0.2.10/24;   ruta default 16.0.2.1   ;;  # Net1-A
n12|n12-*)  host; ip4 eth0 16.0.3.10/24;   ruta default 16.0.3.1   ;;  # Net1-B
n13|n13-*)  host; ip4 eth0 16.0.4.10/25;   ruta default 16.0.4.1   ;;  # Net2-A
n14|n14-*)  host; ip4 eth0 16.0.5.70/27;   ruta default 16.0.5.65  ;;  # Net2-B
n29|n29-*)  host; ip4 eth0 16.0.4.140/25;  ruta default 16.0.4.129 ;;  # Net3-A
n30|n30-*)  host; ip4 eth0 16.0.5.10/26;   ruta default 16.0.5.1   ;;  # Net3-B
n31|n31-*)  host; ip4 eth0 16.0.5.100/27;  ruta default 16.0.5.97  ;;  # Net4-A
n32|n32-*)  host; ip4 eth0 16.0.5.131/27;  ruta default 16.0.5.129 ;;  # Net4-B
n33|n33-*)  host; ip4 eth0 16.0.5.130/27;  ruta default 16.0.5.129 ;;  # Net4-B

n34|n34-*)  # PC de Net5 — también IPv6
    host
    ip4 eth0 16.0.0.10/23
    ruta default 16.0.0.1
    ip -6 addr add 1600:0:0:5::10/64 dev eth0 2>/dev/null
    ip -6 route replace default via 1600:0:0:5::1 dev eth0 ;;

n35|n35-*)  # PC de Net6 — también IPv6
    host
    ip4 eth0 16.0.5.170/28
    ruta default 16.0.5.161
    ip -6 addr add 1600:0:0:6::10/64 dev eth0 2>/dev/null
    ip -6 route replace default via 1600:0:0:6::1 dev eth0 ;;

*)
    echo "!! Nodo '$NODO' no reconocido."
    echo "   Hubs (n3 n4 n19 n20 n25 n26 n27 n28) y switches (n15 n16) NO se configuran."
    echo "   Si es un router/PC, pasá el nombre: bash configurar.sh n1"
    exit 1 ;;
esac

echo "--- direcciones ---"
ip -4 -br addr show | grep -v '^lo'
ip -6 -br addr show 2>/dev/null | grep -v '^lo' | grep -v 'fe80' || true
echo "--- ruteo IPv4 ---"
ip route show
echo "=== $NODO listo ==="
