#!/bin/sh
set -e

# Función para registrar mensajes con timestamp y nivel
log() {
    local level=$1
    local message=$2
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] [${level}] ${message}"
}

# Función para verificar el estado de un servicio
check_service() {
    local service=$1
    local url=$2
    local max_attempts=$3
    local attempt=0

    log "INFO" "Verificando servicio ${service} en ${url}..."
    
    while [ $attempt -lt $max_attempts ]; do
        if curl -s "${url}" > /dev/null 2>&1; then
            log "SUCCESS" "${service} está respondiendo correctamente"
            return 0
        fi
        attempt=$((attempt + 1))
        log "WARN" "Intento ${attempt}/${max_attempts} fallido para ${service}"
        sleep 5
    done
    
    log "ERROR" "${service} no responde después de ${max_attempts} intentos"
    return 1
}

# Función para mostrar el estado del sistema
check_system_status() {
    log "INFO" "=== Estado del Sistema ==="
    log "INFO" "Memoria: $(free -h)"
    log "INFO" "CPU: $(top -bn1 | grep "Cpu(s)" | awk '{print $2}')%"
    log "INFO" "Disco: $(df -h /)"
    
    # Estado de servicios
    log "INFO" "=== Estado de Servicios ==="
    log "INFO" "- n8n: $(curl -s http://localhost:5678/healthz || echo 'No responde')"
    log "INFO" "- Ollama: $(curl -s http://localhost:11434/api/tags || echo 'No responde')"
    log "INFO" "- Modelos cargados: $(curl -s http://localhost:11434/api/tags | jq '.models[].name' 2>/dev/null || echo 'No disponible')"
    log "INFO" "=================================="
}

# Inicio del script principal
log "INFO" "=== Iniciando servicios ==="

# Instalar dependencias necesarias para monitoreo
log "INFO" "Instalando dependencias de monitoreo..."
npm install --quiet systeminformation node-fetch || {
    log "ERROR" "Error instalando dependencias"
    exit 1
}

# Iniciar Ollama
log "INFO" "Iniciando Ollama..."
mkdir -p /root/.ollama
chmod 755 /root/.ollama

# Configurar host de Ollama según el entorno
if [ ! -z "$RENDER" ]; then
    export OLLAMA_HOST="127.0.0.1"
    log "INFO" "Configurando Ollama para Render (localhost)"
else
    export OLLAMA_HOST="0.0.0.0"
    log "INFO" "Configurando Ollama para acceso externo"
fi

OLLAMA_ORIGINS=* ollama serve &
OLLAMA_PID=$!

# Verificar Ollama
if ! check_service "Ollama" "http://localhost:11434/api/tags" 30; then
    log "ERROR" "Ollama no pudo iniciarse correctamente"
    exit 1
fi

# Iniciar el servidor de métricas
log "INFO" "Iniciando servidor de métricas..."
node /app/backend/server.js &
METRICS_PID=$!

# Verificar servidor de métricas
if ! check_service "Metrics Server" "http://localhost:3000/health" 10; then
    log "ERROR" "El servidor de métricas no pudo iniciarse"
    exit 1
fi

# Programar verificación periódica
(while true; do 
    check_system_status
    sleep 60
done) &
MONITOR_PID=$!

# Registrar PIDs para limpieza
echo $OLLAMA_PID > /var/run/ollama.pid
echo $METRICS_PID > /var/run/metrics.pid
echo $MONITOR_PID > /var/run/monitor.pid

# Configurar trap para limpieza
cleanup() {
    log "INFO" "Deteniendo servicios..."
    kill $(cat /var/run/*.pid 2>/dev/null) 2>/dev/null || true
    rm -f /var/run/*.pid
    log "INFO" "Limpieza completada"
}
trap cleanup EXIT

# Esperar a que los servicios estén funcionando
log "INFO" "Esperando a que todos los servicios estén funcionando..."
wait $OLLAMA_PID $METRICS_PID $MONITOR_PID 