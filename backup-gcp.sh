#!/bin/bash
# Script para hacer backup de los datos en Google Cloud

BACKUP_DIR="backups"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

mkdir -p $BACKUP_DIR

# Obtener IP de la instancia
instance_ip=$(cd terraform && terraform output -raw instance_ip)

# Crear backup de N8N
echo "Creando backup de N8N..."
gcloud compute ssh n8n-ollama --command="cd /n8n-ollama/data && tar czf n8n-backup.tar.gz n8n"
gcloud compute scp n8n-ollama:/n8n-ollama/data/n8n-backup.tar.gz $BACKUP_DIR/n8n-backup-$TIMESTAMP.tar.gz

# Crear backup de Ollama
echo "Creando backup de Ollama..."
gcloud compute ssh n8n-ollama --command="cd /n8n-ollama/data && tar czf ollama-backup.tar.gz ollama"
gcloud compute scp n8n-ollama:/n8n-ollama/data/ollama-backup.tar.gz $BACKUP_DIR/ollama-backup-$TIMESTAMP.tar.gz

echo "Backups completados en $BACKUP_DIR" 