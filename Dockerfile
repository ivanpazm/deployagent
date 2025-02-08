FROM ubuntu:20.04
WORKDIR /app

# Evitar interacción durante la instalación
ENV DEBIAN_FRONTEND=noninteractive

# Instalar dependencias básicas
RUN apt-get update && apt-get install -y \
    curl \
    ca-certificates \
    gnupg \
    build-essential \
    libssl-dev \
    net-tools \
    procps \
    && mkdir -p /etc/apt/keyrings \
    && curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg \
    && echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_20.x nodistro main" | tee /etc/apt/sources.list.d/nodesource.list \
    && apt-get update \
    && apt-get install -y nodejs \
    && npm install -g npm@latest \
    && rm -rf /var/lib/apt/lists/*

# Instalar y configurar Ollama
RUN curl -fsSL https://ollama.com/install.sh | bash && \
    mkdir -p /root/.ollama/models && \
    chmod -R 755 /root/.ollama && \
    chown -R root:root /root/.ollama

# Script de inicialización para descargar el modelo
COPY init-ollama.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/init-ollama.sh

# Crear usuario node para n8n
RUN groupadd -r node && \
    useradd -r -g node -u 1000 node && \
    mkdir -p /home/node/.n8n /home/node/.npm && \
    chown -R node:node /home/node

# Instalar n8n como usuario node
USER node
ENV NPM_CONFIG_PREFIX=/home/node/.npm
RUN npm install -g n8n@1.76.1

# Volver a root para la configuración final
USER root

# Configurar n8n
RUN echo '{ \
    "executions.mode": "regular", \
    "executions.timeout": 3600, \
    "userFolder": "/home/node/.n8n", \
    "encryptionKey": "'$(openssl rand -hex 32)'", \
    "diagnostics.enabled": false \
}' > /home/node/.n8n/config.json && \
chown -R node:node /home/node/.n8n

# Instalar supervisor
RUN apt-get update && apt-get install -y supervisor && \
    rm -rf /var/lib/apt/lists/*

# Copiar configuración de supervisor
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Healthcheck para verificar que los servicios están funcionando
HEALTHCHECK --interval=30s --timeout=30s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:5678/healthz || exit 1

EXPOSE 5678 11434

CMD ["/usr/local/bin/init-ollama.sh"] 