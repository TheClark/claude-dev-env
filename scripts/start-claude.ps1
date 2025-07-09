# Enhanced Claude Code Startup Script for Windows
# PowerShell script to start Claude development container

param(
    [string]$ProjectName = "claude-dev",
    [string]$EnvFile = ".env",
    [switch]$Build,
    [switch]$Rebuild,
    [switch]$Detach,
    [string]$Shell = "/bin/bash",
    [switch]$NoInteractive,
    [switch]$Help
)

# Script configuration
$ErrorActionPreference = "Stop"
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$ProjectRoot = Split-Path -Parent $ScriptDir

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
Usage: start-claude.ps1 [OPTIONS]

Start Claude development container with enhanced tools

OPTIONS:
    -ProjectName NAME      Project name (default: claude-dev)
    -EnvFile FILE         Environment file (default: .env)
    -Build                Build image before starting
    -Rebuild              Force rebuild image
    -Detach               Run in detached mode
    -Shell SHELL          Shell to use (default: /bin/bash)
    -NoInteractive        Don't attach to container
    -Help                 Show this help message

EXAMPLES:
    # Start with default settings
    .\start-claude.ps1
    
    # Start specific project
    .\start-claude.ps1 -ProjectName my-project
    
    # Rebuild and start
    .\start-claude.ps1 -Rebuild
    
    # Start in background
    .\start-claude.ps1 -Detach

"@
}

# Show help if requested
if ($Help) {
    Show-Usage
    exit 0
}

# Change to project root
Set-Location $ProjectRoot

# Load environment file
$EnvFilePath = if ([System.IO.Path]::IsPathRooted($EnvFile)) { $EnvFile } else { Join-Path $ProjectRoot $EnvFile }

if (Test-Path $EnvFilePath) {
    Write-ColorOutput "Loading environment from: $EnvFilePath" "Blue"
    
    # Read and parse .env file
    Get-Content $EnvFilePath | ForEach-Object {
        if ($_ -match '^\s*([^#][^=]+?)\s*=\s*(.*)$') {
            $name = $matches[1].Trim()
            $value = $matches[2].Trim()
            
            # Remove quotes if present
            if ($value -match '^"(.*)"$' -or $value -match "^'(.*)'$") {
                $value = $matches[1]
            }
            
            # Set environment variable
            [Environment]::SetEnvironmentVariable($name, $value, "Process")
        }
    }
} else {
    Write-ColorOutput "Warning: No .env file found at $EnvFilePath" "Yellow"
    Write-ColorOutput "Using default values. Copy .env.example to .env and customize." "Yellow"
}

# Get environment variables
$env:PROJECT_NAME = $ProjectName
$ProjectPath = [Environment]::GetEnvironmentVariable("PROJECT_PATH", "Process")

# Convert Windows path to WSL path if needed
function Convert-ToWSLPath {
    param([string]$WindowsPath)
    
    if (-not $WindowsPath) { return $null }
    
    # If already a WSL path, return as-is
    if ($WindowsPath.StartsWith("/")) { return $WindowsPath }
    
    # Convert Windows path to WSL path
    $drive = $WindowsPath.Substring(0, 1).ToLower()
    $path = $WindowsPath.Substring(2).Replace('\', '/')
    return "/mnt/$drive$path"
}

# Validate and convert project path
if (-not $ProjectPath) {
    Write-ColorOutput "Error: PROJECT_PATH not set in environment" "Red"
    Write-ColorOutput "Please set PROJECT_PATH in your .env file" "Yellow"
    exit 1
}

# Convert relative path to absolute path
if (-not [System.IO.Path]::IsPathRooted($ProjectPath)) {
    # It's a relative path - resolve it relative to the claude-setup directory
    $ResolvedPath = Join-Path $ProjectRoot $ProjectPath
    if (Test-Path $ResolvedPath) {
        $ProjectPath = (Resolve-Path $ResolvedPath).Path
        Write-ColorOutput "Resolved relative path to: $ProjectPath" "Cyan"
        [Environment]::SetEnvironmentVariable("PROJECT_PATH", $ProjectPath, "Process")
    } else {
        Write-ColorOutput "Error: Cannot resolve relative path: $ProjectPath" "Red"
        Write-ColorOutput "Make sure the path exists relative to: $ProjectRoot" "Yellow"
        exit 1
    }
}

# Check if running in WSL
$IsWSL = $false
if (Test-Path "/proc/version") {
    $procVersion = Get-Content "/proc/version" -ErrorAction SilentlyContinue
    if ($procVersion -match "microsoft|WSL") {
        $IsWSL = $true
    }
}

# Convert path if needed
if ($IsWSL -or $env:WSL_DISTRO_NAME) {
    $ProjectPath = Convert-ToWSLPath $ProjectPath
    [Environment]::SetEnvironmentVariable("PROJECT_PATH", $ProjectPath, "Process")
}

# Validate project path exists
if ($IsWSL) {
    # Check in WSL
    $pathExists = wsl test -d "$ProjectPath"
    if ($LASTEXITCODE -ne 0) {
        Write-ColorOutput "Error: Project path does not exist: $ProjectPath" "Red"
        exit 1
    }
} else {
    # Check in Windows
    $windowsPath = $ProjectPath.Replace('/', '\')
    if ($windowsPath -match '^/mnt/([a-z])/(.*)$') {
        $windowsPath = "$($matches[1].ToUpper()):\$($matches[2])"
    }
    if (-not (Test-Path $windowsPath)) {
        Write-ColorOutput "Error: Project path does not exist: $windowsPath" "Red"
        exit 1
    }
}

Write-ColorOutput "=== Claude Development Environment ===" "Magenta"
Write-ColorOutput "Project: $ProjectName" "Cyan"
Write-ColorOutput "Path: $ProjectPath" "Cyan"
Write-ColorOutput "Image: claude-enhanced:latest" "Cyan"
Write-Host ""

# Build or rebuild if requested
if ($Rebuild) {
    Write-ColorOutput "Rebuilding Claude image..." "Yellow"
    docker-compose build --no-cache claude-dev
} elseif ($Build) {
    Write-ColorOutput "Building Claude image..." "Yellow"
    docker-compose build claude-dev
}

# Check if container is already running
$runningContainers = docker ps --format "{{.Names}}"
if ($runningContainers -contains $ProjectName) {
    Write-ColorOutput "Container is already running!" "Green"
    
    if (-not $NoInteractive -and -not $Detach) {
        Write-ColorOutput "Attaching to existing container..." "Blue"
        docker exec -it $ProjectName $Shell
    } else {
        Write-ColorOutput "Container running in background" "Blue"
    }
    exit 0
}

# Check if container exists but is stopped
$allContainers = docker ps -a --format "{{.Names}}"
if ($allContainers -contains $ProjectName) {
    Write-ColorOutput "Starting existing container..." "Yellow"
    docker start $ProjectName
    
    if (-not $NoInteractive -and -not $Detach) {
        Write-ColorOutput "Attaching to container..." "Blue"
        docker attach $ProjectName
    }
    exit 0
}

# Start new container
Write-ColorOutput "Starting new Claude container..." "Green"

# Prepare docker-compose command
$composeArgs = @("up")
if ($Detach) {
    $composeArgs += "-d"
}
$composeArgs += "claude-dev"

# Start container
docker-compose @composeArgs

# If interactive and detached, exec into container
if (-not $NoInteractive -and $Detach) {
    Write-ColorOutput "Attaching to container..." "Blue"
    Start-Sleep -Seconds 2  # Give container time to start
    docker exec -it $ProjectName $Shell
}

# Show helpful commands
if ($Detach) {
    Write-Host ""
    Write-ColorOutput "Container started successfully!" "Green"
    Write-ColorOutput "Useful commands:" "Cyan"
    Write-Host "  Attach to container:  docker exec -it $ProjectName $Shell"
    Write-Host "  View logs:           docker logs -f $ProjectName"
    Write-Host "  Stop container:      docker stop $ProjectName"
    Write-Host "  Remove container:    docker rm -f $ProjectName"
}