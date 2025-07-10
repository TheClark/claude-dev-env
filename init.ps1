# Claude Dev Environment - Interactive Setup Script
# This script guides you through setting up your Claude development environment

param(
    [switch]$SkipPrompts,
    [switch]$Help
)

$ErrorActionPreference = "Stop"
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path

# ASCII Art Banner
function Show-Banner {
    Write-Host @"

    ╔═══════════════════════════════════════════════════════╗
    ║         Claude Dev Environment Setup Wizard           ║
    ╚═══════════════════════════════════════════════════════╝
    
"@ -ForegroundColor Cyan
}

# Colors for output
function Write-ColorOutput {
    param(
        [string]$Message,
        [string]$Color = "White"
    )
    Write-Host $Message -ForegroundColor $Color
}

# Show usage
function Show-Usage {
    Write-Host @"
Usage: init.ps1 [OPTIONS]

Interactive setup wizard for Claude development environment

OPTIONS:
    -SkipPrompts    Use defaults where possible
    -Help           Show this help message

This script will:
1. Create your .env configuration file
2. Set up your credentials (GitHub, Anthropic)
3. Build the Docker image
4. Start the container with Claude Code ready to use

"@
}

if ($Help) {
    Show-Usage
    exit 0
}

# Clear screen and show banner
Clear-Host
Show-Banner

Write-ColorOutput "Welcome to Claude Dev Environment Setup!" "Green"
Write-ColorOutput "This wizard will help you get started in just a few minutes.`n" "White"

# Check prerequisites
Write-ColorOutput "Checking prerequisites..." "Yellow"

# Check Docker
try {
    $dockerVersion = docker --version
    Write-ColorOutput "[OK] Docker is installed: $dockerVersion" "Green"
} catch {
    Write-ColorOutput "[ERROR] Docker is not installed or not in PATH" "Red"
    Write-ColorOutput "Please install Docker Desktop from: https://www.docker.com/products/docker-desktop" "Yellow"
    exit 1
}

# Check if Docker is running
try {
    docker ps | Out-Null
    Write-ColorOutput "[OK] Docker is running" "Green"
} catch {
    Write-ColorOutput "[ERROR] Docker is not running" "Red"
    Write-ColorOutput "Please start Docker Desktop and try again" "Yellow"
    exit 1
}

Write-Host ""

# Get project information
Write-ColorOutput "=== Project Configuration ===" "Magenta"

# Project name
$projectName = Read-Host "Enter project name (default: claude-dev)"
if ([string]::IsNullOrWhiteSpace($projectName)) {
    $projectName = "claude-dev"
}

# Project path
Write-ColorOutput "`nWhere is your project located?" "White"
Write-ColorOutput "Examples:" "Gray"
Write-ColorOutput "  - C:\Users\YourName\projects\my-project" "Gray"
Write-ColorOutput "  - ..\my-project (relative path)" "Gray"
Write-ColorOutput "  - . (current directory)" "Gray"

$projectPath = Read-Host "`nEnter project path"
if ([string]::IsNullOrWhiteSpace($projectPath)) {
    $projectPath = ".."
}

# Resolve relative paths
if (-not [System.IO.Path]::IsPathRooted($projectPath)) {
    $resolvedPath = Join-Path $ScriptDir $projectPath
    $resolvedPath = (Resolve-Path $resolvedPath -ErrorAction SilentlyContinue).Path
    if ($resolvedPath) {
        Write-ColorOutput "Resolved to: $resolvedPath" "Gray"
        $projectPath = $resolvedPath
    }
}

# Verify path exists
if (-not (Test-Path $projectPath)) {
    Write-ColorOutput "[ERROR] Project path does not exist: $projectPath" "Red"
    $create = Read-Host "Create this directory? (y/n)"
    if ($create -eq 'y') {
        New-Item -ItemType Directory -Path $projectPath -Force | Out-Null
        Write-ColorOutput "[OK] Directory created" "Green"
    } else {
        exit 1
    }
}

Write-Host ""

# Get credentials
Write-ColorOutput "=== Credentials Setup ===" "Magenta"
Write-ColorOutput "Leave blank to skip (you can add these later)`n" "Gray"

# Git configuration
$gitUserName = Read-Host "Git user name"
$gitUserEmail = Read-Host "Git user email"

# GitHub token
Write-ColorOutput "`nGitHub Personal Access Token (for gh CLI)" "White"
Write-ColorOutput "Create one at: https://github.com/settings/tokens" "Gray"
$githubToken = Read-Host "GitHub token" -AsSecureString
$githubTokenPlain = if ($githubToken.Length -gt 0) {
    [System.Runtime.InteropServices.Marshal]::PtrToStringAuto(
        [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($githubToken)
    )
} else { "" }

# Anthropic API key
Write-ColorOutput "`nAnthropic API Key (for Claude API access)" "White"
Write-ColorOutput "Get one at: https://console.anthropic.com/settings/keys" "Gray"
$anthropicKey = Read-Host "Anthropic API key" -AsSecureString
$anthropicKeyPlain = if ($anthropicKey.Length -gt 0) {
    [System.Runtime.InteropServices.Marshal]::PtrToStringAuto(
        [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($anthropicKey)
    )
} else { "" }

Write-Host ""

# Create .env file
Write-ColorOutput "=== Creating Configuration ===" "Magenta"

$envContent = @"
# Claude Development Environment Configuration
# Generated by init.ps1 on $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")

# Project Configuration
PROJECT_NAME=$projectName
PROJECT_PATH=$projectPath

# Git Configuration
GIT_USER_NAME=$gitUserName
GIT_USER_EMAIL=$gitUserEmail

# API Keys and Tokens
GITHUB_TOKEN=$githubTokenPlain
ANTHROPIC_API_KEY=$anthropicKeyPlain

# Development Environment
NODE_ENV=development
PYTHON_ENV=development
DEBUG=true

# Resource Limits
CPU_LIMIT=4
MEMORY_LIMIT=8G
CPU_RESERVATION=2
MEMORY_RESERVATION=4G
"@

$envPath = Join-Path $ScriptDir ".env"
# Save without BOM
[System.IO.File]::WriteAllText($envPath, $envContent, [System.Text.UTF8Encoding]::new($false))

Write-ColorOutput "[OK] Configuration saved to .env" "Green"

# Ask about building
Write-Host ""
Write-ColorOutput "=== Docker Setup ===" "Magenta"
Write-ColorOutput "Ready to build the Docker image." "White"
Write-ColorOutput "This will take 2-3 minutes on first run.`n" "Gray"

$proceed = Read-Host "Build and start now? (y/n)"
if ($proceed -ne 'y') {
    Write-ColorOutput "`nSetup complete! To start later, run:" "Green"
    Write-ColorOutput "  cd $ScriptDir" "Cyan"
    Write-ColorOutput "  .\scripts\start-claude.ps1" "Cyan"
    exit 0
}

# Build and start
Write-Host ""
Write-ColorOutput "Building Docker image..." "Yellow"
Set-Location $ScriptDir

# Build the image directly with Docker to avoid compose path issues
# Use project-specific image name to avoid conflicts
docker build -f Dockerfile -t "${projectName}-claude:latest" .

if ($LASTEXITCODE -ne 0) {
    Write-ColorOutput "[ERROR] Build failed" "Red"
    exit 1
}

Write-ColorOutput "[OK] Docker image built successfully!" "Green"

# Start the container
Write-Host ""
Write-ColorOutput "Starting Claude development environment..." "Yellow"

# Create a new PowerShell process to run the container
$startScript = Join-Path $ScriptDir "scripts\start-claude.ps1"
$startCommand = "powershell -ExecutionPolicy Bypass -NoExit -File `"$startScript`""

Write-ColorOutput "`n=== Setup Complete! ===" "Green"
Write-ColorOutput "Claude Code is starting in a new window..." "White"
Write-ColorOutput "`nIn the new window, you can run:" "Cyan"
Write-ColorOutput "  claude --help     # See Claude Code options" "Gray"
Write-ColorOutput "  claude           # Start Claude Code" "Gray"
Write-ColorOutput "`nYour project is mounted at: /workspace" "White"

# Start in new window
Start-Process powershell -ArgumentList "-ExecutionPolicy", "Bypass", "-NoExit", "-File", "`"$startScript`""

Write-Host ""
Write-ColorOutput "Happy coding! 🚀" "Green"