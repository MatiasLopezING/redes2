#!/usr/bin/env python3
"""
TP3 - punto 27.a  |  Cliente TCP: envia un archivo.
Uso:  python3 tcp_send.py <ip_destino> <puerto> <archivo>
Ej:   python3 tcp_send.py 16.0.5.130 8000 /tmp/file-in

El shutdown(SHUT_WR) manda el FIN y deja la conexion en medio cierre:
es lo que permite interoperar con `nc -N` (punto 27.b) y lo que se usa
para mostrar los estados FIN_WAIT2 / CLOSE_WAIT del punto 27.e.
"""
import socket, sys

if len(sys.argv) != 4:
    sys.exit("uso: tcp_send.py <ip> <puerto> <archivo>")

ip, puerto, ruta = sys.argv[1], int(sys.argv[2]), sys.argv[3]

s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
s.connect((ip, puerto))

enviados = 0
with open(ruta, "rb") as f:
    while (bloque := f.read(4096)):
        s.sendall(bloque)
        enviados += len(bloque)

s.shutdown(socket.SHUT_WR)           # FIN -> cierre activo de este lado
s.close()
print(f"enviados {enviados} bytes a {ip}:{puerto}")
