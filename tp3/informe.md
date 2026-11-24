# TP3 — Capa de Transporte

**Redes de Datos II — Ing. en Computación — UNLP**

| Integrante | Legajo |
|---|---|
| Matías Lopez | 02670/0 |
| Juan David Alvarez | 03100/2 |
| Lautaro Nahuel Lopes | 02978/9 |

---

## Entorno

Se trabaja sobre la **misma topología del TP2** (Figura 8 del enunciado):
spine1, spine2, leaf1–4 y los hosts n33, n34 y n35.

```bash
# 1. Abrir ../tp2/topologia.imn en CORE y presionar Start
# 2. Configurar los 25 nodos:
sudo bash ../tp2/configs/levantar.sh
```

Direccionamiento: ver `../tp2/direccionamiento.md`.
Programas utilizados: ver `src/README.md`.

---

# Punto 26 — UDP

## 26.a — Programas de envío y recepción

Descripción de los programas
Para realizar la transferencia de archivos mediante UDP se desarrollaron dos programas en Python: un cliente emisor (udp_send.py) y un servidor receptor (udp_recv.py).

**Programa emisor — udp_send.py**
El programa emisor recibe como argumentos la dirección IP del nodo destino, el puerto UDP y la ruta del archivo que se desea transmitir.
Inicialmente, abre el archivo en modo lectura binaria. Luego, lee su contenido en bloques de hasta 1024 bytes y envía cada bloque mediante la función `sendto()` de un socket UDP IPv4.
Al finalizar la lectura del archivo, el cliente envía un datagrama vacío para indicar que no quedan más datos por transmitir.

**Programa receptor — udp_recv.py**
El programa receptor recibe como argumentos el puerto UDP en el que debe escuchar y la ruta del archivo de salida.
Crea un socket UDP IPv4 y lo asocia al puerto especificado mediante `bind()`. Una vez iniciado, permanece esperando datagramas utilizando `recvfrom()`.
Cada datagrama recibido se escribe en el archivo de salida. Cuando recibe un datagrama vacío, interpreta que la transferencia ha finalizado, cierra el archivo y termina la recepción.

**Criterio de fin de archivo**

UDP no proporciona un mecanismo propio para indicar el fin de una transferencia de archivo. Por este motivo, se implementó un criterio de finalización a nivel de aplicación.
El cliente envía un datagrama de longitud cero cuando termina de leer el archivo. El servidor identifica este datagrama porque su contenido es una cadena de bytes vacía (b'') y lo interpreta como una señal de fin de archivo.
De esta manera, el receptor puede distinguir entre los datagramas que contienen datos y el datagrama especial que indica la finalización de la transferencia.
Este mecanismo permite delimitar el archivo recibido, aunque no incorpora por sí mismo mecanismos de confirmación, retransmisión o control de pérdida de datagramas.

![](capturas/)

## 26.b — Interacción con netcat

> _Mostrar las dos direcciones: nuestro cliente contra `nc -u -l`, y `nc -u` contra nuestro servidor._

![](capturas/)

## 26.c — Envío sin servidor corriendo, estados y pérdida

> _Qué notifica el stack (ICMP Port Unreachable 3/3). Comparar `ss -u -a` con y sin netcat.
> Qué pasa al agregar pérdida a un enlace._

![](capturas/)

## 26.d — Captura: formato del datagrama UDP

> _Los 4 campos del encabezado UDP y su encapsulación en IP._

![](capturas/)

---

# Punto 27 — TCP

## 27.a — Programas de envío y recepción

Se programaron dos aplicaciones en **Python 3** sobre la API de sockets
(`socket.AF_INET`, `socket.SOCK_STREAM`), sin dependencias externas:
`src/tcp_send.py` (cliente, corre en **n34**) y `src/tcp_recv.py`
(servidor, corre en **n33**).

**Emisor** — `connect()` al par `(IP, puerto)`, lee el archivo en bloques de
4096 B y los entrega con `sendall()`, que garantiza que se escriban todos los
bytes. Al terminar llama a **`shutdown(SHUT_WR)`**: envía el **FIN** y deja la
conexión en *medio cierre*, con este extremo ya sin transmitir pero todavía
capaz de recibir.

**Receptor** — `bind()` + `listen()` + `accept()`, y lee con `recv()` hasta que
devuelve una secuencia vacía. **Ese `recv()` vacío es la señal del FIN**: no hace
falta ningún marcador de fin de archivo a nivel aplicación, porque TCP es un
flujo con cierre explícito. (Contrasta con UDP, donde sí hubo que inventarlo:
ver punto 26.a.)

Se usa `SO_REUSEADDR` para poder relanzar el servidor sin esperar el `TIME_WAIT`
de la conexión anterior.

**Verificación:** se transfirió un archivo de 200 KB de n34 a n33 y se comparó
con `md5sum` en ambos extremos.

![](capturas/)

## 27.a.bis — Observaciones sobre la captura

En Wireshark se distinguen las tres fases de la sesión:

| Fase | Segmentos | Flags |
|---|---|---|
| Establecimiento | 3 | `SYN` · `SYN,ACK` · `ACK` |
| Transferencia | N | `PSH,ACK` del emisor · `ACK` del receptor |
| Cierre | 3 o 4 | `FIN,ACK` · (`ACK`) · `FIN,ACK` · `ACK` |

El cierre se ve en **3 segmentos** cuando el receptor, que no tiene más datos
que enviar, combina su `ACK` con su propio `FIN` en el mismo segmento. Son
igualmente **4 acciones**: TCP es full-duplex y cada sentido se cierra por
separado.

## 27.b — Interacción con netcat

Se verificó la interoperabilidad **en las dos direcciones**:

| Emisor | Receptor | Comando del receptor |
|---|---|---|
| `tcp_send.py` (n34) | **netcat** (n33) | `nc -N -l 8000 > /tmp/file-nc` |
| **netcat** (n34) | `tcp_recv.py` (n33) | `cat /tmp/file-in \| nc -N 16.0.5.130 8000` |

En los dos casos el archivo llegó íntegro (`md5sum` coincidente).

**Por qué interoperan:** ninguno de los dos programas define un protocolo de
aplicación propio — los dos escriben y leen un **flujo de bytes TCP puro**, así
que son intercambiables. El único detalle que hay que respetar es **quién cierra
y cuándo**: `tcp_send.py` llama a `shutdown(SHUT_WR)` y `nc -N` cierra la mitad
de escritura al terminar su entrada. Ambos producen el mismo **FIN**, que es lo
que hace que el receptor sepa que el archivo terminó. Sin ese FIN el receptor
quedaría bloqueado en `recv()` indefinidamente.

![](capturas/)

## 27.c — Servicios extra en n34 (echo, discard)

> _Cómo se levantaron y verificación con `ss -tulnp`._

![](capturas/)

## 27.d — Conexión desde n33 a discard y echo

> _Cantidad de segmentos, flags y opciones del encabezado TCP
> (MSS, SACK permitted, Window Scale, Timestamps)._

![](capturas/)

## 27.e — Estados: SYN_SENT, TIME_WAIT, FIN_WAIT2

> _En qué estado queda el que hace el cierre activo. Con cuántos segmentos
> se cerró la conexión. Otras variantes de cierre. Valor del 2MSL._

![](capturas/)

## 27.f — Conexión a un puerto sin proceso escuchando

> _Flags de la respuesta (RST, ACK)._

![](capturas/)

## 27.g — Activación del control de flujo

Para forzar el control de flujo se corrió el receptor en modo `--lento`, que
combina dos cosas: un buffer de recepción reducido
(`setsockopt(SO_RCVBUF, 2048)`, que el kernel redondea a **4096 B**) y una
demora entre lecturas, dejando un consumo efectivo de **~10 KB/s**. El emisor,
en cambio, transmite a la velocidad del enlace.

**Secuencia observada en la captura:**

1. Los ACK de n33 anuncian una ventana **decreciente**: `Win=4096 → 3072 → 2048 → 1024`.
2. Aparece **`[TCP ZeroWindow]`**: n33 anuncia `Win=0`, su buffer está lleno.
3. n34 **detiene la transmisión** y envía **`[TCP ZeroWindowProbe]`**: segmentos
   de 1 byte que preguntan periódicamente si se liberó espacio. Existen para
   evitar un *deadlock*: si el emisor esperara pasivamente y el ACK que reabre
   la ventana se perdiera, la conexión quedaría trabada para siempre.
4. Cuando la aplicación lee, n33 envía **`[TCP Window Update]`** con `Win>0` y
   la transferencia se reanuda.
5. El ciclo se repite durante toda la transferencia.

**Medición:** con la ventana del receptor en 4096 B, el ritmo efectivo quedó
fijado en **10,0 KB/s** — exactamente la velocidad a la que la aplicación
consume. El emisor no manda más rápido aunque pueda.

**Observación:** el control de flujo frena al **TCP** del emisor, no
inmediatamente a la aplicación. Mientras haya lugar en el buffer de envío del
socket (`SO_SNDBUF`, del orden de los MB), `sendall()` retorna enseguida y los
bytes quedan encolados en el kernel. Recién cuando ese buffer se llena la
aplicación se bloquea: en una prueba con 3 MB, `sendall()` quedó bloqueado
**61,8 s** tras haber colocado ~2,1 MB.

![](capturas/)

## 27.h — Pérdida en un enlace

Se agregó **5 % de pérdida** a un enlace del camino n34→n33 (en CORE: botón
derecho sobre el enlace → *Configure* → *loss*; equivale a
`tc qdisc add dev ethX root netem loss 5%`) y se repitió la transferencia con
el receptor en modo normal.

**Qué se activa: el CONTROL DE CONGESTIÓN**, no el de flujo.

El receptor consume a toda velocidad, así que su ventana (`rwnd`) nunca se
achica. Lo que cambia es que se pierden segmentos, y el emisor lo detecta de
dos maneras:

| Evento | Cómo lo detecta | Reacción |
|---|---|---|
| **3 ACK duplicados** | el receptor repite el mismo ACK | **Fast Retransmit** + Fast Recovery: `ssthresh = cwnd/2`, `cwnd = ssthresh` |
| **Timeout (RTO)** | no llega ningún ACK | `ssthresh = cwnd/2`, **`cwnd = 1`** y vuelve a Slow Start |

**En la captura se observan:** `[TCP Retransmission]`,
`[TCP Fast Retransmission]`, `[TCP Dup ACK]` y `[TCP Out-Of-Order]`.
El gráfico *Time Sequence (Stevens)* muestra los tramos planos donde la ventana
de congestión se derrumba y vuelve a crecer.

**El archivo llega íntegro igual:** TCP se recupera solo retransmitiendo desde
el primer byte no reconocido. La pérdida se paga en **tiempo**, no en datos.

### Resumen: los dos controles

| | Control de **FLUJO** (27.g) | Control de **CONGESTIÓN** (27.h) |
|---|---|---|
| Protege a | el **receptor** (su buffer) | la **red** (routers y enlaces) |
| Variable | `rwnd` | `cwnd` |
| Quién la fija | el receptor, **explícitamente** en el campo Window | el emisor, **por inferencia** |
| Se dispara con | una aplicación que no lee | pérdidas: timeout o 3 ACK duplicados |
| Alcance | extremo a extremo, 2 equipos | toda la red, muchos flujos |

El emisor transmite como máximo **`min(cwnd, rwnd)`** bytes sin confirmar: en
27.g el que limita es `rwnd`, en 27.h es `cwnd`.

![](capturas/)

---

# Conclusiones

> _A completar._
