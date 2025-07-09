#!/bin/bash

# Tool Initialization Script for Claude Development Container
# This script runs on container startup to configure development tools

set -euo pipefail

# Colors for output
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly RED='\033[0;31m'
readonly NC='\033[0m' # No Color

# Logging functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Banner
echo -e "${BLUE}"
cat << 'EOF'
  ____  _                 _       ____             
 / ___|| | __ _ _   _  __| | ___ |  _ \  _____   __
| |    | |/ _` | | | |/ _` |/ _ \| | | |/ _ \ \ / /
| |___ | | (_| | |_| | (_| |  __/| |_| |  __/\ V / 
 \____||_|\__,_|\__,_|\__,_|\___||____/ \___| \_/  
                                                    
    Enhanced Development Environment Setup
EOF
echo -e "${NC}"

# Configure Git
log_info "Configuring Git..."
if [[ -n "${GIT_USER_NAME:-}" ]]; then
    git config --global user.name "$GIT_USER_NAME"
    log_success "Git user name set to: $GIT_USER_NAME"
fi

if [[ -n "${GIT_USER_EMAIL:-}" ]]; then
    git config --global user.email "$GIT_USER_EMAIL"
    log_success "Git user email set to: $GIT_USER_EMAIL"
fi

# Configure GitHub CLI
if command -v gh &> /dev/null; then
    log_info "Configuring GitHub CLI..."
    if [[ -n "${GITHUB_TOKEN:-}" ]]; then
        echo "$GITHUB_TOKEN" | gh auth login --with-token 2>/dev/null && \
            log_success "GitHub CLI authenticated" || \
            log_warning "GitHub CLI authentication failed"
    else
        log_warning "GITHUB_TOKEN not set, skipping GitHub CLI authentication"
    fi
fi

# Configure Google Cloud SDK
if command -v gcloud &> /dev/null; then
    log_info "Configuring Google Cloud SDK..."
    if [[ -n "${GOOGLE_APPLICATION_CREDENTIALS:-}" ]] && [[ -f "$GOOGLE_APPLICATION_CREDENTIALS" ]]; then
        gcloud auth activate-service-account --key-file="$GOOGLE_APPLICATION_CREDENTIALS" 2>/dev/null && \
            log_success "Google Cloud authenticated" || \
            log_warning "Google Cloud authentication failed"
        
        if [[ -n "${GCP_PROJECT:-}" ]]; then
            gcloud config set project "$GCP_PROJECT" 2>/dev/null && \
                log_success "GCP project set to: $GCP_PROJECT" || \
                log_warning "Failed to set GCP project"
        fi
    else
        log_warning "Google Cloud credentials not found, skipping authentication"
    fi
fi

# Configure AWS CLI
if command -v aws &> /dev/null; then
    log_info "Configuring AWS CLI..."
    if [[ -d "$HOME/.aws" ]]; then
        if [[ -n "${AWS_PROFILE:-}" ]]; then
            export AWS_PROFILE
            log_success "AWS profile set to: $AWS_PROFILE"
        fi
        if [[ -n "${AWS_DEFAULT_REGION:-}" ]]; then
            export AWS_DEFAULT_REGION
            log_success "AWS region set to: $AWS_DEFAULT_REGION"
        fi
    else
        log_warning "AWS credentials not found, skipping configuration"
    fi
fi

# Configure Azure CLI
if command -v az &> /dev/null; then
    log_info "Configuring Azure CLI..."
    if [[ -d "$HOME/.azure" ]]; then
        log_success "Azure credentials found"
    else
        log_warning "Azure credentials not found, skipping configuration"
    fi
fi

# Configure kubectl
if command -v kubectl &> /dev/null; then
    log_info "Configuring kubectl..."
    if [[ -f "$HOME/.kube/config" ]]; then
        log_success "Kubernetes config found"
        # Set up kubectl aliases
        echo "alias k='kubectl'" >> ~/.bashrc
        echo "alias kgp='kubectl get pods'" >> ~/.bashrc
        echo "alias kgs='kubectl get svc'" >> ~/.bashrc
        echo "alias kgd='kubectl get deployment'" >> ~/.bashrc
    else
        log_warning "Kubernetes config not found, skipping configuration"
    fi
fi

# Configure Docker
if [[ -S /var/run/docker.sock ]]; then
    log_info "Configuring Docker..."
    if docker version &> /dev/null; then
        log_success "Docker is accessible"
    else
        log_warning "Docker socket mounted but Docker daemon not accessible"
    fi
fi

# Set up SSH permissions
if [[ -d "$HOME/.ssh" ]]; then
    log_info "Setting up SSH..."
    chmod 700 "$HOME/.ssh" 2>/dev/null || true
    chmod 600 "$HOME/.ssh/"* 2>/dev/null || true
    log_success "SSH permissions configured"
fi

# Initialize Node.js environment
if command -v node &> /dev/null; then
    log_info "Node.js $(node --version) available"
    log_info "npm $(npm --version) available"
    
    # Set up npm aliases
    echo "alias ni='npm install'" >> ~/.bashrc
    echo "alias nr='npm run'" >> ~/.bashrc
    echo "alias nrd='npm run dev'" >> ~/.bashrc
    echo "alias nrs='npm run start'" >> ~/.bashrc
    echo "alias nrt='npm run test'" >> ~/.bashrc
    echo "alias nrb='npm run build'" >> ~/.bashrc
fi

# Initialize Python environment
if command -v python3 &> /dev/null; then
    log_info "Python $(python3 --version) available"
    
    # Create useful Python aliases
    echo "alias py='python3'" >> ~/.bashrc
    echo "alias pip='pip3'" >> ~/.bashrc
    echo "alias venv='python3 -m venv'" >> ~/.bashrc
    echo "alias activate='source venv/bin/activate'" >> ~/.bashrc
fi

# Set up Go environment
if command -v go &> /dev/null; then
    log_info "Go $(go version) available"
    echo "export GOPATH=$HOME/go" >> ~/.bashrc
    echo "export PATH=\$PATH:\$GOPATH/bin" >> ~/.bashrc
fi

# Set up Rust environment
if [[ -f "$HOME/.cargo/env" ]]; then
    log_info "Rust available"
    echo "source $HOME/.cargo/env" >> ~/.bashrc
fi

# Create useful aliases
log_info "Setting up useful aliases..."
cat >> ~/.bashrc << 'ALIASES'

# Navigation aliases
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias l='ls -lah'
alias la='ls -lAh'
alias ll='ls -lh'
alias ls='ls --color=auto'
alias md='mkdir -p'

# Git aliases (in addition to gitconfig)
alias g='git'
alias gs='git status'
alias gd='git diff'
alias gc='git commit'
alias gp='git push'
alias gl='git pull'
alias gco='git checkout'
alias gb='git branch'

# Docker aliases
alias d='docker'
alias dc='docker-compose'
alias dps='docker ps'
alias dpsa='docker ps -a'
alias di='docker images'
alias dex='docker exec -it'
alias dlog='docker logs -f'
alias dstop='docker stop $(docker ps -q)'
alias drm='docker rm $(docker ps -aq)'
alias drmi='docker rmi $(docker images -q)'

# Kubernetes aliases (if kubectl available)
if command -v kubectl &> /dev/null; then
    source <(kubectl completion bash)
    alias k='kubectl'
    complete -F __start_kubectl k
fi

# Python aliases
alias pytest='python -m pytest'
alias black='python -m black'
alias isort='python -m isort'
alias flake8='python -m flake8'

# Utility functions
mkcd() { mkdir -p "$1" && cd "$1"; }
extract() {
    if [ -f "$1" ]; then
        case "$1" in
            *.tar.bz2) tar xjf "$1" ;;
            *.tar.gz) tar xzf "$1" ;;
            *.bz2) bunzip2 "$1" ;;
            *.rar) unrar e "$1" ;;
            *.gz) gunzip "$1" ;;
            *.tar) tar xf "$1" ;;
            *.tbz2) tar xjf "$1" ;;
            *.tgz) tar xzf "$1" ;;
            *.zip) unzip "$1" ;;
            *.Z) uncompress "$1" ;;
            *.7z) 7z x "$1" ;;
            *) echo "'$1' cannot be extracted" ;;
        esac
    else
        echo "'$1' is not a valid file"
    fi
}

# Quick project navigation
proj() {
    cd /workspace/"$1" 2>/dev/null || cd /workspace
}

# Show current cloud context
cloud-context() {
    echo "=== Cloud Context ==="
    if command -v gcloud &> /dev/null; then
        echo "GCP Project: $(gcloud config get-value project 2>/dev/null || echo 'Not set')"
    fi
    if command -v aws &> /dev/null; then
        echo "AWS Profile: ${AWS_PROFILE:-default}"
        echo "AWS Region: ${AWS_DEFAULT_REGION:-Not set}"
    fi
    if command -v kubectl &> /dev/null && [[ -f ~/.kube/config ]]; then
        echo "K8s Context: $(kubectl config current-context 2>/dev/null || echo 'Not set')"
    fi
}

# Development server helpers
serve() {
    local port="${1:-8000}"
    python3 -m http.server "$port"
}

json-server() {
    npx json-server --watch "$@"
}

# Git helpers
git-clean-branches() {
    git branch --merged | grep -v "\*\|main\|master\|develop" | xargs -n 1 git branch -d
}

git-undo() {
    git reset HEAD~1 --soft
}

# Docker helpers
docker-clean() {
    docker system prune -af --volumes
}

# Terminal helpers
alias cls='clear'
alias h='history'
alias j='jobs -l'
alias path='echo -e ${PATH//:/\\n}'
alias now='date +"%Y-%m-%d %H:%M:%S"'
alias timestamp='date +%s'

# Make terminal better
export HISTSIZE=10000
export HISTFILESIZE=20000
export HISTCONTROL=ignoreboth:erasedups
export PROMPT_COMMAND="history -a; $PROMPT_COMMAND"

ALIASES

# Create workspace shortcuts
if [[ -n "${PROJECT_NAME:-}" ]]; then
    echo "alias cdp='cd /workspace'" >> ~/.bashrc
    echo "alias project='cd /workspace && clear && pwd'" >> ~/.bashrc
fi

# Source the updated bashrc
source ~/.bashrc

# Final message
echo ""
log_success "Development environment initialized!"
echo ""
log_info "Quick tips:"
echo "  - Type 'cloud-context' to see current cloud settings"
echo "  - Type 'cdp' to go to your project directory"
echo "  - Type 'h' to see command history"
echo "  - Type 'la' for detailed file listings"
echo ""

# Show current context
if [[ -n "${PROJECT_NAME:-}" ]]; then
    log_info "Project: $PROJECT_NAME"
fi
log_info "Workspace: /workspace"
log_info "Shell: $SHELL"
echo ""