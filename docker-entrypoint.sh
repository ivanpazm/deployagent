#!/bin/bash
set -e

# Función para manejar la terminación (✅ PUNTO CRÍTICO 7.2 - Manejo de señales)
cleanup() {
    echo "Deteniendo servicios..."
    if [ -n "$OLLAMA_PID" ]; then
        echo "[$(date)] Deteniendo Ollama (PID: $OLLAMA_PID)"
        kill $OLLAMA_PID
        wait $OLLAMA_PID
    fi
    if [ -n "$N8N_PID" ]; then
        echo "[$(date)] Deteniendo N8N (PID: $N8N_PID)"
        kill $N8N_PID
        wait $N8N_PID
    fi
    exit 0
}

# Función para verificar proceso (✅ PUNTO CRÍTICO 7.3 - Monitoreo)
check_process() {
    if ! kill -0 $1 2>/dev/null; then
        echo "[$(date)] Proceso $2 (PID: $1) no está ejecutándose"
        return 1
    fi
    return 0
}

# Capturar señales
trap 'cleanup' SIGTERM SIGINT SIGHUP

# Asegurar que los subprocesos también reciben las señales
set -m

echo "[$(date)] === Iniciando servicios ==="

# Verificar binario de Ollama (✅ PUNTO CRÍTICO 1 - Rutas y Binarios)
echo "[$(date)] Verificando binario de Ollama..."
ls -l /usr/local/bin/ollama

# Verificar que el binario es ejecutable
if [ ! -x /usr/local/bin/ollama ]; then
    echo "[$(date)] ERROR: El binario de Ollama no es ejecutable"
    exit 1
fi

# Verificar bibliotecas del sistema (✅ PUNTO CRÍTICO 1 - Dependencias)
echo "[$(date)] Verificando bibliotecas del sistema..."
echo "=== Bibliotecas disponibles ==="
ldconfig || true
echo "=== Verificando Ollama ==="
# Intentar ejecutar Ollama para verificar bibliotecas
/usr/local/bin/ollama -v || {
    echo "[$(date)] ERROR: Problemas con las bibliotecas de Ollama"
    ldd /usr/local/bin/ollama
    exit 1
}

# 1. Configurar permisos de directorios (✅ PUNTO CRÍTICO 2 - Estructura de Permisos)
echo "[$(date)] Configurando permisos para N8N..."
chown -R node:node /home/node/.n8n
chmod -R 750 /home/node/.n8n

echo "[$(date)] Configurando permisos para Ollama..."
chown -R root:root /root/.ollama
chmod -R 755 /root/.ollama

# 2. Configuración de red (✅ PUNTO CRÍTICO 3 - Red)
echo "[$(date)] Configurando red..."
export OLLAMA_HOST=0.0.0.0
export OLLAMA_ORIGINS=*

# 3. Iniciar Ollama como root (✅ PUNTO CRÍTICO 4 - Ollama)
echo "[$(date)] Iniciando Ollama..."
mkdir -p /var/log/ollama

# Verificar el entorno antes de iniciar Ollama
echo "[$(date)] Verificando entorno de Ollama:"
env | grep OLLAMA

# Forzar modo CPU-only
export OLLAMA_SKIP_GPU_DETECTION=true
export OLLAMA_CPU_ONLY=true
export CGO_ENABLED=0

# Verificar permisos del directorio de Ollama
echo "[$(date)] Permisos del directorio de Ollama:"
ls -la /root/.ollama

# Iniciar Ollama con redirección de logs
/usr/local/bin/ollama serve > /var/log/ollama/ollama.log 2>&1 &
OLLAMA_PID=$!
echo "[$(date)] Ollama iniciado con PID: $OLLAMA_PID"

# 4. Esperar respuesta de Ollama (✅ PUNTO CRÍTICO 4 - Ollama API)
echo "[$(date)] Esperando a que Ollama esté listo..."
until curl -s http://127.0.0.1:11434/api/version > /dev/null; do
    echo "[$(date)] Esperando a que Ollama inicie..."
    if ! check_process $OLLAMA_PID "Ollama"; then
        echo "[$(date)] === Últimas líneas del log de Ollama ==="
        tail -n 50 /var/log/ollama/ollama.log
        echo "[$(date)] ERROR: Ollama falló al iniciar"
        exit 1
    fi
    sleep 1
done
echo "[$(date)] Ollama está respondiendo correctamente"

# Verificar y descargar solo el modelo soportado
if ! curl -s http://127.0.0.1:11434/api/tags | grep -q "llama3.2:1b"; then
    echo "[$(date)] Descargando único modelo soportado (llama3.2:1b)..."
    $(which ollama) pull --insecure llama3.2:1b || {
        echo "[$(date)] ERROR: No se pudo descargar el modelo llama3.2:1b"
        exit 1
    }
fi

# Verificar que no haya otros modelos instalados
if [ "$(curl -s http://127.0.0.1:11434/api/tags | grep -v "llama3.2:1b" | wc -l)" -gt 0 ]; then
    echo "[$(date)] ADVERTENCIA: Se detectaron otros modelos instalados. Solo llama3.2:1b está soportado."
fi

# 5. Iniciar N8N como usuario node (✅ PUNTO CRÍTICO 4 - N8N)
echo "[$(date)] Iniciando N8N..."

# Preparar directorio .n8n
echo "[$(date)] Recreando estructura de directorios N8N..."
mkdir -p /home/node/.n8n
# Limpiar solo el contenido, no el directorio en sí
find /home/node/.n8n -mindepth 1 -delete 2>/dev/null || true
# Crear estructura básica
mkdir -p /home/node/.n8n/.n8n
chown -R node:node /home/node/.n8n
chmod -R 750 /home/node/.n8n

# Verificar permisos antes de iniciar N8N
echo "[$(date)] Verificando permisos de N8N..."
ls -la /home/node/.n8n

# Verificar variables de entorno de N8N (✅ PUNTO CRÍTICO 8 - Variables de Entorno)
echo "[$(date)] Variables de entorno de N8N:"
env | grep N8N_

# Iniciar N8N con configuración mínima (✅ PUNTO CRÍTICO 4 - N8N Lecciones Aprendidas)
echo "[$(date)] Iniciando N8N con configuración mínima..."
export NODE_ENV=production
export N8N_ENCRYPTION_KEY=$(openssl rand -hex 24)
export N8N_DISABLE_TUNNEL=true
export N8N_METRICS_DISABLED=true
export N8N_DIAGNOSTICS_DISABLED=true
# Asegurar que el directorio de trabajo existe (✅ PUNTO CRÍTICO 2 - Estructura de Directorios)
gosu node mkdir -p /home/node/.n8n/data

# Iniciar N8N en modo producción (✅ PUNTO CRÍTICO 4.3 - Inicio del Servicio)
echo "[$(date)] Iniciando N8N en modo producción..."
cd /home/node && \
gosu node n8n start &
N8N_PID=$!
echo "[$(date)] N8N iniciado con PID: $N8N_PID"

# Esperar un momento y verificar que N8N está escuchando (✅ PUNTO CRÍTICO 4.3 - Verificación)
echo "[$(date)] Esperando a que N8N inicie..."
sleep 10
if ! curl -s http://127.0.0.1:5678/healthz > /dev/null; then
    echo "[$(date)] === Últimas líneas del log de N8N ==="
    ps aux | grep n8n || true
    echo "[$(date)] Estado del proceso N8N:"
    kill -0 $N8N_PID 2>&1 || echo "Proceso no encontrado"
    echo "[$(date)] ERROR: N8N no está respondiendo en el puerto 5678"
    exit 1
fi

# Esperar a que cualquiera de los procesos termine (✅ PUNTO CRÍTICO 7.3 - Monitoreo de Procesos)
echo "[$(date)] Monitoreando servicios..."
while true; do
    if ! check_process $OLLAMA_PID "Ollama"; then
        echo "[$(date)] ERROR: Ollama se detuvo inesperadamente"
        exit 1
    fi
    if ! check_process $N8N_PID "N8N"; then
        echo "[$(date)] ERROR: N8N se detuvo inesperadamente"
        exit 1
    fi
    sleep 5
done 