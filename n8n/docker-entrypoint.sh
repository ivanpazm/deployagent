#!/bin/bash
set -e

echo "Verificando instalación de n8n..."
which n8n || echo "n8n no encontrado en PATH"
echo "PATH=$PATH"
echo "Contenido de /usr/local/lib/node_modules/n8n/bin:"
ls -la /usr/local/lib/node_modules/n8n/bin || echo "Directorio no encontrado"

# Establecer permisos correctos para el archivo de configuración
if [ ! -f /home/node/.n8n/config ]; then
    touch /home/node/.n8n/config
    chmod 600 /home/node/.n8n/config
fi

# Establecer variable de entorno para los permisos
export N8N_ENFORCE_SETTINGS_FILE_PERMISSIONS=true

# Inicia n8n
exec /usr/local/lib/node_modules/n8n/bin/n8n start 