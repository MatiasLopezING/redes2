#!/bin/bash
# Configura TODOS los nodos de una sola vez.
# Se corre en una terminal de la VM (NO dentro de un nodo), con CORE ya arrancado:
#
#   sudo bash /media/sf_tpi/tp2/configs/levantar.sh
#
# Si algo falla, lo muestra en pantalla en vez de esconderlo.

SCRIPT=/media/sf_tpi/tp2/configs/configurar.sh
VCMD=$(command -v vcmd || echo /usr/local/bin/vcmd)
S=$(ls -dt /tmp/pycore.* 2>/dev/null | head -1)

[ -z "$S" ]       && { echo "✗ CORE no está corriendo. Apretá Start (▶)."; exit 1; }
[ -f "$SCRIPT" ]  || { echo "✗ No existe $SCRIPT — ¿está montada la carpeta compartida?"; exit 1; }
[ -x "$VCMD" ]    || { echo "✗ No encuentro vcmd."; exit 1; }

echo "Sesión : $S"
echo "vcmd   : $VCMD"
echo

# Orden: spines, leafs, routers de LAN, PCs. Los hubs y switches no van.
ORDEN="n5 n6  n7 n8 n9 n10  n1 n2 n17 n18 n21 n22 n23 n24  n11 n12 n13 n14 n29 n30 n31 n32 n33 n34 n35"

ok=0; fallo=0
for base in $ORDEN; do
    sock=""
    for c in "$S/$base" "$S/$base"-*; do
        [ -S "$c" ] && { sock="$c"; break; }
    done
    if [ -z "$sock" ]; then
        echo "  ✗ $base — no encuentro el socket del nodo"; fallo=$((fallo+1)); continue
    fi
    nodo=$(basename "$sock")
    salida=$("$VCMD" -c "$sock" -- bash "$SCRIPT" "$nodo" 2>&1)
    if [ $? -eq 0 ]; then
        echo "  ✓ $nodo"; ok=$((ok+1))
    else
        echo "  ✗ $nodo"
        echo "$salida" | sed 's/^/      /'
        fallo=$((fallo+1))
    fi
done

echo
echo "=== $ok configurados · $fallo con problemas ==="
[ $fallo -eq 0 ] && echo "Probá desde n11:  ping -c2 16.0.5.130"
