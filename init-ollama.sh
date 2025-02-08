#!/bin/bash

# Iniciar Ollama en segundo plano
/usr/local/bin/ollama serve &

# Esperar a que Ollama esté listo
echo "Esperando a que Ollama esté listo..."
until curl -s http://localhost:11434/api/version > /dev/null; do
    sleep 1
done

# Descargar el modelo
echo "Descargando modelo llama3.2:1b..."
/usr/local/bin/ollama pull llama3.2:1b

# Matar el proceso de Ollama
pkill ollama

# Esperar a que termine
sleep 2

# Iniciar supervisor
exec /usr/bin/supervisord -n -c /etc/supervisor/supervisord.conf 