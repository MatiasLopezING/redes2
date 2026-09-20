#!/bin/bash
# =============================================================================
#  Plantilla de configuración de un nodo — TPI Redes II
#
#  USO (dentro de CORE, en la terminal del nodo):
#      bash /media/sf_tpi/configs/nN-<nombre>.sh
#
#  Copiar este archivo como  configs/nN-<nombre>.sh  y completar.
#  NO configurar a mano por la GUI: lo que se clickea no queda versionado
#  ni se puede mostrar en el coloquio.
# =============================================================================

set -e   # cortar ante el primer error

NODO="nXX"          # <-- completar
ROL="router|pc"     # <-- completar

echo "=== Configurando $NODO ($ROL) ==="

# -----------------------------------------------------------------------------
# 1. Habilitar forwarding  (SOLO en routers, spines y leafs — NO en las PCs)
# -----------------------------------------------------------------------------
sysctl -w net.ipv4.ip_forward=1
sysctl -w net.ipv6.conf.all.forwarding=1

# rp_filter: filtro anti-spoofing. Con topologías de caminos múltiples
# (spine-leaf) puede descartar tráfico legítimo. Deshabilitar si hace falta.
sysctl -w net.ipv4.conf.all.rp_filter=0
sysctl -w net.ipv4.conf.default.rp_filter=0

# -----------------------------------------------------------------------------
# 2. Direcciones IPv4
# -----------------------------------------------------------------------------
# ip addr flush dev eth0
# ip addr add 10.0.0.1/30 dev eth0
# ip link set eth0 up

# ip addr add 10.0.1.1/24 dev eth1
# ip link set eth1 up

# -----------------------------------------------------------------------------
# 3. Direcciones IPv6   (solo Net5 / Net6 y el camino entre ellas)
# -----------------------------------------------------------------------------
# ip -6 addr add 2001:db8:0:1::1/64 dev eth0

# -----------------------------------------------------------------------------
# 4. Ruteo estático IPv4
# -----------------------------------------------------------------------------
# Redes conectadas: no hace falta declararlas, el kernel las agrega solo.
#
# Rutas específicas:
# ip route add 10.0.5.0/24 via 10.0.0.2 dev eth0
#
# Ruta por defecto:
# ip route add default via 10.0.0.2 dev eth0

# -----------------------------------------------------------------------------
# 5. Ruteo estático IPv6
# -----------------------------------------------------------------------------
# ip -6 route add 2001:db8:0:2::/64 via 2001:db8:0:1::2 dev eth0
# ip -6 route add default via 2001:db8:0:1::2 dev eth0

# -----------------------------------------------------------------------------
# 6. NAT — punto (c), ALTERNATIVO. Solo en el router de salida de n33.
# -----------------------------------------------------------------------------
# iptables -t nat -A POSTROUTING -s 192.168.0.0/24 -o eth0 -j MASQUERADE

# -----------------------------------------------------------------------------
# 7. MTU — punto (g), ALTERNATIVO
# -----------------------------------------------------------------------------
# ip link set dev eth1 mtu 400

# =============================================================================
echo "--- Verificación ---"
ip -4 addr show   | grep -E "^[0-9]+:|inet "
ip -6 addr show   | grep -E "^[0-9]+:|inet6 "
echo "--- Tabla de ruteo IPv4 ---"
ip route show
echo "--- Tabla de ruteo IPv6 ---"
ip -6 route show
echo "=== $NODO listo ==="
