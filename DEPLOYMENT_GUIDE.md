# Sistema de Despliegue - n8n con Ollama

## Estructura del Sistema

El sistema está compuesto por dos servicios principales que se ejecutan en contenedores Docker: 

- **n8n**: Plataforma de automatización de flujos de trabajo
- **Ollama**: Servicio de modelos de lenguaje

## Configuración de Acceso

### En Local (Desarrollo)
- **n8n**: `http://localhost:5678`
- **Ollama API**: `http://localhost:11434/api`

### En Render (Producción)
- **n8n**: `https://deployagent-9.onrender.com`
- **Ollama API**: Solo accesible internamente por n8n

## Variables de Entorno

### Variables Requeridas en Render

# Variable para detectar que estamos en Render
RENDER=true

# Variables de n8n
N8N_HOST=0.0.0.0
N8N_PROTOCOL=https
N8N_USER_FOLDER=/home/node/.n8n
N8N_DIAGNOSTICS_ENABLED=false
N8N_METRICS_ENABLED=false
N8N_SKIP_WEBHOOK_DEREGISTRATION=true
N8N_ENFORCE_SETTINGS_FILE_PERMISSIONS=true

# Variables de Ollama
OLLAMA_ORIGINS=*

### Variables Automáticas
El sistema configura automáticamente:

# En Render
RENDER=true              # Detecta automáticamente si estamos en Render
PORT=<puerto-asignado>   # Asignado automáticamente por Render

## Desarrollo Local

### Requisitos
- Docker
- Docker Compose

### Iniciar el Sistema
```bash
docker-compose up
```

## Pruebas de Funcionamiento

### Verificar n8n
- Local: Abre `http://localhost:5678` en tu navegador
- Render: Abre `https://deployagent-9.onrender.com` en tu navegador

### Verificar Ollama
- Local: `curl http://localhost:11434/api/tags`
- Render: Ollama solo es accesible internamente por n8n