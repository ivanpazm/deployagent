# Sistema de Despliegue - n8n con Ollama

## Estructura del Sistema

El sistema está compuesto por dos servicios principales que se ejecutan en contenedores Docker: 

- **n8n**: Plataforma de automatización de flujos de trabajo
- **Ollama**: Servicio de modelos de lenguaje

### Modelos Disponibles
- **llama2:13b**: Modelo general para tareas de lenguaje
- **codellama:7b**: Especializado en código y tareas técnicas
- **mistral:7b**: Modelo eficiente para tareas generales

### Casos de Uso
1. **Asistente de Código**
   - Usar codellama:7b para:
     - Revisión de código
     - Generación de tests
     - Documentación técnica

2. **Procesamiento de Lenguaje Natural**
   - Usar llama2:13b para:
     - Análisis de texto
     - Generación de contenido
     - Resúmenes

3. **Tareas Rápidas**
   - Usar mistral:7b para:
     - Respuestas cortas
     - Clasificación
     - Análisis básico

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

# CID (Continuous Integration Dashboard)

## Descripción General
Dashboard de monitoreo que integra n8n y Ollama con una interfaz interactiva construida en React.

## Componentes Principales

### Frontend (React)
- **Dashboard**: Vista principal que integra todos los componentes
- **SystemMetrics**: Monitoreo de CPU, Memoria y Disco
- **AIStatus**: Estado de servicios n8n y Ollama
- **WorkflowStatus**: Estado de flujos de trabajo
- **ChatBot**: Interfaz de chat con Ollama

### Backend
- Node.js + Express
- Nginx como proxy inverso
- API para métricas y chat

## Inicio Rápido

### Requisitos
- Node.js ≥ 20.x
- Docker Desktop
- PowerShell 5.1+

### Instalación y Ejecución
1. Clonar el repositorio
2. Ejecutar el script de construcción:
```powershell
.\monitoring\scripts\build.ps1 -CleanAll -BuildLocal -BuildDocker -StartServices
```

### Acceso a Servicios
- Dashboard: http://localhost
- n8n: http://localhost:5678
- Ollama: http://localhost:11434

## Scripts Disponibles

### Script Principal (build.ps1)
```powershell
# Construcción completa
.\monitoring\scripts\build.ps1 -CleanAll -BuildLocal -BuildDocker -StartServices

# Solo construcción local
.\monitoring\scripts\build.ps1 -BuildLocal

# Solo Docker
.\monitoring\scripts\build.ps1 -BuildDocker -StartServices
```

### Gestión de Puertos
```powershell
# Detener servicios
.\monitoring\scripts\ports.ps1 -Stop

# Iniciar servicios
.\monitoring\scripts\ports.ps1 -Start
```

### Docker
```powershell
# Limpiar recursos
docker-compose down --remove-orphans
docker system prune -f

# Construcción optimizada
$env:DOCKER_BUILDKIT=1
docker-compose build --parallel
```

## Solución de Problemas

### Errores Comunes
1. **Permisos**: Ejecutar PowerShell como administrador
2. **Puertos en uso**: Ejecutar `.\monitoring\scripts\ports.ps1 -Stop`
3. **Docker**: Reiniciar con `docker-compose down && docker system prune -f`

### Logs
- Frontend: `/var/log/nginx/access.log`
- Backend: Consola de Node.js
- Docker: `docker-compose logs`

## Estructura del Proyecto
```
monitoring/
├── frontend/          # Aplicación React
├── backend/           # API Node.js
├── docker/           # Configuración Docker
└── scripts/          # Scripts de automatización
```

## Modelos de IA Disponibles
- **llama2:13b**: Uso general
- **codellama:7b**: Tareas de código
- **mistral:7b**: Respuestas rápidas