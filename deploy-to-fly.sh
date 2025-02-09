#!/bin/bash
set -e

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Variables por defecto
REGION="mad"
APP_NAME="n8n-ollama"
ADMIN_USER="admin"

# Solicitar contraseña si no se proporcionó
if [ -z "$ADMIN_PASS" ]; then
    read -sp "Introduce contraseña para el admin de N8N: " ADMIN_PASS
    echo
fi

echo -e "${GREEN}🚀 Iniciando despliegue en Fly.io...${NC}"

# Verificar Flyctl
if ! command -v flyctl &> /dev/null; then
    echo -e "${YELLOW}⚙️ Instalando Flyctl...${NC}"
    curl -L https://fly.io/install.sh | sh
    export PATH="$HOME/.fly/bin:$PATH"
fi

# Login si es necesario
if ! fly auth whoami &> /dev/null; then
    echo -e "${YELLOW}🔑 Por favor, inicia sesión en Fly.io...${NC}"
    fly auth login
fi

# Crear la aplicación
echo -e "${BLUE}📦 Creando aplicación en Fly.io...${NC}"
fly apps create $APP_NAME --machines || true

# Crear volúmenes
echo -e "${BLUE}💾 Creando volúmenes persistentes...${NC}"
fly volumes create n8n_data --size 1 --region $REGION || true
fly volumes create ollama_data --size 10 --region $REGION || true

# Configurar secretos
echo -e "${BLUE}🔐 Configurando secretos...${NC}"
ENCRYPTION_KEY=$(openssl rand -hex 24)
fly secrets set N8N_BASIC_AUTH_USER=$ADMIN_USER
fly secrets set N8N_BASIC_AUTH_PASSWORD=$ADMIN_PASS
fly secrets set N8N_ENCRYPTION_KEY=$ENCRYPTION_KEY

# Desplegar
echo -e "${GREEN}🚀 Desplegando aplicación...${NC}"
fly deploy

# Verificar despliegue
echo -e "${BLUE}✅ Verificando despliegue...${NC}"
fly status
fly logs

echo -e "${GREEN}🎉 Despliegue completado!${NC}"
echo -e "${YELLOW}📝 Guarda esta información:${NC}"
echo -e "${BLUE}URL: https://$APP_NAME.fly.dev${NC}"
echo -e "${BLUE}Usuario: $ADMIN_USER${NC}"
echo -e "${BLUE}Contraseña: [la que configuraste]${NC}"

# Crear backup inicial
echo -e "${BLUE}📦 Creando backup inicial...${NC}"
mkdir -p backups

# Función para backup
create_backup() {
    local service=$1
    local path=$2
    echo "Creando backup de $service..."
    fly ssh console -C "cd $path && tar czf /backup/$service-backup.tar.gz ."
    fly sftp get /backup/$service-backup.tar.gz backups/
}

create_backup "n8n" "/home/node/.n8n"
create_backup "ollama" "/root/.ollama" 