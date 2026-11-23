#!/usr/bin/env python3
"""
TP3 - punto 27.a  |  Servidor TCP: recibe un archivo.
Uso:  python3 tcp_recv.py <puerto> <archivo_salida> [--lento]
Ej:   python3 tcp_recv.py 8000 /tmp/file-out
      python3 tcp_recv.py 8000 /tmp/file-out --lento   (punto 27.g)

--lento: buffer de recepcion chico + lectura demorada (~10 KB/s).
         Fuerza que la
         aplicacion no consuma, la ventana anunciada caiga y se active
         el CONTROL DE FLUJO (se ve como TCP ZeroWindow en Wireshark).
"""
import socket, sys, time

if len(sys.argv) < 3:
    sys.exit("uso: tcp_recv.py <puerto> <archivo_salida> [--lento]")

puerto, salida = int(sys.argv[1]), sys.argv[2]
lento = "--lento" in sys.argv

s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
s.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
if lento:
    s.setsockopt(socket.SOL_SOCKET, socket.SO_RCVBUF, 2048)
s.bind(("", puerto))
s.listen(1)
print(f"escuchando TCP en el puerto {puerto}{' (modo lento)' if lento else ''}...")

c, origen = s.accept()
recibidos = 0
with open(salida, "wb") as f:
    while True:
        bloque = c.recv(1024 if lento else 4096)
        if not bloque:               # recv() vacio = llego el FIN
            break
        f.write(bloque)
        recibidos += len(bloque)
        if lento:
            time.sleep(0.1)      # ~10 KB/s: suficiente para que la ventana se cierre
c.close(); s.close()
print(f"recibidos {recibidos} bytes de {origen[0]} -> {salida}")
