#!/bin/bash

# Credential Setup Helper for Claude Development Environment
# This script helps set up cloud credentials and authentication

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

# Print colored output
print_color() {
    local color=$1
    shift
    echo -e "${color}$*${NC}"
}

# Print banner
print_banner() {
    print_color "$BLUE" "
╔═══════════════════════════════════════════╗
║   Claude Dev Credential Setup Assistant   ║
╚═══════════════════════════════════════════╝
"
}

# Check if running in container
check_environment() {
    if [[ -f /.dockerenv ]]; then
        print_color "$YELLOW" "Warning: Running inside Docker container"
        print_color "$YELLOW" "Run this script on your host machine instead"
        read -p "Continue anyway? (y/N) " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            exit 0
        fi
    fi
}

# Create directories
create_directories() {
    print_color "$CYAN" "Creating credential directories..."
    
    mkdir -p "$HOME/.ssh"
    mkdir -p "$HOME/.aws"
    mkdir -p "$HOME/.config/gcloud"
    mkdir -p "$HOME/.azure"
    mkdir -p "$HOME/.kube"
    
    print_color "$GREEN" "✓ Directories created"
}

# Setup GitHub
setup_github() {
    print_color "$MAGENTA" "\n=== GitHub Setup ==="
    
    if command -v gh &> /dev/null; then
        print_color "$CYAN" "GitHub CLI detected"
        read -p "Do you want to authenticate with GitHub? (y/N) " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            gh auth login
        fi
    else
        print_color "$YELLOW" "GitHub CLI not installed"
        print_color "$CYAN" "To install: https://cli.github.com/"
    fi
    
    # Check for GitHub token in .env
    if [[ -f "$PROJECT_ROOT/.env" ]] && grep -q "GITHUB_TOKEN=" "$PROJECT_ROOT/.env"; then
        print_color "$GREEN" "✓ GITHUB_TOKEN found in .env"
    else
        read -p "Do you have a GitHub personal access token? (y/N) " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            read -sp "Enter your GitHub token: " token
            echo
            echo "GITHUB_TOKEN=$token" >> "$PROJECT_ROOT/.env"
            print_color "$GREEN" "✓ GitHub token saved to .env"
        else
            print_color "$CYAN" "Create a token at: https://github.com/settings/tokens"
        fi
    fi
}

# Setup SSH keys
setup_ssh() {
    print_color "$MAGENTA" "\n=== SSH Key Setup ==="
    
    if [[ -f "$HOME/.ssh/id_rsa" ]] || [[ -f "$HOME/.ssh/id_ed25519" ]]; then
        print_color "$GREEN" "✓ SSH keys found"
        
        # Fix permissions
        chmod 700 "$HOME/.ssh"
        chmod 600 "$HOME/.ssh/"* 2>/dev/null || true
        chmod 644 "$HOME/.ssh/"*.pub 2>/dev/null || true
        
        print_color "$GREEN" "✓ SSH permissions fixed"
    else
        read -p "No SSH keys found. Generate new SSH key? (y/N) " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            read -p "Enter your email: " email
            ssh-keygen -t ed25519 -C "$email" -f "$HOME/.ssh/id_ed25519"
            print_color "$GREEN" "✓ SSH key generated"
            
            if command -v xclip &> /dev/null; then
                cat "$HOME/.ssh/id_ed25519.pub" | xclip -selection clipboard
                print_color "$GREEN" "✓ Public key copied to clipboard"
            else
                print_color "$CYAN" "Public key:"
                cat "$HOME/.ssh/id_ed25519.pub"
            fi
            
            print_color "$CYAN" "Add this key to:"
            echo "  - GitHub: https://github.com/settings/keys"
            echo "  - GitLab: https://gitlab.com/-/profile/keys"
            echo "  - Bitbucket: https://bitbucket.org/account/settings/ssh-keys/"
        fi
    fi
}

# Setup Google Cloud
setup_gcloud() {
    print_color "$MAGENTA" "\n=== Google Cloud Setup ==="
    
    if command -v gcloud &> /dev/null; then
        print_color "$CYAN" "Google Cloud SDK detected"
        
        # Check if already authenticated
        if gcloud auth list --format="value(account)" 2>/dev/null | grep -q "@"; then
            print_color "$GREEN" "✓ Already authenticated"
            print_color "$CYAN" "Active account: $(gcloud auth list --filter=status:ACTIVE --format='value(account)')"
        else
            read -p "Authenticate with Google Cloud? (y/N) " -n 1 -r
            echo
            if [[ $REPLY =~ ^[Yy]$ ]]; then
                gcloud auth login
                
                # Set default project
                read -p "Set default GCP project? (y/N) " -n 1 -r
                echo
                if [[ $REPLY =~ ^[Yy]$ ]]; then
                    gcloud projects list
                    read -p "Enter project ID: " project_id
                    gcloud config set project "$project_id"
                    echo "GCP_PROJECT=$project_id" >> "$PROJECT_ROOT/.env"
                fi
            fi
        fi
        
        # Application default credentials
        read -p "Set up Application Default Credentials? (y/N) " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            gcloud auth application-default login
        fi
    else
        print_color "$YELLOW" "Google Cloud SDK not installed"
        print_color "$CYAN" "To install: https://cloud.google.com/sdk/docs/install"
    fi
}

# Setup AWS
setup_aws() {
    print_color "$MAGENTA" "\n=== AWS Setup ==="
    
    if command -v aws &> /dev/null; then
        print_color "$CYAN" "AWS CLI detected"
        
        # Check if already configured
        if [[ -f "$HOME/.aws/credentials" ]]; then
            print_color "$GREEN" "✓ AWS credentials found"
            print_color "$CYAN" "Configured profiles:"
            aws configure list-profiles 2>/dev/null || grep "^\[" "$HOME/.aws/credentials" | tr -d '[]'
        else
            read -p "Configure AWS credentials? (y/N) " -n 1 -r
            echo
            if [[ $REPLY =~ ^[Yy]$ ]]; then
                read -p "Profile name (default): " profile
                profile="${profile:-default}"
                aws configure --profile "$profile"
                
                if [[ "$profile" != "default" ]]; then
                    echo "AWS_PROFILE=$profile" >> "$PROJECT_ROOT/.env"
                fi
            fi
        fi
    else
        print_color "$YELLOW" "AWS CLI not installed"
        print_color "$CYAN" "To install: https://aws.amazon.com/cli/"
    fi
}

# Setup Azure
setup_azure() {
    print_color "$MAGENTA" "\n=== Azure Setup ==="
    
    if command -v az &> /dev/null; then
        print_color "$CYAN" "Azure CLI detected"
        
        # Check if already logged in
        if az account show &> /dev/null; then
            print_color "$GREEN" "✓ Already logged in to Azure"
            print_color "$CYAN" "Active subscription: $(az account show --query name -o tsv)"
        else
            read -p "Login to Azure? (y/N) " -n 1 -r
            echo
            if [[ $REPLY =~ ^[Yy]$ ]]; then
                az login
                
                # Set default subscription
                read -p "Set default subscription? (y/N) " -n 1 -r
                echo
                if [[ $REPLY =~ ^[Yy]$ ]]; then
                    az account list --output table
                    read -p "Enter subscription ID: " sub_id
                    az account set --subscription "$sub_id"
                    echo "AZURE_SUBSCRIPTION_ID=$sub_id" >> "$PROJECT_ROOT/.env"
                fi
            fi
        fi
    else
        print_color "$YELLOW" "Azure CLI not installed"
        print_color "$CYAN" "To install: https://docs.microsoft.com/en-us/cli/azure/install-azure-cli"
    fi
}

# Setup Kubernetes
setup_kubernetes() {
    print_color "$MAGENTA" "\n=== Kubernetes Setup ==="
    
    if command -v kubectl &> /dev/null; then
        print_color "$CYAN" "kubectl detected"
        
        # Check for kubeconfig
        if [[ -f "$HOME/.kube/config" ]]; then
            print_color "$GREEN" "✓ Kubernetes config found"
            print_color "$CYAN" "Configured contexts:"
            kubectl config get-contexts -o name
            
            # Check current context
            if kubectl config current-context &> /dev/null; then
                print_color "$CYAN" "Current context: $(kubectl config current-context)"
            fi
        else
            print_color "$YELLOW" "No Kubernetes config found"
            print_color "$CYAN" "To configure:"
            echo "  - For GKE: gcloud container clusters get-credentials CLUSTER_NAME"
            echo "  - For EKS: aws eks update-kubeconfig --name CLUSTER_NAME"
            echo "  - For AKS: az aks get-credentials --name CLUSTER_NAME"
        fi
    else
        print_color "$YELLOW" "kubectl not installed"
        print_color "$CYAN" "To install: https://kubernetes.io/docs/tasks/tools/"
    fi
}

# Setup Docker
setup_docker() {
    print_color "$MAGENTA" "\n=== Docker Setup ==="
    
    if command -v docker &> /dev/null; then
        print_color "$CYAN" "Docker detected"
        
        # Check if Docker daemon is running
        if docker version &> /dev/null; then
            print_color "$GREEN" "✓ Docker daemon is running"
        else
            print_color "$YELLOW" "Docker daemon not accessible"
            print_color "$CYAN" "Make sure Docker Desktop is running"
        fi
        
        # Check Docker Hub login
        if docker info 2>/dev/null | grep -q "Username"; then
            print_color "$GREEN" "✓ Logged in to Docker Hub"
        else
            read -p "Login to Docker Hub? (y/N) " -n 1 -r
            echo
            if [[ $REPLY =~ ^[Yy]$ ]]; then
                docker login
            fi
        fi
    else
        print_color "$YELLOW" "Docker not installed"
        print_color "$CYAN" "To install: https://docs.docker.com/get-docker/"
    fi
}

# Create credential summary
create_summary() {
    print_color "$MAGENTA" "\n=== Creating Credential Summary ==="
    
    cat > "$PROJECT_ROOT/credentials-summary.txt" << EOF
Claude Development Environment - Credential Summary
Generated: $(date)

SSH Keys:
$(ls -la "$HOME/.ssh/"*.pub 2>/dev/null || echo "  No SSH keys found")

GitHub:
$(gh auth status 2>&1 | grep "Logged in" || echo "  Not authenticated")

Google Cloud:
$(gcloud auth list --format="value(account)" 2>/dev/null | sed 's/^/  /' || echo "  Not authenticated")

AWS:
$(aws configure list-profiles 2>/dev/null | sed 's/^/  /' || echo "  No profiles configured")

Azure:
$(az account show --query name -o tsv 2>/dev/null | sed 's/^/  /' || echo "  Not logged in")

Kubernetes:
$(kubectl config current-context 2>/dev/null | sed 's/^/  Current: /' || echo "  No context set")

Docker:
$(docker info 2>/dev/null | grep "Username:" | sed 's/^/  /' || echo "  Not logged in")

Environment Variables Set:
$(grep -E "^(GITHUB_TOKEN|GCP_PROJECT|AWS_PROFILE|AZURE_)" "$PROJECT_ROOT/.env" 2>/dev/null | cut -d= -f1 | sed 's/^/  /' || echo "  None")
EOF

    print_color "$GREEN" "✓ Summary saved to credentials-summary.txt"
}

# Main function
main() {
    print_banner
    check_environment
    
    # Load existing .env if present
    if [[ -f "$PROJECT_ROOT/.env" ]]; then
        print_color "$CYAN" "Loading existing .env file..."
        set -a
        source "$PROJECT_ROOT/.env"
        set +a
    else
        # Create .env from example
        if [[ -f "$PROJECT_ROOT/.env.example" ]]; then
            cp "$PROJECT_ROOT/.env.example" "$PROJECT_ROOT/.env"
            print_color "$GREEN" "✓ Created .env from .env.example"
        fi
    fi
    
    create_directories
    
    # Run setup functions
    setup_ssh
    setup_github
    setup_gcloud
    setup_aws
    setup_azure
    setup_kubernetes
    setup_docker
    
    create_summary
    
    print_color "$GREEN" "\n✓ Credential setup complete!"
    print_color "$CYAN" "Next steps:"
    echo "  1. Review and edit .env file with your project settings"
    echo "  2. Run ./scripts/start-claude.sh to start the development environment"
    echo "  3. Check credentials-summary.txt for setup status"
}

# Run main function
main "$@"