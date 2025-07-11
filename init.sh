#!/bin/bash
# Claude Dev Environment - Interactive Setup Script
# This script guides you through setting up your Claude development environment

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
GRAY='\033[0;90m'
WHITE='\033[0;37m'
NC='\033[0m' # No Color

# Banner
show_banner() {
    echo -e "${CYAN}"
    echo "    ╔═══════════════════════════════════════════════════════╗"
    echo "    ║         Claude Dev Environment Setup Wizard           ║"
    echo "    ╚═══════════════════════════════════════════════════════╝"
    echo -e "${NC}\n"
}

# Usage
show_usage() {
    cat << EOF
Usage: init.sh [OPTIONS]

Interactive setup wizard for Claude development environment

OPTIONS:
    -s, --skip-prompts    Use defaults where possible
    -h, --help           Show this help message

This script will:
1. Create your .env configuration file
2. Set up your credentials (GitHub, Anthropic)
3. Build the Docker image
4. Start the container with Claude Code ready to use

EOF
}

# Parse arguments
SKIP_PROMPTS=false
while [[ $# -gt 0 ]]; do
    case $1 in
        -s|--skip-prompts)
            SKIP_PROMPTS=true
            shift
            ;;
        -h|--help)
            show_usage
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            show_usage
            exit 1
            ;;
    esac
done

# Clear screen and show banner
clear
show_banner

echo -e "${GREEN}Welcome to Claude Dev Environment Setup!${NC}"
echo -e "${WHITE}This wizard will help you get started in just a few minutes.\n${NC}"

# Check prerequisites
echo -e "${YELLOW}Checking prerequisites...${NC}"

# Check Docker
if command -v docker &> /dev/null; then
    DOCKER_VERSION=$(docker --version)
    echo -e "${GREEN}[OK] Docker is installed: $DOCKER_VERSION${NC}"
else
    echo -e "${RED}[ERROR] Docker is not installed or not in PATH${NC}"
    echo -e "${YELLOW}Please install Docker from: https://www.docker.com/products/docker-desktop${NC}"
    exit 1
fi

# Check if Docker is running
if docker ps &> /dev/null; then
    echo -e "${GREEN}[OK] Docker is running${NC}"
else
    echo -e "${RED}[ERROR] Docker is not running${NC}"
    echo -e "${YELLOW}Please start Docker and try again${NC}"
    exit 1
fi

echo ""

# Get project information
echo -e "${MAGENTA}=== Project Configuration ===${NC}"

# Project name
read -p "Enter project name (default: claude-dev): " PROJECT_NAME
PROJECT_NAME=${PROJECT_NAME:-claude-dev}

# Project path
echo -e "\n${WHITE}Where is your project located?${NC}"
echo -e "${GRAY}Examples:${NC}"
echo -e "${GRAY}  - /home/username/projects/my-project${NC}"
echo -e "${GRAY}  - ../my-project (relative path)${NC}"
echo -e "${GRAY}  - . (current directory)${NC}"

read -p $'\nEnter project path: ' PROJECT_PATH
PROJECT_PATH=${PROJECT_PATH:-..}

# Resolve relative paths
if [[ ! "$PROJECT_PATH" = /* ]]; then
    RESOLVED_PATH="$(cd "$SCRIPT_DIR" && cd "$PROJECT_PATH" 2>/dev/null && pwd)"
    if [ -n "$RESOLVED_PATH" ]; then
        echo -e "${GRAY}Resolved to: $RESOLVED_PATH${NC}"
        PROJECT_PATH="$RESOLVED_PATH"
    fi
fi

# Verify path exists
if [ ! -d "$PROJECT_PATH" ]; then
    echo -e "${RED}[ERROR] Project path does not exist: $PROJECT_PATH${NC}"
    read -p "Create this directory? (y/n): " CREATE_DIR
    if [ "$CREATE_DIR" = "y" ]; then
        mkdir -p "$PROJECT_PATH"
        echo -e "${GREEN}[OK] Directory created${NC}"
    else
        exit 1
    fi
fi

echo ""

# Get credentials
echo -e "${MAGENTA}=== Credentials Setup ===${NC}"
echo -e "${GRAY}Leave blank to skip (you can add these later)\n${NC}"

# Git configuration
read -p "Git user name: " GIT_USER_NAME
read -p "Git user email: " GIT_USER_EMAIL

# GitHub token
echo -e "\n${WHITE}GitHub Personal Access Token (for gh CLI)${NC}"
echo -e "${GRAY}Create one at: https://github.com/settings/tokens${NC}"
read -s -p "GitHub token: " GITHUB_TOKEN
echo ""

# Anthropic API key
echo -e "\n${WHITE}Anthropic API Key (for Claude API access)${NC}"
echo -e "${GRAY}Get one at: https://console.anthropic.com/settings/keys${NC}"
read -s -p "Anthropic API key: " ANTHROPIC_API_KEY
echo ""

echo ""

# Create .env file
echo -e "${MAGENTA}=== Creating Configuration ===${NC}"

cat > "$SCRIPT_DIR/.env" << EOF
# Claude Development Environment Configuration
# Generated by init.sh on $(date "+%Y-%m-%d %H:%M:%S")

# Project Configuration
PROJECT_NAME=$PROJECT_NAME
PROJECT_PATH=$PROJECT_PATH

# Git Configuration
GIT_USER_NAME=$GIT_USER_NAME
GIT_USER_EMAIL=$GIT_USER_EMAIL

# API Keys and Tokens
GITHUB_TOKEN=$GITHUB_TOKEN
ANTHROPIC_API_KEY=$ANTHROPIC_API_KEY

# Development Environment
NODE_ENV=development
PYTHON_ENV=development
DEBUG=true

# Docker Build Performance
COMPOSE_BAKE=true

# Resource Limits
CPU_LIMIT=4
MEMORY_LIMIT=8G
CPU_RESERVATION=2
MEMORY_RESERVATION=4G
EOF

echo -e "${GREEN}[OK] Configuration saved to .env${NC}"

# Ask about building
echo ""
echo -e "${MAGENTA}=== Docker Setup ===${NC}"
echo -e "${WHITE}Ready to build the Docker image.${NC}"
echo -e "${GRAY}This will take 2-3 minutes on first run.\n${NC}"

read -p "Build and start now? (y/n): " PROCEED
if [ "$PROCEED" != "y" ]; then
    echo -e "\n${GREEN}Setup complete! To start later, run:${NC}"
    echo -e "${CYAN}  cd $SCRIPT_DIR${NC}"
    echo -e "${CYAN}  ./scripts/start-claude.sh${NC}"
    exit 0
fi

# Build and start
echo ""
echo -e "${YELLOW}Building Docker image...${NC}"
cd "$SCRIPT_DIR"

# Set COMPOSE_BAKE for better performance
export COMPOSE_BAKE=true

# Build the image
docker-compose build claude-dev

if [ $? -ne 0 ]; then
    echo -e "${RED}[ERROR] Build failed${NC}"
    exit 1
fi

echo -e "${GREEN}[OK] Docker image built successfully!${NC}"

# Start the container
echo ""
echo -e "${YELLOW}Starting Claude development environment...${NC}"

echo -e "\n${GREEN}=== Setup Complete! ===${NC}"
echo -e "${WHITE}Starting Claude Code...${NC}"
echo -e "\n${CYAN}You can run:${NC}"
echo -e "${GRAY}  claude --help     # See Claude Code options${NC}"
echo -e "${GRAY}  claude           # Start Claude Code${NC}"
echo -e "\n${WHITE}Your project is mounted at: /workspace${NC}"

# Start the container
echo ""
./scripts/start-claude.sh

echo -e "\n${GREEN}Happy coding! 🚀${NC}"