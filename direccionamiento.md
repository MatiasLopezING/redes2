# Diseño de direccionamiento

> **Bloque IPv4 asignado:** `___.___.___.___/__`
> **Bloque IPv6 asignado:** `____:____::/__`

---

## 1. Inventario de redes (figura 6)

### LANs pedidas por el enunciado

| Red | LAN | Hosts | Router | Bits host | Prefijo | Bloque |
|---|---|---|---|---|---|---|
| Net1 | LAN A | 200 | n1 | 8 | **/24** | 256 |
| Net1 | LAN B | 200 | n2 | 8 | **/24** | 256 |
| Net2 | LAN A | 100 | n17 | 7 | **/25** | 128 |
| Net2 | LAN B | 30 | n18 | 5 | **/27** | 32 |
| Net3 | LAN A | 100 | n21 | 7 | **/25** | 128 |
| Net3 | LAN B | 60 | n22 | 6 | **/26** | 64 |
| Net4 | LAN A | 20 | n23 | 5 | **/27** | 32 |
| Net4 | LAN B | 20 | n24 | 5 | **/27** | 32 |
| Net5 | LAN | 500 | n15 | 9 | **/23** | 512 |
| Net6 | LAN | 10 | n16 | 4 | **/28** | 16 |

*(Regla: `n ≥ log₂(hosts + 2)` → prefijo = 32 − n)*

**Subtotal LANs:** 256+256+128+32+128+64+32+32+512+16 = **1456 direcciones**

### Enlaces punto a punto

El enunciado: *"Considerar los enlaces punto a punto /30 o /31, salvo las redes donde
hay switches/hubs."*

| Tramo | Cantidad | Detalle |
|---|---|---|
| Router de LAN ↔ leaf | 8 | 2 por cada Net1–Net4 |
| Leaf ↔ spine | 8 | cada leaf contra los 2 spines |
| Spine1 ↔ Net5 (n15) | 1 | *verificar en la figura si es p2p o LAN* |
| Spine2 ↔ Net6 (n16) | 1 | *idem* |
| **Total** | **18** | |

| Con /30 | Con /31 (RFC 3021) |
|---|---|
| 18 × 4 = **72 direcciones** | 18 × 2 = **36 direcciones** |

> **Decisión del grupo:** ☐ /30 ☐ /31 — *justificar en el informe*

**TOTAL ESTIMADO:** 1456 + 72 = **1528 direcciones** → entra en un **/21** (2048).
Ajustar según el bloque que nos hayan asignado.

---

## 2. Asignación IPv4 (completar)

> Orden VLSM: **de mayor a menor**, bloques contiguos y alineados.

| # | Segmento | Prefijo | Red | Primera | Última asignable | Broadcast |
|---|---|---|---|---|---|---|
| 1 | Net5 LAN (500) | /23 | | | | |
| 2 | Net1 LAN A (200) | /24 | | | | |
| 3 | Net1 LAN B (200) | /24 | | | | |
| 4 | Net2 LAN A (100) | /25 | | | | |
| 5 | Net3 LAN A (100) | /25 | | | | |
| 6 | Net3 LAN B (60) | /26 | | | | |
| 7 | Net2 LAN B (30) | /27 | | | | |
| 8 | Net4 LAN A (20) | /27 | | | | |
| 9 | Net4 LAN B (20) | /27 | | | | |
| 10 | Net6 LAN (10) | /28 | | | | |
| 11–28 | Enlaces p2p | /30 | | | | |

### Enlaces punto a punto — detalle

| # | Tramo | Red | Extremo A | Extremo B |
|---|---|---|---|---|
| 1 | n1 ↔ n7-leaf1 | | n1: | leaf1: |
| 2 | n2 ↔ n7-leaf1 | | | |
| 3 | n17 ↔ n8-leaf2 | | | |
| 4 | n18 ↔ n8-leaf2 | | | |
| 5 | n21 ↔ n9-leaf3 | | | |
| 6 | n22 ↔ n9-leaf3 | | | |
| 7 | n23 ↔ n10-leaf4 | | | |
| 8 | n24 ↔ n10-leaf4 | | | |
| 9 | leaf1 ↔ spine1 | | | |
| 10 | leaf1 ↔ spine2 | | | |
| 11 | leaf2 ↔ spine1 | | | |
| 12 | leaf2 ↔ spine2 | | | |
| 13 | leaf3 ↔ spine1 | | | |
| 14 | leaf3 ↔ spine2 | | | |
| 15 | leaf4 ↔ spine1 | | | |
| 16 | leaf4 ↔ spine2 | | | |
| 17 | spine1 ↔ n15 (Net5) | | | |
| 18 | spine2 ↔ n16 (Net6) | | | |

---

## 3. Asignación IPv6 — punto (a)

Solo **Net5 y Net6** deben tener conectividad IPv6 entre sí.

> **Regla:** toda LAN lleva **/64**, sin importar la cantidad de hosts.
> El prefijo NO se ajusta al número de hosts — eso es pensamiento IPv4.

| Segmento | Prefijo | Red |
|---|---|---|
| Net5 LAN | /64 | |
| Net6 LAN | /64 | |
| spine1 ↔ n15 | /64 (o /127) | |
| spine2 ↔ n16 | /64 (o /127) | |
| spine1 ↔ spine2 *(si aplica)* | /64 | |

**Direcciones link-local:** cada interfaz tendrá además su `fe80::/64` autoconfigurada.
Verificar con `ip -6 addr show` que el IID se genere por **EUI-64** desde la MAC.

---

## 4. Verificación antes de configurar

- [ ] Ninguna red se superpone con otra
- [ ] Cada bloque arranca en un múltiplo de su tamaño (**alineación**)
- [ ] La suma entra en el bloque asignado
- [ ] Cada interfaz de router tiene una IP de la red de su segmento
- [ ] Los enlaces /30 usan las 2 direcciones asignables (no la de red ni la de broadcast)
- [ ] Las LAN IPv6 son todas /64

---

## 5. Notas de diseño

*(Acá va lo que hay que poder defender en el coloquio: por qué este orden, por qué
/30 o /31, qué se dejó libre para crecimiento, etc.)*
