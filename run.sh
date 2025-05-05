#!/bin/bash

#Logo
print_logo(){
    cat << "EOF"
    
 .----------------.  .----------------.  .----------------.  .----------------.  .----------------.  .----------------.  .----------------.  .----------------.  .----------------.  .----------------. 
| .--------------. || .--------------. || .--------------. || .--------------. || .--------------. || .--------------. || .--------------. || .--------------. || .--------------. || .--------------. |
| |    _______   | || |     ______   | || |  _________   | || |   ______     | || |  _________   | || |     _____    | || |     ______   | || |    ______    | || |     ____     | || |    _______   | |
| |   /  ___  |  | || |   .' ___  |  | || | |_   ___  |  | || |  |_   __ \   | || | |  _   _  |  | || |    |_   _|   | || |   .' ___  |  | || |  .' ___  |   | || |   .'    `.   | || |   /  ___  |  | |
| |  |  (__ \_|  | || |  / .'   \_|  | || |   | |_  \_|  | || |    | |__) |  | || | |_/ | | \_|  | || |      | |     | || |  / .'   \_|  | || | / .'   \_|   | || |  /  .--.  \  | || |  |  (__ \_|  | |
| |   '.___`-.   | || |  | |         | || |   |  _|  _   | || |    |  ___/   | || |     | |      | || |      | |     | || |  | |         | || | | |    ____  | || |  | |    | |  | || |   '.___`-.   | |
| |  |`\____) |  | || |  \ `.___.'\  | || |  _| |___/ |  | || |   _| |_      | || |    _| |_     | || |     _| |_    | || |  \ `.___.'\  | || | \ `.___]  _| | || |  \  `--'  /  | || |  |`\____) |  | |
| |  |_______.'  | || |   `._____.'  | || | |_________|  | || |  |_____|     | || |   |_____|    | || |    |_____|   | || |   `._____.'  | || |  `._____.'   | || |   `.____.'   | || |  |_______.'  | |
| |              | || |              | || |              | || |              | || |              | || |              | || |              | || |              | || |              | || |              | |
| '--------------' || '--------------' || '--------------' || '--------------' || '--------------' || '--------------' || '--------------' || '--------------' || '--------------' || '--------------' |
 '----------------'  '----------------'  '----------------'  '----------------'  '----------------'  '----------------'  '----------------'  '----------------'  '----------------'  '----------------' 

EOF
}

# Limpiamos la pantalla y monstramos el logo
clear
print_logo

# Salimos si hay algun error
set -e

# Cargar funciones auxiliares
source ./utils.sh

# Archivo de configuración bspwm.conf
conf_file="bspwm.conf"

# Listas de paquetes y configuraciones a procesar
packages=()
configs=()
mode=""

# Leer bspwm.conf y separar paquetes y configuraciones
while IFS= read -r line; do
  [[ "$line" =~ ^\s*#.*$ || -z "$line" ]] && continue

  if [[ "$line" == "# --- PACKAGES ---" ]]; then
    mode="packages"
  elif [[ "$line" == "# --- CONFIG_FILES ---" ]]; then
    mode="configs"
  else
    if [[ "$mode" == "packages" ]]; then
      packages+=("$line")
    elif [[ "$mode" == "configs" ]]; then
      configs+=("$line")
    fi
  fi
done < "$conf_file"

# Instalar paquetes faltantes
install_missing_packages "${packages[@]}"

# Copiar archivos de configuración
copy_config_folders "${configs[@]}"

# Asegurarse de que bspwm y sxhkd se ejecuten al iniciar la sesión
echo "Asegurando que bspwm y sxhkd se inicien al arrancar..."

# Crear o actualizar ~/.xinitrc si no existe
if [ ! -f "$HOME/.xinitrc" ]; then
  echo "Creando .xinitrc para iniciar bspwm automáticamente..."
  cat > "$HOME/.xinitrc" << EOF
#!/bin/bash
# Iniciar bspwm y sxhkd
sxhkd &
exec bspwm
EOF
fi

# Configuración adicional de Polybar (si se usa)
if ! grep -q "polybar example" "$HOME/.config/bspwm/bspwmrc"; then
  echo "Añadiendo comando para iniciar Polybar en bspwmrc..."
  echo "polybar example &" >> "$HOME/.config/bspwm/bspwmrc"
fi

# Verificar que el archivo de configuración .xinitrc es ejecutable
chmod +x "$HOME/.xinitrc"

# Recomendación para reiniciar
echo "✅ La configuración se ha completado con éxito. Por favor, reinicia tu computadora para aplicar todos los cambios."

