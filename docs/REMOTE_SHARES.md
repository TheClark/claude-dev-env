# Using Remote Windows Shares with Claude Dev Setup

## Overview

You can mount remote Windows shares (SMB/CIFS) as your project path, but it requires additional setup steps and considerations.

## Methods to Use Remote Shares

### Method 1: Mount in WSL2 (Recommended)

1. **Install CIFS utilities in WSL2**:
   ```bash
   sudo apt update
   sudo apt install cifs-utils
   ```

2. **Create a mount point**:
   ```bash
   sudo mkdir -p /mnt/remote-share
   ```

3. **Create credentials file** (more secure than command line):
   ```bash
   # Create credentials file
   sudo nano /etc/samba/credentials
   
   # Add these lines:
   username=your_windows_username
   password=your_windows_password
   domain=your_domain_or_workgroup
   ```
   
   ```bash
   # Secure the file
   sudo chmod 600 /etc/samba/credentials
   ```

4. **Mount the share**:
   ```bash
   # Temporary mount
   sudo mount -t cifs //server/share /mnt/remote-share -o credentials=/etc/samba/credentials,uid=$(id -u),gid=$(id -g),iocharset=utf8
   
   # Or with specific options for better compatibility
   sudo mount -t cifs //server/share /mnt/remote-share -o credentials=/etc/samba/credentials,uid=$(id -u),gid=$(id -g),iocharset=utf8,file_mode=0755,dir_mode=0755,vers=3.0
   ```

5. **Make it permanent** (auto-mount on boot):
   ```bash
   # Edit fstab
   sudo nano /etc/fstab
   
   # Add this line:
   //server/share /mnt/remote-share cifs credentials=/etc/samba/credentials,uid=1000,gid=1000,iocharset=utf8,file_mode=0755,dir_mode=0755,vers=3.0,_netdev 0 0
   ```

6. **Update your .env**:
   ```bash
   PROJECT_PATH=/mnt/remote-share/my-project
   ```

### Method 2: Mount Directly in Docker Container

Add this to your `docker-compose.yml`:

```yaml
services:
  claude-dev:
    # ... existing configuration ...
    
    # Add privileged mode for mounting
    privileged: true
    
    # Add CIFS mount as volume
    volumes:
      # Method A: Using volume driver
      - type: volume
        source: remote-share
        target: /workspace
        volume:
          driver: local
          driver_opts:
            type: cifs
            device: //server/share
            o: username=${SMB_USERNAME},password=${SMB_PASSWORD},domain=${SMB_DOMAIN},uid=1000,gid=1000,vers=3.0

volumes:
  remote-share:
    driver: local
    driver_opts:
      type: cifs
      device: //server/share
      o: username=${SMB_USERNAME},password=${SMB_PASSWORD},domain=${SMB_DOMAIN},uid=1000,gid=1000,vers=3.0
```

### Method 3: Using Docker Volume Plugins

1. **Install docker-volume-netshare**:
   ```bash
   # Download and install the plugin
   wget https://github.com/ContainX/docker-volume-netshare/releases/download/v0.36/docker-volume-netshare_0.36_amd64.deb
   sudo dpkg -i docker-volume-netshare_0.36_amd64.deb
   
   # Start the CIFS service
   sudo docker-volume-netshare cifs
   ```

2. **Create volume**:
   ```bash
   docker volume create -d cifs \
     --name remote-project \
     --opt share=server/share \
     --opt username=your_username \
     --opt password=your_password
   ```

3. **Use in docker-compose.yml**:
   ```yaml
   volumes:
     - remote-project:/workspace
   ```

## Performance Considerations

### ⚠️ Important Performance Notes

1. **Network Latency**: File operations will be slower than local files
2. **Large Files**: Operations on large files may timeout
3. **Build Performance**: Compilation and package installation will be slower
4. **File Watching**: Some file watchers may not work properly with network shares

### Recommended Optimizations

1. **Cache Dependencies Locally**:
   ```yaml
   volumes:
     # Remote source code
     - /mnt/remote-share:/workspace
     # Local cache for dependencies
     - node-modules:/workspace/node_modules
     - pip-cache:/workspace/.venv
     - build-cache:/workspace/build
   ```

2. **Use .dockerignore**:
   ```
   # Exclude from build context
   node_modules/
   .venv/
   build/
   dist/
   *.log
   ```

3. **Adjust File Watcher Settings**:
   ```javascript
   // For Node.js projects
   // package.json
   {
     "scripts": {
       "dev": "nodemon --legacy-watch server.js"
     }
   }
   ```

   ```python
   # For Python projects
   # watchdog with polling
   observer = Observer(timeout=1.0, use_polling=True)
   ```

## Security Considerations

### 🔒 Security Best Practices

1. **Never commit credentials**:
   ```bash
   # Add to .gitignore
   /etc/samba/credentials
   .env
   *.credential
   ```

2. **Use environment variables**:
   ```bash
   # .env file
   SMB_USERNAME=your_username
   SMB_PASSWORD=your_password
   SMB_DOMAIN=your_domain
   SMB_SERVER=//192.168.1.100/share
   ```

3. **Restrict permissions**:
   ```bash
   # Credentials file
   sudo chmod 600 /etc/samba/credentials
   
   # Mount with specific user
   -o uid=1000,gid=1000,file_mode=0755,dir_mode=0755
   ```

4. **Use read-only where possible**:
   ```bash
   # Read-only mount
   sudo mount -t cifs //server/share /mnt/remote-share -o credentials=/etc/samba/credentials,ro
   ```

## Troubleshooting

### Common Issues

1. **"Host is down" error**:
   ```bash
   # Try different SMB versions
   -o vers=3.0  # or vers=2.1, vers=1.0
   ```

2. **Permission denied**:
   ```bash
   # Check credentials
   smbclient -L //server -U username
   
   # Verify mount options
   -o uid=$(id -u),gid=$(id -g)
   ```

3. **"Invalid argument" error**:
   ```bash
   # Install required packages
   sudo apt install cifs-utils keyutils
   
   # Check kernel support
   modprobe cifs
   ```

4. **Slow performance**:
   ```bash
   # Adjust cache options
   -o cache=loose,actimeo=60
   
   # Increase buffer size
   -o rsize=130048,wsize=130048
   ```

### Testing Connection

```bash
# Test SMB connection
smbclient -L //server -U username

# Test mount manually
sudo mkdir -p /tmp/test-mount
sudo mount -t cifs //server/share /tmp/test-mount -o username=user,password=pass
ls -la /tmp/test-mount
sudo umount /tmp/test-mount
```

## Example Setup Script

Create `scripts/setup-remote-share.sh`:

```bash
#!/bin/bash

# Remote Share Setup Helper
set -euo pipefail

echo "=== Remote Windows Share Setup ==="

# Get credentials
read -p "SMB Server (e.g., //192.168.1.100/share): " SMB_SERVER
read -p "Username: " SMB_USERNAME
read -sp "Password: " SMB_PASSWORD
echo
read -p "Domain (leave empty for WORKGROUP): " SMB_DOMAIN

# Create mount point
MOUNT_POINT="/mnt/$(basename $SMB_SERVER)"
sudo mkdir -p "$MOUNT_POINT"

# Create credentials file
CRED_FILE="/tmp/smb-creds-$$"
cat > "$CRED_FILE" << EOF
username=$SMB_USERNAME
password=$SMB_PASSWORD
domain=${SMB_DOMAIN:-WORKGROUP}
EOF

# Test mount
echo "Testing connection..."
if sudo mount -t cifs "$SMB_SERVER" "$MOUNT_POINT" -o credentials="$CRED_FILE",uid=$(id -u),gid=$(id -g); then
    echo "✓ Connection successful!"
    ls -la "$MOUNT_POINT" | head -5
    sudo umount "$MOUNT_POINT"
    
    # Save to .env
    echo "SMB_SERVER=$SMB_SERVER" >> .env
    echo "PROJECT_PATH=$MOUNT_POINT" >> .env
    echo "✓ Configuration saved to .env"
else
    echo "✗ Connection failed!"
fi

# Clean up
rm -f "$CRED_FILE"
```

## Best Practices Summary

1. **Mount in WSL2** rather than Docker for better performance
2. **Use credentials file** instead of plain text passwords
3. **Cache dependencies locally** to improve build times
4. **Test thoroughly** before relying on remote shares
5. **Have a local backup** for critical development
6. **Monitor performance** and adjust as needed

## Alternative: Sync Instead of Mount

For better performance, consider syncing instead:

```bash
# Use rsync to sync files
rsync -avz --delete user@server:/path/to/project /local/project

# Or use tools like:
# - Syncthing
# - Resilio Sync
# - Git (with remote repository)
```

This approach gives you local performance while keeping files synchronized.