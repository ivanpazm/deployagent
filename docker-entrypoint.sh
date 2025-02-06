#!/bin/sh
set -e

echo "[$(date)] === Iniciando servicios ==="

# Iniciar Ollama
echo "[$(date)] Iniciando Ollama como root..."
mkdir -p /root/.ollama
chmod 755 /root/.ollama
OLLAMA_HOST=0.0.0.0 OLLAMA_ORIGINS=* ollama serve &
OLLAMA_PID=$!

# Verificar que Ollama está funcionando
echo "[$(date)] Esperando a que Ollama esté disponible..."
ATTEMPTS=0
MAX_ATTEMPTS=30
until curl -s http://localhost:11434/api/tags >/dev/null 2>&1; do
    ATTEMPTS=$((ATTEMPTS + 1))
    if [ $ATTEMPTS -ge $MAX_ATTEMPTS ]; then
        echo "[$(date)] ERROR: Ollama no respondió"
        exit 1
    fi
    sleep 2
done

echo "[$(date)] Ollama está listo!"

# Añadir más logging para Ollama
echo "[$(date)] Verificando Ollama en puerto 11434..."
curl -v http://localhost:11434/api/tags

# Configurar n8n
echo "[$(date)] Configurando n8n..."

mkdir -p /home/node/.n8n/.n8n
# Generar un UUID usando /dev/urandom
UUID=$(od -x /dev/urandom | head -1 | awk '{OFS="-"; print $2$3,$4,$5,$6,$7$8$9}')
cat > /home/node/.n8n/.n8n/config << EOL
{
  "encryptionKey": "$(head -c 32 /dev/urandom | base64)",
  "instanceId": "${UUID}",
  "nodes": {}
}
EOL
chown -R node:node /home/node/.n8n
chmod 750 /home/node/.n8n
chmod 600 /home/node/.n8n/.n8n/config

# Usar el puerto proporcionado por Render o el puerto por defecto de n8n
if [ ! -z "$PORT" ]; then
    export N8N_PORT=$PORT
fi

# Iniciar n8n como usuario node
echo "[$(date)] Iniciando n8n..."
su node -c "cd /home/node && NODE_OPTIONS=\"--max-old-space-size=4096\" /usr/local/bin/n8n start" &
N8N_PID=$!

# Esperar a que ambos servicios estén funcionando
wait $OLLAMA_PID $N8N_PID 