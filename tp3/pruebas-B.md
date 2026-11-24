# Parte B (Matías) — Guion de pruebas TCP

Incisos **27.a · 27.b · 27.g · 27.h**.
Cada bloque es: *qué comando tipear* → *qué hay que ver* → *qué captura sacar*.

## Preparación (una sola vez)

```bash
# 1. Abrir ../tp2/topologia.imn en CORE y presionar Start
# 2. Configurar los 25 nodos
sudo bash ../tp2/configs/levantar.sh          # => "25 configurados · 0 con problemas"

# 3. Copiar los programas donde los nodos los vean
#    (los nodos de CORE comparten el filesystem del host)
SRC=$(pwd)/src

# 4. Archivo de prueba en n34
vcmd -c /tmp/pycore.*/n34 -- bash -c 'head -c 200000 /dev/urandom > /tmp/file-in; ls -l /tmp/file-in'
```

**IP de n33:** confirmar en `../tp2/direccionamiento.md` (debería ser `16.0.5.130`).
De acá en adelante se la llama `$N33`.

---

## 27.a — Transferencia de un archivo con nuestros programas

```bash
# terminal 1 — receptor en n33
vcmd -c /tmp/pycore.*/n33 -- python3 $SRC/tcp_recv.py 8000 /tmp/file-out

# terminal 2 — emisor en n34
vcmd -c /tmp/pycore.*/n34 -- python3 $SRC/tcp_send.py 16.0.5.130 8000 /tmp/file-in

# verificar que llegó idéntico
vcmd -c /tmp/pycore.*/n33 -- md5sum /tmp/file-out
vcmd -c /tmp/pycore.*/n34 -- md5sum /tmp/file-in
```

**Qué tiene que verse:** los dos `md5sum` idénticos.
**Captura:** `Ejercicio27a_foto1_transferencia.png` — las dos terminales con los md5 iguales.
**Captura:** `Ejercicio27a_foto2_wireshark.png` — Wireshark sobre el enlace de n34:
handshake `SYN / SYN,ACK / ACK`, los `PSH,ACK` con datos, y el cierre.

---

## 27.b — Interoperar con netcat

Hay que mostrarlo **en las dos direcciones**: nuestro programa es
intercambiable con netcat porque los dos hablan TCP puro.

```bash
# (1) nuestro emisor  →  netcat como servidor
vcmd -c /tmp/pycore.*/n33 -- bash -c 'nc -N -l 8000 > /tmp/file-nc'
vcmd -c /tmp/pycore.*/n34 -- python3 $SRC/tcp_send.py 16.0.5.130 8000 /tmp/file-in

# (2) netcat como emisor  →  nuestro servidor
vcmd -c /tmp/pycore.*/n33 -- python3 $SRC/tcp_recv.py 8000 /tmp/file-out2
vcmd -c /tmp/pycore.*/n34 -- bash -c 'cat /tmp/file-in | nc -N 16.0.5.130 8000'
```

**Por qué funciona:** `tcp_send.py` hace `shutdown(SHUT_WR)`, que manda el **FIN**.
Eso es lo mismo que hace `nc -N` al terminar de leer su entrada: sin ese FIN,
netcat se quedaría esperando para siempre.

**Captura:** `Ejercicio27b_foto1_nc_servidor.png` y `Ejercicio27b_foto2_nc_cliente.png`,
con el `md5sum` coincidente en cada caso.

---

## 27.g — Activar el control de FLUJO

```bash
# receptor LENTO en n33  (buffer chico + lectura demorada ≈ 10 KB/s)
vcmd -c /tmp/pycore.*/n33 -- python3 $SRC/tcp_recv.py 8000 /tmp/file-out --lento

# emisor normal en n34 — manda a toda velocidad
vcmd -c /tmp/pycore.*/n34 -- python3 $SRC/tcp_send.py 16.0.5.130 8000 /tmp/file-in
```

Con Wireshark corriendo **antes** de arrancar, filtro: `tcp.port == 8000`

**Qué tiene que verse (en este orden):**

1. Al principio, los ACK de n33 anuncian una ventana que **va bajando**:
   `Win=4096 → Win=3072 → Win=2048 → Win=1024`
2. Aparece **`[TCP ZeroWindow]`** — n33 anuncia `Win=0`: *"pará, no tengo lugar"*.
3. n34 **deja de transmitir** y manda **`[TCP ZeroWindowProbe]`** cada tanto:
   un segmento de 1 byte preguntando si se liberó espacio.
4. Cuando la aplicación lee, n33 manda **`[TCP Window Update]`** con `Win>0`
   y la transferencia se reanuda.
5. El ciclo se repite durante toda la transferencia.

**Filtro útil para la captura limpia:**
`tcp.analysis.zero_window || tcp.analysis.window_update`

**Captura:** `Ejercicio27g_foto1_zerowindow.png` y `Ejercicio27g_foto2_ventana.png`
(esta última con *Statistics → TCP Stream Graphs → Window Scaling*, que dibuja
la ventana cerrándose).

### Dato medido (verificado fuera de CORE)

| | |
|---|---|
| Ventana real del receptor | **4096 B** (el kernel redondea el `SO_RCVBUF=2048`) |
| Ritmo que impone el receptor | **10,0 KB/s** |
| La aplicación emisora pudo "enviar" | **~2,1 MB instantáneos** antes de bloquearse |
| Después, `sendall()` quedó bloqueado | **61,8 s** |

**El punto fino para el informe:** el control de flujo frena al **TCP** del emisor,
no a la aplicación — hasta que se llena el buffer de envío del socket
(`SO_SNDBUF`, ~2–4 MB). Por eso con un archivo chico la aplicación "termina"
enseguida aunque los bytes todavía estén saliendo a cuentagotas.
**Con 200 KB la captura muestra el ZeroWindow igual**, que es lo que pide el inciso.

---

## 27.h — Agregar pérdida: se activa el control de CONGESTIÓN

```bash
# En CORE: botón derecho sobre un enlace del camino n34→n33
#   → Configure → loss (%) = 5    → Apply
# (o por consola, sobre la interfaz del nodo:)
vcmd -c /tmp/pycore.*/n34 -- tc qdisc add dev eth0 root netem loss 5%

# repetir la transferencia normal (sin --lento)
vcmd -c /tmp/pycore.*/n33 -- python3 $SRC/tcp_recv.py 8000 /tmp/file-out
vcmd -c /tmp/pycore.*/n34 -- python3 $SRC/tcp_send.py 16.0.5.130 8000 /tmp/file-in

# al terminar, sacar la pérdida
vcmd -c /tmp/pycore.*/n34 -- tc qdisc del dev eth0 root
```

**Qué tiene que verse:**

- `[TCP Retransmission]` y `[TCP Fast Retransmission]`
- `[TCP Dup ACK]` — los ACK duplicados que disparan el Fast Retransmit
- `[TCP Out-Of-Order]`
- El archivo **igual llega completo e idéntico**: TCP se recupera solo.

**Filtro:** `tcp.analysis.flags`
**Gráfico:** *Statistics → TCP Stream Graphs → Time Sequence (Stevens)* — se ven
los escalones planos donde la ventana de congestión se derrumba.

**Respuesta del inciso:** se activa el **control de congestión**, no el de flujo.

| | Control de FLUJO | Control de CONGESTIÓN |
|---|---|---|
| Protege a | el **receptor** (su buffer) | la **red** |
| Variable | `rwnd` | `cwnd` |
| Se entera | el receptor **lo avisa** en el campo Window | el emisor lo **deduce** de las pérdidas |
| Se dispara con | app que no lee | timeout o 3 ACK duplicados |

La ventana efectiva es `min(cwnd, rwnd)`: en 27.g manda `rwnd`, en 27.h manda `cwnd`.

---

## Checklist de capturas de la parte B

- [ ] `Ejercicio27a_foto1_transferencia.png`
- [ ] `Ejercicio27a_foto2_wireshark.png`
- [ ] `Ejercicio27b_foto1_nc_servidor.png`
- [ ] `Ejercicio27b_foto2_nc_cliente.png`
- [ ] `Ejercicio27g_foto1_zerowindow.png`
- [ ] `Ejercicio27g_foto2_ventana.png`
- [ ] `Ejercicio27h_foto1_retransmisiones.png`
- [ ] `Ejercicio27h_foto2_stevens.png`
