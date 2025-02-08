#!/bin/bash

# Monitorear estado de los servicios
while true; do
    echo "[$(date)] Verificando estado de servicios..."
    
    # Verificar n8n
    if curl -s http://localhost:5678/healthz > /dev/null; then
        echo "✅ n8n: Funcionando"
    else
        echo "❌ n8n: No responde"
    fi
    
    # Verificar Ollama
    if curl -s http://localhost:11434/api/tags > /dev/null; then
        echo "✅ Ollama: Funcionando"
        echo "📚 Modelos disponibles:"
        curl -s http://localhost:11434/api/tags | jq '.models[].name'
    else
        echo "❌ Ollama: No responde"
    fi
    
    sleep 60
done 