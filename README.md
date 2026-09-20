# TPI Redes II

Topología spine-leaf de la **figura 6** de la Práctica 2. Direccionamiento IPv4 + IPv6,
ruteo estático y capturas.

https://github.com/MatiasLopezING/redes2

| | |
|---|---|
| Integrantes | |
| Bloque IPv4 | |
| Bloque IPv6 | |
| Entrega | |

## Qué hay acá

| | |
|---|---|
| `redes-II-ing-practica_2.pdf` | el enunciado — **el TPI es la página 9** |
| `direccionamiento.md` | el diseño IPv4/IPv6, **el grueso del trabajo** |
| `configs/` | un `.sh` por nodo |
| `capturas/` | `.pcap` y screenshots |

Después se suman `topologia.imn` (la topología de CORE) y `informe.md`.

---

## Setup

```bash
git clone https://github.com/MatiasLopezING/redes2.git
```

Después hay que montar **esa carpeta** en la VM, así CORE lee los `.imn` y guarda las
capturas directo en el repo:

1. VirtualBox → la VM → *Configuración* → *Carpetas compartidas* → agregar la carpeta,
   nombre `tpi`, automontar ✅, solo lectura ❌
2. En la VM: `sudo usermod -aG vboxsf $USER` y reiniciar
3. Queda en `/media/sf_tpi`

Editás y hacés git desde Windows, corrés CORE en la VM.
La `.ova` de 7 GB no va al repo, cada uno la tiene local.

---

## Flujo

Todo en `main`, sin ramas.

```bash
git pull --rebase
# ... trabajar ...
git add -A
git commit -m "net2: LANs de 30 y 100 hosts"
git pull --rebase && git push
```

El `--rebase` evita commits de merge. Si hay conflicto en un `.md`: lo arreglás a mano
(son tablas), `git add <archivo>`, `git rebase --continue`.

**Tres cosas:**

- `git pull --rebase` **antes de tocar nada**. De ahí salen casi todos los quilombos.
- **El `.imn` lo toca uno a la vez** y avisa por el grupo. Es XML: si dos lo editan en
  paralelo, el merge no se puede resolver.
- **Las configs van en scripts**, no clickeadas en la GUI — lo que se clickea en CORE se
  pierde al cerrar.

**El diseño** (VLSM, IPv6, tablas de ruteo, scripts) se puede hacer cada uno por su
lado. **La simulación conviene hacerla los tres juntos en una sola sesión**, en la VM de
uno: el `.imn` es un archivo solo, y armar 35 nodos de a tres —uno dictando del
`direccionamiento.md`, otro verificando— va mucho más rápido. Las capturas de (e), (f)
y (h) salen todas de ahí.

---

## Comandos

```bash
# verificar
ip addr show / ip -6 addr show          # direcciones
ip route show / ip -6 route show        # tablas de ruteo
ip -4 neigh show / ip -6 neigh show     # ARP / NDP
sysctl net.ipv4.ip_forward              # ¿rutea este nodo?
sysctl net.ipv4.conf.all.rp_filter      # si el ping no va, mirá esto

# tests — punto (d)
ping -c 4 <ip>        ping6 -c 4 <ipv6>      ping -nR <ip>
traceroute <ip>       traceroute -I <ip>     traceroute6 <ipv6>

# capturas — puntos (e) (f) (h)
tcpdump -i eth0 -w /media/sf_tpi/capturas/e-n11-n33.pcap 'arp or icmp'
tcpdump -i eth0 -w /media/sf_tpi/capturas/f-traceroute.pcap 'icmp or udp'
tcpdump -i eth0 -w /media/sf_tpi/capturas/h-icmpv6.pcap 'icmp6'
```

**Qué mirar en cada captura**

- **(e)** n11 y n33 están en **redes distintas** → n11 hace ARP **del gateway**, no de
  n33. La IP destino es n33 de punta a punta, la **MAC cambia en cada salto**. Echo
  Request **8/0**, Reply **0/0**.
- **(f)** TTL creciente → cada router devuelve **Time Exceeded 11/0**. El destino
  responde **3/3** si la sonda es UDP (Linux) o **0/0** si es ICMP (Windows).
- **(h)** **NDP** en vez de ARP: NS **135** / NA **136**, a multicast solicited-node
  `ff02::1:ffXX:XXXX`. MAC destino `33:33:ff:` + últimos 3 bytes de la IPv6. Hop Limit
  **255**. Echo Request/Reply **128/129**.

---

## Qué falta

- [ ] Direccionamiento IPv4 (VLSM)
- [ ] IPv6 Net5 / Net6 — **(a)**
- [ ] Topología en CORE
- [ ] Ruteo estático IPv4 e IPv6 — **(b)**
- [ ] ping + traceroute — **(d)**
- [ ] Captura n11 → n33: ARP e ICMP — **(e)**
- [ ] Captura del traceroute — **(f)**
- [ ] IPv6 + ICMPv6 — **(h)**
- [ ] Informe / presentación
- [ ] *Alternativo:* NAT en n33 — **(c)**
- [ ] *Alternativo:* MTU y fragmentación — **(g)**
