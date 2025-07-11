# Claude Dev Environment - Project Context

## What This Is
A Docker-based development environment that allows Claude Code to work with large Windows codebases without limitations. All development tools are pre-installed and Claude Code starts automatically.

## Architecture Overview

### Core Components
```
claude-setup/
├── Dockerfile              # Based on Microsoft Dev Container image
├── docker-compose.yml      # Container orchestration  
├── scripts/
│   ├── entrypoint.sh      # Container startup (shows tools, starts Claude)
│   └── start-claude.ps1   # Windows startup script
├── init.ps1               # One-time setup wizard
└── .env                   # User configuration (paths, credentials)
```

### Key Design Decisions
1. **Microsoft Dev Container Base**: Uses `mcr.microsoft.com/devcontainers/universal:2-linux` for pre-installed tools
2. **Volume Mounting**: Scripts mounted as volumes for live updates without rebuilds
3. **Path Conversion**: Automatic Windows → Linux path conversion (C:\Project → /workspace)
4. **Credential Persistence**: API keys and tokens stored in .env file
5. **Multi-Project Support**: Each project gets unique PROJECT_NAME to avoid conflicts

### Available Tools
The container includes:
- **Languages**: Python, Node.js, Java (8,11,17), Go, Rust, Ruby, PHP, .NET
- **Package Managers**: pip, npm, yarn, maven, gradle, cargo, gem, composer
- **Cloud Tools**: AWS CLI, Azure CLI, Google Cloud SDK, Terraform, kubectl
- **Dev Tools**: Git, GitHub CLI, Docker-in-Docker, VS Code Server
- **Databases**: PostgreSQL, MySQL, MongoDB, Redis clients

### How It Works
1. User runs `start-claude.ps1` from Windows
2. Script checks/starts Docker container with project mounted at `/workspace`
3. Entrypoint script configures environment and shows available tools
4. Claude Code starts automatically with full access to project files
5. When user exits Claude, they return to PowerShell

### Environment Variables
Key variables passed to container:
- `PROJECT_NAME`: Unique container/volume names
- `PROJECT_PATH`: Windows path to mount at /workspace
- `ANTHROPIC_API_KEY`: For Claude Code authentication
- `GITHUB_TOKEN`: For GitHub operations
- Git user configuration

### Future Considerations
- Rename to "Unive" (Universal Development Environment)
- Publish base image to Docker Hub for faster setup
- Add more language support as needed