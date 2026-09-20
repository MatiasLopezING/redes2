#!/bin/bash
# =============================================================================
#  TP2 — Configuración de todos los nodos — grupo 0X
#  Bloque IPv4: 16.0.0.0/16   ·   Bloque IPv6: 1600::/32
#
#  USO: en la terminal de CUALQUIER nodo de CORE, siempre la misma línea:
#
#      bash /media/sf_tpi/tp2/configs/configurar.sh
#
#  El script detecta solo qué nodo es por el hostname.
#  Si el hostname no coincide, pasarlo a mano:
#
#      bash /media/sf_tpi/tp2/configs/configurar.sh n1
#
#  ⚠️ OJO CON ethN: el número que CORE le da a cada interfaz depende del ORDEN
#     en que se crearon los enlaces. Antes de correr esto en un router, verificá
#     con `ip link` que eth0/eth1/... apuntan a donde dice el comentario.
#     Si no coinciden, cambiá los nombres acá y listo.
# =============================================================================

NODO="${1:-$(hostname)}"
echo "=== Configurando: $NODO ==="

# --- helpers -----------------------------------------------------------------
ip4 () {   # ip4 <iface> <dir/prefijo>
    ip addr flush dev "$1" 2>/dev/null
    ip addr add "$2" dev "$1"
    ip link set "$1" up
    echo "    $1 → $2"
}
ruta () {  # ruta <red/prefijo> <gateway>
    ip route add "$1" via "$2" 2>/dev/null || ip route replace "$1" via "$2"
}
router () {
    sysctl -qw net.ipv4.ip_forward=1
    sysctl -qw net.ipv6.conf.all.forwarding=1
    sysctl -qw net.ipv4.conf.all.rp_filter=0
    sysctl -qw net.ipv4.conf.default.rp_filter=0
    iptables  -P FORWARD ACCEPT 2>/dev/null
    ip6tables -P FORWARD ACCEPT 2>/dev/null
}
host () {
    sysctl -qw net.ipv4.ip_forward=0
}

case "$NODO" in

# ╔══════════════════════════════════════════════════════════════════════════╗
# ║  ROUTERS DE LAN — cada uno: su LAN en eth0, el enlace al leaf en eth1     ║
# ╚══════════════════════════════════════════════════════════════════════════╝

n1|*n1-*)            # Net1-A (200 hosts) ── leaf1
    router
    ip4 eth0 16.0.2.1/24
    ip4 eth1 16.0.6.1/30
    ruta default 16.0.6.2 ;;

n2|*n2-*)            # Net1-B (200 hosts) ── leaf1
    router
    ip4 eth0 16.0.3.1/24
    ip4 eth1 16.0.6.5/30
    ruta default 16.0.6.6 ;;

n17|*n17-*)          # Net2-A (100 hosts) ── leaf2
    router
    ip4 eth0 16.0.4.1/25
    ip4 eth1 16.0.6.9/30
    ruta default 16.0.6.10 ;;

n18|*n18-*)          # Net2-B (30 hosts) ── leaf2
    router
    ip4 eth0 16.0.5.65/27
    ip4 eth1 16.0.6.13/30
    ruta default 16.0.6.14 ;;

n21|*n21-*)          # Net3-A (100 hosts) ── leaf3
    router
    ip4 eth0 16.0.4.129/25
    ip4 eth1 16.0.6.17/30
    ruta default 16.0.6.18 ;;

n22|*n22-*)          # Net3-B (60 hosts) ── leaf3
    router
    ip4 eth0 16.0.5.1/26
    ip4 eth1 16.0.6.21/30
    ruta default 16.0.6.22 ;;

n23|*n23-*)          # Net4-A (20 hosts) ── leaf4
    router
    ip4 eth0 16.0.5.97/27
    ip4 eth1 16.0.6.25/30
    ruta default 16.0.6.26 ;;

n24|*n24-*)          # Net4-B (20 hosts) ── leaf4
    router
    ip4 eth0 16.0.5.129/27
    ip4 eth1 16.0.6.29/30
    ruta default 16.0.6.30 ;;

# ╔══════════════════════════════════════════════════════════════════════════╗
# ║  LEAFS — eth0/eth1 hacia los routers de LAN, eth2/eth3 hacia los spines  ║
# ║  Rutas específicas hacia abajo + default hacia spine1                    ║
# ╚══════════════════════════════════════════════════════════════════════════╝

n7|*leaf1*)
    router
    ip4 eth0 16.0.6.2/30      # ── n1
    ip4 eth1 16.0.6.6/30      # ── n2
    ip4 eth2 16.0.6.33/30     # ── spine1
    ip4 eth3 16.0.6.37/30     # ── spine2
    ruta 16.0.2.0/24   16.0.6.1     # Net1-A vía n1
    ruta 16.0.3.0/24   16.0.6.5     # Net1-B vía n2
    ruta default       16.0.6.34    # → spine1
    # leaf1 es el TRÁNSITO entre los dos spines (Net5 ↔ Net6)
    ruta 16.0.5.160/28 16.0.6.38    # Net6 vía spine2
    ruta 16.0.0.0/23   16.0.6.34 ;; # Net5 vía spine1

n8|*leaf2*)
    router
    ip4 eth0 16.0.6.10/30     # ── n17
    ip4 eth1 16.0.6.14/30     # ── n18
    ip4 eth2 16.0.6.41/30     # ── spine1
    ip4 eth3 16.0.6.45/30     # ── spine2
    ruta 16.0.4.0/25  16.0.6.9      # Net2-A vía n17
    ruta 16.0.5.64/27 16.0.6.13     # Net2-B vía n18
    ruta default      16.0.6.42 ;;  # → spine1

n9|*leaf3*)
    router
    ip4 eth0 16.0.6.18/30     # ── n21
    ip4 eth1 16.0.6.22/30     # ── n22
    ip4 eth2 16.0.6.49/30     # ── spine1
    ip4 eth3 16.0.6.53/30     # ── spine2
    ruta 16.0.4.128/25 16.0.6.17    # Net3-A vía n21
    ruta 16.0.5.0/26   16.0.6.21    # Net3-B vía n22
    ruta default       16.0.6.50 ;; # → spine1

n10|*leaf4*)
    router
    ip4 eth0 16.0.6.26/30     # ── n23
    ip4 eth1 16.0.6.30/30     # ── n24
    ip4 eth2 16.0.6.57/30     # ── spine1
    ip4 eth3 16.0.6.61/30     # ── spine2
    ruta 16.0.5.96/27  16.0.6.25    # Net4-A vía n23
    ruta 16.0.5.128/27 16.0.6.29    # Net4-B vía n24
    ruta default       16.0.6.58 ;; # → spine1

# ╔══════════════════════════════════════════════════════════════════════════╗
# ║  SPINES — SIN default (si no, se arma loop). Solo rutas específicas.      ║
# ║  spine1 tiene la LAN de Net5 · spine2 tiene la LAN de Net6                ║
# ╚══════════════════════════════════════════════════════════════════════════╝

n5|*spine1*)
    router
    ip4 eth0 16.0.6.34/30     # ── leaf1
    ip4 eth1 16.0.6.42/30     # ── leaf2
    ip4 eth2 16.0.6.50/30     # ── leaf3
    ip4 eth3 16.0.6.58/30     # ── leaf4
    ip4 eth4 16.0.0.1/23      # ══ LAN Net5 (vía switch n15)
    ruta 16.0.2.0/24   16.0.6.33    # Net1-A vía leaf1
    ruta 16.0.3.0/24   16.0.6.33    # Net1-B vía leaf1
    ruta 16.0.4.0/25   16.0.6.41    # Net2-A vía leaf2
    ruta 16.0.5.64/27  16.0.6.41    # Net2-B vía leaf2
    ruta 16.0.4.128/25 16.0.6.49    # Net3-A vía leaf3
    ruta 16.0.5.0/26   16.0.6.49    # Net3-B vía leaf3
    ruta 16.0.5.96/27  16.0.6.57    # Net4-A vía leaf4
    ruta 16.0.5.128/27 16.0.6.57    # Net4-B vía leaf4
    ruta 16.0.5.160/28 16.0.6.33    # Net6 vía leaf1 → spine2
    # ── IPv6: LAN Net5 + túnel 6in4 hacia spine2 ──
    ip -6 addr add 1600:0:0:5::1/64 dev eth4 2>/dev/null
    ip tunnel del tun6 2>/dev/null
    ip tunnel add tun6 mode sit remote 16.0.6.38 local 16.0.6.34 ttl 64
    ip link set tun6 up
    ip -6 addr add 1600:0:0:ffff::1/64 dev tun6
    ip -6 route add 1600:0:0:6::/64 dev tun6 2>/dev/null ;;

n6|*spine2*)
    router
    ip4 eth0 16.0.6.38/30     # ── leaf1
    ip4 eth1 16.0.6.46/30     # ── leaf2
    ip4 eth2 16.0.6.54/30     # ── leaf3
    ip4 eth3 16.0.6.62/30     # ── leaf4
    ip4 eth4 16.0.5.161/28    # ══ LAN Net6 (vía switch n16)
    ruta 16.0.2.0/24   16.0.6.37    # Net1-A vía leaf1
    ruta 16.0.3.0/24   16.0.6.37    # Net1-B vía leaf1
    ruta 16.0.4.0/25   16.0.6.45    # Net2-A vía leaf2
    ruta 16.0.5.64/27  16.0.6.45    # Net2-B vía leaf2
    ruta 16.0.4.128/25 16.0.6.53    # Net3-A vía leaf3
    ruta 16.0.5.0/26   16.0.6.53    # Net3-B vía leaf3
    ruta 16.0.5.96/27  16.0.6.61    # Net4-A vía leaf4
    ruta 16.0.5.128/27 16.0.6.61    # Net4-B vía leaf4
    ruta 16.0.0.0/23   16.0.6.37    # Net5 vía leaf1 → spine1
    # ── IPv6: LAN Net6 + túnel 6in4 hacia spine1 ──
    ip -6 addr add 1600:0:0:6::1/64 dev eth4 2>/dev/null
    ip tunnel del tun6 2>/dev/null
    ip tunnel add tun6 mode sit remote 16.0.6.34 local 16.0.6.38 ttl 64
    ip link set tun6 up
    ip -6 addr add 1600:0:0:ffff::2/64 dev tun6
    ip -6 route add 1600:0:0:5::/64 dev tun6 2>/dev/null ;;

# ╔══════════════════════════════════════════════════════════════════════════╗
# ║  PCs — una interfaz y el default gateway de su LAN                        ║
# ╚══════════════════════════════════════════════════════════════════════════╝

n11|*n11-*)  host; ip4 eth0 16.0.2.10/24;   ruta default 16.0.2.1   ;;
n12|*n12-*)  host; ip4 eth0 16.0.3.10/24;   ruta default 16.0.3.1   ;;
n13|*n13-*)  host; ip4 eth0 16.0.4.10/25;   ruta default 16.0.4.1   ;;
n14|*n14-*)  host; ip4 eth0 16.0.5.70/27;   ruta default 16.0.5.65  ;;
n29|*n29-*)  host; ip4 eth0 16.0.4.140/25;  ruta default 16.0.4.129 ;;
n30|*n30-*)  host; ip4 eth0 16.0.5.10/26;   ruta default 16.0.5.1   ;;
n31|*n31-*)  host; ip4 eth0 16.0.5.100/27;  ruta default 16.0.5.97  ;;
n32|*n32-*)  host; ip4 eth0 16.0.5.101/27;  ruta default 16.0.5.97  ;;
n33|*n33-*)  host; ip4 eth0 16.0.5.130/27;  ruta default 16.0.5.129 ;;

n34|*n34-*)  # PC de Net5 — también IPv6
    host
    ip4 eth0 16.0.0.10/23
    ruta default 16.0.0.1
    ip -6 addr add 1600:0:0:5::10/64 dev eth0 2>/dev/null
    ip -6 route add default via 1600:0:0:5::1 2>/dev/null ;;

n35|*n35-*)  # PC de Net6 — también IPv6
    host
    ip4 eth0 16.0.5.170/28
    ruta default 16.0.5.161
    ip -6 addr add 1600:0:0:6::10/64 dev eth0 2>/dev/null
    ip -6 route add default via 1600:0:0:6::1 2>/dev/null ;;

*)
    echo "!! Nodo '$NODO' no reconocido."
    echo "   Switches y hubs (n3 n4 n15 n16 n19 n20 n25 n26 n27 n28) NO se configuran."
    echo "   Si es un router/PC, pasá el nombre: bash configurar.sh n1"
    exit 1 ;;
esac

# --- verificación ------------------------------------------------------------
echo "--- direcciones ---"
ip -4 -br addr show | grep -v '^lo'
ip -6 -br addr show 2>/dev/null | grep -v '^lo' | grep -v 'fe80' || true
echo "--- ruteo IPv4 ---"
ip route show
echo "=== $NODO listo ==="
