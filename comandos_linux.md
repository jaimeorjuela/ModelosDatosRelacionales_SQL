# Resumen de Comandos CLI de Linux más Usados

Esta guía contiene una selección de los comandos de terminal más utilizados en Linux, organizados por categorías y con ejemplos prácticos de su sintaxis.

---

## 📂 Navegación y Gestión de Archivos

| Comando | Descripción | Ejemplo de Sintaxis |
| :--- | :--- | :--- |
| **`pwd`** | Muestra la ruta absoluta del directorio actual. | `pwd` |
| **`ls`** | Lista el contenido de un directorio. | `ls -la /var/log` *(Muestra detalles y archivos ocultos)* |
| **`cd`** | Cambia de directorio. | `cd /home/usuario/Documentos` |
| **`mkdir`** | Crea una nueva carpeta o directorio. | `mkdir nuevos_proyectos` |
| **`touch`** | Crea un archivo vacío o actualiza su fecha. | `touch notas.txt` |
| **`cp`** | Copia archivos o directorios. | `cp -r carpeta_origen/ carpeta_destino/` |
| **`mv`** | Mueve o renombra archivos y carpetas. | `mv archivo.txt nuevo_nombre.txt` |
| **`rm`** | Elimina archivos o directorios. | `rm -rf carpeta_vieja/` *(Borrado recursivo y forzado)* |

---

## 📄 Visualización y Edición de Texto

| Comando | Descripción | Ejemplo de Sintaxis |
| :--- | :--- | :--- |
| **`cat`** | Muestra todo el contenido de un archivo en pantalla. | `cat configuracion.conf` |
| **`head`** | Muestra las primeras 10 líneas de un archivo. | `head -n 5 script.sh` *(Muestra las primeras 5 líneas)* |
| **`tail`** | Muestra las últimas 10 líneas de un archivo. | `tail -f acceso.log` *(Sigue los cambios en tiempo real)* |
| **`grep`** | Busca texto específico dentro de archivos. | `grep "ERROR" sistema.log` |
| **`nano`** | Editor de texto simple integrado en la terminal. | `nano tareas.txt` |
| **`vim`** | Editor de texto avanzado y altamente configurable. | `vim codigo.py` |

---

## 🛡️ Permisos y Sistema

| Comando | Descripción | Ejemplo de Sintaxis |
| :--- | :--- | :--- |
| **`sudo`** | Ejecuta un comando con privilegios de superusuario. | `sudo apt update` |
| **`chmod`** | Cambia los permisos de acceso de un archivo/carpeta. | `chmod +x script.sh` *(Otorga permisos de ejecución)* |
| **`chown`** | Cambia el propietario y/o grupo de un archivo. | `chown usuario:grupo archivo.txt` |

---

## 💻 Monitoreo de Procesos y Recursos

| Comando | Descripción | Ejemplo de Sintaxis |
| :--- | :--- | :--- |
| **`top`** | Muestra los procesos activos y uso de recursos. | `top` |
| **`htop`** | Versión interactiva y visual de `top` (más intuitiva). | `htop` |
| **`ps`** | Lista los procesos que se están ejecutando. | `ps aux` *(Muestra todos los procesos del sistema)* |
| **`kill`** | Detiene o fuerza el cierre de un proceso por su ID. | `kill -9 1234` *(Fuerza el cierre del proceso 1234)* |
| **`df`** | Muestra el espacio libre y usado en los discos. | `df -h` *(Formato legible en GB/MB)* |

---

## 🌐 Redes y Descargas

| Comando | Descripción | Ejemplo de Sintaxis |
| :--- | :--- | :--- |
| **`ping`** | Verifica la conectividad con un host remoto. | `ping google.com` |
| **`curl`** | Herramienta para transferir datos desde o hacia un servidor. | `curl -I https://example.com` *(Descarga cabeceras HTTP)* |
| **`wget`** | Descarga archivos directamente desde internet. | `wget https://sitio.com/archivo.zip` |

---

## ⚙️ Comandos de Utilidad Diaria

| Comando | Descripción | Ejemplo de Sintaxis |
| :--- | :--- | :--- |
| **`clear`** | Limpia la pantalla de la terminal. | `clear` *(O el atajo Ctrl + L)* |
| **`history`**| Muestra el historial de comandos ejecutados. | `history` |
| **`man`** | Abre el manual de usuario de cualquier comando. | `man grep` |
