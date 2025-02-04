FROM ubuntu:latest

# Instala los paquetes necesarios
RUN apt-get update && apt-get install -y \
    python3 \
    python3-pip \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Instala Ollama
RUN curl https://ollama.com/install.sh | sh

# Comando de inicio
CMD ["ollama", "run", "llama3.2:1b"]
