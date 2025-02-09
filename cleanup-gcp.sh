#!/bin/bash
# Script para limpiar recursos en GCP

# Colores para output
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Verificar argumentos
if [ -z "$1" ]; then
    echo "Uso: $0 <project_id>"
    exit 1
fi

PROJECT_ID=$1

echo -e "${RED}¡ATENCIÓN! Este script eliminará todos los recursos creados en GCP${NC}"
echo -e "${YELLOW}¿Estás seguro de que quieres continuar? (y/N)${NC}"
read -r response

if [[ "$response" =~ ^[Yy]$ ]]; then
    cd terraform
    terraform destroy -var="project_id=$PROJECT_ID" -auto-approve
    cd ..
    
    # Limpiar archivos de estado de Terraform
    rm -rf terraform/.terraform
    rm -f terraform/*.tfstate*
    
    echo "Limpieza completada"
else
    echo "Operación cancelada"
fi 