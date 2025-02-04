FROM ubuntu:latest

# Instalación de herramientas necesarias
RUN apt-get update && apt-get install -y \
    curl \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Instala Ollama desde el script oficial
RUN curl https://ollama.com/install.sh | sh

# Crear directorio para los modelos de Ollama
RUN mkdir -p /root/.ollama

# Copiar y configurar el script de inicio
COPY docker-entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

# Puerto que expone la API de Ollama
EXPOSE 11434

# Usar el script de entrada personalizado
ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
