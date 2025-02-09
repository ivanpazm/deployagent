# Usar la imagen oficial de n8n
FROM ollama/ollama:latest AS ollama
FROM ubuntu:22.04

# Instalación de herramientas necesarias
USER root
RUN apt-get update && apt-get install -y \
    curl \
    wget \
    python3 \
    ca-certificates \
    gosu \
    procps \
    bash \
    uuid-runtime \
    openssl \
    && rm -rf /var/lib/apt/lists/*

# Instalar Node.js y npm
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - && \
    apt-get install -y nodejs && \
    # Instalar una versión específica de npm compatible
    npm install -g npm@10.2.4 && \
    rm -rf /var/lib/apt/lists/*

# Crear directorios necesarios
RUN mkdir -p /usr/local/bin /lib/x86_64-linux-gnu /data

# Copiar Ollama desde la imagen oficial
COPY --from=ollama /usr/bin/ollama /usr/local/bin/ollama

# Copiar solo las bibliotecas necesarias de Ollama
COPY --from=ollama /usr/lib/x86_64-linux-gnu/libstdc++.so* /usr/lib/x86_64-linux-gnu/
COPY --from=ollama /usr/lib/x86_64-linux-gnu/libgcc_s.so* /usr/lib/x86_64-linux-gnu/

# Asegurar permisos y verificar el binario
RUN chmod 755 /usr/local/bin/ollama

# Crear grupo y usuario node
RUN groupadd -r node && \
    useradd -r -u 1000 -g node -d /home/node -m -s /bin/bash node

# Configurar directorios y n8n
RUN \
    # Configurar directorios en una sola capa
    mkdir -p /root/.ollama /home/node/.n8n/.n8n && \
    chmod 755 /root/.ollama && \
    echo '{}' > /home/node/.n8n/.n8n/config && \
    touch /home/node/.n8n/.n8n/crash.journal && \
    chown -R node:node /home/node/.n8n && \
    chmod -R 750 /home/node/.n8n && \
    # Asegurar que n8n está instalado correctamente
    npm install -g n8n@1.76.1 --legacy-peer-deps && \
    # Limpiar caché
    npm cache clean --force && \
    rm -rf /tmp/*

# Arreglar problema con libstdc++
RUN cd /usr/lib/x86_64-linux-gnu && \
    rm -f libstdc++.so.6 && \
    ln -s libstdc++.so.6.* libstdc++.so.6

# Script de entrada combinado
COPY docker-entrypoint.sh /docker-entrypoint.sh
RUN chmod +x /docker-entrypoint.sh && \
    chmod +x $(which n8n) && \
    # Verificar instalación de N8N
    n8n --version

WORKDIR /home/node
# En local exponemos ambos puertos
EXPOSE 5678 11434

ENV N8N_HOST=0.0.0.0 \
    N8N_PROTOCOL=http \
    NODE_ENV=production \
    N8N_LOG_LEVEL=verbose \
    N8N_USER_FOLDER=/home/node/.n8n \
    N8N_PORT=5678 \
    N8N_DIAGNOSTICS_ENABLED=false \
    N8N_METRICS_ENABLED=false \
    N8N_SKIP_WEBHOOK_DEREGISTRATION=true \
    N8N_ENFORCE_SETTINGS_FILE_PERMISSIONS=true \
    # Configuración de Ollama
    OLLAMA_HOST=0.0.0.0 \
    OLLAMA_ORIGINS=* \
    OLLAMA_SKIP_GPU_DETECTION=true \
    OLLAMA_CPU_ONLY=true \
    OLLAMA_MODELS="llama3.2:1b" \
    CGO_ENABLED=0

# Asegurarnos de que el script de entrada se ejecuta
ENTRYPOINT ["/bin/bash", "/docker-entrypoint.sh"] 