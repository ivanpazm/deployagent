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
    touch /home/node/.n8n/.n8n/config && \
    touch /home/node/.n8n/.n8n/crash.journal && \
    chown -R node:node /home/node/.n8n && \
    chmod -R 755 /home/node/.n8n && \
    chmod 644 /home/node/.n8n/.n8n/config && \
    chmod 644 /home/node/.n8n/.n8n/crash.journal

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

# Usar root para poder iniciar Ollama pero cambiar a node para n8n
USER root
ENTRYPOINT ["tini", "--", "/docker-entrypoint.sh"] 