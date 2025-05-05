#!/bin/bash

# Terminar instancias anteriores
killall -q polybar

# Esperar a que termine
while pgrep -u $UID -x polybar >/dev/null; do sleep 1; done

# Lanzar la barra
polybar example &