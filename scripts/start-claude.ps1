#!/usr/bin/env pwsh
param(
    [switch]$Shell,
    [switch]$AutoStart,
    [switch]$Rebuild
)

Write-Host "Starting Claude Code Docker Environment..." -ForegroundColor Green

# Check if required SMB variables are set
$requiredVars = @('SMB_SERVER', 'SMB_SHARE', 'SMB_USERNAME', 'SMB_PASSWORD')
$missingVars = @()

foreach ($var in $requiredVars) {
    if (-not (Get-Content .env -ErrorAction SilentlyContinue | Select-String "^$var=")) {
        $missingVars += $var
    }
}

if ($missingVars.Count -gt 0) {
    Write-Warning "Missing required SMB configuration variables: $($missingVars -join ', ')"
    Write-Host "Please add these to your .env file:"
    foreach ($var in $missingVars) {
        Write-Host "  $var=your-value-here"
    }
    exit 1
}
if (-not (Test-Path ".env")) {
    Write-Warning "No .env file found. Creating example..."
    @"
# Required: Anthropic API Key
ANTHROPIC_API_KEY=your_api_key_here

# Optional: Git Configuration  
GIT_USER_NAME=Your Name
GIT_USER_EMAIL=your.email@example.com

# Optional: Auto-start Claude Code (true/false)
AUTO_START_CLAUDE=false
"@ | Out-File ".env" -Encoding UTF8
    Write-Host "Please edit .env file with your settings and run again." -ForegroundColor Yellow
    exit 1
}

# Rebuild if requested
if ($Rebuild) {
    Write-Host "Rebuilding container..." -ForegroundColor Yellow
    docker-compose down
    docker-compose build --no-cache
}

# Set auto-start if requested
if ($AutoStart) {
    $env:AUTO_START_CLAUDE = "true"
}

# Start the container
Write-Host "Starting container..." -ForegroundColor Blue
docker-compose up -d

# Wait a moment for container to be ready
Start-Sleep 2

# Check if container is running
$containerStatus = docker-compose ps -q claude-dev
if (-not $containerStatus) {
    Write-Error "Failed to start container"
    exit 1
}

Write-Host "Container started successfully!" -ForegroundColor Green

if ($Shell) {
    Write-Host "Opening bash shell..." -ForegroundColor Cyan
    docker-compose exec claude-dev bash
} elseif ($AutoStart) {
    Write-Host "Claude Code is starting automatically..." -ForegroundColor Magenta
    Write-Host "To connect: docker-compose exec claude-dev bash" -ForegroundColor Gray
} else {
    # Default behavior: Start Claude Code interactively
    Write-Host "Starting Claude Code..." -ForegroundColor Cyan
    docker-compose exec claude-dev claude
}