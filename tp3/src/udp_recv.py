#!/usr/bin/env python3
"""
TP3 - punto 26.a  |  Servidor UDP: recibe un archivo.
Uso:  python3 udp_recv.py <puerto> <archivo_salida>
Ej:   python3 udp_recv.py 8000 /tmp/file-out
"""
import socket, sys

if len(sys.argv) != 3:
    sys.exit("uso: udp_recv.py <puerto> <archivo_salida>")

puerto, salida = int(sys.argv[1]), sys.argv[2]

s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
s.bind(("", puerto))
print(f"escuchando UDP en el puerto {puerto}...")

recibidos = 0
with open(salida, "wb") as f:
    while True:
        datos, origen = s.recvfrom(2048)
        if not datos:                # datagrama vacio = EOF
            break
        f.write(datos)
        recibidos += len(datos)
s.close()
print(f"recibidos {recibidos} bytes de {origen[0]} -> {salida}")
