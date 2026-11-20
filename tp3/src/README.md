# Programas del TP3

Cuatro programas mínimos sobre la API de sockets. Python 3.8 o superior
(usan el operador walrus `:=`). No necesitan instalar nada.

## Uso

```bash
# ── UDP (punto 26.a) ──
python3 udp_recv.py 8000 /tmp/file-out          # en n33 (receptor)
python3 udp_send.py <IP_n33> 8000 /tmp/file-in  # en n34 (emisor)

# ── TCP (punto 27.a) ──
python3 tcp_recv.py 8000 /tmp/file-out          # en n33 (receptor)
python3 tcp_send.py <IP_n33> 8000 /tmp/file-in  # en n34 (emisor)

# ── TCP con control de flujo (punto 27.g) ──
python3 tcp_recv.py 8000 /tmp/file-out --lento  # en n33
```

Dentro de CORE, anteponer `vcmd`:

```bash
vcmd -c /tmp/pycore.*/n33 -- python3 /ruta/tcp_recv.py 8000 /tmp/file-out
```

## Prueba rápida sin CORE

```bash
head -c 100000 /dev/urandom > /tmp/file-in
python3 tcp_recv.py 8000 /tmp/file-out &
python3 tcp_send.py 127.0.0.1 8000 /tmp/file-in
cmp /tmp/file-in /tmp/file-out && echo OK
```

## Interoperar con netcat (puntos 26.b y 27.b)

```bash
# nuestro emisor contra netcat como servidor
nc -u -l 8000 > /tmp/file-out        # UDP
nc -N  -l 8000 > /tmp/file-out       # TCP

# netcat como emisor contra nuestro servidor
cat /tmp/file-in | nc -u <IP> 8000   # UDP
cat /tmp/file-in | nc -N <IP> 8000   # TCP
```

## Decisiones de diseño (para justificar en el informe)

**UDP — el datagrama vacío como fin de archivo.**
UDP no tiene cierre de conexión ni fin de flujo: el receptor no tiene forma
de saber que no viene nada más. Por eso el fin de archivo hay que
**inventarlo a nivel aplicación**; acá se usa un datagrama de longitud 0.
En TCP esto no hace falta porque el FIN hace que `recv()` devuelva vacío.

**TCP — `shutdown(SHUT_WR)` en lugar de solo `close()`.**
Envía el FIN y deja la conexión en **medio cierre**: este extremo ya no manda
pero sigue pudiendo recibir. Es lo que hace que interopere con `nc -N`
(punto 27.b) y lo que permite observar los estados `FIN_WAIT2` del lado que
cierra y `CLOSE_WAIT` del otro (punto 27.e).

**TCP — el modo `--lento`.**
Combina un `SO_RCVBUF` chico con una demora entre lecturas. La aplicación no
consume, el buffer se llena, la ventana anunciada baja hasta 0 y el emisor
frena: eso es el **control de flujo**, y en Wireshark se ve como
`TCP ZeroWindow` seguido de `TCP Window Update` (punto 27.g).
