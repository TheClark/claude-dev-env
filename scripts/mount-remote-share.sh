#!/bin/bash

# Mount Remote Windows Share Helper Script
# This script helps mount SMB/CIFS shares for use with Claude Dev

set -euo pipefail

# Colors for output
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
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

# Check if running in WSL
check_wsl() {
    if [[ ! -f /proc/version ]] || ! grep -qi microsoft /proc/version; then
        print_color "$YELLOW" "Warning: This script is designed for WSL2"
        read -p "Continue anyway? (y/N) " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            exit 0
        fi
    fi
}

# Install dependencies
install_dependencies() {
    print_color "$CYAN" "Checking dependencies..."
    
    if ! command -v mount.cifs &> /dev/null; then
        print_color "$YELLOW" "Installing CIFS utilities..."
        sudo apt update
        sudo apt install -y cifs-utils
    fi
    
    print_color "$GREEN" "✓ Dependencies installed"
}

# Load environment
load_env() {
    if [[ -f "$PROJECT_ROOT/.env" ]]; then
        print_color "$BLUE" "Loading .env file..."
        set -a
        source "$PROJECT_ROOT/.env"
        set +a
    fi
}

# Setup credentials
setup_credentials() {
    local cred_dir="/etc/samba"
    local cred_file="$cred_dir/claude-dev.credentials"
    
    # Get credentials
    if [[ -z "${SMB_SERVER:-}" ]]; then
        read -p "SMB Server (e.g., //192.168.1.100/share): " SMB_SERVER
    else
        print_color "$GREEN" "Using SMB server: $SMB_SERVER"
    fi
    
    if [[ -z "${SMB_USERNAME:-}" ]]; then
        read -p "Username: " SMB_USERNAME
    fi
    
    if [[ -z "${SMB_PASSWORD:-}" ]]; then
        read -sp "Password: " SMB_PASSWORD
        echo
    fi
    
    if [[ -z "${SMB_DOMAIN:-}" ]]; then
        read -p "Domain (default: WORKGROUP): " SMB_DOMAIN
        SMB_DOMAIN="${SMB_DOMAIN:-WORKGROUP}"
    fi
    
    # Create credentials file
    print_color "$BLUE" "Creating credentials file..."
    sudo mkdir -p "$cred_dir"
    
    sudo tee "$cred_file" > /dev/null << EOF
username=$SMB_USERNAME
password=$SMB_PASSWORD
domain=$SMB_DOMAIN
EOF
    
    sudo chmod 600 "$cred_file"
    print_color "$GREEN" "✓ Credentials saved securely"
    
    echo "$cred_file"
}

# Test connection
test_connection() {
    local server=$1
    local cred_file=$2
    
    print_color "$BLUE" "Testing connection to $server..."
    
    # Extract server name for smbclient
    local server_name=$(echo "$server" | sed 's|//||' | cut -d'/' -f1)
    
    if smbclient -L "//$server_name" -A "$cred_file" &> /dev/null; then
        print_color "$GREEN" "✓ Connection successful"
        return 0
    else
        print_color "$RED" "✗ Connection failed"
        return 1
    fi
}

# Mount share
mount_share() {
    local server=$1
    local cred_file=$2
    local mount_point=$3
    
    # Create mount point
    sudo mkdir -p "$mount_point"
    
    # Try different SMB versions
    local versions=("3.0" "2.1" "2.0" "1.0")
    local mounted=false
    
    for vers in "${versions[@]}"; do
        print_color "$BLUE" "Trying SMB version $vers..."
        
        if sudo mount -t cifs "$server" "$mount_point" \
            -o credentials="$cred_file",uid=$(id -u),gid=$(id -g),iocharset=utf8,file_mode=0755,dir_mode=0755,vers=$vers 2>/dev/null; then
            mounted=true
            print_color "$GREEN" "✓ Mounted successfully with SMB $vers"
            break
        fi
    done
    
    if [[ "$mounted" == false ]]; then
        print_color "$RED" "✗ Failed to mount share"
        return 1
    fi
    
    # Test mount
    if ls -la "$mount_point" &> /dev/null; then
        print_color "$GREEN" "✓ Mount verified"
        ls -la "$mount_point" | head -5
    else
        print_color "$RED" "✗ Mount verification failed"
        return 1
    fi
}

# Update fstab for permanent mount
make_permanent() {
    local server=$1
    local cred_file=$2
    local mount_point=$3
    
    read -p "Make this mount permanent? (y/N) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        # Backup fstab
        sudo cp /etc/fstab /etc/fstab.backup.$(date +%Y%m%d_%H%M%S)
        
        # Add entry
        local fstab_entry="$server $mount_point cifs credentials=$cred_file,uid=$(id -u),gid=$(id -g),iocharset=utf8,file_mode=0755,dir_mode=0755,vers=3.0,_netdev 0 0"
        
        # Check if already exists
        if ! grep -q "$mount_point" /etc/fstab; then
            echo "$fstab_entry" | sudo tee -a /etc/fstab > /dev/null
            print_color "$GREEN" "✓ Added to /etc/fstab"
        else
            print_color "$YELLOW" "Entry already exists in /etc/fstab"
        fi
    fi
}

# Update .env file
update_env() {
    local mount_point=$1
    
    # Update or add PROJECT_PATH
    if grep -q "^PROJECT_PATH=" "$PROJECT_ROOT/.env" 2>/dev/null; then
        sed -i "s|^PROJECT_PATH=.*|PROJECT_PATH=$mount_point|" "$PROJECT_ROOT/.env"
    else
        echo "PROJECT_PATH=$mount_point" >> "$PROJECT_ROOT/.env"
    fi
    
    print_color "$GREEN" "✓ Updated PROJECT_PATH in .env"
}

# Main function
main() {
    print_color "$BLUE" "=== Remote Windows Share Mount Helper ==="
    
    check_wsl
    install_dependencies
    load_env
    
    # Setup credentials
    local cred_file=$(setup_credentials)
    
    # Test connection
    if ! test_connection "$SMB_SERVER" "$cred_file"; then
        print_color "$RED" "Cannot connect to server. Please check:"
        echo "  - Server address is correct"
        echo "  - Credentials are correct"
        echo "  - Network connectivity"
        echo "  - Firewall settings"
        exit 1
    fi
    
    # Determine mount point
    local share_name=$(basename "$SMB_SERVER")
    local mount_point="/mnt/smb-$share_name"
    
    read -p "Mount point (default: $mount_point): " custom_mount
    mount_point="${custom_mount:-$mount_point}"
    
    # Mount share
    if mount_share "$SMB_SERVER" "$cred_file" "$mount_point"; then
        make_permanent "$SMB_SERVER" "$cred_file" "$mount_point"
        update_env "$mount_point"
        
        print_color "$GREEN" "\n✓ Setup complete!"
        print_color "$CYAN" "Your remote share is mounted at: $mount_point"
        print_color "$CYAN" "You can now run: ./scripts/start-claude.sh"
    else
        print_color "$RED" "\n✗ Setup failed"
        exit 1
    fi
}

# Run main function
main "$@"