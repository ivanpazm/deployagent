#!/bin/bash
set -e

echo "Iniciando Ollama..."
# Configurar Ollama para escuchar en todas las interfaces (0.0.0.0)
OLLAMA_HOST=0.0.0.0:11434 ollama serve &
OLLAMA_PID=$!

# Esperar a que Ollama esté completamente iniciado
echo "Esperando a que Ollama esté disponible..."
until curl -s http://localhost:11434/api/tags >/dev/null 2>&1; do
    echo "Ollama no está listo todavía..."
    sleep 1
done

echo "Ollama está listo!"

# Manejar señales de terminación correctamente
trap "kill $OLLAMA_PID" SIGINT SIGTERM
wait $OLLAMA_PID 