# Guía Rápida de Comandos CLI de Linux

Un resumen estructurado de los comandos de la interfaz de línea de comandos (CLI) de Linux más utilizados, organizados por su función principal.

## 📂 Navegación y Gestión de Archivos
* **`pwd`**: Muestra la **ruta absoluta del directorio actual** en el que estás posicionado.
* **`ls`**: Lista el **contenido de un directorio**. Se suele usar como `ls -la` para ver archivos ocultos y detalles de permisos.
* **`cd`**: Cambia de **directorio** (ej. `cd Documentos`). Escribir solo `cd` te devuelve a tu carpeta de usuario (*home*).
* **`mkdir`**: Crea una **nueva carpeta** o directorio.
* **`touch`**: Crea un **archivo vacío** o actualiza su fecha de modificación.
* **`cp`**: Copia **archivos o directorios**. Usa `cp -r` para duplicar carpetas completas.
* **`mv`**: Mueve o **renombra archivos y carpetas**.
* **`rm`**: Elimina **archivos**. Para borrar carpetas con todo su contenido de forma definitiva, se usa `rm -rf`.

## 📄 Visualización y Edición de Texto
* **`cat`**: Muestra todo el **contenido de un archivo** directamente en la pantalla.
* **`head` / `tail`**: Muestran las **primeras o últimas 10 líneas** de un archivo, respectivamente. Muy útil para revisar registros (*logs*).
* **`grep`**: Busca **texto específico dentro de uno o varios archivos** (ej. `grep "error" sistema.log`).
* **`nano` / `vim`**: Editores de **texto directamente en la terminal**. `nano` es el más sencillo para principiantes.

## 🛡️ Permisos y Sistema
* **`sudo`**: Ejecuta un comando con **privilegios de superusuario (root)**.
* **`chmod`**: Cambia los **permisos de lectura, escritura y ejecución** de un archivo o carpeta.
* **`chown`**: Cambia el **propietario o grupo** de un archivo.

## 💻 Monitoreo de Procesos y Recursos
* **`top` / `htop`**: Muestran en tiempo real el **uso de CPU, memoria y los procesos activos**. (`htop` es una versión gráfica mucho más amigable).
* **`ps`**: Lista los **procesos que se están ejecutando** en el momento.
* **`kill`**: Detiene o **fuerza el cierre de un proceso** usando su ID.
* **`df -h`**: Muestra el **espacio libre y usado en los discos** en un formato fácil de leer (Gigabytes/Megabytes).

## 🌐 Redes y Descargas
* **`ping`**: Verifica la **conectividad con un servidor** o dirección IP.
* **`curl` / `wget`**: Herramientas para **descargar archivos o interactuar con APIs** desde internet.

## ⚙️ Comandos de Utilidad Diaria
* **`clear`**: Limpia la **pantalla de la terminal** (también puedes usar el atajo `Ctrl + L`).
* **`history`**: Muestra el **historial de los comandos** que has escrito antes.
* **`man`**: Abre el **manual de cualquier comando** para ver cómo se usa y qué opciones tiene (ej. `man ls`).
