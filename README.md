# Redes de Datos II

Matías Lopez · Juan David Alvarez · Lautaro Nahuel Lopes

> 📖 **[La wiki](https://github.com/MatiasLopezING/redes2/wiki)** explica el TP desde cero:
> la teoría de cada inciso, por qué tomamos cada decisión, los errores que cometimos y las
> preguntas de coloquio. Este README es solo para poner la red a andar.

| Trabajo | Estado |
|---|---|
| [`tp2/`](tp2/) | **completo** — los 8 incisos, 44 figuras |

## Estructura

```
tp2/
├── informe.md                      el entregable
├── direccionamiento.md             qué IP va en cada interfaz
├── topologia.imn                   la topología de CORE
├── configs/configurar.sh           configura cualquier nodo
├── capturas/                       las figuras
└── redes-II-ing-practica_2.pdf     el enunciado (pág. 9)
```

| Bloque IPv4 | Bloque IPv6 |
|---|---|
| `16.0.0.0/16` | `1600::/32` |

## Setup

```bash
git clone https://github.com/MatiasLopezING/redes2.git
```

Montar esa carpeta en la VM para que CORE la vea:

1. VirtualBox → la VM apagada → *Configuración* → *Carpetas compartidas* → agregarla con
   nombre **`tpi`**, automontar ✅, solo lectura ❌
2. En la VM: `sudo usermod -aG vboxsf $USER` y reiniciar
3. Queda en `/media/sf_tpi`

Se edita y se hace git desde Windows; CORE corre en la VM. La `.ova` no va al repo.

## Levantar la red

1. En la VM: `core-gui &` → abrir `/media/sf_tpi/tp2/topologia.imn` → **Start** ▶
2. Doble click en **cada router y cada PC** → en su terminal:

```bash
bash /media/sf_tpi/tp2/configs/configurar.sh
```

El script detecta solo qué nodo es. Hubs y switches no se configuran.
Orden: spines → leafs → routers de LAN → PCs.

```bash
# probar, desde n11
ping -c2 16.0.5.130    # a n33, cruza toda la topología (TTL 59)
ping -c2 1.2.3.4       # debe dar Net Unreachable, NO Time Exceeded
```

> Si algo no anda → **[Errores y diagnóstico](https://github.com/MatiasLopezING/redes2/wiki/11-Errores-y-diagnostico)**

## Las interfaces no son simétricas

CORE las numeró según el orden en que se trazaron los enlaces. Tenerlo a mano al configurar:

| | eth0 | eth1 | eth2 | eth3 | eth4 |
|---|---|---|---|---|---|
| spine1 | leaf1 | **LAN Net5** | leaf2 | leaf3 | leaf4 |
| spine2 | leaf4 | leaf3 | **LAN Net6** | leaf2 | leaf1 |
| leaf1 | n1 | n2 | spine1 | spine2 | |
| leaf2/3/4 | router | router | **spine2** | **spine1** | |
| n1, n2 | **leaf** | LAN | | | |
| n17…n24 | **LAN** | leaf | | | |

## Git

Todo en `main`, sin ramas.

```bash
git pull --rebase
git add -A && git commit -m "tp2: ..."
git pull --rebase && git push
```

- `git pull --rebase` **antes de tocar nada**
- **El `.imn` lo toca uno a la vez** y avisa por el grupo
- Las configs van en el script, no clickeadas en la GUI
- La wiki es **otro repo** (`redes2.wiki.git`): se clona y se commitea aparte
