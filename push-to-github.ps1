# Obtener timestamp corto (formato: MMDD_HHMM)
$TIMESTAMP = Get-Date -Format "MMdd_HHmm"

# Añadir todos los cambios
git add .

# Crear el commit con el timestamp
git commit -m "feat: change LLM model to qwen:0.5b [$TIMESTAMP]

- Updated model from llama3.2:1b to qwen:0.5b
- Updated deployment guide documentation
- Lighter and faster model for better performance
- Updated render.yaml configuration
- Fixed file permissions
- Added encryption key
- Fixed permissions for n8n execution"

# Subir los cambios
git push -f origin main

Write-Host "Cambios subidos a GitHub con timestamp: $TIMESTAMP" 