#!/bin/bash

# Verificación de los parámetros de entrada
if [ $# -lt 2 ]; then
    echo "Uso: $0 archivo comando_herramienta [-t threads]"
    exit 1
fi

# Parseo de los parámetros de entrada
archivo="$1"
comando_herramienta="$2"
tool=$(echo "$comando_herramienta" | awk '{print $1}')
threads=1

while getopts ":t:" opt; do
  case $opt in
    t)
      threads=$OPTARG
      ;;
    \?)
      echo "Opción inválida: -$OPTARG" >&2
      exit 1
      ;;
  esac
done

# Verifica si el archivo existe
if [ ! -f "$archivo" ]; then
    echo "El archivo $archivo no existe."
    exit 1
fi

# Función para procesar una línea
function procesar_linea {
    local linea="$1"
    # Eliminar "http://" o "https://" del inicio del nombre de la línea
    local nombre_archivo=$(echo "$linea" | sed -e 's,^\(http://\|https://\),,')
    nombre_archivo="${nombre_archivo}_${tool}.txt"
    # Ejecutar el comando de la herramienta con la línea actual como argumento y redirigir la salida al archivo
    $comando_herramienta "$linea" > "$nombre_archivo" 2>&1
}

# Leer el archivo y procesar cada línea secuencialmente
while IFS= read -r linea || [[ -n "$linea" ]]; do
    # Ejecutar la línea
    procesar_linea "$linea"
    # Esperar a que termine antes de pasar a la siguiente línea
    sleep 1
done < "$archivo"

# Salir del script
exit 0
