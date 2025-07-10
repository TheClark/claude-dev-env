# Claude Development Environment - Universal Dev Tools
# Based on Microsoft's Dev Container for maximum compatibility
FROM mcr.microsoft.com/devcontainers/universal:2-linux

# This image includes:
# ✓ Languages: Python, Node.js, Java, .NET, Go, Ruby, PHP, Rust
# ✓ Tools: Git, GitHub CLI, Docker, kubectl, Terraform
# ✓ Package managers: pip, npm, yarn, maven, gradle
# ✓ Cloud CLIs: AWS, Azure, Google Cloud
# ✓ And much more!

USER root

# Add only what's missing from the Dev Container image
RUN apt-get update && apt-get install -y --no-install-recommends \
    subversion \
    redis-tools \
    ncdu \
    && rm -rf /var/lib/apt/lists/*

# Install Java 8 if specifically needed (Dev Container has 11 & 17)
RUN apt-get update && apt-get install -y openjdk-8-jdk && rm -rf /var/lib/apt/lists/*

# Create a startup script to fix permissions
RUN echo '#!/bin/bash\n\
# Fix workspace permissions if running as root\n\
if [ "$(id -u)" = "0" ] && [ -d "/workspace" ]; then\n\
    echo "Fixing workspace permissions..."\n\
    chown -R codespace:codespace /workspace 2>/dev/null || true\n\
    chmod -R 755 /workspace 2>/dev/null || true\n\
fi\n\
# Switch to codespace user and run the actual entrypoint\n\
exec su - codespace -c "cd /workspace && /bin/bash /home/codespace/scripts/entrypoint.sh $*"' > /usr/local/bin/docker-entrypoint.sh && \
    chmod +x /usr/local/bin/docker-entrypoint.sh

# Install Claude Code as codespace user
USER codespace
RUN npm install -g @anthropic-ai/claude-code

# Switch back to root for the entrypoint (will switch to codespace internally)
USER root
WORKDIR /workspace

# Use the wrapper script as entrypoint
ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
CMD []