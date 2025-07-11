# Fresh Claude Code Environment - Enhanced Setup
FROM mcr.microsoft.com/devcontainers/universal:2-linux

# Switch to codespace user
USER codespace

# Install Claude Code and set PATH during build
RUN npm install -g @anthropic-ai/claude-code && \
    echo "export PATH=\"$(npm config get prefix)/bin:\$PATH\"" >> ~/.bashrc

# Set the PATH as an environment variable so it persists
ENV PATH="$PATH:/usr/local/share/nvm/versions/node/v22.15.0/bin"

# Create enhanced setup script
RUN echo '#!/bin/bash\n\
echo "Setting up Claude Code environment..."\n\
\n\
# Set up API key if provided\n\
if [ -n "$ANTHROPIC_API_KEY" ]; then\n\
    mkdir -p ~/.config/claude\n\
    echo "api_key = \"$ANTHROPIC_API_KEY\"" > ~/.config/claude/config.toml\n\
    echo "✓ API key configured"\n\
fi\n\
\n\
# Set up Git configuration from environment variables\n\
if [ -n "$GIT_USER_NAME" ]; then\n\
    git config --global user.name "$GIT_USER_NAME"\n\
    echo "✓ Git user.name set to: $GIT_USER_NAME"\n\
fi\n\
\n\
if [ -n "$GIT_USER_EMAIL" ]; then\n\
    git config --global user.email "$GIT_USER_EMAIL"\n\
    echo "✓ Git user.email set to: $GIT_USER_EMAIL"\n\
fi\n\
\n\
# Set up GitHub CLI if token is provided\n\
if [ -n "$GITHUB_TOKEN" ]; then\n\
    echo "$GITHUB_TOKEN" | gh auth login --with-token 2>/dev/null && \\\n\
    echo "✓ GitHub CLI authenticated" || \\\n\
    echo "⚠ GitHub CLI authentication failed"\n\
fi\n\
\n\
echo "\n🚀 Claude Code environment ready!"\n\
echo "Available commands:"\n\
echo "  claude          - Start Claude Code"\n\
echo "  claude --help   - Show Claude Code help"\n\
echo "  gh              - GitHub CLI (if configured)"\n\
echo "\nTo start an interactive session: docker-compose exec claude-dev bash"\n\
\n\
# Auto-start Claude Code if AUTO_START_CLAUDE is set\n\
if [ "$AUTO_START_CLAUDE" = "true" ]; then\n\
    echo "🤖 Auto-starting Claude Code..."\n\
    claude &\n\
    CLAUDE_PID=$!\n\
    echo "Claude Code started with PID: $CLAUDE_PID"\n\
    \n\
    # Wait for Claude Code or container shutdown\n\
    wait $CLAUDE_PID\n\
else\n\
    # Keep container running for manual use\n\
    tail -f /dev/null\n\
fi' > /home/codespace/setup.sh && chmod +x /home/codespace/setup.sh

# Create a helper script for starting Claude interactively
RUN echo '#!/bin/bash\n\
echo "Starting Claude Code in interactive mode..."\n\
exec claude "$@"' > /home/codespace/start-claude.sh && chmod +x /home/codespace/start-claude.sh

# Set working directory
WORKDIR /workspace

# Run setup and keep container alive
CMD ["/home/codespace/setup.sh"]