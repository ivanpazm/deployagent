#!/bin/bash
# Script de inicio para la instancia de GCP

# Instalar Docker
apt-get update
apt-get install -y apt-transport-https ca-certificates curl software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
apt-get update
apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin

# Crear directorios
mkdir -p /n8n-ollama/data/{n8n,ollama}

# Clonar repositorio
cd /n8n-ollama
git clone https://github.com/ivanpazm/deployagent .

# Iniciar servicios
docker compose up -d 