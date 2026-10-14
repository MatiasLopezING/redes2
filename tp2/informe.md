# Trabajo Práctico Integrador — Redes de Datos II

**Grupo 0X — 2026**

Matías Lopez (02670/0) · Juan David Alvarez (03100/2) · Lautaro Nahuel Lopes (02978/9)

---
<img width="1078" height="568" alt="fig6-diag1tpi" src="https://github.com/user-attachments/assets/eb6abe47-e7fd-4b79-854d-59211c8adab2" />

---
## Datos

| Bloque IPv4 | Bloque IPv6 |
|---|---|
| `16.0.0.0/16` | `1600::/32` |

- Para `16.0.0.0/16`, el tamaño del bloque indica que hay **16 bits** (32 − 16) para
  hosts, es decir **65.536 direcciones** disponibles, 1 subred.
- Para `1600::/32`, el tamaño del bloque indica que hay **96 bits** (128 − 32) para
  hosts, 1 subred.

**Topología:** figura 6 del enunciado — arquitectura **spine-leaf** con 2 spines
(`n5-spine1`, `n6-spine2`), 4 leafs (`n7-leaf1` … `n10-leaf4`), 8 routers de borde,
8 hubs, 2 switches y 11 PCs.

| Nodo | Rol |
|---|---|
| n5, n6 | spines |
| n7, n8, n9, n10 | leafs |
| n1, n2, n17, n18, n21, n22, n23, n24 | routers de LAN |
| n3, n4, n19, n20, n25, n26, n27, n28 | hubs |
| n15, n16 | switches |
| n11 – n14, n29 – n35 | PCs |

---

## Direccionamiento IPv4

### Análisis de requisitos

Se analizaron los requisitos de hosts de cada segmento para determinar la cantidad de
direcciones necesarias. La fórmula aplicada es `2ⁿ − 2 ≥ hosts`, donde n es la cantidad
de bits de host; se restan 2 por la dirección de red y la de broadcast.

| Segmento | Hosts pedidos | Bits de host | Prefijo | Direcciones |
|---|---|---|---|---|
| Net5 | 500 | 2⁹ − 2 = 510 → **9** | `/23` | 512 |
| Net1-A | 200 | 2⁸ − 2 = 254 → **8** | `/24` | 256 |
| Net1-B | 200 | 2⁸ − 2 = 254 → **8** | `/24` | 256 |
| Net2-A | 100 | 2⁷ − 2 = 126 → **7** | `/25` | 128 |
| Net3-A | 100 | 2⁷ − 2 = 126 → **7** | `/25` | 128 |
| Net3-B | 60 | 2⁶ − 2 = 62 → **6** | `/26` | 64 |
| Net2-B | 30 | 2⁵ − 2 = 30 → **5** | `/27` | 32 |
| Net4-A | 20 | 2⁵ − 2 = 30 → **5** | `/27` | 32 |
| Net4-B | 20 | 2⁵ − 2 = 30 → **5** | `/27` | 32 |
| Net6 | 10 | 2⁴ − 2 = 14 → **4** | `/28` | 16 |

**Subtotal LANs: 1456 direcciones.**

El enunciado indica considerar los enlaces punto a punto `/30` o `/31`. Se contabilizaron **16 enlaces punto a punto**:

- 8 entre cada router de LAN y su leaf (2 por cada Net1 a Net4)
- 8 entre cada leaf y los dos spines (4 leafs × 2 spines)

> **Net5 y Net6 no tienen enlace punto a punto.** El enunciado los menciona únicamente
> como *"una red de 500 hosts"* y *"una red de 10 hosts"*, sin la aclaración *"y las
> punto a punto con leaf"* que sí aparece en Net1 a Net4. En la topología, **n15 y n16
> son switches**, por lo que la LAN de Net5 queda directamente conectada a una interfaz
> de spine1 y la de Net6 a una de spine2.

Se optó por `/30` en lugar de `/31` por claridad: cada enlace conserva su dirección de
red y de broadcast explícitas, lo que facilita la lectura de las tablas de ruteo. El
costo es de 2 direcciones por enlace (32 en total), despreciable frente al tamaño del
bloque asignado.

**Subtotal enlaces: 16 × 4 = 64 direcciones.**
**Total: 1520 de 65.536 direcciones disponibles (2,3 % del bloque).**

### Asignación VLSM

Se aplicó VLSM sobre `16.0.0.0/16` comenzando por el segmento que requiere más
direcciones y continuando en orden decreciente, de modo que cada bloque quede alineado a
un múltiplo de su propio tamaño.

- El primer segmento es **Net5**, que requiere 512 direcciones (`/23`). Se le asigna
  `16.0.0.0/23`, que abarca de `16.0.0.0` a `16.0.1.255`.
- Siguen **Net1-A** y **Net1-B**, de 256 direcciones cada una (`/24`): que abarcan 
  de `16.0.2.0/24` a `16.0.2.255/24` y de `16.0.3.0/24` a `16.0.3.255/24`.
- Siguen **Net2-A** y **Net3-A**, de 128 direcciones (`/25`). Se subnetea `16.0.4.0/24`
  en dos `/25`: `16.0.4.0/25` y `16.0.4.128/25`.
- Sigue **Net3-B**, de 64 direcciones (`/26`). Se subnetea `16.0.5.0/24`:
  `16.0.5.0/26` queda asignada.
- Siguen **Net2-B**, **Net4-A** y **Net4-B**, de 32 direcciones (`/27`):
  `16.0.5.64/27`, `16.0.5.96/27` y `16.0.5.128/27`.
- Sigue **Net6**, de 16 direcciones (`/28`): `16.0.5.160/28`.
- Finalmente, los **16 enlaces punto a punto** se agrupan en `16.0.6.0/26`, subneteado
  en 16 redes `/30` consecutivas de `16.0.6.0` a `16.0.6.60`.

Queda libre `16.0.5.176` – `16.0.5.255` y todo `16.0.6.64` – `16.0.255.255`.

### Tabla de direccionamiento

| Red | Segmento | Prefijo | Dirección de red | Primera | Última asignable | Broadcast |
|---|---|---|---|---|---|---|
| Net5 | spine1 ↔ n15 ↔ n34 | /23 | `16.0.0.0` | 16.0.0.1 | 16.0.1.254 | `16.0.1.255` |
| Net1-A | n1 ↔ n3 ↔ n11 | /24 | `16.0.2.0` | 16.0.2.1 | 16.0.2.254 | `16.0.2.255` |
| Net1-B | n2 ↔ n4 ↔ n12 | /24 | `16.0.3.0` | 16.0.3.1 | 16.0.3.254 | `16.0.3.255` |
| Net2-A | n17 ↔ n19 ↔ n13 | /25 | `16.0.4.0` | 16.0.4.1 | 16.0.4.126 | `16.0.4.127` |
| Net3-A | n21 ↔ n25 ↔ n29 | /25 | `16.0.4.128` | 16.0.4.129 | 16.0.4.254 | `16.0.4.255` |
| Net3-B | n22 ↔ n26 ↔ n30 | /26 | `16.0.5.0` | 16.0.5.1 | 16.0.5.62 | `16.0.5.63` |
| Net2-B | n18 ↔ n20 ↔ n14 | /27 | `16.0.5.64` | 16.0.5.65 | 16.0.5.94 | `16.0.5.95` |
| Net4-A | n23 ↔ n27 ↔ n31 | /27 | `16.0.5.96` | 16.0.5.97 | 16.0.5.126 | `16.0.5.127` |
| Net4-B | n24 ↔ n28 ↔ n32, n33 | /27 | `16.0.5.128` | 16.0.5.129 | 16.0.5.158 | `16.0.5.159` |
| Net6 | spine2 ↔ n16 ↔ n35 | /28 | `16.0.5.160` | 16.0.5.161 | 16.0.5.174 | `16.0.5.175` |

**Enlaces punto a punto** — todos `/30`, máscara `255.255.255.252`

| Red | Segmento | Extremo A | Extremo B |
|---|---|---|---|
| `16.0.6.0/30` | n1 ↔ leaf1 | n1 → `.1` | leaf1 → `.2` |
| `16.0.6.4/30` | n2 ↔ leaf1 | n2 → `.5` | leaf1 → `.6` |
| `16.0.6.8/30` | n17 ↔ leaf2 | n17 → `.9` | leaf2 → `.10` |
| `16.0.6.12/30` | n18 ↔ leaf2 | n18 → `.13` | leaf2 → `.14` |
| `16.0.6.16/30` | n21 ↔ leaf3 | n21 → `.17` | leaf3 → `.18` |
| `16.0.6.20/30` | n22 ↔ leaf3 | n22 → `.21` | leaf3 → `.22` |
| `16.0.6.24/30` | n23 ↔ leaf4 | n23 → `.25` | leaf4 → `.26` |
| `16.0.6.28/30` | n24 ↔ leaf4 | n24 → `.29` | leaf4 → `.30` |
| `16.0.6.32/30` | leaf1 ↔ spine1 | leaf1 → `.33` | spine1 → `.34` |
| `16.0.6.36/30` | leaf1 ↔ spine2 | leaf1 → `.37` | spine2 → `.38` |
| `16.0.6.40/30` | leaf2 ↔ spine1 | leaf2 → `.41` | spine1 → `.42` |
| `16.0.6.44/30` | leaf2 ↔ spine2 | leaf2 → `.45` | spine2 → `.46` |
| `16.0.6.48/30` | leaf3 ↔ spine1 | leaf3 → `.49` | spine1 → `.50` |
| `16.0.6.52/30` | leaf3 ↔ spine2 | leaf3 → `.53` | spine2 → `.54` |
| `16.0.6.56/30` | leaf4 ↔ spine1 | leaf4 → `.57` | spine1 → `.58` |
| `16.0.6.60/30` | leaf4 ↔ spine2 | leaf4 → `.61` | spine2 → `.62` |

### Tabla de interfaces

> Los nombres `ethN` están tomados del archivo `topologia.imn`, no asumidos: CORE los
> asigna según el orden en que se crearon los enlaces. **No son simétricos entre nodos
> equivalentes** — en leaf1 el enlace a spine1 es `eth2`, mientras que en leaf2, leaf3 y
> leaf4 es `eth3`.

| Nodo | Interfaz | Segmento | IPv4 | IPv6 |
|---|---|---|---|---|
| **n1** | eth0 | n1–leaf1 | `16.0.6.1/30` | – |
|  | eth1 | LAN Net1-A | `16.0.2.1/24` | – |
| **n2** | eth0 | n2–leaf1 | `16.0.6.5/30` | – |
|  | eth1 | LAN Net1-B | `16.0.3.1/24` | – |
| **n17** | eth0 | LAN Net2-A | `16.0.4.1/25` | – |
|  | eth1 | n17–leaf2 | `16.0.6.9/30` | – |
| **n18** | eth0 | LAN Net2-B | `16.0.5.65/27` | – |
|  | eth1 | n18–leaf2 | `16.0.6.13/30` | – |
| **n21** | eth0 | LAN Net3-A | `16.0.4.129/25` | – |
|  | eth1 | n21–leaf3 | `16.0.6.17/30` | – |
| **n22** | eth0 | LAN Net3-B | `16.0.5.1/26` | – |
|  | eth1 | n22–leaf3 | `16.0.6.21/30` | – |
| **n23** | eth0 | LAN Net4-A | `16.0.5.97/27` | – |
|  | eth1 | n23–leaf4 | `16.0.6.25/30` | – |
| **n24** | eth0 | LAN Net4-B | `16.0.5.129/27` | – |
|  | eth1 | n24–leaf4 | `16.0.6.29/30` | – |
| **leaf1 (n7)** | eth0 | n1–leaf1 | `16.0.6.2/30` | – |
|  | eth1 | n2–leaf1 | `16.0.6.6/30` | – |
|  | eth2 | leaf1–spine1 | `16.0.6.33/30` | – |
|  | eth3 | leaf1–spine2 | `16.0.6.37/30` | – |
| **leaf2 (n8)** | eth0 | n17–leaf2 | `16.0.6.10/30` | – |
|  | eth1 | n18–leaf2 | `16.0.6.14/30` | – |
|  | eth2 | leaf2–**spine2** | `16.0.6.45/30` | – |
|  | eth3 | leaf2–**spine1** | `16.0.6.41/30` | – |
| **leaf3 (n9)** | eth0 | n21–leaf3 | `16.0.6.18/30` | – |
|  | eth1 | n22–leaf3 | `16.0.6.22/30` | – |
|  | eth2 | leaf3–**spine2** | `16.0.6.53/30` | – |
|  | eth3 | leaf3–**spine1** | `16.0.6.49/30` | – |
| **leaf4 (n10)** | eth0 | n23–leaf4 | `16.0.6.26/30` | – |
|  | eth1 | n24–leaf4 | `16.0.6.30/30` | – |
|  | eth2 | leaf4–**spine2** | `16.0.6.61/30` | – |
|  | eth3 | leaf4–**spine1** | `16.0.6.57/30` | – |
| **spine1 (n5)** | eth0 | leaf1–spine1 | `16.0.6.34/30` | – |
|  | eth1 | **LAN Net5** | `16.0.0.1/23` | `1600:0:0:5::1/64` |
|  | eth2 | leaf2–spine1 | `16.0.6.42/30` | – |
|  | eth3 | leaf3–spine1 | `16.0.6.50/30` | – |
|  | eth4 | leaf4–spine1 | `16.0.6.58/30` | – |
|  | tun6 | túnel 6in4 | – | `1600:0:0:ffff::1/64` |
| **spine2 (n6)** | eth0 | leaf4–spine2 | `16.0.6.62/30` | – |
|  | eth1 | leaf3–spine2 | `16.0.6.54/30` | – |
|  | eth2 | **LAN Net6** | `16.0.5.161/28` | `1600:0:0:6::1/64` |
|  | eth3 | leaf2–spine2 | `16.0.6.46/30` | – |
|  | eth4 | leaf1–spine2 | `16.0.6.38/30` | – |
|  | tun6 | túnel 6in4 | – | `1600:0:0:ffff::2/64` |
| **n11** | eth0 | LAN Net1-A | `16.0.2.10/24` | – |
| **n12** | eth0 | LAN Net1-B | `16.0.3.10/24` | – |
| **n13** | eth0 | LAN Net2-A | `16.0.4.10/25` | – |
| **n14** | eth0 | LAN Net2-B | `16.0.5.70/27` | – |
| **n29** | eth0 | LAN Net3-A | `16.0.4.140/25` | – |
| **n30** | eth0 | LAN Net3-B | `16.0.5.10/26` | – |
| **n31** | eth0 | LAN Net4-A | `16.0.5.100/27` | – |
| **n32** | eth0 | LAN Net4-B | `16.0.5.131/27` | – |
| **n33** | eth0 | LAN Net4-B | `16.0.5.130/27` | – |
| **n34** | eth0 | LAN Net5 | `16.0.0.10/23` | `1600:0:0:5::10/64` |
| **n35** | eth0 | LAN Net6 | `16.0.5.170/28` | `1600:0:0:6::10/64` |

*Los hubs (n3, n4, n19, n20, n25–n28) y los switches (n15, n16) no llevan dirección
IP: operan en capa 1 y capa 2 respectivamente.*

---

## Inciso A — Configurar Net5 y Net6 con IPv6

Se asigna el bloque `1600::/32`. Cada LAN lleva prefijo **/64**, que es el tamaño
estándar en IPv6 independientemente de la cantidad de hosts, ya que los últimos 64 bits
están reservados al *Interface ID* y no se subnetean.

| Red | Prefijo | Nodo | Dirección |
|---|---|---|---|
| LAN Net5 | `1600:0:0:5::/64` | spine1 eth1 | `1600:0:0:5::1/64` |
| | | n34 | `1600:0:0:5::10/64` |
| LAN Net6 | `1600:0:0:6::/64` | spine2 eth2 | `1600:0:0:6::1/64` |
| | | n35 | `1600:0:0:6::10/64` |
| Túnel 6in4 | `1600:0:0:ffff::/64` | spine1 tun6 | `1600:0:0:ffff::1/64` |
| | | spine2 tun6 | `1600:0:0:ffff::2/64` |

### Mecanismo de transición: túnel 6in4

Para dar conectividad IPv6 entre Net5 y Net6 se optó por un **túnel 6in4** (modo `sit`,
protocolo IP 41) en lugar de configurar IPv6 de forma nativa en todo el camino.

**Justificación:** Net5 cuelga de spine1 y Net6 de spine2. Un despliegue nativo exigiría
configurar direcciones IPv6, rutas, forwarding y reglas de filtrado en los dos spines y
en el leaf de tránsito. Con el túnel, los nodos intermedios solo ven datagramas IPv4
ordinarios y **la configuración IPv6 queda confinada a los dos extremos**. Es además uno
de los mecanismos de transición previstos por la RFC 4213, lo que lo hace preferible a
un despliegue parcial ad-hoc.

Como extremos del túnel se usan las interfaces IPv4 de cada spine hacia leaf1:
`16.0.6.34` (spine1) y `16.0.6.38` (spine2). El túnel transita por leaf1.

```bash
# spine1
ip -6 addr add 1600:0:0:5::1/64 dev eth1
ip tunnel add tun6 mode sit remote 16.0.6.38 local 16.0.6.34 ttl 64
ip link set tun6 up
ip -6 addr add 1600:0:0:ffff::1/64 dev tun6
ip -6 route add 1600:0:0:6::/64 dev tun6

# spine2
ip -6 addr add 1600:0:0:6::1/64 dev eth2
ip tunnel add tun6 mode sit remote 16.0.6.34 local 16.0.6.38 ttl 64
ip link set tun6 up
ip -6 addr add 1600:0:0:ffff::2/64 dev tun6
ip -6 route add 1600:0:0:5::/64 dev tun6
```

En los nodos de CORE el forwarding IPv6 viene deshabilitado y la política por defecto de
`ip6tables` es `DROP`, por lo que en ambos spines fue necesario además:

```bash
sysctl -w net.ipv6.conf.all.forwarding=1
ip6tables -P FORWARD ACCEPT
```

> *(Figura A.1 — salida de `ip -6 addr show` en spine1)*
> *(Figura A.2 — salida de `ip -6 addr show` en spine2)*

---

## Inciso B — Ruteo estático IPv4 e IPv6

### Criterio adoptado

La topología spine-leaf tiene **caminos redundantes**: cada leaf se conecta a los dos
spines. Con ruteo estático esto habilita bucles si se configuran rutas por defecto
enfrentadas. El criterio aplicado para evitarlos es:

1. **Las rutas por defecto apuntan únicamente "hacia arriba"**: PC → router de LAN →
   leaf → spine.
2. **Hacia abajo se usan rutas específicas**: cada leaf conoce las redes de sus routers;
   cada spine conoce qué leaf alcanza cada red.
3. **Los spines no tienen ruta por defecto.** Como la topología no tiene salida a
   Internet, el tráfico hacia un destino desconocido debe descartarse en el nivel
   superior en lugar de rebotar entre spines.

No fue necesario agregar un enlace directo entre spine1 y spine2: las redes Net1 a Net4
cuelgan de leafs conectados a ambos spines, por lo que alcanzan Net5 y Net6 directamente.
El único par que requiere cruzar de un spine al otro es **Net5 ↔ Net6**, y se resuelve
con una ruta específica a través de leaf1.

### Las redes de tránsito

Una primera versión de las tablas de los spines incluía únicamente las LANs. Al probar
conectividad extremo a extremo entre `n1` y `n24` el ping fallaba con 100 % de pérdida,
pero el mismo ping forzando la dirección de origen a la LAN (`ping -I 16.0.2.1`)
funcionaba con TTL 61.

El diagnóstico es que **el camino de ida era correcto y el de vuelta no**: al enviar el
datagrama, `n1` lo emite con dirección de origen `16.0.6.1` —la interfaz del enlace
punto a punto, porque es la que usa para salir—. `n24` responde a esa dirección, pero al
llegar la respuesta a spine1, este no tenía ruta hacia la red `16.0.6.0/30` y descartaba
el datagrama.

Se agregaron entonces las rutas hacia las **redes de tránsito**. El direccionamiento
permitió **sumarizarlas**: los dos enlaces de cada leaf quedaron contiguos y alineados,
por lo que cada par de `/30` se agrupa en un único `/29`.

| Leaf | Enlaces hacia abajo | Enlaces hacia arriba |
|---|---|---|
| leaf1 | `16.0.6.0/30` + `16.0.6.4/30` → **`16.0.6.0/29`** | `16.0.6.32/30` + `16.0.6.36/30` → **`16.0.6.32/29`** |
| leaf2 | `16.0.6.8/30` + `16.0.6.12/30` → **`16.0.6.8/29`** | `16.0.6.40/30` + `16.0.6.44/30` → **`16.0.6.40/29`** |
| leaf3 | `16.0.6.16/30` + `16.0.6.20/30` → **`16.0.6.16/29`** | `16.0.6.48/30` + `16.0.6.52/30` → **`16.0.6.48/29`** |
| leaf4 | `16.0.6.24/30` + `16.0.6.28/30` → **`16.0.6.24/29`** | `16.0.6.56/30` + `16.0.6.60/30` → **`16.0.6.56/29`** |

De este modo cada spine incorpora **8 rutas** en lugar de 16, y la tabla refleja la
jerarquía de la topología: cada `/29` identifica a un leaf.

Los leafs no necesitan estas rutas: alcanzan los enlaces de las otras ramas por su ruta
por defecto hacia spine1.


### Tablas de ruteo IPv4

### Routers de LAN

**n1**

| Destino | Next hop | Máscara | Interfaz |
|---|---|---|---|
| 16.0.2.0/24 (su LAN) | – | 255.255.255.0 | eth1 |
| 16.0.6.0/30 (n1–leaf1) | – | 255.255.255.252 | eth0 |
| **default** | **16.0.6.2** (leaf1) | 0.0.0.0 | eth0 |

**n2**

| Destino | Next hop | Máscara | Interfaz |
|---|---|---|---|
| 16.0.3.0/24 (su LAN) | – | 255.255.255.0 | eth1 |
| 16.0.6.4/30 (n2–leaf1) | – | 255.255.255.252 | eth0 |
| **default** | **16.0.6.6** (leaf1) | 0.0.0.0 | eth0 |

**n17**

| Destino | Next hop | Máscara | Interfaz |
|---|---|---|---|
| 16.0.4.0/25 (su LAN) | – | 255.255.255.128 | eth0 |
| 16.0.6.8/30 (n17–leaf2) | – | 255.255.255.252 | eth1 |
| **default** | **16.0.6.10** (leaf2) | 0.0.0.0 | eth1 |

**n18**

| Destino | Next hop | Máscara | Interfaz |
|---|---|---|---|
| 16.0.5.64/27 (su LAN) | – | 255.255.255.224 | eth0 |
| 16.0.6.12/30 (n18–leaf2) | – | 255.255.255.252 | eth1 |
| **default** | **16.0.6.14** (leaf2) | 0.0.0.0 | eth1 |

**n21**

| Destino | Next hop | Máscara | Interfaz |
|---|---|---|---|
| 16.0.4.128/25 (su LAN) | – | 255.255.255.128 | eth0 |
| 16.0.6.16/30 (n21–leaf3) | – | 255.255.255.252 | eth1 |
| **default** | **16.0.6.18** (leaf3) | 0.0.0.0 | eth1 |

**n22**

| Destino | Next hop | Máscara | Interfaz |
|---|---|---|---|
| 16.0.5.0/26 (su LAN) | – | 255.255.255.192 | eth0 |
| 16.0.6.20/30 (n22–leaf3) | – | 255.255.255.252 | eth1 |
| **default** | **16.0.6.22** (leaf3) | 0.0.0.0 | eth1 |

**n23**

| Destino | Next hop | Máscara | Interfaz |
|---|---|---|---|
| 16.0.5.96/27 (su LAN) | – | 255.255.255.224 | eth0 |
| 16.0.6.24/30 (n23–leaf4) | – | 255.255.255.252 | eth1 |
| **default** | **16.0.6.26** (leaf4) | 0.0.0.0 | eth1 |

**n24**

| Destino | Next hop | Máscara | Interfaz |
|---|---|---|---|
| 16.0.5.128/27 (su LAN) | – | 255.255.255.224 | eth0 |
| 16.0.6.28/30 (n24–leaf4) | – | 255.255.255.252 | eth1 |
| **default** | **16.0.6.30** (leaf4) | 0.0.0.0 | eth1 |

### Leafs

**leaf1**

| Destino | Next hop | Máscara | Interfaz |
|---|---|---|---|
| 16.0.6.0/30 (n1–leaf1) | – | 255.255.255.252 | eth0 |
| 16.0.6.4/30 (n2–leaf1) | – | 255.255.255.252 | eth1 |
| 16.0.6.32/30 (leaf1–spine1) | – | 255.255.255.252 | eth2 |
| 16.0.6.36/30 (leaf1–spine2) | – | 255.255.255.252 | eth3 |
| 16.0.2.0/24 (Net1-A, vía n1) | 16.0.6.1 | 255.255.255.0 | eth0 |
| 16.0.3.0/24 (Net1-B, vía n2) | 16.0.6.5 | 255.255.255.0 | eth1 |
| 16.0.5.160/28 (Net6, vía spine2) | 16.0.6.38 | 255.255.255.240 | eth3 |
| **default** | **16.0.6.34** (spine1) | 0.0.0.0 | eth2 |

**leaf2**

| Destino | Next hop | Máscara | Interfaz |
|---|---|---|---|
| 16.0.6.8/30 (n17–leaf2) | – | 255.255.255.252 | eth0 |
| 16.0.6.12/30 (n18–leaf2) | – | 255.255.255.252 | eth1 |
| 16.0.6.44/30 (leaf2–spine2) | – | 255.255.255.252 | eth2 |
| 16.0.6.40/30 (leaf2–spine1) | – | 255.255.255.252 | eth3 |
| 16.0.4.0/25 (Net2-A, vía n17) | 16.0.6.9 | 255.255.255.128 | eth0 |
| 16.0.5.64/27 (Net2-B, vía n18) | 16.0.6.13 | 255.255.255.224 | eth1 |
| **default** | **16.0.6.42** (spine1) | 0.0.0.0 | eth3 |

**leaf3**

| Destino | Next hop | Máscara | Interfaz |
|---|---|---|---|
| 16.0.6.16/30 (n21–leaf3) | – | 255.255.255.252 | eth0 |
| 16.0.6.20/30 (n22–leaf3) | – | 255.255.255.252 | eth1 |
| 16.0.6.52/30 (leaf3–spine2) | – | 255.255.255.252 | eth2 |
| 16.0.6.48/30 (leaf3–spine1) | – | 255.255.255.252 | eth3 |
| 16.0.4.128/25 (Net3-A, vía n21) | 16.0.6.17 | 255.255.255.128 | eth0 |
| 16.0.5.0/26 (Net3-B, vía n22) | 16.0.6.21 | 255.255.255.192 | eth1 |
| **default** | **16.0.6.50** (spine1) | 0.0.0.0 | eth3 |

**leaf4**

| Destino | Next hop | Máscara | Interfaz |
|---|---|---|---|
| 16.0.6.24/30 (n23–leaf4) | – | 255.255.255.252 | eth0 |
| 16.0.6.28/30 (n24–leaf4) | – | 255.255.255.252 | eth1 |
| 16.0.6.60/30 (leaf4–spine2) | – | 255.255.255.252 | eth2 |
| 16.0.6.56/30 (leaf4–spine1) | – | 255.255.255.252 | eth3 |
| 16.0.5.96/27 (Net4-A, vía n23) | 16.0.6.25 | 255.255.255.224 | eth0 |
| 16.0.5.128/27 (Net4-B, vía n24) | 16.0.6.29 | 255.255.255.224 | eth1 |
| **default** | **16.0.6.58** (spine1) | 0.0.0.0 | eth3 |

### Spines

**spine1** — sin ruta por defecto

| Destino | Next hop | Máscara | Interfaz |
|---|---|---|---|
| 16.0.6.32/30 (leaf1) | – | 255.255.255.252 | eth0 |
| 16.0.0.0/23 (LAN Net5) | – | 255.255.254.0 | eth1 |
| 16.0.6.40/30 (leaf2) | – | 255.255.255.252 | eth2 |
| 16.0.6.48/30 (leaf3) | – | 255.255.255.252 | eth3 |
| 16.0.6.56/30 (leaf4) | – | 255.255.255.252 | eth4 |
| 16.0.2.0/24 (Net1-A) | 16.0.6.33 (leaf1) | 255.255.255.0 | eth0 |
| 16.0.3.0/24 (Net1-B) | 16.0.6.33 (leaf1) | 255.255.255.0 | eth0 |
| 16.0.4.0/25 (Net2-A) | 16.0.6.41 (leaf2) | 255.255.255.128 | eth2 |
| 16.0.5.64/27 (Net2-B) | 16.0.6.41 (leaf2) | 255.255.255.224 | eth2 |
| 16.0.4.128/25 (Net3-A) | 16.0.6.49 (leaf3) | 255.255.255.128 | eth3 |
| 16.0.5.0/26 (Net3-B) | 16.0.6.49 (leaf3) | 255.255.255.192 | eth3 |
| 16.0.5.96/27 (Net4-A) | 16.0.6.57 (leaf4) | 255.255.255.224 | eth4 |
| 16.0.5.128/27 (Net4-B) | 16.0.6.57 (leaf4) | 255.255.255.224 | eth4 |
| 16.0.5.160/28 (Net6) | 16.0.6.33 (leaf1 → spine2) | 255.255.255.240 | eth0 |
| 16.0.6.0/29 (enlaces de leaf1) | 16.0.6.33 (leaf1) | 255.255.255.248 | eth0 |
| 16.0.6.32/29 (enlaces de leaf1) | 16.0.6.33 (leaf1) | 255.255.255.248 | eth0 |
| 16.0.6.8/29 (enlaces de leaf2) | 16.0.6.41 (leaf2) | 255.255.255.248 | eth2 |
| 16.0.6.40/29 (enlaces de leaf2) | 16.0.6.41 (leaf2) | 255.255.255.248 | eth2 |
| 16.0.6.16/29 (enlaces de leaf3) | 16.0.6.49 (leaf3) | 255.255.255.248 | eth3 |
| 16.0.6.48/29 (enlaces de leaf3) | 16.0.6.49 (leaf3) | 255.255.255.248 | eth3 |
| 16.0.6.24/29 (enlaces de leaf4) | 16.0.6.57 (leaf4) | 255.255.255.248 | eth4 |
| 16.0.6.56/29 (enlaces de leaf4) | 16.0.6.57 (leaf4) | 255.255.255.248 | eth4 |

**spine2** — sin ruta por defecto

| Destino | Next hop | Máscara | Interfaz |
|---|---|---|---|
| 16.0.6.60/30 (leaf4) | – | 255.255.255.252 | eth0 |
| 16.0.6.52/30 (leaf3) | – | 255.255.255.252 | eth1 |
| 16.0.5.160/28 (LAN Net6) | – | 255.255.255.240 | eth2 |
| 16.0.6.44/30 (leaf2) | – | 255.255.255.252 | eth3 |
| 16.0.6.36/30 (leaf1) | – | 255.255.255.252 | eth4 |
| 16.0.2.0/24 (Net1-A) | 16.0.6.37 (leaf1) | 255.255.255.0 | eth4 |
| 16.0.3.0/24 (Net1-B) | 16.0.6.37 (leaf1) | 255.255.255.0 | eth4 |
| 16.0.4.0/25 (Net2-A) | 16.0.6.45 (leaf2) | 255.255.255.128 | eth3 |
| 16.0.5.64/27 (Net2-B) | 16.0.6.45 (leaf2) | 255.255.255.224 | eth3 |
| 16.0.4.128/25 (Net3-A) | 16.0.6.53 (leaf3) | 255.255.255.128 | eth1 |
| 16.0.5.0/26 (Net3-B) | 16.0.6.53 (leaf3) | 255.255.255.192 | eth1 |
| 16.0.5.96/27 (Net4-A) | 16.0.6.61 (leaf4) | 255.255.255.224 | eth0 |
| 16.0.5.128/27 (Net4-B) | 16.0.6.61 (leaf4) | 255.255.255.224 | eth0 |
| 16.0.0.0/23 (Net5) | 16.0.6.37 (leaf1 → spine1) | 255.255.254.0 | eth4 |
| 16.0.6.0/29 (enlaces de leaf1) | 16.0.6.37 (leaf1) | 255.255.255.248 | eth4 |
| 16.0.6.32/29 (enlaces de leaf1) | 16.0.6.37 (leaf1) | 255.255.255.248 | eth4 |
| 16.0.6.8/29 (enlaces de leaf2) | 16.0.6.45 (leaf2) | 255.255.255.248 | eth3 |
| 16.0.6.40/29 (enlaces de leaf2) | 16.0.6.45 (leaf2) | 255.255.255.248 | eth3 |
| 16.0.6.16/29 (enlaces de leaf3) | 16.0.6.53 (leaf3) | 255.255.255.248 | eth1 |
| 16.0.6.48/29 (enlaces de leaf3) | 16.0.6.53 (leaf3) | 255.255.255.248 | eth1 |
| 16.0.6.24/29 (enlaces de leaf4) | 16.0.6.61 (leaf4) | 255.255.255.248 | eth0 |
| 16.0.6.56/29 (enlaces de leaf4) | 16.0.6.61 (leaf4) | 255.255.255.248 | eth0 |

### Tabla de ruteo IPv6

Al resolverse la conectividad IPv6 mediante el túnel, el ruteo IPv6 se reduce a una ruta
estática en cada spine.

**spine1**

| Destino | Next hop | Interfaz |
|---|---|---|
| `1600:0:0:5::/64` (LAN Net5) | – | eth4 |
| `1600:0:0:ffff::/64` (túnel) | – | tun6 |
| `1600:0:0:6::/64` (LAN Net6) | – *(on-link por el túnel)* | tun6 |

**spine2**

| Destino | Next hop | Interfaz |
|---|---|---|
| `1600:0:0:6::/64` (LAN Net6) | – | eth4 |
| `1600:0:0:ffff::/64` (túnel) | – | tun6 |
| `1600:0:0:5::/64` (LAN Net5) | – *(on-link por el túnel)* | tun6 |

**n34 y n35** llevan únicamente la ruta por defecto hacia el spine de su LAN:

```bash
# n34
ip -6 route add default via 1600:0:0:5::1
# n35
ip -6 route add default via 1600:0:0:6::1
```

> *(Figura B.1 … B.14 — salida de `ip route show` en cada router)*
> *(Figura B.15 — salida de `ip -6 route show` en spine1 y spine2)*

---

## Inciso C — NAT con direccionamiento privado *(alternativo)*

Se asigna a **n33** una dirección privada según **RFC 1918**, que define tres rangos:

```
10.0.0.0    – 10.255.255.255     (1 red clase A)
172.16.0.0  – 172.31.255.255     (16 redes clase B)
192.168.0.0 – 192.168.255.255    (256 redes clase C)
```

Se elige `192.168.0.0/24` para el segmento, con `192.168.0.10` para n33 y
`192.168.0.1` para la interfaz de n24 que actúa como gateway. Como las direcciones
privadas no son ruteables fuera de la organización, n24 debe traducirlas.

```bash
# n24
ip addr add 192.168.0.1/24 dev eth0
sysctl -w net.ipv4.ip_forward=1
iptables -P FORWARD ACCEPT
iptables -t nat -A POSTROUTING -s 192.168.0.0/24 -o eth1 -j MASQUERADE

# n33
ip addr add 192.168.0.10/24 dev eth0
ip route add default via 192.168.0.1
```

Se usa **MASQUERADE** (NAPT) en lugar de SNAT estático porque traduce contra la
dirección que tenga la interfaz de salida sin necesidad de fijarla en la regla.

Verificación:

```bash
iptables -t nat -L -n -v
conntrack -L
```

> *(Figura C.1 — regla de NAT en n24)*
> *(Figura C.2 — ping desde n33 y tabla de conntrack mostrando la traducción)*

> **Orden de ejecución:** este inciso se realizó **después** del inciso E, ya que al
> quedar n33 detrás de NAT el intercambio capturado en E cambiaría.

---

## Inciso D — Test con ping y traceroute

Con el direccionamiento y las rutas configuradas, se verificó la conectividad entre
nodos adyacentes y entre extremos de la topología con `ping` y `traceroute`.

```bash
ping -c 4 16.0.2.1          # n11 → su gateway
ping -c 4 16.0.6.2          # n11 → leaf1
ping -c 4 16.0.5.130        # n11 → n33, atraviesa toda la topología
traceroute 16.0.5.130
```

**Verificación de ausencia de bucles.** Se hace ping a una dirección que no existe en la
topología:

```bash
ping 1.2.3.4
```

- Respuesta **ICMP Destination Unreachable, Net Unreachable (tipo 3, código 0)** →
  correcto: algún router descartó el datagrama por falta de ruta.
- Respuesta **ICMP Time Exceeded (tipo 11, código 0)** → indicaría que el datagrama
  circuló hasta agotar el TTL, es decir, **hay un bucle de ruteo**.

**Figuras:**

<img width="561" height="145" alt="ping-n11n33" src="https://github.com/user-attachments/assets/bbf23ddd-fb4a-483e-ab50-3ecc3978f42e" />

> *Figura d.1 — ping de n11 a n33*

<img width="561" height="138" alt="traceroute-n11n33" src="https://github.com/user-attachments/assets/d5c3f311-dfbf-4f54-b35c-182e37d01319" />

> *Figura d.2 — traceroute de n11 a n33*

<img width="560" height="138" alt="ping-unreachable" src="https://github.com/user-attachments/assets/cdc3237b-82c4-4a12-8615-8b2c77c448a0" />

> *Figura d.3 — ping de n11 a red inexistente*

---

## Inciso E — Captura del tráfico n11 → n33: ARP e ICMP

Se realiza un ping desde **n11** (`16.0.2.10`, Net1-A) hacia **n33** (`16.0.5.130`,
Net4-B) y se captura el tráfico en el segmento de n11.

```bash
tcpdump -i eth0 -w /media/sf_tpi/tp2/capturas/e-n11-n33.pcap 'arp or icmp'
```

Como n11 y n33 **no pertenecen a la misma red**, el Echo Request debe enviarse al
default gateway. Antes, n11 necesita la MAC de ese gateway, y para eso emite un **ARP
Request**.

**ARP Request** — trama Ethernet con EtherType `0x0806`:

| Campo | Valor |
|---|---|
| MAC destino | `FF:FF:FF:FF:FF:FF` (broadcast) |
| MAC origen | MAC de n11 |
| IP origen | `16.0.2.10` (n11) |
| IP destino | **`16.0.2.1` (n1)** ← el gateway, **no** n33 |

**ARP Reply** — respuesta de n1, en unicast:

| Campo | Valor |
|---|---|
| MAC destino | MAC de n11 |
| MAC origen | MAC de n1 |
| IP origen | `16.0.2.1` |
| IP destino | `16.0.2.10` |

Recién entonces n11 emite el **ICMP Echo Request (tipo 8, código 0)**, encapsulado en
una trama dirigida a la MAC de n1 pero con **IP destino `16.0.5.130`**.

**Observación central:** la dirección IP de destino se mantiene constante de extremo a
extremo, mientras que **las direcciones MAC se reescriben en cada salto**. Cada tramo del
camino resuelve su propio ARP de forma independiente. n11 nunca conoce la MAC de n33.

El camino completo del datagrama es:

```
n11 → n3(hub) → n1 → leaf1 → spine(1 o 2) → leaf4 → n24 → n28(hub) → n33
```

Como el segmento de n11 cuelga de un **hub**, la captura puede tomarse desde cualquier
PC del mismo segmento: al ser un único dominio de colisión, todas las estaciones reciben
todas las tramas.

> *(Figura E.1 — ping de n11 a n33)*
> *(Figura E.2 — ARP Request en Wireshark, con los campos resaltados)*
> *(Figura E.3 — ARP Reply)*
> *(Figura E.4 — ICMP Echo Request y Echo Reply)*

---

## Inciso F — Traceroute capturado

`traceroute` se apoya en el campo **TTL** del datagrama IPv4 y en los mensajes ICMP:

1. El origen envía una sonda con **TTL = 1**.
2. El primer router lo decrementa a 0, descarta el datagrama y devuelve al origen un
   **ICMP Time Exceeded — In Transit (tipo 11, código 0)**, revelando su dirección.
3. El origen repite con TTL = 2, 3, … y así descubre cada salto del camino.
4. Al llegar al destino, la respuesta depende del tipo de sonda:
   - **Linux** (`traceroute`) usa por defecto **sondas UDP a puertos altos**; el destino
     responde **ICMP Destination Unreachable — Port Unreachable (tipo 3, código 3)**.
   - **Windows** (`tracert`) usa **ICMP Echo**; el destino responde
     **Echo Reply (tipo 0, código 0)**.

```bash
traceroute 16.0.5.130
tcpdump -i eth0 -w /media/sf_tpi/tp2/capturas/f-traceroute.pcap 'icmp or udp'
```

> *(Figura F.1 — salida de traceroute de n11 a n33)*
> *(Figura F.2 — captura: sondas con TTL creciente y los Time Exceeded)*
> *(Figura F.3 — mensaje final del destino)*

---

## Inciso G — Modificación de MTU y fragmentación *(alternativo)*

Se verifica primero el tamaño de un Echo Request estándar (84 bytes: 20 de cabecera IP +
8 de cabecera ICMP + 56 de datos). Luego se reduce el MTU de un enlace intermedio para
forzar la fragmentación.

```bash
ip link set dev eth1 mtu 500
ping -s 1400 16.0.5.130
tcpdump -i eth1 -w /media/sf_tpi/tp2/capturas/g-fragmentacion.pcap icmp
```

En la captura se observan los campos **Identification** (igual en todos los fragmentos
del mismo datagrama), **More Fragments** (en 1 salvo en el último) y **Fragment Offset**
(expresado en unidades de 8 bytes).

**Contraste con IPv6.** Si se reduce el MTU por debajo de **1280 bytes** en el camino
IPv6, la comunicación se interrumpe: 1280 es el MTU mínimo obligatorio de IPv6. Además,
**los routers intermedios no fragmentan en IPv6**; el router devuelve un **ICMPv6 Packet
Too Big (tipo 2)** y es el nodo origen quien debe fragmentar mediante el *extension
header* Fragment, previo descubrimiento del Path MTU.

> *(Figura G.1 — tamaño del datagrama antes de fragmentar)*
> *(Figura G.2 — configuración del MTU)*
> *(Figura G.3 — fragmentos en Wireshark con Identification, MF y Offset)*

---

## Inciso H — Conectividad IPv6 y análisis de ICMPv6

Se verifica la conectividad entre Net5 y Net6 con `ping6`, y se captura el tráfico para
analizar ICMPv6.

```bash
# desde n34
ping6 -c 4 1600:0:0:6::10
traceroute6 1600:0:0:6::10
tcpdump -i eth0 -w /media/sf_tpi/tp2/capturas/h-icmpv6.pcap icmp6
```

### Diferencias respecto de IPv4

| | IPv4 | IPv6 |
|---|---|---|
| Resolución dirección ↔ MAC | **ARP**, protocolo independiente | **NDP**, dentro de ICMPv6 |
| Mensajes | Request / Reply | **Neighbor Solicitation (135)** / **Neighbor Advertisement (136)** |
| Destino de la consulta | broadcast `FF:FF:FF:FF:FF:FF` | **multicast solicited-node** `ff02::1:ffXX:XXXX` |
| MAC destino | broadcast | `33:33:ff:` + últimos 3 bytes de la IPv6 |
| Echo Request / Reply | 8 / 0 | **128 / 129** |

El **Neighbor Solicitation** lleva **Hop Limit = 255**, requisito de seguridad de NDP: un
nodo que recibe un NDP con Hop Limit distinto de 255 lo descarta, ya que garantiza que el
mensaje no atravesó ningún router.

A diferencia del ARP Request, que interrumpe a todas las estaciones del segmento, el NS
se envía a la dirección multicast *solicited-node*, formada con los últimos 24 bits de la
dirección buscada. Solo procesan la trama los nodos cuyo sufijo coincide.

Para que el tráfico IPv6 atravesara los nodos fue necesario, en cada spine:

```bash
sysctl -w net.ipv6.conf.all.forwarding=1
ip6tables -P FORWARD ACCEPT
```

El segundo comando corresponde al script `ipv6-unfilter.sh` provisto por la cátedra: en
los nodos del simulador la política por defecto de la cadena FORWARD de `ip6tables` es
`DROP`, por lo que los datagramas IPv6 se descartan silenciosamente aunque el
direccionamiento y el ruteo sean correctos.

> *(Figura H.1 — ping6 de n34 a n35)*
> *(Figura H.2 — traceroute6)*
> *(Figura H.3 — Neighbor Solicitation y Neighbor Advertisement en Wireshark)*
> *(Figura H.4 — Echo Request / Echo Reply ICMPv6)*
> *(Figura H.5 — datagramas encapsulados en el túnel, vistos desde leaf1)*

---

## Conclusiones

*(a completar)*
