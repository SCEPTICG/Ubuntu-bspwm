#!/bin/bash

# Verifica si un paquete está instalado
is_installed() {
  dpkg -s "$1" &>/dev/null
}

# Instala todos los paquetes que no estén presentes
install_missing_packages() {
  local missing=()

  for pkg in "$@"; do
    if ! is_installed "$pkg"; then
      missing+=("$pkg")
    else
      echo "[OK] $pkg ya está instalado"
    fi
  done

  if [ "${#missing[@]}" -gt 0 ]; then
    echo "Instalando paquetes faltantes: ${missing[*]}"
    sudo apt-get update
    sudo apt-get install -y "${missing[@]}"
  else
    echo "Todos los paquetes ya están instalados."
  fi
}

# Copia carpetas de configuración desde el repo a ~/.config
copy_config_folders() {
  for dir in "$@"; do
    src="$dir"
    dest="$HOME/.config/$dir"

    # Verificar si el directorio de destino existe, si no, crear
    if [ ! -d "$dest" ]; then
      echo "Creando directorio $dest"
      mkdir -p "$dest"
    fi

    echo "Copiando configuración de $src a $dest"
    cp -r "$src/"* "$dest/"
  done
}

# Verificar si un directorio existe, si no, crearlo
create_dir_if_not_exists() {
  dir="$1"
  if [ ! -d "$dir" ]; then
    echo "Creando directorio $dir"
    mkdir -p "$dir"
  fi
}
