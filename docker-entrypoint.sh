#!/bin/bash
set -e

echo "[$(date)] === Iniciando servicios ==="

# Configurar OLLAMA_HOST si no está definido
if [ -z "$OLLAMA_HOST" ]; then
    export OLLAMA_HOST="0.0.0.0"
fi

# Iniciar Ollama en segundo plano
/usr/local/bin/ollama serve &
OLLAMA_PID=$!

# Esperar a que Ollama esté listo
echo "Esperando a que Ollama esté listo..."
until curl -s http://localhost:11434/api/version > /dev/null; do
    sleep 1
done

# Descargar el modelo si no existe
if ! curl -s http://localhost:11434/api/tags | grep -q "llama3.2:1b"; then
    echo "Descargando modelo llama3.2:1b..."
    /usr/local/bin/ollama pull llama3.2:1b
fi

# Iniciar n8n
echo "Iniciando n8n..."
exec su-exec node n8n start 