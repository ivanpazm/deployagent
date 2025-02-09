#!/bin/bash
set -e

# Colores para output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Variables
REGION="eu-madrid-1"
COMPARTMENT_NAME="n8n-ollama"

echo -e "${GREEN}Iniciando despliegue en Oracle Cloud...${NC}"

# Verificar OCI CLI
if ! command -v oci &> /dev/null; then
    echo -e "${YELLOW}Instalando Oracle Cloud CLI...${NC}"
    echo "Por favor, instala Oracle Cloud CLI desde: https://docs.oracle.com/en-us/iaas/Content/API/SDKDocs/cliinstall.htm"
    exit 1
fi

# Verificar Terraform
if ! command -v terraform &> /dev/null; then
    echo -e "${YELLOW}Instalando Terraform...${NC}"
    echo "Por favor, instala Terraform desde: https://www.terraform.io/downloads"
    exit 1
fi

# Login en OCI
echo -e "${BLUE}Configurando OCI CLI...${NC}"
oci setup config

# Inicializar Terraform
echo -e "${BLUE}Inicializando Terraform...${NC}"
cd terraform
terraform init

# Aplicar configuración
echo -e "${GREEN}Desplegando infraestructura...${NC}"
terraform apply -auto-approve

# Obtener IP de la instancia
instance_ip=$(terraform output -raw instance_ip)

# Esperar a que la instancia esté lista
echo -e "${BLUE}Esperando a que la instancia esté lista...${NC}"
until ssh -o StrictHostKeyChecking=no opc@$instance_ip "echo 'Conexión establecida'"; do
    echo "Esperando conexión SSH..."
    sleep 5
done

# Configurar Docker en la instancia
echo -e "${BLUE}Configurando instancia...${NC}"
ssh opc@$instance_ip "sudo dnf config-manager --add-repo=https://download.docker.com/linux/centos/docker-ce.repo"
ssh opc@$instance_ip "sudo dnf install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin"
ssh opc@$instance_ip "sudo systemctl start docker"
ssh opc@$instance_ip "sudo systemctl enable docker"
ssh opc@$instance_ip "sudo usermod -aG docker opc"

# Crear directorios necesarios
echo -e "${BLUE}Preparando directorios...${NC}"
ssh opc@$instance_ip "mkdir -p ~/n8n-ollama/{data/n8n,data/ollama}"

# Copiar archivos
echo -e "${BLUE}Copiando archivos de configuración...${NC}"
scp docker-compose.yml opc@$instance_ip:~/n8n-ollama/
scp .env.production opc@$instance_ip:~/n8n-ollama/
scp Dockerfile opc@$instance_ip:~/n8n-ollama/
scp docker-entrypoint.sh opc@$instance_ip:~/n8n-ollama/

# Iniciar servicios
echo -e "${GREEN}Iniciando servicios...${NC}"
ssh opc@$instance_ip "cd ~/n8n-ollama && docker compose up -d"

# Mostrar información
echo -e "${GREEN}¡Despliegue completado!${NC}"
echo -e "${YELLOW}Información importante:${NC}"
echo -e "${BLUE}URL: http://$instance_ip${NC}"
echo -e "${BLUE}SSH: ssh opc@$instance_ip${NC}"

# Mostrar logs
echo -e "${BLUE}Mostrando logs...${NC}"
ssh opc@$instance_ip "cd ~/n8n-ollama && docker compose logs -f" 