# Inciso A - Envio/Recepcion mediante API socket UDP

## Preparación

En CORE, abrir una terminal en cada nodo:
- n33: servidor/receptor.
- n34: cliente/emisor.

En n34, preparar el archivo de prueba:

```bash
echo "Prueba UDP de n34 a n33" > /tmp/file-in
cat /tmp/file-in
sha256sum /tmp/file-in
```

## Ejecutar el servidor en n33

En la terminal de n33, ejecutar el script receptor udp_recv.py:

```bash
python3 /tmp/udp_recv.py 8000 /tmp/file-out
```

Dejar esa terminal abierta. Debe aparecer un mensaje similar a:
`escuchando UDP en el puerto 8000...`

## Enviar el archivo desde n34

En la terminal de n34:

```bash
python3 /home/redes/redes2/tp3/src/udp_send.py 16.0.5.130 8000 /tmp/file-in

Resultado esperado:
enviados 24 bytes a 16.0.5.130:8000
```

## Comprobar la recepción en n33

En la terminal de n33, el servidor debe informar algo similar a:
recibidos 24 bytes de 16.0.0.10 -> /tmp/file-out


Luego, en n33:
```bash
cat /tmp/file-out
sha256sum /tmp/file-out
```

El contenido debe ser:
`Prueba UDP de n34 a n33`
Y el hash debe coincidir con el calculado en n34

# Inciso B - Envio y Recepcion con herramienta netcat

# Envio con Netcat

## Preparar el archivo en n34
```bash
echo "Prueba UDP de n34 a n33" > /tmp/file-in
cat /tmp/file-in
sha256sum /tmp/file-in
```
Anotar el hash original para compararlo luego.

## Ejecutar el receptor Python en n33
```bash
python3 /home/redes/redes2/tp3/src/udp_recv.py 8000 /tmp/file-out
```
Dejarlo escuchando.

## Enviar con netcat desde n34
```bash
cat /tmp/file-in | nc -u 16.0.5.130 8000
```
- `cat /tmp/file-in`: lee el archivo.
- `|`: conecta la salida de cat con la entrada de netcat.
- `nc -u`: transmite los datos mediante UDP.

La terminal puede quedar esperando. Esto no significa necesariamente que los datos no se hayan enviado.
Presionar `Ctrl + C` en la terminal de n34 y, si el servidor continúa esperando, también en n33.

## Verificar el archivo en n33
```bash
cat /tmp/file-out
sha256sum /tmp/file-out
```

El hash debe coincidir con el del archivo original

# Recepción con Netcat

## Ejecutar recepción con netcat en n33

En el nodo n33:
```bash
nc -u -l 8000 > /tmp/file-out
```

- `nc -u`: recibe los datos mediante UDP.
- `-l`: modo escucha, es decir, espera recibir datos.
- `> /tmp/file-out`: guarda lo recibido en ese archivo.


## Envío con Python desde n34

```bash
python3 /home/redes/redes2/tp3/src/udp_send.py 16.0.5.130 8000 /tmp/file-in
```

Como UDP no tiene un mecanismo propio de cierre de conexión ni de fin de archivo, netcat puede permanecer esperando nuevos datagramas.
Cuando se haya comprobado la transmision los datos, interrumpí el proceso de netcat en n33 con: `Ctrl + C`.


## Verificar el archivo recibido

En n33:
```bash
cat /tmp/file-out
sha256sum /tmp/file-out
```

Comparar el hash con el archivo original de n34:
```bash
sha256sum /tmp/file-in
```

Si ambos hashes coinciden, el contenido recibido es idéntico al original.