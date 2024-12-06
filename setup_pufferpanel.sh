#!/bin/bash

# Colores para mensajes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m'

echo -e "${GREEN}Iniciando configuración completa de PufferPanel...${NC}"

# 1. Verificar si Docker está instalado
if ! command -v docker &> /dev/null; then
  echo -e "${YELLOW}Docker no está instalado. Instalando Docker...${NC}"
  curl -fsSL https://get.docker.com -o get-docker.sh
  sh get-docker.sh
  rm get-docker.sh
else
  echo -e "${GREEN}Docker ya está instalado.${NC}"
fi

# 2. Crear volúmenes persistentes para configuración y datos
echo -e "${YELLOW}Creando volúmenes para PufferPanel...${NC}"
docker volume create pufferpanel-config
docker volume create pufferpanel-data

# 3. Descargar e iniciar el contenedor de PufferPanel
echo -e "${YELLOW}Iniciando el contenedor de PufferPanel...${NC}"
docker run -d --name pufferpanel \
  -p 8080:8080 \
  -p 5657:5657 \
  -v pufferpanel-config:/etc/pufferpanel \
  -v pufferpanel-data:/var/lib/pufferpanel \
  --restart=on-failure \
  pufferpanel/pufferpanel:latest

# 4. Esperar unos segundos para que el contenedor arranque
echo -e "${YELLOW}Esperando a que PufferPanel se inicialice...${NC}"
sleep 10

# 5. Verificar la existencia de config.json
CONFIG_PATH="/workspace/.docker-root/volumes/pufferpanel-config/_data"
if [ ! -f "$CONFIG_PATH/config.json" ]; then
  echo -e "${YELLOW}Creando archivo config.json...${NC}"
  docker exec -it pufferpanel pufferpanel configure # Genera el archivo inicial en el contenedor
  docker cp pufferpanel:/etc/pufferpanel/config.json "$CONFIG_PATH/config.json"
else
  echo -e "${GREEN}El archivo config.json ya existe.${NC}"
fi

# 6. Asegurar que el archivo config.json esté correctamente ubicado
echo -e "${YELLOW}Estableciendo permisos correctos para config.json...${NC}"
docker exec -it pufferpanel chmod 600 /etc/pufferpanel/config.json
docker exec -it pufferpanel chown -R 1000:1000 /etc/pufferpanel
echo -e "${GREEN}Permisos establecidos.${NC}"

# 7. Reiniciar el contenedor para aplicar configuraciones
echo -e "${YELLOW}Reiniciando PufferPanel para aplicar configuraciones...${NC}"
docker restart pufferpanel

# 8. Mostrar información de acceso
echo -e "${GREEN}Instalación completada. Puedes acceder a PufferPanel usando:${NC}"
echo -e "${GREEN}http://localhost:8080${NC} (si estás en la misma máquina)"
echo -e "${GREEN}http://<tu-IP>:8080${NC} (desde otra máquina en la red)"

# Información final
echo -e "${YELLOW}Si necesitas administrar usuarios, utiliza los siguientes comandos:${NC}"
echo -e "${GREEN}Para crear un usuario administrador:${NC}"
echo -e "${GREEN}docker exec -it pufferpanel pufferpanel user create <email> <contraseña> --admin${NC}"

