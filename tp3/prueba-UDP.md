# Inciso A

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

**Capturas:**

`Figura 1. Archivo de prueba generado en el nodo n34 y cálculo de su hash SHA-256.`
`Figura 2. Envío del archivo desde n34 y recepción de los datagramas UDP en n33.`
`Figura 3. Verificación del contenido y de la integridad del archivo recibido mediante SHA-256.`
