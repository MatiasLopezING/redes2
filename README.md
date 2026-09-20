# TPI Redes II — grupo

Topología spine-leaf de la **figura 6** (Práctica 2, rev 2.6). Direccionamiento IPv4 +
IPv6, ruteo estático y capturas.

| | |
|---|---|
| Integrantes | |
| Bloque IPv4 | |
| Bloque IPv6 | |
| Entrega | |

## Qué hay acá

| | |
|---|---|
| `redes-II-ing-practica_2.pdf` | la práctica completa — **el TPI es la página 9** (consigna + figura 6) |
| `direccionamiento.md` | el diseño IPv4/IPv6 — **el grueso del trabajo** |
| `configs/` | un `.sh` por nodo |
| `capturas/` | `.pcap` y screenshots |
| `topologia.imn` | la topología de CORE *(cuando exista)* |
| `informe.md` | lo que se entrega *(crear al final)* |

---

## Cómo laburamos

### El repo en Windows, la VM solo corre

Todo lo que versionamos es texto: el `.imn` es XML, las configs son bash, los docs
Markdown. La `.ova` de 7 GB no entra al repo — cada uno la tiene local.

**Setup (una vez):** VirtualBox → la VM → *Configuración* → *Carpetas compartidas* →
agregar esta carpeta, nombre `tpi`, automontar ✅.
En la VM: `sudo usermod -aG vboxsf $USER` y reiniciar → queda en `/media/sf_tpi`.

Editás y hacés git en Windows; abrís CORE y guardás capturas en `/media/sf_tpi/capturas/`.

### Todo en `main`

```bash
git pull --rebase          # antes de empezar y antes de pushear
git add -A
git commit -m "net2: LANs de 30 y 100 hosts"
git pull --rebase && git push
```

El `--rebase` evita commits de merge. Si hay conflicto en un `.md`: lo arreglás a mano
(son tablas), `git add <archivo>`, `git rebase --continue`.

### Lo único que hay que respetar

- **`git pull --rebase` antes de tocar nada.** De ahí salen casi todos los quilombos.
- **El `.imn` lo toca uno a la vez.** Es XML: si dos lo editan en paralelo, el merge no
  se puede resolver. Avisar por el grupo y pushear apenas terminás.
- **Las configs van en scripts**, no clickeadas en la GUI — lo que se clickea en CORE se
  pierde al cerrar.

### Sugerencia de cómo dividirlo

El **diseño** (VLSM, IPv6, tablas de ruteo, scripts) se puede hacer cada uno por su
lado, en paralelo, sin pisarse. Es el 70% del laburo.

La **simulación** conviene hacerla en **una sola sesión con los tres** (juntos o por
Discord con control remoto), en la VM de uno: el `.imn` es un solo archivo, y armar 35
nodos entre tres —uno dictando del `direccionamiento.md`, otro verificando— va mucho
más rápido que en paralelo. Las capturas de (e), (f) y (h) salen todas de ahí.

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

## Arrancar el repo (uno solo, la primera vez)

```bash
git init -b main
git add -A
git commit -m "inicial"
# crear repo privado en GitHub (vacío, sin README) y:
git remote add origin <url>
git push -u origin main
# Settings > Collaborators > invitar a los otros dos
```

Los otros: `git clone <url>`

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
