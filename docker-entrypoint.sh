#!/bin/sh
set -e

echo "[$(date)] === Iniciando servicios ==="

echo "[$(date)] Iniciando Ollama como root..."
mkdir -p /root/.ollama
chmod 755 /root/.ollama
OLLAMA_HOST=0.0.0.0 OLLAMA_ORIGINS=* ollama serve &
OLLAMA_PID=$!
echo "[$(date)] PID de Ollama: $OLLAMA_PID"

echo "[$(date)] Esperando a que Ollama esté disponible..."
ATTEMPTS=0
MAX_ATTEMPTS=30
until curl -s http://localhost:11434/api/tags >/dev/null 2>&1; do
    ATTEMPTS=$((ATTEMPTS + 1))
    if [ $ATTEMPTS -ge $MAX_ATTEMPTS ]; then
        echo "[$(date)] ERROR: Ollama no respondió después de $MAX_ATTEMPTS intentos"
        echo "[$(date)] Estado de los procesos:"
        ps aux
        exit 1
    fi
    echo "[$(date)] Ollama no está listo todavía... (intento $ATTEMPTS de $MAX_ATTEMPTS)"
    sleep 2
done

echo "[$(date)] Ollama está listo!"

echo "[$(date)] === Configurando permisos ==="
echo "[$(date)] Creando directorios necesarios..."
mkdir -p /home/node/.n8n/.n8n
touch /home/node/.n8n/.n8n/config
touch /home/node/.n8n/.n8n/crash.journal
touch /home/node/.n8n/.n8n/n8n.log

echo "[$(date)] Estableciendo propietario y permisos..."
chown -R node:node /home/node/.n8n
chmod -R 755 /home/node/.n8n
chmod -R 777 /home/node/.n8n/.n8n
chmod 666 /home/node/.n8n/.n8n/config
chmod 666 /home/node/.n8n/.n8n/crash.journal
chmod 666 /home/node/.n8n/.n8n/n8n.log

echo "[$(date)] === Verificando sistema de archivos ==="
echo "[$(date)] Contenido de /home/node:"
ls -la /home/node/
echo "[$(date)] Contenido de /home/node/.n8n:"
ls -la /home/node/.n8n/
echo "[$(date)] Contenido de /home/node/.n8n/.n8n:"
ls -la /home/node/.n8n/.n8n/

echo "[$(date)] === Configurando n8n ==="
echo "[$(date)] Versión de n8n:"
n8n --version
echo "[$(date)] Usuario actual: $(whoami)"
echo "[$(date)] Directorio actual: $(pwd)"

echo "[$(date)] === Iniciando n8n ==="
echo "[$(date)] Comando: n8n start"

# Iniciar n8n como usuario node
su -c "
    cd /home/node
    export N8N_HOST=0.0.0.0
    export N8N_PROTOCOL=http
    export N8N_PORT=5678
    export NODE_ENV=production
    export N8N_LOG_LEVEL=verbose
    export N8N_USER_FOLDER=/home/node/.n8n
    export N8N_DIAGNOSTICS_ENABLED=false
    export N8N_METRICS_ENABLED=false
    export N8N_SKIP_WEBHOOK_DEREGISTRATION=true
    n8n start
" node &

N8N_PID=$!
echo "[$(date)] PID de n8n: $N8N_PID"

echo "[$(date)] Esperando a que n8n se inicie..."
sleep 15

echo "[$(date)] Verificando si n8n responde..."
ATTEMPTS=0
MAX_ATTEMPTS=30
until curl -s http://localhost:5678/healthz >/dev/null 2>&1; do
    ATTEMPTS=$((ATTEMPTS + 1))
    if [ $ATTEMPTS -ge $MAX_ATTEMPTS ]; then
        echo "[$(date)] ERROR: n8n no responde después de $MAX_ATTEMPTS intentos"
        echo "[$(date)] Estado de los procesos:"
        ps aux
        echo "[$(date)] Últimas líneas del log de n8n:"
        tail -n 50 /home/node/.n8n/.n8n/n8n.log
        exit 1
    fi
    echo "[$(date)] n8n no está listo todavía... (intento $ATTEMPTS de $MAX_ATTEMPTS)"
    sleep 2
done

echo "[$(date)] n8n está respondiendo correctamente"

echo "[$(date)] === Configurando manejadores de señales ==="
trap "echo '[$(date)] Recibida señal de terminación'; kill $OLLAMA_PID $N8N_PID; exit 0" INT TERM

echo "[$(date)] === Servicios iniciados correctamente ==="
echo "[$(date)] Ollama en puerto 11434"
echo "[$(date)] n8n en puerto 5678"

wait $OLLAMA_PID $N8N_PID 