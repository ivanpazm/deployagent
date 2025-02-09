#!/bin/bash
# Script de despliegue para Google Cloud

# Colores para output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Verificar argumentos
if [ -z "$1" ]; then
    echo "Uso: $0 <project_id> [region]"
    echo "Ejemplo: $0 my-project-id europe-west1"
    exit 1
fi

PROJECT_ID=$1
REGION=${2:-"europe-west1"}

echo -e "${GREEN}Iniciando despliegue en Google Cloud...${NC}"

# Verificar gcloud CLI
if ! command -v gcloud &> /dev/null; then
    echo -e "${YELLOW}Instalando Google Cloud SDK...${NC}"
    echo "Por favor, instala Google Cloud SDK desde: https://cloud.google.com/sdk/docs/install"
    exit 1
fi

# Verificar Terraform
if ! command -v terraform &> /dev/null; then
    echo -e "${YELLOW}Instalando Terraform...${NC}"
    echo "Por favor, instala Terraform desde: https://www.terraform.io/downloads"
    exit 1
fi

# Login en GCP
echo -e "${BLUE}Configurando Google Cloud...${NC}"
gcloud auth application-default login
gcloud config set project $PROJECT_ID

# Inicializar Terraform
echo -e "${BLUE}Inicializando Terraform...${NC}"
cd terraform
terraform init

# Aplicar configuración
echo -e "${GREEN}Desplegando infraestructura...${NC}"
terraform apply -var="project_id=$PROJECT_ID" -var="region=$REGION" -auto-approve 