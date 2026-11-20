#!/usr/bin/env python3
"""
TP3 - punto 26.a  |  Cliente UDP: envia un archivo.
Uso:  python3 udp_send.py <ip_destino> <puerto> <archivo>
Ej:   python3 udp_send.py 16.0.5.130 8000 /tmp/file-in

Nota: UDP no tiene cierre de conexion, asi que el fin de archivo
      se senaliza a nivel aplicacion con un datagrama vacio.
"""
import socket, sys

if len(sys.argv) != 4:
    sys.exit("uso: udp_send.py <ip> <puerto> <archivo>")

ip, puerto, ruta = sys.argv[1], int(sys.argv[2]), sys.argv[3]
MTU = 1024

s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
enviados = 0
with open(ruta, "rb") as f:
    while (bloque := f.read(MTU)):
        s.sendto(bloque, (ip, puerto))
        enviados += len(bloque)
s.sendto(b"", (ip, puerto))          # EOF
s.close()
print(f"enviados {enviados} bytes a {ip}:{puerto}")
