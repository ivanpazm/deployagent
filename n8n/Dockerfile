# Usa la imagen base de n8n
ARG NODE_VERSION=20
FROM n8nio/base:${NODE_VERSION}

# Verifica que la versión de n8n esté especificada
ARG N8N_VERSION
RUN if [ -z "$N8N_VERSION" ] ; then echo "The N8N_VERSION argument is missing!" ; exit 1; fi

# Metadatos de la imagen
LABEL org.opencontainers.image.title="n8n"
LABEL org.opencontainers.image.description="Workflow Automation Tool"
LABEL org.opencontainers.image.source="https://github.com/n8n-io/n8n"
LABEL org.opencontainers.image.url="https://n8n.io"
LABEL org.opencontainers.image.version=${N8N_VERSION}

# Variables de entorno
ENV N8N_VERSION=${N8N_VERSION}
ENV NODE_ENV=production
ENV N8N_RELEASE_TYPE=stable

# Instalación de n8n
RUN set -eux; \
    npm install -g --omit=dev n8n@${N8N_VERSION} --ignore-scripts && \
    npm rebuild --prefix=/usr/local/lib/node_modules/n8n sqlite3 && \
    find /usr/local/lib/node_modules/n8n -type f -name "*.ts" -o -name "*.js.map" -o -name "*.vue" | xargs rm -f && \
    rm -rf /root/.npm

# Configuración de la entrada del contenedor
COPY docker-entrypoint.sh /

# Permisos y usuario
RUN \
    mkdir .n8n && \
    chown node:node .n8n
ENV SHELL /bin/sh
USER node
ENTRYPOINT ["tini", "--", "/docker-entrypoint.sh"]
