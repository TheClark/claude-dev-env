#!/bin/bash

# Enhanced Claude Code Startup Script
# This script starts a Claude development container with all tools configured

set -euo pipefail

# Colors for output
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly MAGENTA='\033[0;35m'
readonly CYAN='\033[0;36m'
readonly NC='\033[0m' # No Color

# Script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

# Default values
PROJECT_NAME="${PROJECT_NAME:-claude-dev}"
INTERACTIVE=true
BUILD=false
REBUILD=false
DETACH=false
SHELL="/bin/bash"

# Function to print colored output
print_color() {
    local color=$1
    shift
    echo -e "${color}$*${NC}"
}

# Function to print usage
usage() {
    cat << EOF
Usage: $(basename "$0") [OPTIONS]

Start Claude development container with enhanced tools

OPTIONS:
    -p, --project NAME      Project name (default: claude-dev)
    -e, --env FILE         Environment file (default: .env)
    -b, --build            Build image before starting
    -r, --rebuild          Force rebuild image
    -d, --detach           Run in detached mode
    -s, --shell SHELL      Shell to use (default: /bin/bash)
    --no-interactive       Don't attach to container
    -h, --help             Show this help message

EXAMPLES:
    # Start with default settings
    $(basename "$0")
    
    # Start specific project
    $(basename "$0") -p my-project
    
    # Rebuild and start
    $(basename "$0") -r
    
    # Start in background
    $(basename "$0") -d

EOF
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -p|--project)
            PROJECT_NAME="$2"
            shift 2
            ;;
        -e|--env)
            ENV_FILE="$2"
            shift 2
            ;;
        -b|--build)
            BUILD=true
            shift
            ;;
        -r|--rebuild)
            REBUILD=true
            BUILD=true
            shift
            ;;
        -d|--detach)
            DETACH=true
            INTERACTIVE=false
            shift
            ;;
        -s|--shell)
            SHELL="$2"
            shift 2
            ;;
        --no-interactive)
            INTERACTIVE=false
            shift
            ;;
        -h|--help)
            usage
            exit 0
            ;;
        *)
            print_color "$RED" "Unknown option: $1"
            usage
            exit 1
            ;;
    esac
done

# Load environment file
ENV_FILE="${ENV_FILE:-$PROJECT_ROOT/.env}"
if [[ -f "$ENV_FILE" ]]; then
    print_color "$BLUE" "Loading environment from: $ENV_FILE"
    set -a
    source "$ENV_FILE"
    set +a
else
    print_color "$YELLOW" "Warning: No .env file found at $ENV_FILE"
    print_color "$YELLOW" "Using default values. Copy .env.example to .env and customize."
fi

# Validate required environment variables
if [[ -z "${PROJECT_PATH:-}" ]]; then
    print_color "$RED" "Error: PROJECT_PATH not set in environment"
    print_color "$YELLOW" "Please set PROJECT_PATH in your .env file"
    exit 1
fi

# Convert relative path to absolute path
if [[ ! "$PROJECT_PATH" =~ ^/ ]] && [[ ! "$PROJECT_PATH" =~ ^[A-Za-z]: ]]; then
    # It's a relative path - resolve it relative to the claude-setup directory
    PROJECT_PATH="$(cd "$PROJECT_ROOT" && cd "$PROJECT_PATH" 2>/dev/null && pwd)" || {
        print_color "$RED" "Error: Cannot resolve relative path: $PROJECT_PATH"
        print_color "$YELLOW" "Make sure the path exists relative to: $PROJECT_ROOT"
        exit 1
    }
    print_color "$CYAN" "Resolved relative path to: $PROJECT_PATH"
fi

# Check if project path exists
if [[ ! -d "$PROJECT_PATH" ]]; then
    print_color "$RED" "Error: Project path does not exist: $PROJECT_PATH"
    exit 1
fi

# Export the resolved path for docker-compose
export PROJECT_PATH

# Export PROJECT_NAME for docker-compose
export PROJECT_NAME

print_color "$MAGENTA" "=== Claude Development Environment ==="
print_color "$CYAN" "Project: $PROJECT_NAME"
print_color "$CYAN" "Path: $PROJECT_PATH"
print_color "$CYAN" "Image: claude-enhanced:latest"
echo ""

# Change to project root
cd "$PROJECT_ROOT"

# Build or rebuild if requested
if [[ "$REBUILD" == true ]]; then
    print_color "$YELLOW" "Rebuilding Claude image..."
    docker-compose build --no-cache claude-dev
elif [[ "$BUILD" == true ]]; then
    print_color "$YELLOW" "Building Claude image..."
    docker-compose build claude-dev
fi

# Check if container is already running
if docker ps --format '{{.Names}}' | grep -q "^${PROJECT_NAME}$"; then
    print_color "$GREEN" "Container is already running!"
    
    if [[ "$INTERACTIVE" == true ]]; then
        print_color "$BLUE" "Attaching to existing container..."
        docker exec -it "$PROJECT_NAME" "$SHELL"
    else
        print_color "$BLUE" "Container running in background"
    fi
    exit 0
fi

# Check if container exists but is stopped
if docker ps -a --format '{{.Names}}' | grep -q "^${PROJECT_NAME}$"; then
    print_color "$YELLOW" "Starting existing container..."
    docker start "$PROJECT_NAME"
    
    if [[ "$INTERACTIVE" == true ]]; then
        print_color "$BLUE" "Attaching to container..."
        docker attach "$PROJECT_NAME"
    fi
    exit 0
fi

# Start new container
print_color "$GREEN" "Starting new Claude container..."

# Prepare docker-compose command
COMPOSE_CMD="docker-compose up"

if [[ "$DETACH" == true ]]; then
    COMPOSE_CMD="$COMPOSE_CMD -d"
fi

# Start container
$COMPOSE_CMD claude-dev

# If interactive and detached, exec into container
if [[ "$INTERACTIVE" == true && "$DETACH" == true ]]; then
    print_color "$BLUE" "Attaching to container..."
    sleep 2  # Give container time to start
    docker exec -it "$PROJECT_NAME" "$SHELL"
fi

# Show helpful commands
if [[ "$DETACH" == true ]]; then
    echo ""
    print_color "$GREEN" "Container started successfully!"
    print_color "$CYAN" "Useful commands:"
    echo "  Attach to container:  docker exec -it $PROJECT_NAME $SHELL"
    echo "  View logs:           docker logs -f $PROJECT_NAME"
    echo "  Stop container:      docker stop $PROJECT_NAME"
    echo "  Remove container:    docker rm -f $PROJECT_NAME"
fi