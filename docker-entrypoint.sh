#!/bin/bash
set -e

echo "Iniciando Ollama como root..."
OLLAMA_HOST=0.0.0.0:11434 ollama serve &
OLLAMA_PID=$!

echo "Esperando a que Ollama esté disponible..."
until curl -s http://localhost:11434/api/tags >/dev/null 2>&1; do
    echo "Ollama no está listo todavía..."
    sleep 1
done

echo "Ollama está listo!"

echo "Cambiando a usuario node para n8n..."
exec su node -c '
    echo "Iniciando n8n..."
    n8n start &
    N8N_PID=$!

    # Manejar señales de terminación
    trap "kill $N8N_PID" SIGINT SIGTERM

    # Esperar a que n8n termine
    wait $N8N_PID
' &

N8N_PARENT_PID=$!

# Manejar señales para ambos procesos
trap 'kill $OLLAMA_PID $N8N_PARENT_PID' SIGINT SIGTERM

# Esperar a que ambos procesos terminen
wait $OLLAMA_PID $N8N_PARENT_PID 