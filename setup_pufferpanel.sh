#!/bin/bash

# Create the necessary directory
mkdir -p /var/lib/pufferpanel

# Create Docker volume for PufferPanel config
docker volume create pufferpanel-config

# Create and run the PufferPanel container
docker create --name pufferpanel \
  -p 8080:8080 -p 5657:5657 \
  -v pufferpanel-config:/etc/pufferpanel \
  -v /var/lib/pufferpanel:/var/lib/pufferpanel \
  -v /var/run/docker.sock:/var/run/docker.sock \
  --restart=always \
  pufferpanel/pufferpanel:latest

# Start the PufferPanel container
docker start pufferpanel

# Add a user to PufferPanel interactively
docker exec -it pufferpanel /pufferpanel/pufferpanel user add
