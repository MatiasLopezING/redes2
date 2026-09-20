# Redes de Datos II — trabajos prácticos

| | |
|---|---|
| Integrantes | |
| Materia | Redes de Datos II — Ing. en Computación, UNLP |

## Trabajos

| | Tema | Estado |
|---|---|---|
| [`tp2/`](tp2/) | Direccionamiento IPv4/IPv6, ruteo estático, NAT, capturas | en curso |

---

## Setup (una vez por persona)

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
git commit -m "tp2: LANs de 30 y 100 hosts"
git pull --rebase && git push
```

El `--rebase` evita commits de merge. Si hay conflicto en un `.md`: lo arreglás a mano
(son tablas), `git add <archivo>`, `git rebase --continue`.

**Tres cosas:**

- `git pull --rebase` **antes de tocar nada**. De ahí salen casi todos los quilombos.
- **Los `.imn` los toca uno a la vez** y avisa por el grupo. Es XML: si dos lo editan en
  paralelo, el merge no se puede resolver.
- **Las configs van en scripts**, no clickeadas en la GUI — lo que se clickea en CORE se
  pierde al cerrar.

Poné el número de TP al principio del mensaje de commit (`tp2: ...`), así el historial
se lee solo.

**Cómo dividirlo:** el diseño (direccionamiento, tablas de ruteo, scripts) se puede
hacer cada uno por su lado. La simulación conviene hacerla **los tres juntos en una sola
sesión**, en la VM de uno: el `.imn` es un archivo solo y armar la topología de a tres
—uno dictando direcciones, otro verificando— va mucho más rápido.

---

## Comandos de CORE / Linux

```bash
# verificar
ip addr show / ip -6 addr show          # direcciones
ip route show / ip -6 route show        # tablas de ruteo
ip -4 neigh show / ip -6 neigh show     # ARP / NDP
sysctl net.ipv4.ip_forward              # ¿rutea este nodo?
sysctl net.ipv6.conf.all.forwarding     # ídem IPv6 (viene APAGADO en CORE)
sysctl net.ipv4.conf.all.rp_filter      # si el ping no va, mirá esto

# tests
ping -c 4 <ip>        ping6 -c 4 <ipv6>      ping -nR <ip>
traceroute <ip>       traceroute -I <ip>     traceroute6 <ipv6>

# capturas — guardar en la carpeta compartida para que queden en el repo
tcpdump -i eth0 -w /media/sf_tpi/tpN/capturas/<nombre>.pcap 'arp or icmp'
tcpdump -i eth0 -n -p arp               # ver en vivo, sin guardar
```

### Si algo no anda

| Síntoma | Probable causa |
|---|---|
| El ping no pasa de un router | `sysctl -w net.ipv4.ip_forward=1` |
| Pasa en una dirección pero no en la otra | `sysctl -w net.ipv4.conf.all.rp_filter=0` |
| IPv6 anda entre vecinos pero no atraviesa un router | `sysctl -w net.ipv6.conf.all.forwarding=1` |
| IPv6 sigue sin pasar con forwarding en 1 | `ip6tables -P FORWARD ACCEPT` |
| El nodo dejó de recibir RA al prender forwarding | `sysctl -w net.ipv6.conf.eth0.accept_ra=2` |
| `ping` a una IP inexistente responde Time Exceeded | **hay un loop de ruteo** |
