# Sistema de Despliegue - n8n con Ollama

## Estructura del Sistema
El sistema está compuesto por dos servicios principales que se ejecutan en contenedores Docker: 

- **n8n**: Plataforma de automatización de flujos de trabajo
- **Ollama**: Servicio de modelos de lenguaje (qwen:0.5b)

## Requisitos
- Docker y Docker Compose
- 4GB RAM mínimo recomendado
- 10GB espacio en disco

## Configuración de Acceso

### En Local (Desarrollo)
- **n8n**: `http://localhost:5678`
- **Ollama API**: `http://localhost:11434/api`
- Ollama es accesible externamente (OLLAMA_HOST=0.0.0.0)

### En Render (Producción)
- **n8n**: `https://deployagent-9.onrender.com`
- **Ollama API**: Solo accesible internamente por n8n
- Ollama solo es accesible localmente (OLLAMA_HOST=127.0.0.1)

## Variables de Entorno

### Variables Requeridas en Render
```
# Variable crítica para diferenciar entorno
RENDER=true

# Variables de n8n
N8N_HOST=0.0.0.0
N8N_PORT=5678  # Será sobreescrito por $PORT en Render
N8N_PROTOCOL=https
N8N_USER_FOLDER=/home/node/.n8n
NODE_ENV=production
N8N_LOG_LEVEL=verbose
N8N_DIAGNOSTICS_ENABLED=false
N8N_METRICS_ENABLED=false
N8N_SKIP_WEBHOOK_DEREGISTRATION=true
N8N_ENFORCE_SETTINGS_FILE_PERMISSIONS=true
N8N_ENCRYPTION_KEY=your-secret-key-min-32-chars-long  # Cambiar en producción

# Variables de Ollama
OLLAMA_ORIGINS=*
OLLAMA_HOST=127.0.0.1  # Crítico: En Render debe ser 127.0.0.1
```

### Variables Automáticas en Render
- `PORT`: Asignado automáticamente por Render (sobreescribe N8N_PORT)

### Notas Importantes
- El valor de N8N_ENCRYPTION_KEY debe ser único y seguro en producción
- El puerto en Render es dinámico y se maneja automáticamente
- OLLAMA_HOST debe ser 127.0.0.1 en Render para seguridad

## Modelo de Ollama
Por defecto se usa qwen:0.5b. Para cambiar el modelo, modifica `docker-entrypoint.sh`.

## Volúmenes
- `n8n_data`: Datos de n8n
- `ollama_data`: Modelos y datos de Ollama