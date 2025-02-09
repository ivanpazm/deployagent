# Script de despliegue para Oracle Cloud
param(
    [string]$region = "mad",  # Madrid
    [string]$compartment_name = "n8n-ollama"
)

Write-Host "Iniciando despliegue en Oracle Cloud..." -ForegroundColor Green

# Verificar OCI CLI
if (!(Get-Command oci -ErrorAction SilentlyContinue)) {
    Write-Host "Instalando Oracle Cloud CLI..." -ForegroundColor Yellow
    Write-Host "Por favor, instala Oracle Cloud CLI desde: https://docs.oracle.com/en-us/iaas/Content/API/SDKDocs/cliinstall.htm"
    exit 1
}

# Verificar Terraform
if (!(Get-Command terraform -ErrorAction SilentlyContinue)) {
    Write-Host "Instalando Terraform..." -ForegroundColor Yellow
    Write-Host "Por favor, instala Terraform desde: https://www.terraform.io/downloads"
    exit 1
}

# Login en OCI
Write-Host "Configurando OCI CLI..." -ForegroundColor Blue
oci setup config

# Inicializar Terraform
Write-Host "Inicializando Terraform..." -ForegroundColor Blue
Set-Location terraform
terraform init

# Aplicar configuración
Write-Host "Desplegando infraestructura..." -ForegroundColor Green
terraform apply -auto-approve

# Obtener IP de la instancia
$instance_ip = terraform output instance_ip

# Configurar Docker en la instancia
Write-Host "Configurando instancia..." -ForegroundColor Blue
ssh opc@$instance_ip "sudo yum install -y docker docker-compose"
ssh opc@$instance_ip "sudo systemctl start docker"
ssh opc@$instance_ip "sudo systemctl enable docker"

# Copiar archivos
Write-Host "Copiando archivos de configuración..." -ForegroundColor Blue
scp docker-compose.yml opc@$instance_ip:~/
scp .env.production opc@$instance_ip:~/

# Iniciar servicios
Write-Host "Iniciando servicios..." -ForegroundColor Green
ssh opc@$instance_ip "docker-compose up -d"

Write-Host "Despliegue completado!" -ForegroundColor Green
Write-Host "URL: http://$instance_ip" -ForegroundColor Cyan 