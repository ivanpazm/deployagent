# Script de despliegue para Google Cloud
param(
    [string]$project_id,
    [string]$region = "europe-west1"
)

Write-Host "Iniciando despliegue en Google Cloud..." -ForegroundColor Green

# Verificar gcloud CLI
if (!(Get-Command gcloud -ErrorAction SilentlyContinue)) {
    Write-Host "Instalando Google Cloud SDK..." -ForegroundColor Yellow
    Write-Host "Por favor, instala Google Cloud SDK desde: https://cloud.google.com/sdk/docs/install"
    exit 1
}

# Verificar Terraform
if (!(Get-Command terraform -ErrorAction SilentlyContinue)) {
    Write-Host "Instalando Terraform..." -ForegroundColor Yellow
    Write-Host "Por favor, instala Terraform desde: https://www.terraform.io/downloads"
    exit 1
}

# Login en GCP
Write-Host "Configurando Google Cloud..." -ForegroundColor Blue
gcloud auth application-default login
gcloud config set project $project_id

# Inicializar Terraform
Write-Host "Inicializando Terraform..." -ForegroundColor Blue
Set-Location terraform
terraform init

# Aplicar configuración
Write-Host "Desplegando infraestructura..." -ForegroundColor Green
terraform apply -var="project_id=$project_id" -var="region=$region" -auto-approve 