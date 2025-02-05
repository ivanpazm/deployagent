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

# Configurar n8n
echo "[$(date)] Configurando n8n..."
mkdir -p /home/node/.n8n/.n8n
chown -R node:node /home/node/.n8n
chmod 750 /home/node/.n8n
chmod 600 /home/node/.n8n/.n8n/config

# Iniciar n8n como usuario node
echo "[$(date)] Iniciando n8n..."
su node -c "cd /home/node && /usr/local/bin/n8n start" &
N8N_PID=$!

# Esperar a que ambos servicios estén funcionando
wait $OLLAMA_PID $N8N_PID 