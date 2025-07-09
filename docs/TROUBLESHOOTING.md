# Troubleshooting Guide

This guide covers common issues and their solutions when using Claude Dev Environment.

## 🐛 Common Issues

### Docker Issues

#### Container won't start

**Symptoms:**
- Error: "Cannot connect to Docker daemon"
- Container exits immediately
- Port already in use errors

**Solutions:**

1. **Check Docker is running:**
   ```bash
   docker version
   # If error, start Docker Desktop
   ```

2. **Check for existing containers:**
   ```bash
   docker ps -a | grep claude
   # Remove old containers
   docker rm -f $(docker ps -a | grep claude | awk '{print $1}')
   ```

3. **Check disk space:**
   ```bash
   docker system df
   # Clean up if needed
   docker system prune -af
   ```

#### Build failures

**Symptoms:**
- Package installation fails
- Network timeout errors
- Out of space errors

**Solutions:**

1. **Clear Docker cache:**
   ```bash
   docker builder prune -af
   ```

2. **Build with no cache:**
   ```bash
   docker-compose build --no-cache claude-dev
   ```

3. **Check network:**
   ```bash
   # Test DNS
   docker run --rm alpine nslookup google.com
   ```

### Path Issues

#### "Project path does not exist"

**Symptoms:**
- Error about missing project path
- Cannot resolve relative path

**Solutions:**

1. **Check current directory:**
   ```bash
   pwd  # Should be in claude-setup directory
   ```

2. **Verify path exists:**
   ```bash
   # For relative path
   ls -la ../
   
   # Test path resolution
   cd .. && pwd && cd -
   ```

3. **Use absolute path temporarily:**
   ```bash
   # Find absolute path
   realpath ../
   # Update .env with absolute path
   ```

#### Windows path problems

**Symptoms:**
- Path with backslashes not working
- Drive letter issues
- WSL path conversion errors

**Solutions:**

1. **Use forward slashes:**
   ```bash
   # Good
   PROJECT_PATH=C:/Users/name/project
   
   # Bad
   PROJECT_PATH=C:\Users\name\project
   ```

2. **Check WSL conversion:**
   ```bash
   # In WSL, convert Windows path
   wslpath "C:\Users\name\project"
   ```

3. **Use WSL paths:**
   ```bash
   PROJECT_PATH=/mnt/c/Users/name/project
   ```

### Permission Issues

#### SSH key permissions

**Symptoms:**
- "Permissions are too open" error
- Cannot read SSH key
- Git authentication fails

**Solutions:**

```bash
# Fix permissions
chmod 700 ~/.ssh
chmod 600 ~/.ssh/id_*
chmod 644 ~/.ssh/*.pub

# Test SSH
ssh -T git@github.com
```

#### Docker socket permissions

**Symptoms:**
- Cannot connect to Docker daemon inside container
- Permission denied on /var/run/docker.sock

**Solutions:**

```bash
# On Linux, add user to docker group
sudo usermod -aG docker $USER
# Log out and back in

# Or temporarily
sudo chmod 666 /var/run/docker.sock
```

### Environment Variable Issues

#### Variables not set in container

**Symptoms:**
- Git user not configured
- Cloud tools not authenticated
- Missing expected environment

**Solutions:**

1. **Check .env file:**
   ```bash
   # Verify .env exists
   ls -la .env
   
   # Check contents
   cat .env | grep -v PASSWORD
   ```

2. **Verify variable export:**
   ```bash
   # Inside container
   env | grep PROJECT
   env | grep GIT
   ```

3. **Debug docker-compose:**
   ```bash
   # See resolved configuration
   docker-compose config
   ```

### Performance Issues

#### Slow file operations

**Symptoms:**
- npm install takes forever
- Build processes are slow
- File watching doesn't work

**Solutions:**

1. **Use local volumes for dependencies:**
   ```yaml
   # In docker-compose.yml
   volumes:
     - node-modules:/workspace/node_modules
   ```

2. **Adjust file watcher:**
   ```javascript
   // For Node.js
   // Use polling in nodemon.json
   {
     "legacyWatch": true,
     "pollingInterval": 1000
   }
   ```

3. **Cache package managers:**
   ```bash
   # Already included in setup
   # Just ensure volumes are used
   ```

### Network Issues

#### Cannot reach external services

**Symptoms:**
- npm install fails
- Git clone fails
- API calls timeout

**Solutions:**

1. **Check DNS:**
   ```bash
   # Inside container
   nslookup google.com
   cat /etc/resolv.conf
   ```

2. **Use host network:**
   ```bash
   # Temporarily for debugging
   docker run --network host ...
   ```

3. **Proxy settings:**
   ```bash
   # If behind corporate proxy
   export HTTP_PROXY=http://proxy:port
   export HTTPS_PROXY=http://proxy:port
   ```

## 🔧 Platform-Specific Issues

### Windows/WSL2

#### WSL2 not working

**Solutions:**

1. **Enable WSL2:**
   ```powershell
   # As Administrator
   wsl --install
   wsl --set-default-version 2
   ```

2. **Update WSL2:**
   ```powershell
   wsl --update
   ```

3. **Check WSL2 backend in Docker:**
   - Docker Desktop → Settings → General → Use WSL2 based engine

### macOS

#### Docker Desktop slow

**Solutions:**

1. **Allocate more resources:**
   - Docker Desktop → Settings → Resources
   - Increase CPU and Memory

2. **Use native volumes:**
   - Avoid mounting large directories
   - Use .dockerignore

### Linux

#### SELinux issues

**Solutions:**

```bash
# Add :Z to volume mounts
volumes:
  - ./project:/workspace:Z
```

## 🔍 Debugging Commands

### Container debugging

```bash
# View logs
docker logs -f claude-dev

# Execute commands in running container
docker exec -it claude-dev bash

# Inspect container
docker inspect claude-dev

# Check resource usage
docker stats claude-dev
```

### Script debugging

```bash
# Run with debug output
bash -x ./scripts/start-claude.sh

# Check script syntax
bash -n ./scripts/start-claude.sh
```

## 🆘 Getting More Help

1. **Check existing issues:**
   - Search [GitHub Issues](https://github.com/TheClark/claude-dev-env/issues)

2. **Enable verbose logging:**
   ```bash
   # Add to docker-compose.yml
   environment:
     - DEBUG=true
   ```

3. **Collect diagnostic info:**
   ```bash
   # System info
   docker version
   docker-compose version
   uname -a
   
   # Container info
   docker inspect claude-dev > diagnostic.json
   ```

4. **Ask for help:**
   - Include error messages
   - Share diagnostic info
   - Describe what you tried

## 🚨 Emergency Fixes

### Reset everything

```bash
# Stop all containers
docker stop $(docker ps -q)

# Remove all Claude containers
docker rm -f $(docker ps -a | grep claude | awk '{print $1}')

# Remove all Claude images
docker rmi $(docker images | grep claude | awk '{print $3}')

# Remove all volumes
docker volume rm $(docker volume ls | grep claude | awk '{print $2}')

# Start fresh
./scripts/start-claude.sh --rebuild
```

### Quick workarounds

```bash
# Can't build? Use base Claude image
docker run -it -v $(pwd):/workspace \
  ghcr.io/anthropics/claude-code:latest

# Script not working? Run manually
docker-compose up claude-dev

# Path issues? Use absolute path
PROJECT_PATH=$(realpath ..) ./scripts/start-claude.sh
```

Remember: Most issues are related to Docker configuration or path resolution. When in doubt, start with a clean slate!