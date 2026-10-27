# TPI Redes de Datos II — Grupo 0X

Matías Lopez (02670/0) · Juan David Alvarez (03100/2) · Lautaro Nahuel Lopes (02978/9)

Topología de la **figura 6** (spine-leaf). Bloques asignados: `16.0.0.0/16` y `1600::/32`.

## Contenido

| Archivo | |
|---|---|
| `topologia.imn` | la topología de CORE, con el direccionamiento ya cargado |
| `configurar.sh` | configura un nodo: rutas, sysctl y el túnel 6in4 |
| `levantar.sh` | corre `configurar.sh` en los 25 nodos de una sola vez |
| `informe.pdf` | **el informe** — 42 páginas, autocontenido |
| `informe.md` | el mismo informe en Markdown, por si se quiere editar |
| `capturas/` | las 45 figuras que referencia el `.md` |

## Cómo levantar la red

1. `core-gui &` → **File → Open** → `topologia.imn` → **Start ▶**
2. En una terminal **de la VM** (no de un nodo), parado en esta carpeta:

```bash
sudo bash levantar.sh
```

Configura los 25 nodos en unos segundos e imprime el resultado de cada uno.
Los hubs y switches no se configuran: son capa 1 y capa 2.

> **Por qué hace falta el script.** El formato `.imn` guarda las direcciones de interfaz y
> los servicios de cada nodo, pero **no** las rutas estáticas, el túnel ni los parámetros
> del kernel. El direccionamiento ya viene en el `.imn`; el script agrega lo demás.
>
> Para configurar un nodo suelto, desde su propia terminal:
> `bash <ruta>/configurar.sh`

## Verificación rápida

Desde **n11**:

```bash
ping -c2 16.0.5.130       # a n33 — TTL 59, cruza los 5 routers
traceroute 16.0.5.130     # 6 saltos: n1 → leaf1 → spine1 → leaf4 → n24 → n33
ping -c2 1.2.3.4          # Net Unreachable desde el spine: no hay bucles de ruteo
```

Desde **spine1 (n5)**:

```bash
ping6 -c2 1600:0:0:6::1   # LAN Net6, atravesando el túnel 6in4
```

## Incisos

Los ocho están resueltos y documentados en `informe.md`, incluidos los dos alternativos:
**c)** NAT con direccionamiento RFC 1918 y **g)** modificación de MTU y fragmentación.

Para reproducir esos dos, el informe indica los comandos; ambos modifican el estado de la
red, así que conviene correrlos al final.
