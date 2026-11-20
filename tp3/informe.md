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

> _Describir los dos programas, la elección del lenguaje y el criterio de fin de archivo._

Código: `src/udp_send.py` y `src/udp_recv.py`.

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

> _Describir los programas y el uso de `shutdown(SHUT_WR)`._

Código: `src/tcp_send.py` y `src/tcp_recv.py`.

![](capturas/)

## 27.b — Interacción con netcat

> _`nc -N` en las dos direcciones._

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

> _Receptor en modo `--lento`. Capturar `TCP ZeroWindow` y `Window Update`._

![](capturas/)

## 27.h — Pérdida en un enlace

> _Qué control de TCP se activa y por qué (congestión, no flujo)._

![](capturas/)

---

# Conclusiones

> _A completar._
