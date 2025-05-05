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

    echo "Copiando configuración de $src a $dest"
    mkdir -p "$dest"
    cp -r "$src/"* "$dest/"
  done
}
