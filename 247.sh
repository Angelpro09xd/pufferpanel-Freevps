#!/bin/bash

echo "¿Cada cuántos minutos deseas enviar pings para mantener la sesión activa?"
read -p "Introduce un número (en minutos): " interval

# Convertir minutos a segundos
seconds=$((interval * 60))

# Función para mostrar mensaje animado con colores
function show_animated_message {
  local message="Enviando pings cada $interval minuto(s). Presiona Ctrl+C para detener."
  local colors=(31 32 33 34 35 36) # Rojo, verde, amarillo, azul, magenta, cyan
  while true; do
    for color in "${colors[@]}"; do
      echo -ne "\e[1;${color}m$message\e[0m\r"
      sleep 0.3
    done
  done
}

# Ejecutar el mensaje animado en segundo plano
show_animated_message &

# Guardar el PID del proceso animado para detenerlo más tarde
animation_pid=$!

# Mantener sesión activa
echo "Manteniendo la sesión activa..."
while true; do
  curl -s https://gitpod.io/ping > /dev/null
  sleep "$seconds"  # Esperar el intervalo especificado
done

# Detener la animación (esto se ejecutará solo si el script termina, lo cual no sucede normalmente)
kill $animation_pid
