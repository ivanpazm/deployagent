# Usar la imagen oficial de n8n
FROM n8nio/n8n:1.76.3

# Instalación de herramientas necesarias
USER root
RUN apk add --no-cache \
    curl \
    tini \
    ca-certificates \
    dos2unix \
    file \
    bash \
    procps \
    wget \
    gnupg && \
    # Descargar Ollama precompilado
    wget https://github.com/ollama/ollama/releases/download/v0.1.27/ollama-linux-amd64 && \
    mv ollama-linux-amd64 /usr/local/bin/ollama && \
    chmod +x /usr/local/bin/ollama && \
    # Configurar directorios
    mkdir -p /root/.ollama && \
    chmod 755 /root/.ollama && \
    mkdir -p /home/node/.n8n/.n8n && \
    echo '{}' > /home/node/.n8n/.n8n/config && \
    touch /home/node/.n8n/.n8n/crash.journal && \
    chown -R node:node /home/node/.n8n && \
    chmod -R 750 /home/node/.n8n && \
    chmod 640 /home/node/.n8n/.n8n/config && \
    chmod 640 /home/node/.n8n/.n8n/crash.journal

# Script de entrada combinado
COPY docker-entrypoint.sh /docker-entrypoint.sh
RUN dos2unix /docker-entrypoint.sh && \
    chmod +x /docker-entrypoint.sh

# Verificar el archivo
RUN ls -la /docker-entrypoint.sh && \
    file /docker-entrypoint.sh

# Configurar usuario y directorio de trabajo
WORKDIR /home/node

# Exponer puertos
EXPOSE 5678 11434

# Variables de entorno para n8n
ENV N8N_HOST=0.0.0.0
ENV N8N_PROTOCOL=http
ENV N8N_PORT=5678
ENV NODE_ENV=production
ENV N8N_LOG_LEVEL=verbose
ENV N8N_USER_FOLDER=/home/node/.n8n
ENV N8N_DIAGNOSTICS_ENABLED=false
ENV N8N_METRICS_ENABLED=false
ENV N8N_SKIP_WEBHOOK_DEREGISTRATION=true
ENV N8N_ENFORCE_SETTINGS_FILE_PERMISSIONS=true

# Usar root para poder iniciar Ollama pero cambiar a node para n8n
USER root
ENTRYPOINT ["tini", "--", "/docker-entrypoint.sh"] 