FROM node:18-slim

# Variables de entorno
ARG N8N_VERSION
ENV N8N_VERSION=${N8N_VERSION} \
    NODE_ENV=production \
    N8N_RELEASE_TYPE=stable \
    PATH=/usr/local/lib/node_modules/n8n/bin:$PATH

# Instalación de herramientas necesarias
RUN apt-get update && \
    apt-get install -y \
    dos2unix \
    curl \
    python3 \
    build-essential \
    tini && \
    rm -rf /var/lib/apt/lists/*

# Instalación de n8n
RUN if [ -z "$N8N_VERSION" ] ; then echo "The N8N_VERSION argument is missing!" ; exit 1; fi && \
    npm install -g n8n@${N8N_VERSION} && \
    npm rebuild --prefix=/usr/local/lib/node_modules/n8n sqlite3 && \
    chown -R node:node /usr/local/lib/node_modules/n8n

# Configuración de directorios y permisos
RUN mkdir -p /home/node/.n8n && \
    chown -R node:node /home/node/.n8n && \
    chmod 750 /home/node/.n8n

# Configuración de la entrada del contenedor
COPY ./docker-entrypoint.sh /docker-entrypoint.sh
RUN dos2unix /docker-entrypoint.sh && \
    chmod +x /docker-entrypoint.sh

WORKDIR /home/node
USER node

EXPOSE 5678

ENTRYPOINT ["tini", "--", "/docker-entrypoint.sh"]
