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
N8N_ENCRYPTION_KEY=dK8xJ2mP9nQ7vR4tL5wC3bE6yH8uM1pX  # Clave por defecto

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

# Guía de Despliegue en Fly.io

## Requisitos Previos
1. Instalar Flyctl
```bash
# Windows (PowerShell como administrador)
iwr https://fly.io/install.ps1 -useb | iex

# MacOS/Linux
curl -L https://fly.io/install.sh | sh
```

2. Autenticarse
```bash
fly auth signup  # Para nueva cuenta
# o
fly auth login   # Para cuenta existente
```

## Pasos de Despliegue

1. Crear volúmenes persistentes
```bash
fly volumes create n8n_data --size 1 --region mad
fly volumes create ollama_data --size 10 --region mad
```

2. Configurar secretos
```bash
fly secrets set N8N_BASIC_AUTH_USER=admin
fly secrets set N8N_BASIC_AUTH_PASSWORD=<contraseña-segura>
fly secrets set N8N_ENCRYPTION_KEY=$(openssl rand -hex 24)
```

3. Desplegar la aplicación
```bash
fly launch
fly deploy
```

4. Verificar el despliegue
```bash
fly status
fly logs
```

## Variables de Entorno
- `N8N_BASIC_AUTH_USER`: Usuario admin
- `N8N_BASIC_AUTH_PASSWORD`: Contraseña segura
- `N8N_ENCRYPTION_KEY`: Clave de encriptación
- `OLLAMA_ORIGINS`: Se configura automáticamente

## Monitoreo
```bash
# Ver logs en tiempo real
fly logs

# Estado de la aplicación
fly status

# Información de volúmenes
fly volumes list
```

## Backups
1. N8N Workflows
```bash
fly ssh console
cd /home/node/.n8n
tar czf /backup/n8n-backup.tar.gz .
exit
fly sftp get /backup/n8n-backup.tar.gz
```

2. Modelos Ollama
```bash
fly ssh console
cd /root/.ollama
tar czf /backup/ollama-backup.tar.gz .
exit
fly sftp get /backup/ollama-backup.tar.gz
```

### Opción 1: Despliegue Automatizado
```bash
# Windows PowerShell
./deploy-to-fly.ps1

# Linux/MacOS
chmod +x deploy-to-fly.sh
./deploy-to-fly.sh
```

### Opción 2: Despliegue Manual
```bash
# Windows PowerShell
./deploy-to-fly.ps1

# Linux/MacOS
chmod +x deploy-to-fly.sh
./deploy-to-fly.sh
```

## Opciones de Despliegue

### Google Cloud Platform (Recomendado)

#### Requisitos Previos
1. Cuenta en Google Cloud Platform
2. Google Cloud SDK instalado
3. Terraform instalado

#### Pasos de Despliegue
```bash
# Windows PowerShell
./deploy-to-gcp.ps1 -project_id "tu-proyecto-id"

# Linux/MacOS
chmod +x deploy-to-gcp.sh
./deploy-to-gcp.sh "tu-proyecto-id"
```

#### Recursos Creados
- VPC con subnet
- Instancia (4 vCPUs, 16GB RAM)
- Volúmenes para datos
- Reglas de firewall (puertos 80, 22)

#### Verificación
```bash
# Verificar estado
terraform show

# Ver logs
ssh opc@<instance_ip> "docker-compose logs -f"
```

### Fly.io (Alternativa)