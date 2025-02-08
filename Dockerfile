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
    su-exec \
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
    chmod 600 /home/node/.n8n/.n8n/config && \
    chmod 600 /home/node/.n8n/.n8n/crash.journal

# Verificar la instalación de n8n
RUN which n8n && \
    ls -la $(which n8n) && \
    ls -la /usr/local/lib/node_modules/n8n/bin/ || true && \
    ls -la /usr/local/bin/n8n || true

# Script de entrada combinado
COPY docker-entrypoint.sh /docker-entrypoint.sh
RUN dos2unix /docker-entrypoint.sh && \
    chmod +x /docker-entrypoint.sh

WORKDIR /home/node
# En local exponemos ambos puertos
EXPOSE 5678 11434

ENV N8N_HOST=0.0.0.0 \
    N8N_PROTOCOL=http \
    NODE_ENV=production \
    N8N_LOG_LEVEL=verbose \
    N8N_USER_FOLDER=/home/node/.n8n \
    N8N_DIAGNOSTICS_ENABLED=false \
    N8N_METRICS_ENABLED=false \
    N8N_SKIP_WEBHOOK_DEREGISTRATION=true \
    N8N_ENFORCE_SETTINGS_FILE_PERMISSIONS=true \
    # OLLAMA_HOST se configura en runtime \
    OLLAMA_ORIGINS=*

USER root
ENTRYPOINT ["tini", "--", "/docker-entrypoint.sh"] 