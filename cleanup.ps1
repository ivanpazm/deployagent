$files_to_remove = @(
    "Dockerfile.backend",
    "start.sh",
    "monitor.sh",
    "supervisord.backend.conf",
    "docker-compose.override.yml"
)

$dirs_to_remove = @(
    "monitoring",
    "frontend",
    "backend",
    "nginx",
    ".github",
    "scripts",
    "config",
    "logs"
) 