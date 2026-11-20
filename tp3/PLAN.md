# TP3 — Capa de Transporte · Plan de trabajo

Grupo: Matías Lopez (02670/0) · Juan David Alvarez (03100/2) · Lautaro Nahuel Lopes (02978/9)

---

## 1. Qué se entrega

De los 27 puntos de la práctica, **solo se entregan el 26 y el 27**.
Los puntos 1 a 25 son teoría y ejercicios de papel: se estudian, no se entregan.

| Punto | Tema | Incisos |
|---|---|---|
| **26** | UDP | a, b, c, d |
| **27** | TCP | a, b, c, d, e, f, g, h |

---

## 2. La topología es la MISMA del TP2

La **Figura 8** del enunciado es exactamente la topología que ya tenemos
funcionando: `spine1`, `spine2`, `leaf1–4`, `n33`, `n34`, `n35`, Net5 y Net6.

**No hay que armar red nueva.** Se reusa tal cual:

```
../tp2/topologia.imn              →  abrir en CORE, Start
../tp2/configs/levantar.sh        →  sudo bash levantar.sh   (25 nodos)
../tp2/direccionamiento.md        →  las IP de cada nodo
```

Dirección de trabajo que pide el enunciado: **n34 (emisor) → n33 (receptor)**.

---

## 3. División de tareas

Armada para que **nadie espere a nadie**: los tres arrancan el minuto cero.
A y B pueden probar todo en su propia máquina con `127.0.0.1` antes de tocar CORE.

### Persona A — UDP
- [ ] **26.a** — `src/udp_send.py` y `src/udp_recv.py` (ya están escritos, probarlos)
- [ ] **26.b** — interoperar con netcat en las dos direcciones:
      - `nc -u -l 8000 > /tmp/file-out`  ← contra nuestro `udp_send.py`
      - `cat /tmp/file-in | nc -u <IP> 8000` → contra nuestro `udp_recv.py`
- [ ] **26.c** — enviar datos **antes** de levantar el servidor; ver cómo lo notifica
      el stack (ICMP Port Unreachable 3/3). Comparar estados con `ss -u -a`.
      Agregar pérdida a un enlace y ver qué pasa (spoiler: UDP no reacciona).
- [ ] **26.d** — capturar con Wireshark y mostrar el **formato del datagrama UDP**
      (4 campos: puerto origen, destino, longitud, checksum) y su encapsulación en IP.

### Persona B — TCP
- [ ] **27.a** — `src/tcp_send.py` y `src/tcp_recv.py` (ya están escritos, probarlos)
- [ ] **27.b** — interoperar con netcat:
      - `nc -N -l 8000 > /tmp/file-out`  ← contra nuestro `tcp_send.py`
      - `cat /tmp/file-in | nc -N <IP> 8000` → contra nuestro `tcp_recv.py`
      - (el `-N` cierra al terminar; nuestro `shutdown(SHUT_WR)` hace lo mismo)
- [ ] **27.g** — **control de flujo**: correr el receptor con `--lento`
      y capturar los `TCP ZeroWindow` / `Window Update`.
- [ ] **27.h** — agregar **pérdida** a un enlace (en CORE: botón derecho sobre el
      enlace → Configure → loss %). Capturar retransmisiones.
      Responder: se activa el **control de congestión** (no el de flujo).

### Persona C — Servicios y estados TCP
*(Es quien necesita la topología desde el inicio — ya la tenemos andando.)*
- [ ] **27.c** — en **n34** levantar servicios extra (`echo`, `discard`) con `inetd`.
      Si CORE no trae `inetd`, se simulan con dos scripts Python de 5 líneas.
      Verificar con `ss -tulnp`.
- [ ] **27.d** — desde **n33** conectarse a `discard` (puerto 9) y a `echo` (puerto 7),
      enviar datos y capturar. Analizar: cantidad de segmentos, flags, y las
      **opciones del encabezado TCP** (MSS, SACK permitted, Window Scale, Timestamps).
- [ ] **27.e** — generar y capturar los estados **SYN_SENT**, **TIME_WAIT**, **FIN_WAIT2**.
      Responder: el cierre activo queda en `TIME_WAIT`; la conexión se cierra en
      **3 o 4 segmentos** según si el otro extremo junta su ACK con su FIN;
      medir el **2MSL** con `cat /proc/sys/net/ipv4/tcp_fin_timeout`.
- [ ] **27.f** — conectar a un **puerto sin proceso escuchando** → TCP responde con
      un segmento **RST, ACK**. Capturarlo.

### Los tres, al final
- [ ] Juntarse una vez, levantar la topología y sacar las **capturas definitivas**.
- [ ] Escribir un único `informe.md` con las capturas embebidas.

---

## 4. Checklist de entrega

- [ ] `src/` con los 4 programas
- [ ] `capturas/` con los PNG numerados por inciso (`Ejercicio26a_foto1.png`, etc.)
- [ ] `informe.md` con todos los incisos respondidos, sin "no realizado"
- [ ] Verificar que todas las figuras del informe resuelven
- [ ] Carpeta `Entrega/` con: informe (md y pdf), programas, capturas y el `.imn`

---

## 5. Convención de nombres de capturas

Igual que en el TP2, que funcionó bien:

```
Ejercicio26a_foto1_n34.png
Ejercicio27d_foto2_discard.png
```

Siempre: `Ejercicio<punto><inciso>_foto<N>_<qué muestra>.png`
