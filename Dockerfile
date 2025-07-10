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

# Switch to the default user (codespace)
USER codespace
WORKDIR /home/codespace

# Install Claude Code
RUN npm install -g @anthropic-ai/claude-code

# Just set workdir - the directory should exist from volume mount
WORKDIR /workspace

# Use bash to run the mounted script (avoids permission issues)
ENTRYPOINT ["/bin/bash", "/home/codespace/scripts/entrypoint.sh"]
CMD []