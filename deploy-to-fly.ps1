# Script de despliegue para Windows
param(
    [string]$region = "mad",
    [string]$app_name = "n8n-ollama"
)

# Iniciar despliegue
Write-Host "Iniciando despliegue en Fly.io..." -ForegroundColor Green

# Verificar y configurar Flyctl
if (!(Get-Command flyctl -ErrorAction SilentlyContinue)) {
    Write-Host "Instalando Flyctl..." -ForegroundColor Yellow
    iwr https://fly.io/install.ps1 -useb | iex
    
    # Actualizar PATH para incluir Flyctl
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
}

# Verificar la instalación
if (!(Get-Command flyctl -ErrorAction SilentlyContinue)) {
    Write-Host "Error: No se pudo instalar Flyctl. Por favor, instálalo manualmente:" -ForegroundColor Red
    Write-Host "1. Visita: https://fly.io/docs/hands-on/install-flyctl/" -ForegroundColor Yellow
    Write-Host "2. Reinicia PowerShell después de la instalación" -ForegroundColor Yellow
    exit 1
}

# Login si es necesario
try {
    flyctl auth whoami
    if ($LASTEXITCODE -ne 0) {
        Write-Host "Por favor, inicia sesion en Fly.io..." -ForegroundColor Yellow
        flyctl auth login
    }
} catch {
    Write-Host "Por favor, inicia sesion en Fly.io..." -ForegroundColor Yellow
    flyctl auth login
}

# Crear la aplicación
Write-Host "Creando aplicacion en Fly.io..." -ForegroundColor Blue
try {
    flyctl apps create $app_name --machines
} catch {
    Write-Host "La aplicacion ya existe, continuando..." -ForegroundColor Yellow
}

# Crear volúmenes
Write-Host "Creando volumenes persistentes..." -ForegroundColor Blue
try {
    flyctl volumes create n8n_data --size 1 --region $region
    flyctl volumes create ollama_data --size 10 --region $region
} catch {
    Write-Host "Los volumenes ya existen, continuando..." -ForegroundColor Yellow
}

# Configurar secretos
Write-Host "Configurando secretos..." -ForegroundColor Blue
$encryption_key = -join ((48..57) + (97..122) | Get-Random -Count 32 | ForEach-Object {[char]$_})
flyctl secrets set N8N_ENCRYPTION_KEY=$encryption_key

# Desplegar
Write-Host "Desplegando aplicacion..." -ForegroundColor Green
flyctl deploy

# Verificar despliegue
Write-Host "Verificando despliegue..." -ForegroundColor Blue
flyctl status
flyctl logs

# Mostrar información
Write-Host "Despliegue completado!" -ForegroundColor Green
Write-Host "Informacion importante:" -ForegroundColor Yellow
Write-Host "URL: https://$app_name.fly.dev" -ForegroundColor Cyan

# Limpiar variables sensibles
$encryption_key = $null
[System.GC]::Collect() 