# Redes de Datos II

Matías Lopez · Juan David Alvarez · Lautaro Nahuel Lopes

| Trabajo | Estado |
|---|---|
| [`tp2/`](tp2/) | en curso |

## Setup

```bash
git clone https://github.com/MatiasLopezING/redes2.git
```

Montar **esa carpeta** en la VM para que CORE la vea:

1. VirtualBox → la VM (apagada) → *Configuración* → *Carpetas compartidas* → agregar la
   carpeta, nombre **`tpi`**, automontar ✅, solo lectura ❌
2. En la VM: `sudo usermod -aG vboxsf $USER` y reiniciar
3. Queda en `/media/sf_tpi`

Se edita y se hace git desde Windows; CORE corre en la VM.
La `.ova` no va al repo, cada uno la tiene local.

## Git

Todo en `main`, sin ramas.

```bash
git pull --rebase
git add -A && git commit -m "tp2: ..."
git pull --rebase && git push
```

- `git pull --rebase` **antes de tocar nada**
- **El `.imn` lo toca uno a la vez** y avisa por el grupo
- Las configs van en scripts, no clickeadas en la GUI
